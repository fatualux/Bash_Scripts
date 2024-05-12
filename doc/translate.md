# Translation Script

## Overview
This Bash script allows you to select a language and translate a given text using the `trans` command. It utilizes Zenity for GUI dialogs.

## Requirements
Make sure the following dependencies are installed:

- [Zenity](https://help.gnome.org/users/zenity/stable/)
- [trans](https://github.com/soimort/translate-shell)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard)

## Usage
1. Run the script in a terminal:

   ```
   ./translate_script.sh
   ```

2. Select the target language from the list provided by Zenity.

3. Enter the text you want to translate in the Zenity entry dialog.

4. The translation will be displayed in the terminal and copied to the clipboard.

## Notes

 If any of the dependencies are missing, the script will display an error message and exit.

 The default language is English, and if no language is selected, it defaults to English.

 Press Enter to exit the script after translation.
