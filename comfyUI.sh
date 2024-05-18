#!/bin/sh

clear

WORKDIR=$HOME/.virtualenv/comfyUI

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.11/site-packages/

cd $WORKDIR
source $WORKDIR/bin/activate && pip install --upgrade pip
pip install -r $WORKDIR/requirements.txt
python $WORKDIR/main.py
