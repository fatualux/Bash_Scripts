#!/bin/bash

WORKDIR="$HOME/Documents/Projects/ollama-cat"

check_dependencies() {
  if ! command -v yad &> /dev/null; then
    echo "Yad could not be found. Please install it and try again."
    exit 1
  else
    echo "Yad is installed."
  fi
}

start_containers() {
  echo "Changing directory to $WORKDIR"
  cd "$WORKDIR" || { echo "Failed to change directory to $WORKDIR"; exit 1; }
  echo "Starting Docker containers"
  docker compose up -d
  if [ $? -eq 0 ]; then
    echo "Docker containers started successfully."
  else
    echo "Failed to start Docker containers."
  fi
}

stop_containers() {
  echo "Changing directory to $WORKDIR"
  cd "$WORKDIR" || { echo "Failed to change directory to $WORKDIR"; exit 1; }
  echo "Stopping Docker containers"
  docker compose down
  if [ $? -eq 0 ]; then
    echo "Docker containers stopped successfully."
  else
    echo "Failed to stop Docker containers."
  fi
}

prompt_action() {
  echo "Prompting user for action"
  ACTION=$(yad --width=300 --height=100 --title="Cheshire Cat" --text="Do you want to start or stop the containers?" --button=Start:0 --button=Stop:1)
  YAD_EXIT_CODE=$?
  echo "User selected action $ACTION with exit code $YAD_EXIT_CODE"
  case $YAD_EXIT_CODE in
    0)
      start_containers
      ;;
    1)
      stop_containers
      ;;
    *)
      echo "Invalid selection."
      ;;
  esac
}

echo "Checking dependencies"
check_dependencies
echo "Prompting action"
prompt_action
