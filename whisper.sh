#!/bin/sh
#This script is based on faster-whisper (https://github.com/guillaumekln/faster-whisper)

WORKDIR=$HOME/.virtualenv/faster-whisper

source $WORKDIR/bin/activate

cd $WORKDIR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.11/site-packages/nvidia/cudnn/lib/:$WORKDIR/lib/python3.11/site-packages/nvidia/cublas/lib/

SelectFile() {
  FILES_LIST=files.txt
  if [ -f "$FILES_LIST" ]; then
    rm $FILES_LIST
  fi
  files=$(zenity --title "Which file do you want to transcribe?"  --file-selection --multiple --filename=$HOME/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> $FILES_LIST
  done
}

ListModels() {
  model=$(zenity --list --text "Select which model to use for operation:"  \
    --column "Models" "TINY" "BASE" "SMALL" "MEDIUM" "LARGE" \
    --width=750 --height=460 --hide-header)
  case $model in
    "TINY")
      export MODEL="tiny"
      ;;
    "BASE")
      export MODEL="base"
      ;;
    "SMALL")
      export MODEL="small"
      ;;
    "MEDIUM")
      export MODEL="medium"
      ;;
    "LARGE")
      export MODEL="large-v2"
      ;;
  esac
}

OutputFormat(){
  format=$(zenity --list --text "Select output format:"  \
    --column "Format"  "TXT" "VTT" "SRT" "TSV" "JSON" "ALL" \
    --width=750 --height=460 --hide-header)
  case $format in
    "TXT")
      export FORMAT="txt"
      ;;
    "VTT")
      export FORMAT="vtt"
      ;;
    "SRT")
      export FORMAT="srt"
      ;;
    "TSV")
      export FORMAT="tsv"
      ;;
    "JSON")
      export FORMAT="json"
      ;;
    "ALL")
      export FORMAT="all"
      ;;
  esac
}

CustomOptions() {
  options=$(zenity --list --text "Select additional options:"  \
    --column "Options:" "Print colors" "Highlight words" "Both" "None"\
    --width=750 --height=460 --hide-header)
  case $options in
    "Print colors")
      export COLORS="True"
      export HIGHLIGHT="False"
      ;;
    "Highlight words")
      export HIGHLIGHT="True"
      export COLORS="False"
      ;;
    "Both")
      export COLORS="True"
      export HIGHLIGHT="True"
      ;;
    "None")
      export COLORS="False"
      export HIGHLIGHT="False"
      ;;
  esac
}

Command_Lang() {
  IFS=$'\n'
  for FILE in $(cat $FILES_LIST);
  do
    whisper-ctranslate2 "$FILE" --language "$LANG" --model "$MODEL" --model_dir $WORKDIR/models --device cuda --output_format "$FORMAT" --output_dir "$HOME/Media/" --print_colors "$COLORS" --word_timestamps "$HIGHLIGHT" --highlight_words "$HIGHLIGHT"
  done
  rm $FILES_LIST
  echo "Done!"
}

Command_Auto() {
  IFS=$'\n'
  for FILE in $(cat $FILES_LIST);
  do
    whisper-ctranslate2 "$FILE" --model "$MODEL" --model_dir $WORKDIR/models --device cuda --output_format "$FORMAT" --output_dir "$HOME/Media/" --print_colors "$COLORS" --word_timestamps "$HIGHLIGHT" --highlight_words "$HIGHLIGHT"
  done
  rm $FILES_LIST
  echo "Done!"
}

ListLanguages() {
  lang=$(zenity --list --text "Select a language:"  \
    --column "Language" "English" "French" "Spanish" "German" \
    "Italian" "Japanese" "Hindi" "Russian" "Chinese" "Autodetect"\
    --width=750 --height=460)
    case $lang in
      "English")
        export LANG="en"
        ;;
      "French")
        export LANG="fr"
        ;;
      "Spanish")
        export LANG="es"
        ;;
      "German")
        export LANG="de"
        ;;
      "Italian")
        export LANG="it"
        ;;
      "Japanese")
        export LANG="ja"
        ;;
      "Hindi")
        export LANG="hi"
        ;;
      "Russian")
        export LANG="ru"
        ;;
      "Chinese")
        export LANG="zh"
        ;;
        "Autodetect")
          SelectFile
          ListModels
          OutputFormat
          CustomOptions
          Command_Auto
          exit
        ;;
        
    esac
}

ListLanguages
SelectFile
ListModels
OutputFormat
CustomOptions
Command_Lang
