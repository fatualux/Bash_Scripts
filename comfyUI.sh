#!/bin/sh

clear

WORKDIR=$HOME/.virtualenv/comfyui

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.10/site-packages/

cd $WORKDIR
source $WORKDIR/.venv/bin/activate && pip install --upgrade pip
python $WORKDIR/ComfyUI/main.py
