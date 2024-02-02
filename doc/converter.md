# FFMPEG Converter Script

This Bash script provides a user-friendly interface to interact with ffmpeg. It utilizes Zenity for GUI dialogs and is designed for various media conversion tasks.

## Dependencies

Ensure the following dependencies are installed:

- [bash](https://www.gnu.org/software/bash/)
- [zenity](https://help.gnome.org/users/zenity/stable/)
- [ffmpeg](https://ffmpeg.org/)

## Usage

1. Run the script in a terminal:

   ```bash
   ./ffmpeg_converter.sh
   ```
2. Choose an action from the list provided by Zenity: Media Converter, Image Converter, Scale Images, Images to Video, Video to Frames, Invert Frames, or Detect Framerate.

3. Depending on your choice, follow the prompts to select files, formats, and other options.

4. The script will perform the chosen operation, and the output will be saved in the specified directories.

Notes

- The script uses Zenity for user interaction, so ensure it is installed.

- Press Enter to exit the script after the chosen operation is completed.

- The temporary files are removed automatically after each operation.

- The script provides various actions for media conversion, image conversion, scaling images, creating videos from images, extracting frames from videos, inverting frames, and detecting the framerate of videos.
