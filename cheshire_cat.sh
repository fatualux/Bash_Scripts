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
  if docker compose up -d; then
    echo "Docker containers started successfully."
  else
    echo "Failed to start Docker containers."
    exit 1
  fi
}

stop_containers() {
  echo "Changing directory to $WORKDIR"
  cd "$WORKDIR" || { echo "Failed to change directory to $WORKDIR"; exit 1; }
  
  echo "Stopping Docker containers"
  if docker compose down; then
    echo "Docker containers stopped successfully."
  else
    echo "Failed to stop Docker containers."
    exit 1
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
      total_progress=200
      for (( i=0; i<=total_progress; i++ )); do
        sleep 0.1  # Simulate some work being done
        ProgressBar "$i" "$total_progress"
      done
      echo "The Cat is now running!"
      sleep 5
      ;;
    1)
      stop_containers
      ;;
    *)
      echo "Invalid selection."
      ;;
  esac
}


print_messages() {
  echo "Connect to the Cat's IP address and see the messages!"
  echo ""
  echo "http://localhost:1865/admin"
}


ProgressBar() {
  local current="$1"
  local total="$2"
  local bar_size=40
  local bar_char_done="#"
  local bar_char_todo="-"
  local bar_percentage_scale=2
  local percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total" )
  local done=$(bc <<< "scale=0; $bar_size * $percent / 100" )
  local todo=$(( bar_size - done ))
  local done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
  local todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")
  echo -ne "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%"
  if [ "$total" -eq "$current" ]; then
    echo -e "\nDONE"
  fi
}

echo "Checking dependencies"
check_dependencies

echo "Prompting action"
prompt_action

print_messages

