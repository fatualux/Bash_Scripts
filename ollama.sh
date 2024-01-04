#!/bin/bash
# This script depends on bash python3 fzf ollama ollama-ui

check_dependencies() {
  local dependencies=("bash" "python3" "fzf" "ollama")
  local missing=()

  for dep in "${dependencies[@]}"; do
    command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "All dependencies satisfied."
  else
    echo "The following dependencies are missing: ${missing[*]}"
    read -p "Press OK to exit." -n 1 -r
    echo
    exit 1
  fi
}

check_dependencies

LOAD_DIR="$HOME/Documents/Projects/ollama-ui/model_chooser/"
SERVER_DIR="$HOME/Documents/Projects/ollama-ui/"
PORT="${1-8000}"

load() {
  cd "$LOAD_DIR" || exit
  source ./bin/activate || exit
  pip install -r requirements.txt || exit
  python3 app.py
}

serve() {
  cd "$SERVER_DIR" || exit
  # host local webserver and specify the index.html file to serve
  python3 -m http.server --bind 127.0.0.1 "$PORT"
}

choose_action() {
  clear
  ACTION=$(echo -e "Load model\nServe" | fzf --height 100% --reverse --prompt="Choose action: " --header="Ollama")
  case $ACTION in
    "Load model")
      load
      ;;
    "Serve")
      serve
      ;;
    *)
      echo "Invalid action"
      ;;
  esac
}

while true; do
  choose_action
done
