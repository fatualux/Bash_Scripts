#!/bin/sh
#It is a basic bash script to interact with ffmpeg (very few options added by now)
#It depends on bash zenity ffmpeg

OUTPUT_DIR=$(pwd)/CONVERTED/
FILES_LIST=/tmp/files.txt

sel_width() {
  WIDTH=$(zenity --entry --title "Enter the desired width:" --text "Enter the desired width for the image")
  export WIDTH
}

sel_height() {
  HEIGHT=$(zenity --entry --title "Enter the desired height:" --text "Enter the desired height for the image")
  export HEIGHT
}

sel_framerate() {
  FPS=$(zenity --entry --title "Enter the framerate" --text "Enter the desired framerate:")
  [[ "$FPS" ]] || exit 1
}

list_ratios() {
  echo "Common resolutions:"
  echo "1080p: 1920x1080 16:9"
  echo "720p: 1280x720 16:9"
  echo "480p: 854x480 16:9"
  echo "360p: 640x360 16:9"
  echo "240p: 426x240 16:9"
  echo "144p: 256x144 16:9"
  sel_width
  sel_height
}

sel_dir() {
  dir=$(zenity --file-selection --directory)
  export DIR=$dir
}

sel_file() {
  files=$(zenity --title "Select a one or more files:"  --file-selection --multiple --filename=$(pwd)/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> /tmp/files.txt
  done
}

vid_to_gif() {
  sel_framerate
  list_ratios
  mkdir -p $OUTPUT_DIR
  for FILE in $(cat $FILES_LIST); do
    FILENAME=$(basename "$FILE")
    OUTPUT_FILE="$OUTPUT_DIR${FILENAME%.*}.gif"
    ffmpeg -i $FILE -vf scale=$WIDTH:$HEIGHT $OUTPUT_FILE
  done
}

sel_media_format() {
  option=$(zenity --list --title "Video Format" --text "Select a video format:" \
  --column "MEDIA FORMAT:" "mp3" "flac" "wav" "opus" "mp4" "mkv" "avi" "gif" \
  --hide-header --width=820 --height=460 --ok-label="OK" --cancel-label="Cancel")
  case $option in
    "mp3")
      export M_FORMAT="mp3"
      ;;
    "flac")
      export M_FORMAT="flac"
      ;;
    "wav")
      export M_FORMAT="wav"
      ;;
    "opus")
      export M_FORMAT="opus"
      ;;
    "mp4")
      export M_FORMAT="mp4"
      ;;
    "mkv")
      export M_FORMAT="mkv"
      ;;
    "avi")
      export M_FORMAT="avi"
      ;;
    "gif")
      export M_FORMAT="gif"
      ;;
  esac
}

sel_img_format() {
  option=$(zenity --list --title "Image Format" --text "Select an image format:" \
  --column "MEDIA FORMAT:" "jpg" "jpeg" "tiff" "png" "gif" "webp" "avif" \
  --hide-header --width=820 --height=460 --ok-label="OK" --cancel-label="Cancel")
  case $option in
    "jpg")
      export I_FORMAT="jpg"
      ;;
    "jpeg")
      export I_FORMAT="jpeg"
      ;;
      "tiff")
      export I_FORMAT="tiff"
      ;;
    "png")
      export I_FORMAT="png"
      ;;
    "gif")
      export I_FORMAT="gif"
      ;;
    "webp")
      export I_FORMAT="webp"
      ;;
    "avif")
      export I_FORMAT="avif"
      ;;
  esac
}

media_conv() {
  sel_file
  sel_media_format
  mkdir -p $OUTPUT_DIR
  IFS=$'\n'
  if [ "$M_FORMAT" = "gif" ]; then
    vid_to_gif
  else
    for FILE in $(cat $FILES_LIST);
    do
      FILENAME=`basename "${FILE}"`
      OUTPUT_FILE="$OUTPUT_DIR${FILENAME%.*}.$M_FORMAT"
      echo "Converting $FILENAME to $OUTPUT_FILE"
      ffmpeg -i "$FILE" -c:v libx264 -pix_fmt yuv420p "$OUTPUT_FILE"
    done
  fi
  rm files.txt
  rm $FILES_LIST
  echo "Temporary files removed!"
}

image_conv() {
  sel_file
  sel_img_format
  mkdir -p $OUTPUT_DIR
  IFS=$'\n'
  for FILE in $(cat "$FILES_LIST"); do
    FILENAME=$(basename "$FILE")
    OUTPUT_FILE="$OUTPUT_DIR${FILENAME%.*}.$I_FORMAT"
    echo "Converting $FILENAME to $OUTPUT_FILE"
    ffmpeg -i "$FILE" "$OUTPUT_FILE"
  done
  rm "$FILES_LIST"
  echo "Temporary files removed!"
}

