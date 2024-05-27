#!/bin/bash

# Function to prompt user with yes/no dialog
function confirm_backup {
    zenity --question --text="$1 $2?"
    return $?
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
mkdir -p "$ARCH_BACKUP_DIR"

# Confirm before creating a tar archive of the files and directories
confirm_backup "Create backup" "of config files and directories"
if [[ $? -eq 0 ]]; then
    TAR_CONF="$ARCH_BACKUP_DIR/dotconf.tar.gz"

    (
        # Start a subshell for progress bar
        (
            echo "10"
            sleep 1
            echo "30"
            tar -czvf "$TAR_CONF" -C "$HOME" "${CONFIG_FILES[@]}"
            echo "100"
        ) | zenity --progress --title="Creating Config Archive" --text="Please wait..." --percentage=0 --auto-close --auto-kill
    )

    echo "Config archive created in $TAR_CONF"

    # Inform the user after each file is backed up
    for item in "${CONFIG_FILES[@]}"; do
        echo "Backup of $item completed."
    done
else
    echo "Backup of config files and directories canceled."
fi

# Backup each directory with confirmation
for dir in "${CONFIG_DIRS[@]}"; do
    confirm_backup "Create backup" "of $dir directory"
    if [[ $? -eq 0 ]]; then
        (
            # Start a subshell for progress bar
            (
                echo "10"
                sleep 1
                echo "30"
                tar -czvf "$ARCH_BACKUP_DIR/${dir//\//_}.tar.gz" -C "$HOME" "$dir"
                echo "100"
            ) | zenity --progress --title="Creating Archive for $dir" --text="Please wait..." --percentage=0 --auto-close --auto-kill
        )

        echo "Backup of $dir completed."
    else
        echo "Backup of $dir canceled."
    fi
done

# Confirm before creating a separate tarball for the .virtualenv directory
confirm_backup "Create backup" "of .virtualenv directory"
if [[ $? -eq 0 ]]; then
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

    echo ".virtualenv archive created in $VENV_DIR"
else
    echo "Backup of .virtualenv directory canceled."
fi

# Function to create package list
function create_pkg_list {
    pkg_list_type=$1
    pkg_list_file=$2
    confirm_backup "Create $pkg_list_type" "package list"
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
        echo "$pkg_list_type package list created in $pkg_list_file"
    else
        echo "Backup of $pkg_list_type package list canceled."
    fi
}

REPO_PKG_LIST="$ARCH_BACKUP_DIR/repo-pkglist.txt"
create_pkg_list "Repo" "$REPO_PKG_LIST"

AUR_PKG_LIST="$ARCH_BACKUP_DIR/cust-pkglist.txt"
create_pkg_list "AUR" "$AUR_PKG_LIST"

echo "Backup and package list creation completed."

RESTORE_SCRIPT="$ARCH_BACKUP_DIR/restore.sh"

cat << 'EOF' > "$RESTORE_SCRIPT"
#!/bin/bash

sudo pacman -Syu

# Install packages from the official repositories
if [[ -f "./repo-pkglist.txt" ]]; then
  sudo pacman -S --needed - < "./repo-pkglist.txt"
else
  echo "Error: Repository package list not found."
  exit 1
fi

# Install packages from the AUR
if command -v trizen > /dev/null 2>&1; then
  if [[ -f "./cust-pkglist.txt" ]]; then
    trizen -S --needed - < "./cust-pkglist.txt"
  else
    echo "Error: AUR package list not found."
    exit 1
  fi
else
  echo "Error: Trizen is not installed."
  exit 1
fi
EOF

chmod +x "$RESTORE_SCRIPT"

echo "Restore script created in $ARCH_BACKUP_DIR"
zenity --info --text="To restore the backup, run $ARCH_BACKUP_DIR/restore.sh"

GROUPADD_SCRIPT="$ARCH_BACKUP_DIR/groupadd.sh"
zenity --info --text="Creating $GROUPADD_SCRIPT script..."
USER=$(whoami)
echo $(groups $USER) > /tmp/groups.txt
cat << EOF > "$GROUPADD_SCRIPT"
#/bin/bash
sudo usermod -aG $(cat /tmp/groups.txt) $USER
EOF
rm /tmp/groups.txt
chmod +x "$GROUPADD_SCRIPT"

echo "Groupadd script created in $ARCH_BACKUP_DIR"
zenity --info --text="To add user to groups, run $ARCH_BACKUP_DIR/groupadd.sh"
