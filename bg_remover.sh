#!/bin/bash
# This script is based on backgroundremover (https://github.com/nadermx/backgroundremover)#

WORKDIR="$HOME/.virtualenv/background_remover"
OUTPUT_DIR="$HOME/BG_REMOVED/"
source $WORKDIR/bin/activate && pip install --upgrade pip
pip install -r $WORKDIR/requirements.txt && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.10/site-packages/

SelectFile() {
  files=$(zenity --title "Which media file do you want to process?" --file-selection --multiple --filename="$HOME/")
  [[ "$files" ]] || exit 1
  FILES_LIST="files.txt"
  if [ -f "$FILES_LIST" ]; then
    rm "$FILES_LIST"
  fi
  echo "$files" | tr "|" "\n" > "$FILES_LIST"
}

RemovalType() {
  r_type=$(zenity --title "Choose the type of removal you want to perform:" --list --column "Type" "Human" "Medium" "Strong" --hide-header --width 820 --height 460)
  case $r_type in
    "Human")
      export R_TYPE="u2net_human_seg"
      ;;
    "Medium")
      export R_TYPE="u2netp"
      ;;
    "Strong")
      export R_TYPE="u2net"
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
}

FrameRate() {
  r_frame=$(zenity --title "Choose the frame rate you want to process:" --list --column "Frame Rate" "30" "60" "120" --hide-header --width 820 --height 460)
  case $r_frame in
    "30" | "60" | "120")
      export R_FRAME="$r_frame"
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
}

process_video() {
  IFS=$'\n'
  for FILE in $(cat "$FILES_LIST"); do
    mkdir -p "$OUTPUT_DIR"  # Create the output directory if it doesn't exist
    OUTPUT_FILE="$OUTPUT_DIR/BGR_$(date +"%Y%m%d_%H%M%S").mov"
    backgroundremover -i "$FILE" -m "$R_TYPE" -tv -fr "$R_FRAME" -o "$OUTPUT_FILE"
  done
  rm "$FILES_LIST"
  echo "Done!"
}

process_image() {
  IFS=$'\n'
  for FILE in $(cat "$FILES_LIST"); do
    mkdir -p "$OUTPUT_DIR"  # Create the output directory if it doesn't exist
    OUTPUT_FILE="$OUTPUT_DIR/BGR_$(date +"%Y%m%d_%H%M%S").png"
    backgroundremover -i "$FILE" -m "$R_TYPE" -o "$OUTPUT_FILE"
  done
  rm "$FILES_LIST"
  echo "Done!"
}

MediaType() {
  m_type=$(zenity --title "What type of media is it?" --list --column "TYPE" "Video" "Image" --width 820 --height 460 --hide-header)
  case $m_type in
    "Video")
      RemovalType
      FrameRate
      process_video
      ;;
    "Image")
      RemovalType
      process_image
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
}

SelectFile
MediaType
