# My Scripts

### A small collection of scripts to speed up everyday tasks
##### Here are some scripts I often use (I assigned them shortcuts in my i3 wm config to speed up execution).

**Here is a short demostration of some of them:**
#### [Youtube Demo](https://www.youtube.com/watch?v=aAU71nJ2XCA)

## Description

### ALARM

This sets a timer based on the user's input and uses both a terminal-based progress bar and Zenity notifications.
It then uses espeak for an audible alert and displays a Zenity info dialog when the timer is complete.

#### Dependencies

* `bash`
* `zenity`
* `espeak`

#### Usage

1. **Run the Script:**
    ```bash
    ./alarm
    ```


### ARCH_BACKUP

This Bash script automates the process of creating a backup of your essential Arch Linux configuration files, directories, and package lists. It utilizes Zenity for user interaction and displays progress bars during the backup process.

#### Dependencies

* `bash`
* `zenity`

#### Usage

1. **Run the Script:**
   ```bash
   ./arch_backup
   ```


### ARGOS

This script is a simple interface for using [Argos Translate](https://github.com/argosopentech/argos-translate) in the terminal. It allows you to translate text or files between various languages.

#### Dependencies

* `bash`
* `zenity`
* `python3`
* `argos-translate`

#### Usage

1. Save the script (argos) on a directory of your choice.
2. Set the `WORKDIR` variable in the script to the path of your Argos Translate virtual environment.

```bash
./argos
```


### BATCH_RENAMER

This Bash script provides a simple interface for batch renaming files and directories. It uses Zenity for GUI prompts and allows you to choose whether to rename files or directories.

#### Dependencies

* `bash`
* `zenity`

#### Usage

1. Run the script in the terminal:

   ```bash
   ./batch_renamer
   ```


### CONVERTER

This Bash script provides a basic interface to interact with FFMPEG for various media processing tasks. It allows you to convert video and image formats, scale images, create videos from images, extract frames from videos, invert the frames of videos, detect framerates, and more. The script utilizes Zenity for GUI prompts.

#### Dependencies

* `bash`
* `zenity`
* `ffmpeg`

#### Usage

1. Run the script in the terminal:

   ```bash
   ./converter
   ```

1. Select the desired action from the list using the Zenity dialog.

2. Follow the prompts for each action, such as selecting file(s), specifying output formats, dimensions, framerates, etc.

### Actions

***Video Converter***
Converts video files to a specified format (e.g., mp4, mkv, avi).

***Image Converter***
Converts image files to a specified format (e.g., jpg, png, gif).

***Scale Images***
Scales image files to a specified width and height or predefined aspect ratios.

***Scale and Crop***
Scales and crops images to a specified width, height, and aspect ratio.

***Images to Video***
Combines images into a video with a specified framerate.

***Video to Frames***
Extracts frames from a video.

***Invert Frames***
Inverts the frames of a video.

***Detect framerates***
Displays the framerate of selected video file(s).


### DOWNLOADER

This Bash script is a simple interface to interact with [yt-dlp](https://github.com/yt-dlp/yt-dlp), a command-line tool to download videos and playlists from YouTube and other supported sites. The script uses Zenity for GUI prompts.

#### Dependencies

* `bash`
* `zenity`
* `yt-dlp`
* `xclip`

#### Usage

1. Run the script in the terminal:

   ```bash
   ./downloader
   ```

1. Choose the action you want to perform from the list using the Zenity dialog..

2. Follow the prompts to enter the URL or select files as required for the chosen action.

### Actions

***Download a video***
Downloads a single video from the provided URL.

***Extract the audio from a video***
Extracts the audio from a video and saves it in the specified format.

***Download video playlist***
Downloads all videos from a video playlist.

***Download audio playlist****
Downloads the audio from a playlist and saves it in the specified format..


### OPENSSL

This Bash script generates an OpenSSL key and certificate. It prompts the user to enter a filename, the number of days the certificate is valid, and then generates the key and certificate accordingly.

#### Dependencies

Make sure you have the OpenSSL tool installed on your system.

#### Usage

1. Run the script in the terminal:

   ```bash
   ./openssl
   ```
#### Functions

***ChooseFilename***
Prompts the user to enter a filename for the key and certificate.

***ChooseNumdays***
Prompts the user to enter the number of days for which the certificate will be valid.

***Main***
The main section of the script sets up the working directory, prompts for a filename and number of days, generates a key, and then generates a certificate based on the user inputs.


### RM_DUPS

This Bash script uses Zenity to prompt the user to select a directory, then scans the specified directory for duplicate files based on their content using MD5 hashing. It removes duplicate files, keeping only one copy.

#### Dependencies

- Bash
- Zenity

#### Usage

1. Run the script in the terminal:

   ```bash
   ./rm_dups
   ```
1. A Zenity dialog will appear, asking you to select a directory to scan for duplicate files.

2. The script will then scan the selected directory for duplicate files based on MD5 hashing and remove the duplicates.

3. A progress bar will show the scanning progress.

Once the process is complete, a message will inform you that duplicate files have been removed.

The script uses Zenity for user interaction and creates an associative array (file_content) to keep track of file content and paths. It then iterates through files in the selected directory, calculates MD5 hashes, and checks for duplicates. Duplicate files are removed, and the progress is displayed using a Zenity progress bar.


### TRANSLATE

This Bash script utilizes Zenity for user interaction and the `translate-shell` (https://github.com/soimort/translate-shell) command-line tool for translation. It allows the user to choose a target language from a list and then enter a word or phrase for translation.

#### Dependencies

- Bash
- Zenity
- translate-shell

#### Usage

1. Run the script in the terminal:

   ```bash
   ./translate
   ```

1. A Zenity dialog will appear, prompting you to select a target language from a list of options.

2. After selecting the language, another dialog will appear, asking you to enter the word or phrase you want to translate.

3. The script will use the trans command to perform the translation and display the result.

4. The translated text will be copied to the clipboard.

5. Press Enter to exit the script.

### Supported Languages

The script supports the translation to the following languages:

    English
    Italian
    French
    Spanish
    German
    Japanese
    Russian
    Chinese


### VACTIVATE

This Bash script simplifies the management of Python virtual environments. It allows the user to choose a virtualenv from a list, and then it sends the necessary commands to activate it to the clipboard using xclip.

#### Dependencies

- Bash
- Zenity
- xclip
- virtualenv

#### Usage

1. Run the script in the terminal:

   ```bash
   ./vactivate
   ```

1. A Zenity dialog will appear, listing available Python virtual environments (you can edit the directory of your virtual environments in the script, mine is ~/.virtualenv).

2. Choose a virtual environment from the list.

3. The script will generate the activation command and copy it to the clipboard.

4. Optionally, you can choose additional actions such as updating the virtualenv or opening its directory.

5. Paste the copied command in the terminal to activate/update the selected virtualenv.

### Actions

    Update:
        This action updates the selected virtualenv using git pull if it is a Git repository.

    Open Venv Directory:
        This action changes the current directory to the selected virtualenv's directory and copies the command to the clipboard.


### 7Zip_GUI

The script is a bash script that provides a simple GUI interface for using the 7zip command-line tool to compress and extract files. Here is a summarized explanation of the logic:
It lets the user choose between compressing or extracting, creating new archives or adding files to existing archives, and selecting the compression algorithm. The script uses Zenity for user interaction.

#### Usage

1. Run the script in the terminal:
```bash
./7zip_gui
```

#### Dependencies
    bash
    zenity


### git_helper

See [GIT_HELPER](https://gitlab.com/fatualux/git_helper)

### Virtual Environments

The other scripts allow me to interact easily with my virtual environments (such as OpenAI Whisper, Coqui TTS and Tesseract OCR) by activating them with precise parameters, from a GUI; they are intended to be a sort of backup for me, but they mayi be useful as template/inspiration for someone else.

Feel free to ask me for more information in the issues.


## License

This project is licensed under the [GNU General Public License v3] License - see the LICENSE.md file for details.
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
