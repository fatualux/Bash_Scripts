# FFMPEG Converter Script

## Overview
This Bash script provides a user-friendly interface to interact with ffmpeg. It utilizes Zenity for GUI dialogs and is designed for various media conversion tasks.

## Requirements
Ensure the following dependencies are installed:

- [zenity](https://help.gnome.org/users/zenity/stable/)
- [ffmpeg](https://ffmpeg.org/)

## Usage
Clone the repository or download the script.
Make the script executable:

```
chmod +x converter.sh
```

Run the script:

```
./converter.sh
```

## Features
- Media Converter: Allows you to convert media files from one format to another.
- Image Converter: Allows you to convert images from one format to another.
- Scale Images: Allows you to resize images.
- Images to Video: Converts images to video.
- Video to Frames: Extracts frames from a video.
- Invert Frames: Inverts the sequence of the frames in a video.
- Detect Framerate: Detects the framerate of a video.
