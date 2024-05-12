export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.11/site-packages/nvidia/cudnn/lib/:$WORKDIR/lib/python3.11/site-packages/nvidia/cublas/lib/

WORKDIR=$HOME/.virtualenv/faster-whisper

source $WORKDIR/bin/activate

# Functions
ListModels() {
  model=$(zenity --list --text "Select which model to use for operation:" \
    --column "Models" "TINY" "BASE" "SMALL" "MEDIUM" "LARGE" \
    --width=750 --height=460 --hide-header)
  case $model in
    "TINY")
      export MODEL="tiny"
      ;;
    "BASE")
      export MODEL="base"
      ;;
    "SMALL")
      export MODEL="small"
      ;;
    "MEDIUM")
      export MODEL="medium"
      ;;
    "LARGE")
      export MODEL="large-v2"
      ;;
  esac
}

ListDevices() {
  python -m sounddevice
  echo " "
  read -p "Choose an audio device please: " DEVICE
}

# Capture the output and send it to wl-copy while also printing to the terminal
CaptureAndSendToClipboard() {
  whisper-ctranslate2 --live_transcribe=true --language it --live_input_device $DEVICE --device cuda --model_dir $WORKDIR/models --model "$MODEL" |
  while read -r line; do
    echo "$line"  # Print the transcribed text to the terminal
    echo "$line" | wl-copy
  done
}

# Main script
ListModels
ListDevices

CaptureAndSendToClipboard
