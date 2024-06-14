#!/bin/bash

verbose() {
    echo "$@" >&2
}

selected_dir=$(zenity --file-selection --directory --title="Select a directory to scan for duplicates")
if [ -z "$selected_dir" ]; then
    zenity --info --text="No directory selected. Exiting."
    exit 1
fi

if [ ! -d "$selected_dir" ]; then
    zenity --error --text="The selected directory does not exist."
    exit 1
fi

sanitize_directories() {
    find "$1" -depth -type d -name "*[\"'*?<>| ]*" | parallel -0 -j+0 'sanitized_dir=$(echo "{}" | sed "s/[\"'\''*?<>| ]/_/g"); if [ "{}" != "$sanitized_dir" ]; then verbose "Renaming directory '{}' to '$sanitized_dir'"; mv "{}" "$sanitized_dir"; fi'
}

sanitize_filenames() {
    find "$1" -depth -type f -name "*[\"'*?<>|]*" | parallel -0 -j+0 'sanitized_file=$(echo "{}" | sed "s/[\"'\''*?<>|]/_/g"); if [ "{}" != "$sanitized_file" ]; then verbose "Renaming file '{}' to '$sanitized_file'"; mv "{}" "$sanitized_file"; fi'
}

remove_empty_directories() {
    find "$1" -type d -empty | parallel -0 -j+0 'zenity --question --text="Do you want to remove the empty directory {}?"; if [ $? -eq 0 ]; then rmdir "{}"; if [ $? -eq 0 ]; then verbose "Removed empty directory: {}"; else verbose "Failed to remove empty directory: {}"; fi; fi'
}

# Function to delete duplicate files with shortest path and longer name
delete_duplicate_files() {
    # Create an associative array to store filenames based on MD5sum
    declare -A file_md5sums

    # Variable to store total size freed up
    total_size=0

    # Find all files and store their MD5sums
    while IFS= read -r -d '' file; do
        md5sum=$(md5sum "$file" | awk '{print $1}')
        if [ -n "${file_md5sums[$md5sum]}" ]; then
            # Compare file paths and names
            if [ ${#file} -lt ${#file_md5sums[$md5sum]} ]; then
                # If current file has a shorter path, check if it's in a subdirectory
                if [[ "$file" != */* ]]; then
                    # If current file is not in a subdirectory, delete the longer path
                    verbose "Deleting file: ${file_md5sums[$md5sum]}"
                    size=$(du -b "${file_md5sums[$md5sum]}" | cut -f1)
                    total_size=$((total_size + size))
                    rm "${file_md5sums[$md5sum]}"
                    file_md5sums[$md5sum]="$file"
                else
                    # If current file is in a subdirectory, check if the other file is not in a subdirectory
                    if [[ "${file_md5sums[$md5sum]}" == */* ]]; then
                        # If the other file is also in a subdirectory, delete the current file
                        verbose "Deleting file: $file"
                        size=$(du -b "$file" | cut -f1)
                        total_size=$((total_size + size))
                        rm "$file"
                    else
                        # If the other file is not in a subdirectory, delete the longer path
                        verbose "Deleting file: ${file_md5sums[$md5sum]}"
                        size=$(du -b "${file_md5sums[$md5sum]}" | cut -f1)
                        total_size=$((total_size + size))
                        rm "${file_md5sums[$md5sum]}"
                        file_md5sums[$md5sum]="$file"
                    fi
                fi
            elif [ ${#file} -gt ${#file_md5sums[$md5sum]} ]; then
                # If current file has a longer path, delete the current file
                verbose "Deleting file: $file"
                size=$(du -b "$file" | cut -f1)
                total_size=$((total_size + size))
                rm "$file"
            fi
        else
            # Store the file path for each MD5sum
            file_md5sums[$md5sum]="$file"
        fi
    done < <(find "$1" -type f -print0)

    # Convert total size to MB
    total_size_mb=$((total_size / 1024 / 1024))
    # Display the amount of storage freed up in a Zenity dialog
    zenity --info --text="Freed up storage: $total_size_mb MB"
}

zenity --question --text="This script will scan the directory '$selected_dir' for filenames and directory names with special characters and rename them. Do you want to proceed?"
if [ $? -eq 0 ]; then
    sanitize_directories "$selected_dir"
    sanitize_filenames "$selected_dir"
    verbose "Names sanitized."
else
    zenity --info --text="Operation cancelled."
    exit 1
fi

delete_duplicate_files "$selected_dir"

zenity --question --text="Do you want to scan and remove empty directories?"
if [ $? -eq 0 ]; then
    remove_empty_directories "$selected_dir"
    verbose "Empty directories removed."
else
    zenity --info --text="Empty directory removal skipped."
fi
