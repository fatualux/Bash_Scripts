#!/bin/bash
#This script can be used to interact with tts, a library for advanced Text-to-Speech generation. (https://github.com/coqui-ai/TTS)
#It depends on: bash zenity tts

WORKDIR="$HOME/.virtualenv/tts"
MODEL="tts_models/multilingual/multi-dataset/your_tts"
source $WORKDIR/bin/activate

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.9/site-packages/

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

SelectWav() {
  WAV=$(zenity --title "Select an audio to clone:"  --file-selection --filename=$WORKDIR/wav/)
  export WAV
}

SelectVoice() {
  VOICE=$(zenity --list --title "Choose a voice" --text "Choose a voice" --column "VOICE" \
    "English" "Italian (Male)" "Italian (Female)" --width 820 --height 460 --hide-header)
  case $VOICE in
    "English")
      SelectWav
      MODEL="tts_models/multilingual/multi-dataset/your_tts"
      tts --text "$TEXT" --model_name "$MODEL" --speaker_wav "$WAV" --language_idx "en" --progress_bar true --use_cuda true --out_path $HOME/$(date +"%m-%d-%y-%T").wav
      ;;
    "Italian (Male)")
      MODEL="tts_models/it/mai_male/glow-tts"
      tts --text "$TEXT" --model_name "$MODEL" --language_idx "it" --progress_bar true --use_cuda true --out_path $HOME/$(date +"%m-%d-%y-%T").wav
      ;;
    "Italian (Female)")
      MODEL="tts_models/it/mai_female/glow-tts"
      tts --text "$TEXT" --model_name "$MODEL" --language_idx "it" --progress_bar true --use_cuda true --out_path $HOME/$(date +"%m-%d-%y-%T").wav
      ;;
  esac
}

ChooseTask
SelectVoice
echo ""
echo "Done!"
sleep 1
exit
