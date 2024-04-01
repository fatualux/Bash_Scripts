#!/bin/bash
# A simple bash script to interact with yt-dlp (https://github.com/yt-dlp/yt-dlp)
# Depends on: bash, yt-dlp, wl-clipboard

CheckClipboardTool() {
  if command -v wl-copy >/dev/null 2>&1; then
    export CLIP_TOOL="wl-copy"
    export PASTE_TOOL="wl-paste"
  else
    echo "Error: No clipboard tool (wl-copy) found!"
    exit 1
  fi
}

ListActions() {
  option=$(zenity --list --title "Video Downloader" --text "Select an action to perform:" \
    --column "ACTIONS:" "Download a video" "Extract the audio from a video" \
    "Download video playlist" "Download audio playlist" \
    --hide-header --width=750 --height=460 --ok-label="OK" --cancel-label="Cancel")
  case $option in
    "Download a video")
      echo "You chose to download a video"
      export ACTION="download"
      ;;
    "Extract the audio from a video")
      echo "You chose to extract the audio from a video"
      export ACTION="extract"
      ;;
    "Download video playlist")
      echo "You chose to download a video playlist"
      export ACTION="v_playlist"
      ;;
    "Download audio playlist")
      echo "You chose to download an audio playlist"
      export ACTION="a_playlist"
      ;;
  esac
}

InsertURL() {
  CheckClipboardTool
  CLIP_CONTENT=$($PASTE_TOOL)
  URL=$(zenity --entry --title "Video Downloader" --text "Enter the video URL:" --entry-text "$CLIP_CONTENT")
  [[ "$URL" ]] || exit 1
  echo "$URL"
  echo "$URL" | $CLIP_TOOL
  echo "$URL" >> urls.txt
}

DownloadFunction() {
  command="$1"
  shift
  $command "$@" --print-traffic "$URL" --lazy-playlist
}

ListActions

if [ "$ACTION" = "download" ]; then
  echo ""
  echo "VIDEO DOWNLOADER"
  InsertURL
  echo "Searching for available formats..."
  DownloadFunction yt-dlp -o "Media/$(date +%Y%m%d-%H%M%S)-%(title)s" -i --hls-prefer-ffmpeg
  echo "Done!"
  rm urls.txt
  echo "Video Download Completed!"
fi

if [ "$ACTION" = "extract" ]; then
  echo ""
  echo "AUDIO EXTRACTOR"
  InsertURL
  DownloadFunction yt-dlp --audio-quality "ba" -x " --audio-format mp3 $URL" -o "Media/$(date +%Y%m%d-%H%M%S)-%(title)s.%(ext)s"
  echo "Done!"
  rm urls.txt
  echo "Audio Extraction Completed!"
fi

if [ "$ACTION" = "v_playlist" ]; then
  echo ""
  echo "VIDEO PLAYLIST DOWNLOADER"
  InsertURL
  DownloadFunction yt-dlp -f 'bv*[height=1080]+ba' "$URL" -o 'VideoPlaylist/%(title)s.%(ext)s'
  echo "Done!"
  rm urls.txt
  echo "Video Playlist Download Completed!"
fi

if [ "$ACTION" = "a_playlist" ]; then
  echo ""
  echo "AUDIO PLAYLIST DOWNLOADER"
  InsertURL
  DownloadFunction yt-dlp --audio-quality "ba" -x "$URL" -o 'AudioPlaylist/%(title)s.%(ext)s'
  echo "Done!"
  rm urls.txt
  echo "Audio Playlist Download Completed!"
fi
