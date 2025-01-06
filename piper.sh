#!/bin/bash
# This script interacts with Piper TTS for Text-to-Speech generation on a Raspberry Pi or similar environments.
# It depends on: bash, zenity, piper

WORKDIR="$HOME/.virtualenv/tts"
MODEL_DIR="$WORKDIR/models"
OUTPUT_DIR="$HOME"
PIPER_BIN="$WORKDIR/bin/piper"
source $WORKDIR/bin/activate && pip install --upgrade pip

ChooseTask() {
  task=$(zenity --list --title "Choose task" --text "Choose task" --column "TASK" \
        "Input text" "Read a file" --width 820 --height 460 --hide-header)
  case $task in
    "Input text")
      InputText
      ;;
    "Read a file")
      SelectFile
      ;;
  esac
}

SelectFile() {
  files=$(zenity --file-selection --multiple --filename=$HOME/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> files.txt
  done
  IFS=$'\n'
  for FILE in $(cat files.txt);
  do
    TEXT=$(cat $FILE)
  done
  rm files.txt
  echo "Done!"
}

InputText() {
  TEXT=$(zenity --entry --title "Input text" --text "Input text")
  [[ "$TEXT" ]] || exit 1
  export TEXT
  echo "Done!"
}

SelectModel() {
  # List all .onnx model files in the models directory
  MODEL=$(zenity --list --title "Choose a model" --text "Choose a model" --column "MODEL" \
    $(ls "$MODEL_DIR"/*.onnx) --width 820 --height 460 --hide-header)

  [[ "$MODEL" ]] || exit 1

  OUTPUT_FILE="$OUTPUT_DIR/$(date +"%m-%d-%y-%T").wav"

  echo "$TEXT" | $PIPER_BIN --model "$MODEL" --output-file "$OUTPUT_FILE"
  
  zenity --info --text="Audio generated and saved to $OUTPUT_FILE"
}

ChooseTask
SelectModel
echo ""
echo "Done!"
sleep 1
exit

