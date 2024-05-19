# YouTube Downloader Script

## Overview
This Bash script provides a user-friendly interface to interact with yt-dlp, a powerful YouTube downloader.
It uses Zenity for GUI dialogs and is designed to download videos, extract audio, or download entire video or audio playlists.

## Requirements
Ensure the following dependencies are installed:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [Zenity](https://help.gnome.org/users/zenity/stable/)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) - needed to detect clipboard contents

## Usage
Clone the repository or download the script.
Make the script executable:

```
chmod +x downloader.sh
```

Run the script:

```
./downloader.sh
```

## Features

- Download a video
- Extract audio from a video
- Download a video playlist
- Download an audio playlist
