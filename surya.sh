#!/bin/sh

WORKDIR=$HOME/.virtualenv/surya/

Launch() {
  cd $WORKDIR
  source $WORKDIR/bin/activate && pip install --upgrade pip
  pip install -r $WORKDIR/requirements.txt && surya_gui
}

Launch
