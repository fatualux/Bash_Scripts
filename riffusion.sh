#!/bin/sh

WORKDIR=$HOME/.virtualenv/riffusion/

Launch() {
  cd $WORKDIR
  source $WORKDIR/bin/activate
  python -m riffusion.streamlit.playground
}

Launch
