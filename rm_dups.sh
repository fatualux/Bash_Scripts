#!/bin/bash

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
removed_files=""
total_size=0

# Find duplicate files based on content
file_count=$(find "$selected_dir" -type f | wc -l)
current_file=0

# Display dialog with duplicate files before removal
duplicate_files=$(find "$selected_dir" -type f -exec md5sum {} \; | \
                    awk '{print $1}' | sort | uniq -d | \
                    while read md5sum; do
                        find "$selected_dir" -type f -exec md5sum {} \; | \
                        awk -v sum="$md5sum" '$1 == sum {print $2}' | \
                        tr '\n' ' '
                    done)

if [ -n "$duplicate_files" ]; then
    size_duplicate_files=$(du -ch $duplicate_files 2>/dev/null | tail -1 | cut -f1)
    zenity --question --text="Duplicate files found:\n$duplicate_files\nTotal size: $size_duplicate_files\nDo you want to remove them?"
    response=$?
else
    zenity --info --text="No duplicate files found."
    exit 0
fi

if [ $response -eq 0 ]; then
    # Initialize the progress bar
    (
        find "$selected_dir" -type f -exec md5sum {} \; | while read md5sum path; do
            current_file=$((current_file + 1))
            progress=$((current_file * 100 / file_count))
            echo "$progress"
            if [ -n "${file_content[$md5sum]}" ]; then
                removed_files+="\n$path"
                total_size=$((total_size + $(du -b "$path" | cut -f1)))
                rm "$path"
                echo "Removing: $path"
            else
                file_content["$md5sum"]=$path
                echo "Storing: $path with MD5sum: $md5sum"
            fi
        done
    ) | zenity --progress --title="Removing Duplicate Files" --text="Scanning for duplicates..." --percentage=0 --auto-close

    # Display information about removed files and freed up storage
    if [ -n "$removed_files" ]; then
        freed_up_space=$((total_size / 1024 / 1024)) # Convert total_size to MB
        zenity --info --text="Duplicate files have been removed:\n$removed_files\n\nFreed up storage: $freed_up_space MB"
    else
        zenity --info --text="No duplicate files found."
    fi
else
    zenity --info --text="Operation canceled by user."
fi

exit 0
