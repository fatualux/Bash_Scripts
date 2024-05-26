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
        duplicate_files[$md5sum]+="\n$file"
    else
        file_content[$md5sum]=$file
    fi
done < <(find "$selected_dir" -type f -print0)

# Display dialog with duplicate files before removal
dialog_text="Duplicate files found:\n"
total_size=0
for md5sum in "${!duplicate_files[@]}"; do
    dialog_text+="MD5sum: $md5sum\n${duplicate_files[$md5sum]}\n\n"
done

# Prompt the user to select which file(s) to delete for each set of duplicates
deleted_files=""
for md5sum in "${!duplicate_files[@]}"; do
    # Prepare the dialog text
    dialog_text=""
    # Convert dialog text to array for use in Zenity checklist
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
            deleted_files+="\n$choice"
            size=$(du -b "$choice" | cut -f1)
            total_size=$((total_size + size))
            rm "$choice"
            # Debug output: display file deletion status
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

exit 0
