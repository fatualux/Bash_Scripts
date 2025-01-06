#!/bin/bash

check_dependencies() {
  local dependencies=("bash" "python3" "fzf")
  local missing=()

  for dep in "${dependencies[@]}"; do
    command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "All dependencies satisfied."
  else
    echo "The following dependencies are missing: ${missing[*]}"
    read -p "Press any key to exit." -n 1 -r
    echo
    exit 1
  fi
}

cleanup() {
  # Terminate ollama process if it's running
  if pgrep -x "ollama" >/dev/null; then
    echo "Terminating ollama process..."
    pkill -x "ollama"
  fi
}

trap cleanup EXIT

check_dependencies

WORKDIR="$HOME/Documents/Github/ollama-webui/backend/"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKDIR/lib/python3.12/site-packages/
PORT="${1-8000}"

webui() {
  cd "$WORKDIR" || exit
  source bin/activate
  ollama serve | bash start.sh
}

webui
