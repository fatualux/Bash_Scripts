#!/bin/bash

select_item_type() {
  user_input=$(zenity --list --radiolist --title="Select Item Type" --text="Select the type of items to rename:" --column="Select" --column="Item Type" TRUE "Files" FALSE "Directories")

  case $user_input in
    "Files") item_type="file";;
    "Directories") item_type="directory";;
    *) echo "Invalid selection. Exiting." && exit 1;;
  esac
}

rename_files() {
  selected_files=$(zenity --file-selection --multiple --separator=" " --title "Select Files to Rename")

  if [ -z "$selected_files" ]; then
    zenity --error --text "No files selected. Exiting."
    exit 1
  fi

  user_input=$(zenity --forms --title="Rename Files" --text="Enter rename options:" \
    --add-entry="Prefix" \
    --add-entry="Suffix" \
    --add-entry="Incremental Order (e.g., %03d)" \
    --add-entry="Counter Start Value (e.g., 1)")

  IFS='|' read -r prefix suffix incremental_format start_counter <<< "$user_input"

  counter=$start_counter
  for file in $selected_files; do
    file_extension="${file##*.}"

    new_filename="${prefix}$(printf "$incremental_format" $counter)${suffix}.$file_extension"

    if [ "$file" != "$new_filename" ]; then
      mv "$file" "$(dirname "$file")/$new_filename"
    fi

    ((counter++))
  done

  zenity --info --text "Files have been renamed successfully."
}

rename_directories() {
  selected_directories=$(zenity --file-selection --multiple --directory --separator="|" --title "Select Directories to Rename")

  if [ -z "$selected_directories" ]; then
    zenity --error --text "No directories selected. Exiting."
    exit 1
  fi

  user_input=$(zenity --forms --title="Rename Directories" --text="Enter rename options:" \
    --add-entry="Prefix" \
    --add-entry="Suffix" \
    --add-entry="Incremental Order (e.g., %03d)" \
    --add-entry="Counter Start Value (e.g., 1)")

  IFS='|' read -r prefix suffix incremental_format start_counter <<< "$user_input"

  counter=$start_counter
  IFS='|' read -ra directories <<< "$selected_directories"
  for directory in "${directories[@]}"; do
    if [ ! -d "$directory" ]; then
      echo "Skipping non-directory item: $directory"
      continue
    fi

    new_directory_name="${prefix}$(printf "$incremental_format" $counter)${suffix}"

    if [ "$directory" != "$(dirname "$directory")/$new_directory_name" ]; then
      mv "$directory" "$(dirname "$directory")/$new_directory_name"
      echo "Renamed Successfully: $directory to $new_directory_name"
    else
      echo "No renaming needed: $directory"
    fi

    ((counter++))
  done

  zenity --info --text "Directories have been renamed successfully."
}

select_item_type

if [ "$item_type" == "file" ]; then
  rename_files
elif [ "$item_type" == "directory" ]; then
  rename_directories
else
  echo "Unknown item type. Exiting."
  exit 1
fi
