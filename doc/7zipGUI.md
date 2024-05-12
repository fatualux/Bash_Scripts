# 7zip GUI Script

## Overview
This Bash script provides a graphical user interface (GUI) for interacting with 7-Zip, allowing users to compress and extract files easily. The script relies on `zenity` for GUI dialogs and `7z` for compression and extraction.

## Requirements
* Zenity installed
* 7-Zip installed
* Bash shell

## Usage
Clone the repository or download the script.
Make the script executable:

```
chmod +x 7zip-gui.sh
```

Run the script:

```
./7zip-gui.sh
```

The script will prompt you to choose an action (Compress or Extract) and guide you through the process using Zenity dialogs.

## Features
Compress files into a new archive or add to an existing archive.
Choose compression methods (7z, zip, tar, tar.gz, tar.bz2) and compression levels.
Extract files from an archive to a specified output directory.
