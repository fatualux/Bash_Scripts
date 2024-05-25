#!/bin/bash

# Function to prompt user with yes/no dialog
function confirm_backup {
    zenity --question --text="$1 $2?"
}

# Ask the user for the destination folder using Zenity
DESTINATION_FOLDER=$(zenity --file-selection --directory --title="Select Destination Folder")

# Check if the user canceled folder selection
if [[ -z $DESTINATION_FOLDER ]]; then
    zenity --error --text="Destination folder not selected. Exiting."
    exit 1
fi

CONFIG_FILES=(
    ".bashrc"
    ".vimrc"
    ".xinitrc"
    ".Xdefaults"
)

CONFIG_DIRS=(
    ".bash"
    ".config"
    ".fontconfig"
    ".local/share"
    ".scripts"
    ".themes"
    ".fonts"
    ".w3m"
    ".ssh"
    ".vim"
)

# Create an ARCH_BACKUP directory in the chosen destination folder
ARCH_BACKUP_DIR="$DESTINATION_FOLDER/ARCH_BACKUP"
if [[ ! -d "$ARCH_BACKUP_DIR" ]]; then
    mkdir -p "$ARCH_BACKUP_DIR"
fi

# Create a tar archive of the files and directories (excluding .virtualenv)
TAR_CONF="$ARCH_BACKUP_DIR/dotconf.tar.gz"
TODO=("${CONFIG_FILES[@]}" "${CONFIG_DIRS[@]}")

(
  # Start a subshell for progress bar
  (
    echo "10"
    sleep 1
    echo "30"
    for item in "${CONFIG_FILES[@]}" "${CONFIG_DIRS[@]}"; do
        confirm_backup "Backup" "$item"
        if [[ $? -eq 0 ]]; then
            tar -czvf "$TAR_CONF" -C "$HOME" "$item"
        fi
    done
    echo "100"
  ) | zenity --progress --title="Creating Config Archive" --text="Please wait..." --percentage=0 --auto-close --auto-kill
)

zenity --info --text="Config archive created in $TAR_CONF"

# Create a separate tarball for the .virtualenv directory in the ARCH_BACKUP directory
VENV_DIR="$ARCH_BACKUP_DIR/virtualenv.tar.gz"

(
  # Start a subshell for progress bar
  (
    echo "10"
    sleep 1
    echo "30"
    confirm_backup "Backup" ".virtualenv"
    if [[ $? -eq 0 ]]; then
        tar -czvf "$VENV_DIR" -C "$HOME" ".virtualenv"
    fi
    echo "100"
  ) | zenity --progress --title="Creating .virtualenv Archive" --text="Please wait..." --percentage=0 --auto-close --auto-kill
)

zenity --info --text=".virtualenv archive created in $VENV_DIR"

# Function to create package list
function create_pkg_list {
    pkg_list_type=$1
    pkg_list_file=$2
    confirm_backup "Create $pkg_list_type" "Package List"
    if [[ $? -eq 0 ]]; then
        (
            echo "10"
            sleep 1
            echo "30"
            if [[ $pkg_list_type == "Repo" ]]; then
                pacman -Qqen > "$pkg_list_file"
            else
                pacman -Qqem > "$pkg_list_file"
            fi
            echo "100"
        ) | zenity --progress --title="Creating $pkg_list_type Package List" --text="Please wait..." --percentage=0 --auto-close --auto-kill
        zenity --info --text="$pkg_list_type package list created in $pkg_list_file"
    else
        zenity --info --text="$pkg_list_type package list creation skipped."
    fi
}

# List packages from the official repo
REPO_PKG_LIST="$ARCH_BACKUP_DIR/repo-pkglist.txt"
create_pkg_list "Repo" "$REPO_PKG_LIST"

# List foreign packages (custom e.g. AUR)
AUR_PKG_LIST="$ARCH_BACKUP_DIR/cust-pkglist.txt"
create_pkg_list "AUR" "$AUR_PKG_LIST"

zenity --info --text="Backup and package list creation completed."
zenity --info --text="To restore packages, simply run \"pacman -S --needed - < $REPO_PKG_LIST\" or \"pacman -S --needed - < $AUR_PKG_LIST\"."
