#!/bin/bash
#This script opens a shell prompt, asks user for an URL and plays it with no sound.
#It depends on: bash mpv yt-dlp

COLS=$(tput cols)
text="Insert a YouTube Video URL:"
h_text=${#text}

printf "%*s\n" $((COLS/2+h_text/2)) "$text"
echo ""
echo ""

read -r URL

mpv $URL --ytdl-format=best --no-video --shuffle
