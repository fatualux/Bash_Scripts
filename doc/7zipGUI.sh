# 7zip GUI Script

This Bash script provides a graphical user interface (GUI) for interacting with 7-Zip, allowing users to compress and extract files easily. The script relies on `zenity` for GUI dialogs and `7z` for compression and extraction.

## Prerequisites

Ensure that the following dependencies are installed:

- Bash
- Zenity
- 7z (7-Zip)

You can install the dependencies using your package manager. For example, on Debian-based systems:

```bash```
sudo apt-get install bash zenity p7zip-full

## Usage

Clone the repository or download the script.
Make the script executable:

```bash```
chmod +x 7zip-gui.sh

Run the script:

```bash```
./7zip-gui.sh

The script will prompt you to choose an action (Compress or Extract) and guide you through the process using Zenity dialogs.

Features

Compress files into a new archive or add to an existing archive.
Choose compression methods (7z, zip, tar, tar.gz, tar.bz2) and compression levels.
Extract files from an archive to a specified output directory.
