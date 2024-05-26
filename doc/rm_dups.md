# Duplicate File Remover Script

## Overview
This Bash script provides a simple interface to identify and remove duplicate files within a selected directory.
It uses Zenity for GUI dialogs.
Before starting the md5 checksum, it gives the option to operate a bulk renaming of files and directories, to avoid incorrect names' splitting; spaces will be replaced by underscores, and other special characters will be removed.
Than, the user is asked to choose which one of the duplicate files should be removed.
At the end of the operation, the user can choose if the script should remove the empty directories.

## Requirements
Ensure that the following dependencies are installed:
- [Zenity](https://help.gnome.org/users/zenity/stable/)

## Usage

1. Make the script executable and run it in a terminal:

   ```
   chmod +x rm_dups.sh && ./rm_dups.sh
   ```

2. Run the script in a terminal:

   ```
   ./rm_dups.sh
   ```

3. Select the directory where the files will be removed.

4. Follow the instructions in the dialog box.
