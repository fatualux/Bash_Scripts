#!/bin/bash

function display_error() {
  zenity --error --text="$1"
  exit 1
}

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
echo "Debug: \$action is '$action'"

case "$action" in
  "Compress")
    archive_operation=$(zenity --list --title="Archive Operation" --column="Operation" "Create New Archive" "Add to Existing Archive")
    echo "Debug: \$archive_operation is '$archive_operation'"

    case "$archive_operation" in
      "Create New Archive")
        archive_name=$(zenity --entry --title="Archive Name")
        compression_method=$(zenity --list --title="Compression Method" --column="Method" "7z" "zip" "tar" "tar.gz" "tar.bz2")
        compression_level=$(zenity --scale --title="Compression Level" --min-value=1 --max-value=9 --value=5 --step=1)
        file_names=$(zenity --file-selection --multiple --title="Select Files")

        # Compress the files
        7z a -t${compression_method} -mx${compression_level} "${archive_name}" ${file_names//|/ } || display_error "Compression failed"
        ;;
      "Add to Existing Archive")
        archive_name=$(zenity --file-selection --title="Select Existing Archive")
        add_file_names=$(zenity --file-selection --multiple --title="Select Files to Add")

        # Add files to the existing archive
        7z u "${archive_name}" ${add_file_names//|/ } || display_error "Adding files failed"
        ;;
      *)
        display_error "Invalid Archive Operation"
        ;;
    esac
    ;;
  "Extract")
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
