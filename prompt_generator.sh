#!/bin/sh

WORKDIR=$HOME/.virtualenv/prompt_generator

choose_image() {
  IMAGE=$(yad --title="Choose imege type;" --list --column="Type" --column="Image" \
    "Text" "text.png" \
    "Emoji" "emoji.png" \
    "Icon" "icon.png" \:wq)
}


vactivate() {
  cd $WORKDIR
  source $WORKDIR/bin/activate
  python $WORKDIR/app.py
}
