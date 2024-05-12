# Arch Backup Script

## Overview
This script automates the process of creating backups of important files and directories on an Arch Linux system.

## Requirements
* Zenity installed (`sudo pacman -S zenity`)
* Bash shell

## Usage
Clone the repository or download the script.
Make the script executable:

```
chmod +x archBackup.sh
```

Run the script:

```
./archBackup.sh
```

## Features
* Creates backups of important files and directories
* Displays progress bars using Zenity
* Provides options for backing up the `.virtualenv` directory
* Generates package lists for the official Arch Linux repository and foreign packages (e.g., AUR packages)
