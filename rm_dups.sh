#!/bin/bash

# Function to print verbose message
verbose() {
    echo "$@" >&2
}

# Ask the user to select a directory using Zenity
selected_dir=$(zenity --file-selection --directory --title="Select a directory to scan for duplicates")
if [ -z "$selected_dir" ]; then
    zenity --info --text="No directory selected. Exiting."
    exit 1
fi

# Check if the specified directory exists
if [ ! -d "$selected_dir" ]; then
    zenity --error --text="The selected directory does not exist."
    exit 1
fi

# Function to sanitize directory names recursively
sanitize_directories() {
    find "$1" -depth -type d -name "*[\"'*?<>| ]*" | while IFS= read -r dir; do
        sanitized_dir=$(echo "$dir" | sed 's/[\"'\''*?<>| ]/_/g')
        if [ "$dir" != "$sanitized_dir" ]; then
            verbose "Renaming directory '$dir' to '$sanitized_dir'"
            mv "$dir" "$sanitized_dir"
        fi
    done
}

# Function to sanitize filenames
sanitize_filenames() {
    find "$1" -depth -type f -name "*[\"'*?<>|]*" | while IFS= read -r file; do
        sanitized_file=$(echo "$file" | sed 's/[\"'\''*?<>|]/_/g')
        if [ "$file" != "$sanitized_file" ]; then
            verbose "Renaming file '$file' to '$sanitized_file'"
            mv "$file" "$sanitized_file"
        fi
    done
}

# Ask for confirmation before renaming files and directories
zenity --question --text="This script will scan the directory '$selected_dir' for filenames and directory names with special characters and rename them. Do you want to proceed?"
if [ $? -eq 0 ]; then
    sanitize_directories "$selected_dir"
    sanitize_filenames "$selected_dir"
    verbose "Names sanitized."
else
    zenity --info --text="Operation cancelled."
    exit 1
fi

# Ask if user wants to rename all files with spaces or parentheses at once
rename_all=$(zenity --question --title="Rename Files" --text="Do you want to rename all files with spaces or parentheses at once without confirmation for each file?" --ok-label="Yes" --cancel-label="No" && echo "yes" || echo "no")

# Scan directory and rename files with parentheses or spaces
if [ "$rename_all" == "yes" ]; then
    find "$selected_dir" -type f | while IFS= read -r file; do
        base=$(basename "$file")
        dir=$(dirname "$file")
        newbase=$(echo "$base" | sed 's/ /_/g; s/[()]//g')
        if [ "$base" != "$newbase" ]; then
            verbose "Renaming '$base' to '$newbase'"
            mv -v "$dir/$base" "$dir/$newbase"
        fi
    done
else
    find "$selected_dir" -type f | while IFS= read -r file; do
        base=$(basename "$file")
        dir=$(dirname "$file")
        newbase=$(echo "$base" | sed 's/ /_/g; s/[()]//g')
        if [ "$base" != "$newbase" ]; then
            zenity --question --text="Do you want to rename '$base' to '$newbase'?"
            if [ $? -eq 0 ]; then
                mv -v "$dir/$base" "$dir/$newbase"
            fi
        fi
    done
fi

# Create an associative array to track file content and paths
declare -A file_content
declare -A duplicate_files

# Find duplicate files based on content
while IFS= read -r -d '' file; do
    md5sum=$(md5sum "$file" | awk '{print $1}')
    if [ -n "${file_content[$md5sum]}" ]; then
        if [ -z "${duplicate_files[$md5sum]}" ]; then
            duplicate_files[$md5sum]="${file_content[$md5sum]}"
        fi
        duplicate_files[$md5sum]+=$'\n'"$file"
    else
        file_content[$md5sum]=$file
    fi
done < <(find "$selected_dir" -type f -print0)

# Display dialog with duplicate files before removal
deleted_files=""
total_size=0
for md5sum in "${!duplicate_files[@]}"; do
    # Prepare the dialog text
    dialog_text=""
    IFS=$'\n' read -r -d '' -a file_list < <(echo -e "${duplicate_files[$md5sum]}")
    for file in "${file_list[@]}"; do
        dialog_text+="FALSE \"$file\" "
    done
    # Display the Zenity checklist dialog
    choices=$(zenity --list --checklist --title="Select file(s) to delete (MD5sum: $md5sum)" --text="Select files to delete:" --column="Delete" --column="File" --separator=$'\n' $dialog_text)
    if [ -n "$choices" ]; then
        # Delete selected files
        for choice in $choices; do
            choice=$(echo "$choice" | sed 's/^"\(.*\)"$/\1/') # Remove double quotes
            deleted_files+=$'\n'"$choice"
            size=$(du -b "$choice" | cut -f1)
            total_size=$((total_size + size))
            rm "$choice"
            if [ $? -eq 0 ]; then
                verbose "Deleted file: $choice"
            else
                verbose "Failed to delete file: $choice"
            fi
        done
    fi
done

# Display information about removed files and freed up space
if [ -n "$deleted_files" ]; then
    freed_up_space=$((total_size / 1024 / 1024)) # Convert total_size to MB
    zenity --info --text="Duplicate files have been removed:\n$deleted_files\n\nFreed up storage: $freed_up_space MB"
else
    zenity --info --text="No duplicate files found."
fi

verbose "Script execution completed."
exit 0
