#!/bin/bash

# Ask the user for the destination folder using Zenity
DESTINATION_FOLDER=$(zenity --file-selection --directory --title="Select Destination Folder")

# Check if the user canceled folder selection
if [[ -z $DESTINATION_FOLDER ]]; then
    zenity --error --text="Destination folder not selected. Exiting."
    exit 1
fi

# Define the list of files and folders to backup (excluding .virtualenv)
CONFIG_FILES=(
    ".bashrc"
    ".vimrc"
    ".xinitrc"
    ".Xdefaults"
)

CONFIG_DIRS=(
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
    tar -czvf "$TAR_CONF" -C "$HOME" "${TODO[@]}"
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
    tar -czvf "$VENV_DIR" -C "$HOME" ".virtualenv"
    echo "100"
  ) | zenity --progress --title="Creating .virtualenv Archive" --text="Please wait..." --percentage=0 --auto-close --auto-kill
)

zenity --info --text=".virtualenv archive created in $VENV_DIR"

# List packages from the official repo
REPO_PKG_LIST="$ARCH_BACKUP_DIR/repo-pkglist.txt"

(
  # Start a subshell for progress bar
  (
    echo "10"
    sleep 1
    echo "30"
    pacman -Qqen > "$REPO_PKG_LIST"
    echo "100"
  ) | zenity --progress --title="Creating Repo Package List" --text="Please wait..." --percentage=0 --auto-close --auto-kill
)

zenity --info --text="Repo package list created in $REPO_PKG_LIST"

# List foreign packages (custom e.g. AUR)
AUR_PKG_LIST="$ARCH_BACKUP_DIR/cust-pkglist.txt"

(
  # Start a subshell for progress bar
  (
    echo "10"
    sleep 1
    echo "30"
    pacman -Qqem > "$AUR_PKG_LIST"
    echo "100"
  ) | zenity --progress --title="Creating AUR Package List" --text="Please wait..." --percentage=0 --auto-close --auto-kill
)

zenity --info --text="AUR package list created in $AUR_PKG_LIST"

zenity --info --text="Backup and package list creation completed."
