#!/bin/sh
# It is a simple bash script to interact with yt-dlp (https://github.com/yt-dlp/yt-dlp)
# It depends on: bash zenity yt-dlp wl-clipboard

CheckClipboardTool() {
  if command -v wl-copy >/dev/null 2>&1; then
    export CLIP_TOOL="wl-copy"
    export PASTE_TOOL="wl-paste"
  else
    zenity --error --text "Error: No clipboard tool (wl-copy) found!"
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

ProgressFunction() {
  # Use this function to show progress bar
  command="$1"
  shift
  $command "$@" | zenity --progress --title="Progress" --text="Working..." --percentage=0 --auto-close
}

ListActions

if [ "$ACTION" = "download" ]; then
  echo ""
  echo "VIDEO DOWNLOADER"
  InsertURL
  echo "Searching for available formats..."
  ProgressFunction yt-dlp -o "Media/$(date +%Y%m%d-%H%M%S)-%(title)s" -i --hls-prefer-ffmpeg --print-traffic "$URL" --lazy-playlist
  echo "Done!"
  rm urls.txt
  zenity --info --text="Video Download Completed!"
fi

if [ "$ACTION" = "extract" ]; then
  echo ""
  echo "AUDIO EXTRACTOR"
  InsertURL
  ProgressFunction yt-dlp --audio-quality "ba" -x "$URL" -o "Media/$(date +%Y%m%d-%H%M%S)-%(title)s.%(ext)s"
  echo "Done!"
  rm urls.txt
  zenity --info --text="Audio Extraction Completed!"
fi

if [ "$ACTION" = "v_playlist" ]; then
  echo ""
  echo "VIDEO PLAYLIST DOWNLOADER"
  InsertURL
  ProgressFunction yt-dlp -f 'bv*[height=1080]+ba' "$URL" -o 'VideoPlaylist/$(date "%H%M%S")-%(title)s.%(ext)s'
  echo "Done!"
  rm urls.txt
  zenity --info --text="Video Playlist Download Completed!"
fi

if [ "$ACTION" = "a_playlist" ]; then
  echo ""
  echo "AUDIO PLAYLIST DOWNLOADER"
  InsertURL
  ProgressFunction yt-dlp --audio-quality "ba" -x "$URL" -o 'AudioPlaylist/$(date +%Y%m%d-%H%M%S)-%(title)s.%(ext)s'
  echo "Done!"
  rm urls.txt
  zenity --info --text="Audio Playlist Download Completed!"
fi
