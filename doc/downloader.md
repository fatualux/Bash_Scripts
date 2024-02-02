# YouTube Downloader Script

This Bash script provides a user-friendly interface to interact with yt-dlp, a powerful YouTube downloader. It utilizes Zenity for GUI dialogs and is designed to download videos, extract audio, or download entire video or audio playlists.

## Dependencies

Ensure the following dependencies are installed:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [Zenity](https://help.gnome.org/users/zenity/stable/)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard)

## Usage

1. Run the script in a terminal:

   ```bash
   ./youtube_downloader.sh
   ```
2. Choose an action from the list provided by Zenity: Download a video, Extract audio from a video, Download a video playlist, or Download an audio playlist.

3. Depending on your choice, provide the video URL when prompted by Zenity.

3. The script will search for available formats, initiate the download, and display the progress in the terminal.

4.  Upon completion, a success message will be shown, and the downloaded media will be saved in the specified directories.

## Notes

- If any dependencies are missing, the script will display an error message and exit.

- The script defaults to English, and if no action is selected, it defaults to downloading a video.

- Press Enter to exit the script after the chosen operation is completed.
