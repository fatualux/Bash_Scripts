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

# Find duplicate files based on content
file_count=$(find "$selected_dir" -type f | wc -l)
current_file=0

# Initialize the progress bar
(
    find "$selected_dir" -type f -exec md5sum {} \; | while read md5sum path; do
        current_file=$((current_file + 1))
        progress=$((current_file * 100 / file_count))
        echo "$progress"
        if [ -n "${file_content[$md5sum]}" ]; then
            zenity --info --text="Removing duplicate file: $path"
            rm "$path"
        else
            file_content["$md5sum"]=$path
        fi
    done
) | zenity --progress --title="Removing Duplicate Files" --text="Scanning for duplicates..." --percentage=0 --auto-close

zenity --info --text="Duplicate files have been removed."

exit 0
