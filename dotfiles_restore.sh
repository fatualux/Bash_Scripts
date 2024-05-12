#!/bin/bash

git_helper() {
  GIT_PLATFORM=$(zenity --entry --title "Git Platform Chooser" --text "Enter the git platform:" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$GIT_PLATFORM" ]; then
    zenity --error --text "Error: No git platform provided."
    exit 1
  fi
  echo "Git platform: $GIT_PLATFORM"
  
  GIT_USER=$(zenity --entry --title "Git User Chooser" --text "Enter the git user name:" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$GIT_USER" ]; then
    zenity --error --text "Error: No git user name provided."
    exit 1
  fi
  echo "Git user: $GIT_USER"
  GIT_REPO=$(zenity --entry --title "Git Repo Chooser" --text "Enter the git repo URL:" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$GIT_REPO" ]; then
    zenity --error --text "Error: No git repo URL provided."
    exit 1
  fi
  echo "Git repo URL: $GIT_REPO"
  GIT_URL="https://${GIT_PLATFORM}.com/${GIT_USER}/${GIT_REPO}"  # Fixed the typo here
  git clone "$GIT_URL"
  MSG="Successfully cloned repository: $GIT_URL"
  echo "$MSG"
  export GIT_REPO
}

dotfiles_restore() {
  echo "Starting dotfiles restore process..."
  git_helper
  if [ ! -d "$GIT_REPO" ]; then
    echo "Error: Git repository not found."
    exit 1
  fi
  echo "Navigating into the git repository: $GIT_REPO"
  pushd "$GIT_REPO" || exit 1
  FILES=$(git ls-tree --name-only HEAD)
  echo "List of files in the repository: $FILES"
  # replace dotfiles with the ones saved in a git repo
  for file in $FILES; do
    if [[ $file == .* ]]; then
      echo "Copying dotfile: $file to ~/$(basename "$file")"
      cp -r "$file" ~/$(basename "$file")
    fi
  done
  MSG="Successfully restored dotfiles from repository: $GIT_URL"
  echo "$MSG"
  # remove git repo
  popd || exit 1
  echo "Removing git repository: $GIT_REPO"
  rm -rf "$GIT_REPO"
  echo "Dotfiles restore process completed."
}

dotfiles_restore
