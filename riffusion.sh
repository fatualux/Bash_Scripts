#!/bin/sh

WORKDIR=$HOME/.virtualenv/riffusion/

Launch() {
  cd $WORKDIR && git pull
  source $WORKDIR/bin/activate && pip install --upgrade pip
  pip install -r $WORKDIR/requirements.txt
  python -m riffusion.streamlit.playground
}

Launch
