#!/bin/bash
#It depends on: bash mpv yad yt-dlp

CLIPBOARD=$(wl-paste)
URL=$(yad --title="YouTube Stream" --form --field="YouTube URL:" "$CLIPBOARD" --width=820 --height=460)

mpv $URL --ytdl-format=best --no-video --shuffle