scale() {
  sel_file

  option=$(zenity --list --title "Scale Type" --text "Select a scale type:" \
    --column "SCALE TYPE:" "Free Scale" "Fixed Scale" \
    --hide-header --width=275 --height=200 --ok-label="OK" --cancel-label="Cancel")

  case $option in
    "Free Scale")
      sel_width
      sel_height
      SCALE_FOLDER="FREE_SCALED"
      ;;
    "Fixed Scale")
      scale_option=$(zenity --list --title "Scale Option" --text "Select a scale option:" \
        --column "SCALE OPTION:" "Increase" "Decrease" \
        --hide-header --width=275 --height=200 --ok-label="OK" --cancel-label="Cancel")

      case $scale_option in
        "Increase")
          scale_factor=$(zenity --entry --title "Enter the scale factor" --text "Enter the scale factor:")
          [ -z "$scale_factor" ] && exit 1
          SCALE_FOLDER="UPSCALED"
          ;;
        "Decrease")
          scale_factor=$(zenity --entry --title "Enter the scale factor" --text "Enter the scale factor:")
          [ -z "$scale_factor" ] && exit 1
          SCALE_FOLDER="DOWNSCALED"
          ;;
        *)
          exit 1
          ;;
      esac
      ;;
    *)
      exit 1
      ;;
  esac

  mkdir -p "$SCALE_FOLDER"

  IFS=$'\n'
  for FILE in $(cat /tmp/files.txt); do
    FILENAME=$(basename "$FILE")
    FILE_EXTENSION="${FILENAME##*.}" # Extract file extension
    OUTPUT_FILE="$SCALE_FOLDER/${FILENAME%.*}.$FILE_EXTENSION"

    if [ "$option" = "Free Scale" ]; then
      ffmpeg -i "$FILE" -vf "scale=$WIDTH:$HEIGHT" "$OUTPUT_FILE"
    elif [ "$option" = "Fixed Scale" ]; then
      if [ "$scale_option" = "Increase" ]; then
        ffmpeg -i "$FILE" -vf "scale=iw*$scale_factor:ih*$scale_factor" -c:a copy "$OUTPUT_FILE"
      elif [ "$scale_option" = "Decrease" ]; then
        ffmpeg -i "$FILE" -vf "scale=iw/$scale_factor:ih/$scale_factor" -c:a copy "$OUTPUT_FILE"
      fi
    fi

    echo "Scaled $FILENAME and saved to $SCALE_FOLDER"
  done

  rm /tmp/files.txt
  echo "Temporary files removed!"
}

img_vid() {
  sel_dir
  sel_img_format
  sel_media_format
  sel_framerate
  GLOB_PATTERN="*.$I_FORMAT"
  mkdir -p $OUTPUT_DIR
  OUTPUT_FILE="$OUTPUT_DIR$(date +%Y%m%d-%H%M%S).$M_FORMAT"
  cd $DIR
  ffmpeg -framerate $FPS -pattern_type glob -i "$GLOB_PATTERN" -c:a copy -shortest -c:v libx264 -pix_fmt yuv420p "$OUTPUT_FILE"
  rm $FILES_LIST
  echo ""
  echo "Temporary files removed!"
}

frames() {
  FILES_LIST=/tmp/files.txt
  sel_file
  sel_img_format
  sel_framerate
  mkdir -p $OUTPUT_DIR
  IFS=$'\n'
  for FILE in $(cat $FILES_LIST);
  do
    FILE_NAME=$(basename "$FILE")
    OUTPUT_FILE="$OUTPUT_DIR/frame_%05d.${I_FORMAT}"
    ffmpeg -i "$FILE" -r $FPS -f image2 "$OUTPUT_FILE"
    echo "Created $OUTPUT_DIR/frame_%05d.${I_FORMAT}"
  done
  rm $FILES_LIST
  echo "Temporary files removed!"
}

invert_frames() {
  FILE=$(zenity --file-selection --title "Select a video file:")
  [ -z "$FILE" ] && return
  OUTPUT_FILE=$(zenity --file-selection --save --confirm-overwrite --title "Save As" --file-filter="Video files (mp4 mkv avi)")
  [ -z "$OUTPUT_FILE" ] && return
  ffmpeg -i "$FILE" -vf "reverse" "$OUTPUT_FILE"
  echo "Frames inverted successfully! Output saved to: $OUTPUT_FILE"
}

get_framerate() {
  sel_file
  FILE_NAME_WITH_BACKSLASH=""
  FILES_LIST=/tmp/files.txt
  IFS=$'\n'
  for FILE in $(cat $FILES_LIST); do
    FILE_NAME=$(basename "$FILE")
    FILE_FPS=$(ffmpeg -i "$FILE" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
    FILE_NAME_WITH_BACKSLASH=$(echo "$FILE_NAME" | sed 's/ /\\ /g')
    echo ""
    echo "The original framerate of $FILE_NAME_WITH_BACKSLASH is $FILE_FPS fps"
    zenity --info --text "The original framerate of $FILE_NAME_WITH_BACKSLASH is $FILE_FPS fps"
    echo ""
  done
  rm $FILES_LIST
  echo "Temporary files removed!"
}

sel_action() {
  option=$(zenity --list --title "FFMPEG Converter" --text "Select an action to perform:" \
  --column "ACTIONS:" "Media Converter" "Image Converter" "Scale Images" \
   "Images to video" "Video to frames" "Invert frames" "Detect framerate" \
  --hide-header --width=275 --height=350 --ok-label="OK" --cancel-label="Cancel")
  case $option in
    "Media Converter")
      media_conv
      ;;
    "Image Converter")
      image_conv
      ;;
    "Scale Images")
      scale
      ;;
    "Images to video")
      img_vid
      ;;
    "Video to frames")
      frames
      ;;
    "Invert frames")
      invert_frames
      ;;
    "Detect framerate")
      get_framerate
      ;;
  esac
}

sel_action
