#!/bin/bash

# script to make a virtualenv of a git repository

check_dependencies() {
  local dependencies=("git" "python3" "virtualenv" "zenity")
  for dep in "${dependencies[@]}"; do
    command -v "$dep" &> /dev/null || zenity --error --text "Error: $dep is not installed. Please install it before running this script."
  done
}

repo_chooser() {
  repo_url=$(zenity --entry --title "Git Repo Chooser" --text "Enter the git repo URL:" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$repo_url" ]; then
    zenity --error --text "Error: No repo URL provided."
    exit 1
  fi
  if ! git ls-remote "$repo_url" &>/dev/null; then
    zenity --error --text "Error: Repo not found."
    exit 1
  fi
  repo_name=$(basename "$repo_url" .git)
  echo "Repo selected: $repo_url"
  echo "Repo name: $repo_name"
}

virtualenv_creator() {
  WORK_DIR=$HOME/.virtualenv
  venv_name=$(zenity --entry --title "Virtualenv Name Chooser" --text "Enter the name of the virtualenv:" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$venv_name" ]; then
    zenity --error --text "Error: No virtualenv name provided."
    exit 1
  fi
  virtualenv "$WORK_DIR/$venv_name"
  cd "$WORK_DIR/$venv_name"
  git clone "$repo_url"
  repo_name=$(basename "$repo_url" .git)
  # Check if directory exists, if yes, move files into it, else, create directory and move files
  if [ -d "$repo_name" ]; then
    shopt -s dotglob # include hidden files
    mv -n "$repo_name"/* .
    shopt -u dotglob # reset to default
  else
    mkdir "$repo_name"
    mv "$repo_name"/* "$repo_name"/.??* .
  fi
  rm -rf "$repo_name"
  echo "Virtualenv created: $venv_name"
}

virtualenv_activator() {
  cd "$WORK_DIR/$venv_name" || { zenity --error --text "Error: Virtual environment directory not found."; exit 1; }
  source "bin/activate"
  echo "Virtualenv activated: $venv_name"
  if [ -f "requirements.txt" ]; then
    requirements_file="requirements.txt"
    pip install --upgrade pip
    pip install -r "${requirements_file}"
  else
    zenity --error --text "Error: Requirements file not found."
    exit 1
  fi
  exit 0
}

check_dependencies
repo_chooser
virtualenv_creator
virtualenv_activator
