#!/bin/bash
# This script is based on translate-shell (https://github.com/soimort/translate-shell)
# It depends on: bash zenity

CheckClipboardTool() {
  if command -v wl-copy >/dev/null 2>&1; then
    export CLIP_TOOL="wl-copy"
    export PASTE_TOOL="wl-paste"
  else
    echo "Error: No clipboard tool (wl-copy) found!"
    export CLIP_TOOL="NO"
  fi
}

check_dependencies() {
  dependencies=("zenity" "trans" "wl-copy")

  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      echo "Error: $dep not found. Please install it and try again."
      exit 1
    fi
  done
}

ListLanguages() {
  options=("English" "Italian" "French" "Spanish" "German" "Japanese" "Russian" "Chinese")
  LANG=$(zenity --list --title="Select Language" --text="Select one option" --column="Language" "${options[@]}")
  case $LANG in
    "English") LANG="en";;
    "Italian") LANG="it";;
    "French") LANG="fr";;
    "Spanish") LANG="es";;
    "German") LANG="de";;
    "Japanese") LANG="ja";;
    "Russian") LANG="ru";;
    "Chinese") LANG="zh";;
    *) LANG="en";; # Default to English if nothing is selected
  esac
}

translate_cmd() {
  if [ CLIP_TOOL = "NO" ]; then
    TERM=$(zenity --entry --title="Enter Text" --text="Enter word or phrase:")
    if [ -z "$TERM" ]; then
      zenity --info --text="Translation canceled."
      exit 1
    fi
  else
    TERM=$(wl-paste)
  fi

  output=$(trans -b -no-play -t "$LANG" "$TERM")
  echo ""
  echo -e '\e[40m\e[92m'
  echo "$output"
  zenity --info --text=".: $output :. has been copied to clipboard."
  echo "$output" | wl-copy
  echo -e '\e[0m'
  echo ""
  echo "Done!"
  read -p "Press Enter to exit..."
  exit 0
}

check_dependencies
ListLanguages
translate_cmd
