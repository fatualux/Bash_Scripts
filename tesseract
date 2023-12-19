#!/bin/sh
#A basic bash script to interact with tesseract-ocr
#It depends on: bash zenity tesseract (https://github.com/tesseract-ocr/tesseract)

################################ FUNCTIONS ################################

ListLanguages() {
  lang=$(zenity --list --text "Which is the language to translate from?" \
     --column "Language" --width=820 --height=460 --hide-header \
    "English" "French" "Spanish" "German" "Italian" "Japanese" "Hindi" "Russian" "Chinese")
  case $lang in
    "English")
      export LANG="eng"
      ;;
    "French")
      export LANG="fra"
      ;;
    "Spanish")
      export LANG="spa"
      ;;
    "German")
      export LANG="deu"
      ;;
    "Italian")
      export LANG="ita"
      ;;
    "Japanese")
      export LANG="jpn"
      ;;
    "Hindi")
      export LANG="hin"
      ;;
    "Russian")
      export LANG="rus"
      ;;
    "Chinese")
      export LANG="chi-tra"
      ;;
  esac
}

ListOutputs(){
  output=$(zenity --list --text "Select one option using up/down keys and enter to confirm:" \
     --column "Output" --width=820 --height=460 --hide-header \
    "Text" "PDF" "HOCR" "TSV")
  case $output in
    "Text")
      export OUTPUT="txt"
      ;;
    "PDF")
      export OUTPUT="pdf"
      ;;
    "HOCR")
      export OUTPUT="hocr"
      ;;
    "TSV")
      export OUTPUT="tsv"
      ;;
  esac
}

PageSegmentation(){
  segmentation=$(zenity --list --text "Select one option using up/down keys and enter to confirm:" \
     --column "Segmentation" --width=820 --height=460 --hide-header \
"Orientation and script detection (OSD) only" "Automatic page segmentation with OSD" \
  "Automatic page segmentation (No OSD or OCR)" "Fully automatic page segmentation (No OSD, default)" \
  "Assume a single column of text of variable sizes" "Assume a single uniform block of vertically aligned text" \
  "Assume a single uniform block of text" "Treat the image as a single text line" \
  "Treat the image as a single word" "Treat the image as a single word in a circle" \
  "Treat the image as a single character" "Find as much text as possible in no particular order" \
  "Sparse text with OSD" "Treat the image as a single text line")
  case $segmentation in
    "Orientation and script detection (OSD) only")
      export PAGE_SEGMENTATION="0"
      ;;
    "Automatic page segmentation with OSD")
      export PAGE_SEGMENTATION="1"
      ;;
    "Automatic page segmentation (No OSD or OCR)")
      export PAGE_SEGMENTATION="2"
      ;;
    "Fully automatic page segmentation (No OSD, default)")
      export PAGE_SEGMENTATION="3"
      ;;
    "Assume a single column of text of variable sizes")
      export PAGE_SEGMENTATION="4"
      ;;
    "Assume a single uniform block of vertically aligned text")
      export PAGE_SEGMENTATION="5"
      ;;
    "Assume a single uniform block of text")
      export PAGE_SEGMENTATION="6"
      ;;
    "Treat the image as a single text line")
      export PAGE_SEGMENTATION="7"
      ;;
    "Treat the image as a single word")
      export PAGE_SEGMENTATION="8"
      ;;
    "Treat the image as a single word in a circle")
      export PAGE_SEGMENTATION="9"
      ;;
      "Treat the image as a single character")
      export PAGE_SEGMENTATION="10"
      ;;
    "Find as much text as possible in no particular order")
      export PAGE_SEGMENTATION="11"
      ;;
    "Sparse text with OSD")
      export PAGE_SEGMENTATION="12"
      ;;
      "Treat the image as a single text line")
      export PAGE_SEGMENTATION="13"
      ;;
  esac
}

OcrEngine(){
  engine=$(zenity --list --text "Select one option using up/down keys and enter to confirm:" \
     --column "Ocr Engine" --width=820 --height=460 --hide-header \
      "Legacy engine only" "Neural nets LSTM engine only" \
      "Legacy + LSTM engines" "Default, based on what is available")
  case $engine in
    "Legacy engine only")
      export OCR_ENGINE="0"
      ;;
    "Neural nets LSTM engine only")
      export OCR_ENGINE="1"
      ;;
    "Legacy + LSTM engines")
      export OCR_ENGINE="2"
      ;;
    "Default, based on what is available")
      export OCR_ENGINE="3"
      ;;
  esac
}

SelectFile() {
  files=$(zenity --title "Which file do you want to transcribe?"  --file-selection --multiple --filename=$(pwd)/)
  [[ "$files" ]] || exit 1
  echo $files | tr "|" "\n" | while read file
  do
    echo "$file" >> /tmp/files.txt
  done
}

################################## SCRIPT ##################################

FILES_LIST=/tmp/files.txt

SelectFile
ListLanguages
ListOutputs
PageSegmentation
OcrEngine

IFS=$'\n'
for FILE in $(cat $FILES_LIST);
do
  tesseract --tessdata-dir "/usr/share/tessdata" "$FILE" "$FILE"".psm""$PAGE_SEGMENTATION" -l "$LANG" "$OUTPUT" --psm "$PAGE_SEGMENTATION" -oem "$OCR_ENGINE"
done
echo "Done!"
