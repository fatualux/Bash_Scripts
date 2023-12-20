#!/bin/bash

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
  TERM=$(zenity --entry --title="Enter Text" --text="Enter word or phrase:")
  if [ -z "$TERM" ]; then
    zenity --info --text="Translation canceled."
    exit 1
  fi

  output=$(trans -b -no-play -t "$LANG" "$TERM")
  echo ""
  echo -e '\e[40m\e[92m'
  echo "$output"
  echo "$output" | wl-copy
  echo -e '\e[0m'
  echo ""
  echo "Done!"
  read -p "Press Enter to exit..."
  exit 0
}

ListLanguages

translate_cmd
