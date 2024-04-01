#!/bin/bash
#This script is based on Polymath by Sanim23 (https://github.com/samim23/polymath).
#It assumes a virtual environment named "polymath" is installed in the working directory.
#It depends on: bash zenity polymath

WORKDIR="$HOME/.virtualenv/polymath"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.9/site-packages/

cd $WORKDIR && git pull
source $WORKDIR/bin/activate && pip install --upgrade pip
pip install -r $WORKDIR/requirements.txt

ChooseAction() {
  ACTION=$(zenity --list --title "Polymath" --text "Select the action you want to perform:" \
    --column "Actions" "Download an audio file" "Split tracks" "Transform to midi" \
    "Quantize a song" --width 820 --height 460 --hide-header)
  case $ACTION in
    "Download an audio file")
        echo "Paste the last part of a YouTube URL:"
        read -r URL
        COMMAND="python polymath.py -a $URL"
      ;;
    "Split tracks")
        echo ""
        echo "Input folder added."
        COMMAND="python polymath.py -a input/"
      ;;
    "Transform to midi")
        echo ""
        echo "Input folder added."
        echo "Choose a BPM:"
        read -r BPM
        COMMAND="python polymath.py -q all -t $BPM -m"
      ;;
    "Quantize a song")
        echo ""
        echo "Input folder added."
        echo "Choose a BPM:"
        read -r BPM
        COMMAND="python polymath.py -q all -t $BPM"
      ;;
  esac
      export COMMAND
}

ChooseAction

Commands() {
  $COMMAND
  }

Commands

rm $WORKDIR/library/*

echo ""
echo "Press any key to continue"
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
exit ;
else
sleep 1
fi
done
