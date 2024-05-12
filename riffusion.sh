#!/bin/sh

WORKDIR=$HOME/.virtualenv/riffusion/

Launch() {
  cd $WORKDIR
  source $WORKDIR/bin/activate && pip install --upgrade pip
  pip install -r $WORKDIR/requirements.txt
  python -m riffusion.streamlit.playground
}

Launch
