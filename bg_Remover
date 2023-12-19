#!/bin/sh
#This script is based on backgroundremover (https://github.com/nadermx/backgroundremover)#

WORKDIR=$HOME/.virtualenv/background-remover
source $WORKDIR/bin/activate

SelectFile() {
  files=$(zenity --title "Which media file do you want to process?"  --file-selection --multiple --filename=$HOME/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> files.txt
  done
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
  esac
}

FrameRate() {
  r_frame=$(zenity --title "Choose the frame rate you want to process:" --list --column "Frame Rate" "30" "60" "120" --hide-header --width 820 --height 460)
  case $r_frame in
    "30")
      export R_FRAME="30"
      ;;
    "60")
      export R_FRAME="60"
      ;;
    "120")
      export R_FRAME="120"
      ;;
  esac
}

VideoFormat() {
  v_format=$(zenity --title "What video format do you want to process?" --list --column "Format" "MOV" "GIF" --hide-header --width 820 --height 460)
  case $v_format in
    "MOV")
        IFS=$'\n'
        for FILE in $(cat files.txt);
        do
          backgroundremover -i "$FILE" -m "$R_TYPE" -tv -fr "$R_FRAME" -o "$HOME/Media/BGR_""$(date +"%S")".mov
          rm files.txt
        done
        echo "Done!"
      ;;
    "GIF")
        IFS=$'\n'
        for FILE in $(cat files.txt);
        do
          backgroundremover -i "$FILE" -m "$R_TYPE" -tg -fr "$R_FRAME" -o "$HOME/Media/BGR_""$(date +"%S")".gif
          rm files.txt
        done
        echo "Done!"
      ;;
  esac
}

MediaType() {
  m_type=$(zenity --title "What type of media is it?" --list --column "TYPE" "Video" "Image" --width 820 --height 460 --hide-header)
  case $m_type in
    "Video")
       RemovalType
       FrameRate
       VideoFormat
      ;;
    "Image")
       RemovalType
        IFS=$'\n'
        for FILE in $(cat files.txt);
        do
          backgroundremover -i "$FILE" -m "$R_TYPE" -o "$HOME/Media/BGR_$(date +"%S")".png
          rm files.txt
        done
        echo "Done!"
      ;;
  esac
}

SelectFile
MediaType
