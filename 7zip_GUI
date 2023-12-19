#!/bin/bash

function display_error() {
  yad --error --text="$1"
  exit 1
}

# Set the working directory to the user's home
cd "$HOME" || display_error "Could not change directory to home"

action=$(yad --list --title="7zip GUI" --column="Action" "Compress" "Extract")

if [ "$action" == "Compress" ]; then
  archive_operation=$(yad --list --title="Archive Operation" --column="Operation" "Create New Archive" "Add to Existing Archive")

  if [ "$archive_operation" == "Create New Archive" ]; then
    archive_name=$(yad --entry --title="Archive Name")
    compression_method=$(yad --list --title="Compression Method" --column="Method" "7z" "zip" "tar" "tar.gz" "tar.bz2")
    compression_level=$(yad --scale --title="Compression Level" --min-value=1 --max-value=9 --value=5 --step=1)
    file_names=$(yad --file-selection --multiple --title="Select Files")

    # Compress the files
    7z a -t${compression_method} -mx${compression_level} "${archive_name}" ${file_names//|/ } || display_error "Compression failed"

  elif [ "$archive_operation" == "Add to Existing Archive" ]; then
    archive_name=$(yad --file-selection --title="Select Existing Archive")
    add_file_names=$(yad --file-selection --multiple --title="Select Files to Add")

    # Add files to the existing archive
    7z u "${archive_name}" ${add_file_names//|/ } || display_error "Adding files failed"
  else
    display_error "Invalid Archive Operation"
  fi

elif [ "$action" == "Extract" ]; then
  archive_name=$(yad --file-selection --title="Select Archive to Extract")
  output_directory=$(yad --file-selection --directory --title="Select Output Directory")

  # Extract the files
  7z x "${archive_name}" -o"${output_directory}" || display_error "Extraction failed"

else
  display_error "Invalid Action"
fi

yad --info --text="Operation completed successfully"
