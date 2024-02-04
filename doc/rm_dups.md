# Duplicate File Remover Script

This Bash script provides a simple interface to identify and remove duplicate files within a selected directory. It utilizes Zenity for GUI dialogs and displays a progress bar during the removal process. The script prompts the user for confirmation before removing duplicate files and provides information about the removed files and the freed-up storage space.

## Dependencies

Ensure that the following dependencies are installed:

- [Zenity](https://help.gnome.org/users/zenity/stable/)

## Usage

1. Run the script in a terminal:

   ```bash
   ./rm_dups.sh
   ```
2. The script will prompt you to select a directory for duplicate file scanning.

3. If duplicate files are found, a dialog will display the list of duplicates along with the total size.3. The script will search for available formats, initiate the download, and display the progress in the terminal.

4. Confirm whether you want to remove the duplicate files.

5. The script will initiate the removal process, displaying a progress bar during the operation.

6. Upon completion, a success message will be shown, and information about the removed files and freed-up storage space will be displayed.

## Notes

- If no duplicate files are found, the script will display a message and exit.

- The script defaults to English.

-  Press Enter to exit the script after the operation is completed.
