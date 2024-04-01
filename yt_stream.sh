#!/bin/bash
#This script opens a shell prompt, asks user for an URL and plays it with no sound.
#It depends on: bash mpv yad yt-dlp

# precompile yad form with clipboard content
CLIPBOARD=$(wl-paste)
URL=$(yad --title="YouTube Stream" --form --field="YouTube URL:" "$CLIPBOARD" --width=820 --height=460)

mpv $URL --ytdl-format=best --no-video --shuffle
