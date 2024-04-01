#!/bin/sh
# Choose from a list of Python virtualenvs and sends the commands to activate it to wl-copy.
# It depends on bash zenity wl-clipboard

clear

WORKDIR=$HOME/.virtualenv

ChooseVenv(){
  venv=$(ls $WORKDIR|sort|zenity --list --title "Choose Python virtualenv" --text "Choose a virtualenv" --column "Virtualenv" --width=820 --height=460 --hide-header)
  if [ -z "$venv" ]; then
    exit 1
  fi
  if [ ! -d "$WORKDIR/$venv" ]; then
    mkdir -p "$WORKDIR/$venv"
  fi
  echo "source $WORKDIR/$venv/bin/activate" > /tmp/venv.txt
  wl-copy < /tmp/venv.txt
}

UpdateChoice(){
  CHOICE=$(zenity --list --text "Select an action to perform:" \
    --column "Actions" "Update" "Open Venv Directory" \
    --width=420 --height=280\
    --ok-label "OK" --cancel-label "Cancel" \
)
  case $CHOICE in
    "Update")
    echo "cd $WORKDIR/$venv" >> /tmp/venv.txt
    echo "git pull" >> /tmp/venv.txt
    wl-copy < /tmp/venv.txt
    ;;
    "Open Venv Directory")
    echo "cd $WORKDIR/$venv" >> /tmp/venv.txt
    wl-copy < /tmp/venv.txt
    ;;
  esac
}

ChooseVenv
UpdateChoice
