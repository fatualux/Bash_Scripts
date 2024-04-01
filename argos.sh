#!/bin/bash
# This script is based on argos-translate (https://github.com/argosopentech/argos-translate)
# It depends on: bash zenity python argos-translate

WORKDIR="$HOME/.virtualenv/argostranslate"
cd $WORKDIR && git pull
source $WORKDIR/bin/activate && pip install --upgrade pip
pip install -r $WORKDIR/requirements.txt && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.10/site-packages/

InputLanguage(){
  CHOICE=$(zenity --list --text "Which is the language to translate from?" \
    --column "Language" "English" "German" "Russian" "French" "Italian" "Hindi" \
  "Chinese" "Japanese" "Arabic" "Portuguese" "Polish" "Turkish" "Spanish" \
    --width=820 --height=460\
    --ok-label "OK" --cancel-label "Cancel" \
)
  case $CHOICE in
    "English")
      echo "Input language: English"
      export INPUT_LANGUAGE="en"
      ;;
    "German")
      echo "Input language: German"
      export INPUT_LANGUAGE="de"
      ;;
    "Russian")
      echo "Input language: Russian"
      export INPUT_LANGUAGE="ru"
      ;;
    "French")
      echo "Input language: French"
      export INPUT_LANGUAGE="fr"
      ;;
    "Italian")
      echo "Input language: Italian"
      export INPUT_LANGUAGE="it"
      ;;
    "Hindi")
      echo "Input language: Hindi"
      export INPUT_LANGUAGE="hi"
      ;;
    "Chinese")
      echo "Input language: Chinese"
      export INPUT_LANGUAGE="zh"
      ;;
    "Japanese")
      echo "Input language: Japanese"
      export INPUT_LANGUAGE="ja"
      ;;
    "Arabic")
      echo "Input language: Arabic"
      export INPUT_LANGUAGE="ar"
      ;;
    "Portuguese")
      echo "Input language: Portuguese"
      export INPUT_LANGUAGE="pt"
      ;;
    "Polish")
      echo "Input language: Polish"
      export INPUT_LANGUAGE="pl"
      ;;
    "Turkish")
      echo "Input language: Turkish"
      export INPUT_LANGUAGE="tr"
      ;;
    "Spanish")
      echo "Input language: Spanish"
      export INPUT_LANGUAGE="es"
      ;;
  esac
}

OutputLanguage(){
  CHOICE=$(zenity --list --text "Which is the language to translate to?" \
    --column "Language" "English" "German" "Russian" "French" "Italian" "Hindi" \
  "Chinese" "Japanese" "Arabic" "Portuguese" "Polish" "Turkish" "Spanish" \
    --width=820 --height=460\
    --ok-label "OK" --cancel-label "Cancel" \
)
  case $CHOICE in
    "English")
      echo "Output language: English"
      export OUTPUT_LANGUAGE="en"
      ;;
    "German")
      echo "Output language: German"
      export OUTPUT_LANGUAGE="de"
      ;;
    "Russian")
      echo "Output language: Russian"
      export OUTPUT_LANGUAGE="ru"
      ;;
    "French")
      echo "Output language: French"
      export OUTPUT_LANGUAGE="fr"
      ;;
    "Italian")
      echo "Output language: Italian"
      export OUTPUT_LANGUAGE="it"
      ;;
    "Hindi")
      echo "Output language: Hindi"
      export OUTPUT_LANGUAGE="hi"
      ;;
    "Chinese")
      echo "Output language: Chinese"
      export OUTPUT_LANGUAGE="zh"
      ;;
    "Japanese")
      echo "Output language: Japanese"
      export OUTPUT_LANGUAGE="ja"
      ;;
    "Arabic")
      echo "Output language: Arabic"
      export OUTPUT_LANGUAGE="ar"
      ;;
    "Portuguese")
      echo "Output language: Portuguese"
      export OUTPUT_LANGUAGE="pt"
      ;;
    "Polish")
      echo "Output language: Polish"
      export OUTPUT_LANGUAGE="pl"
      ;;
    "Turkish")
      echo "Output language: Turkish"
      export OUTPUT_LANGUAGE="tr"
      ;;
    "Spanish")
      echo "Output language: Spanish"
      export OUTPUT_LANGUAGE="es"
      ;;
  esac
}

InputText(){
echo ""
echo "Word or phrase?"
echo "(Press Ctrl + D when you have done typing, or Ctrl + C to cancel)"
echo ""
echo "________________________________________"
echo ""
read -r -d $'\04' TERM
echo ""
echo ""
echo Translating...
echo ""
echo ""
echo -e '\033[0;31m'
argos-translate --from $INPUT_LANGUAGE --to $OUTPUT_LANGUAGE "$TERM"
}

SelectFile() {
  files=$(zenity --title "Which file do you want to transcribe?"  --file-selection --multiple --filename=$HOME/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> files.txt
  done
  IFS=$'\n'
  for FILE in $(cat files.txt);
  do
    echo "________________________________________"
    echo ""
    echo "Translating $FILE"
    echo ""
    echo -e '\033[0;31m'
    argos-translate --from $INPUT_LANGUAGE --to $OUTPUT_LANGUAGE < $FILE > $FILE.translated.txt
    rm files.txt
  done
}

Task(){
  CHOICE=$(zenity --list --text "What do you want to do?" \
    --column "Task" "Input some text" "Translate a file" \
    --width=820 --height=460\
    --ok-label "OK" --cancel-label "Cancel" \
)
  case $CHOICE in
    "Input some text")
      echo "Task chosen: translate some text"
      InputText
      ;;
    "Translate a file")
      echo "Task chosen: translate a file"
      SelectFile
      ;;
  esac
}

InputLanguage
OutputLanguage
Task

echo ""
echo -e '\033[0;34m'
echo "Press any key to continue"
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
exit ;
else
sleep 1
fi
done
