#!/bin/bash

git_helper() {
  echo -n "Enter the git platform: "
  read -r GIT_PLATFORM
  if [ -z "$GIT_PLATFORM" ]; then
    echo "Error: No git platform provided."
    exit 1
  fi
  echo "Git platform: $GIT_PLATFORM"
  echo -n "Enter the git user name: "
  read -r GIT_USER
  if [ -z "$GIT_USER" ]; then
    echo "Error: No git user name provided."
    exit 1
  fi
  echo "Git user: $GIT_USER"
  echo -n "Enter the git repo URL: "
  read -r GIT_REPO
  if [ -z "$GIT_REPO" ]; then
    echo "Error: No git repo URL provided."
    exit 1
  fi
  echo "Git repo URL: $GIT_REPO"
  GIT_URL="https://${GIT_PLATFORM}.com/${GIT_USER}/${GIT_REPO}"
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
