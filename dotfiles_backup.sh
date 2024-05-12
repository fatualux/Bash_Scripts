#!/bin/bash

check_dependencies() {
  local dependencies=("git" "zenity")

  for dep in "${dependencies[@]}"; do
    command -v "$dep" &> /dev/null || display_error "Error: $dep is not installed. Please install it before running this script."
  done
}

# generate a list of files to backup
select_files() {
  # retrieve all previously committed files
  FILES=$(git ls-files)
  zenity --list --title "Select Files" --text "Select files to backup:" --multiple --column "Select" --column "File" $FILES
  if [ -z "$FILES" ]; then
    display_error "Error: No files selected."
  fi
  zenity --question --title "Add Other Files" --text "Do you want to add other files?" --ok-label="Yes" --cancel-label="No"
  if [ $? -eq 0 ]; then
    FILES="$FILES $(zenity --list --title "Select Files" --text "Select files to backup:" --multiple --column "Select" --column "File" $(git ls-files))"
  fi
  echo $FILES > .dotfiles.txt
}

git_helper() {
  FILES=$(cat .dotfiles.txt)
  git pull
  git add $FILES
  COMMIT_MESSAGE=$(zenity --entry --title "Commit Message" --text "What is the commit message?" --ok-label="OK" --cancel-label="Cancel")
  if [ -z "$COMMIT_MESSAGE" ]; then
    display_error "Error: No commit message selected."
  fi
  git commit -m "$COMMIT_MESSAGE"
  BRANCH=$(git branch -a | fzf | sed 's/.* //')
  if [ -z "$BRANCH" ]; then
    display_error "Error: No branch selected."
  fi
  git push origin $BRANCH
  echo "Backup created successfully!"
}

display_error() {
  zenity --error --text="$1"
  exit 1
}

check_dependencies
select_files
git_helper
