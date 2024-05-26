#!/bin/bash

# Check for dependencies
if ! command -v zenity &> /dev/null; then
    echo "Error: Zenity is not installed. Please install Zenity to proceed."
    exit 1
fi

# Function to choose directory using Zenity
choose_directory() {
    local directory=$(zenity --file-selection --directory --title="$1")
    echo "$directory"
}

# Function to compare directories and backup missing files
compare_and_backup() {
    local source_dir="$1"
    local backup_dir="$2"

    # Loop through files in source directory
    while IFS= read -r -d '' file; do
        relative_path="${file#$source_dir}"
        backup_path="$backup_dir$relative_path"

        # Check if file doesn't exist in backup directory
        if [ ! -e "$backup_path" ]; then
            # Create directory if it doesn't exist
            mkdir -p "$(dirname "$backup_path")"

            # Copy the file to backup directory
            cp "$file" "$backup_path"

            # Display confirmation dialog
            zenity --question --text="Do you want to save $relative_path to backup directory?"
            response=$?
            if [ $response -ne 0 ]; then
                # If user cancels, remove the copied file
                rm "$backup_path"
            fi
        fi
    done < <(find "$source_dir" -type f -print0)
}

# Main script

# Choose source directory
source_directory=$(choose_directory "Select directory to backup")
if [ -z "$source_directory" ]; then
    echo "Error: No directory selected."
    exit 1
fi

# Choose backup directory
backup_directory=$(choose_directory "Select backup directory")
if [ -z "$backup_directory" ]; then
    echo "Error: No backup directory selected."
    exit 1
fi

# Compare and backup missing files
compare_and_backup "$source_directory" "$backup_directory"

echo "Backup completed."
