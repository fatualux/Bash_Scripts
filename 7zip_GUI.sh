#!/bin/bash

# Function to display error messages and exit
function display_error() {
  zenity --error --text="$1"
  exit 1
}

# Function to check if required dependencies are installed
function check_dependencies() {
  local dependencies=("zenity" "7z")

  for dep in "${dependencies[@]}"; do
    command -v "$dep" &> /dev/null || display_error "Error: $dep is not installed. Please install it before running this script."
  done
}

# Check dependencies before proceeding
check_dependencies

# Set the working directory to the user's home
cd "$HOME" || display_error "Could not change directory to home"

# Get the action with trailing '|', and remove it
action=$(zenity --list --title="7zip GUI" --column="Action" "Compress" "Extract" | sed 's/|$//')

case "$action" in
  "Compress")
    # Get the compression method and level
    compression_method=$(zenity --list --title="Compression Method" --column="Method" "7z" "zip" "tar" "tar.gz" "tar.bz2")
    compression_level=$(zenity --scale --title="Compression Level" --min-value=1 --max-value=9 --value=5 --step=1)
    # Prompt user to select files to compress
    file_names=$(zenity --file-selection --multiple --title="Select Files")

    # Prompt user for archive name
    archive_name=$(zenity --entry --title="Archive Name")

    # Compress the files
    7z a -t${compression_method} -mx${compression_level} "${archive_name}" ${file_names//|/ } || display_error "Compression failed"
    ;;
  "Extract")
    # Prompt user to select archive and output directory
    archive_name=$(zenity --file-selection --multiple --title="Select Archive to Extract")
    output_directory=$(zenity --file-selection --directory --title="Select Output Directory")

    # Extract the files
    7z x "${archive_name}" -o"${output_directory}" || display_error "Extraction failed"
    ;;
  *)
    display_error "Invalid Action"
    ;;
esac

zenity --info --text="Operation completed successfully"
