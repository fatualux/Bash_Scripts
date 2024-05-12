# Audio Splitter with Silence Detection

## Overview
This bash script allows you to split audio files based on silence detection using ffmpeg. It provides a user-friendly interface (using yad) to select the input audio file; then it splits the audio into individual tracks based on detected silence intervals.

## Dependencies
- yad
- ffmpeg

## Usage
1. Make sure you have the required dependencies installed.
2. Download the `audio_splitter.sh` script.
3. Make the script executable with the command `chmod +x audio_splitter.sh`.
4. Run the script with `./audio_splitter.sh`.
5. Use the yad file chooser dialog to select the input audio file.
6. Wait for the script to split the audio file into individual tracks. The progress will be displayed verbosely in the terminal.
7. Once completed, the split tracks will be saved in a folder named "SPLIT" within the directory where the original file is located.

## Features
- Choose the input audio file with a graphical file chooser dialog
- Split the audio file into individual tracks based on silence detection
- Save the split tracks in a folder called "SPLIT" within the directory where the original file is located
- Progress is shown verbosely during the splitting process
