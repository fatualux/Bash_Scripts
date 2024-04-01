#!/bin/bash
# DESCRIPTION: This script is used to run git commands with interactive prompts
# DEPENDENCIES: bash git zenity github-cli gitlab-cli wl-clipboard
# USAGE: ./git_helper.sh
# AUTHOR: FZ

T_EMULATOR="alacritty"

PlatformChooser() {
  option=$(zenity --list --title "Choose a platform" --text "Select a platform:" \
  --column "Platform" "Gitlab" "Github")
  if [ -n "$option" ]; then
      echo "Platform selected: $option"
      case $option in
      "Gitlab")
        export PLATFORM="gitlab"
        export CLI="glab"
        ;;
      "Github")
        export PLATFORM="github"
        export CLI="gh"
        ;;
      *)
        echo "No platform selected."
        exit 1
        ;;
      esac
  else
    echo "No platform selected."
    exit 1
  fi
}

UserChooser() {
  option=$(zenity --entry --title "User Chooser" --text "What is your ${PLATFORM} username?" --ok-label="OK" --cancel-label="Cancel")
  echo "Selected GitHub username: $option"
  if [ -n "$option" ]; then
      export GIT_USER=$option
      echo "GitHub username selected: $GIT_USER"
  else
    echo "No GitHub username selected."
    exit 1
  fi
}

RepoNameChooser() {
  option=$(zenity --entry --title "Repo Name Chooser" --text "What is the name of your repo?" --ok-label="OK" --cancel-label="Cancel")
  echo "Selected repo name: $option"
  if [ -n "$option" ]; then
      export REPO_NAME=$option
      echo "Repo name selected: $REPO_NAME"
  else
    echo "No repo name selected."
    exit 1
  fi
}

RepoTypeChooser() {
  option=$(zenity --list --title "Repo Type Chooser" --text "Select a repo type:" \
  --column "Type" "Private" "Public")
  echo "Selected repo type: $option"
  if [ -n "$option" ]; then
      export TYPE=$option
      echo "Repo type selected: $TYPE"
      if [ "$TYPE" == "Private" ]; then
          export O_TYPE="--private"
      elif [ "$TYPE" == "Public" ]; then
          export O_TYPE="--public"
      fi
  else
    echo "No repo type selected."
    exit 1
  fi
}

DirectoryChooser() {
  option=$(zenity --file-selection --title "Choose a directory" --directory)
  echo "Selected directory: $option"
  if [ -n "$option" ]; then
      export WORK_DIR=$option
      cp licenses.json $WORK_DIR
      echo "Directory selected: $WORK_DIR"
      echo "Copying licenses.json to $WORK_DIR"
  else
    echo "No directory selected."
    exit 1
  fi
}

ListActions() {
  option=$(zenity --list --title "Git Helper" --text "Select an action to perform:" \
  --column "Action" "README Generator" "Repo Creator" "Repo Remover" \
  "CLONE" "PR Creator" "Contribute" \
  --hide-header --width=400 --height=400 --ok-label="OK" --cancel-label="Cancel")
  case $option in
  "README Generator")
    READMEGenerator
    ;;
  "Repo Creator")
    RepoCreator
    ;;
  "Repo Remover")
    RepoRemover
    ;;
  "CLONE")
    Clone
    ;;
  "PR Creator")
    PRCreator
    ;;
  "Contribute")
    Contribute
    ;;
  *)
    exit 1
    ;;
  esac
}

ChooseLicense() {
  licenses=$(cat $(dirname "$0")/licenses.json)
  options=$(echo "$licenses" | jq -r '.[].name')
  selected_license=$(zenity --list --title "Choose a license" --text "Select a license:" \
  --column "License" $options)
  echo "Selected license: $selected_license"
  license_url=$(echo "$licenses" | jq -r --arg selected_license "$selected_license" '.[] | select(.name == $selected_license) | .link')
  cd $WORK_DIR && wget "$license_url" -O LICENSE
  license_file=$(basename "$license_url")
  echo "License downloaded: $license_file"
  license_name=$(echo "$licenses" | jq -r --arg selected_license "$selected_license" '.[] | select(.name == $selected_license) | .name')
  license_badge=$(echo "$licenses" | jq -r --arg selected_license "$selected_license" '.[] | select(.name == $selected_license) | .badge')
  echo "" >> $WORK_DIR/README.md
  echo "## LICENSE" >> $WORK_DIR/README.md
  echo "" >> $WORK_DIR/README.md
  echo "[![License]$license_badge" >> $WORK_DIR/README.md
  echo "" >> $WORK_DIR/README.md
  echo "This project is licensed under the $license_name license." >> $WORK_DIR/README.md
  echo "See LICENSE file for more details." >> $WORK_DIR/README.md
  if [[ $selected_license == "GPLv2" || $selected_license == "GPLv3" || $selected_license == "LGPLv3" || $selected_license == "AGPLv3" ]]; then
    gnu_version=$(zenity --list --title "Choose a version" --text "Select a version:" \
    --column "Version" "V1" "V2" "V3")
    echo "Selected GNU version: $gnu_version"
  fi
}

READMEGenerator() {
  DirectoryChooser
  elements=("Title" "Description" "Installation" "Usage" "Dependencies" "Contributors" "Links" "Acknowledgments" "License")
  for element in "${elements[@]}"; do
    choice=$(zenity --question --text="Do you want to include $element?" --ok-label="Yes" --cancel-label="No" --width=300)
    case $? in
      0) # Yes
        case $element in
          "Title")
            TITLE=$(zenity --entry --title "README Generator" --text "What is the title of your project?" --width=300)
            mu_TITLE="# $TITLE"
            echo "$mu_TITLE" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Description")
            DESCRIPTION=$(zenity --entry --title "README Generator" --text "Write a short description of your project:" --width=300)
            mu_DESCRIPTION="### $DESCRIPTION"
            echo "$mu_DESCRIPTION" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Installation")
            echo "## INSTALLATION" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            INSTALLATION=$(zenity --entry --title "README Generator" --text "Write the installation instructions:" --width=300)
            echo "\`\`\`" >> $WORK_DIR/README.md
            echo "$INSTALLATION" >> $WORK_DIR/README.md
            echo "\`\`\`" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Usage")
            echo "## USAGE" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            USAGE=$(zenity --entry --title "README Generator" --text "Write the usage instructions:" --width=300)
            echo "\`\`\`" >> $WORK_DIR/README.md
            echo "$USAGE" >> $WORK_DIR/README.md
            echo "\`\`\`" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Dependencies")
            echo "## DEPENDENCIES" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            DEPENDENCIES=$(zenity --entry --title "README Generator" --text "List the dependencies of your project (separated by spaces):" --width=300)
            echo "- $(echo $DEPENDENCIES | sed 's/ /\n- /g')" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Contributors")
            echo "## CONTRIBUTORS" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            CONTRIBUTORS=$(zenity --entry --title "README Generator" --text "List the contributors of your project (separated by spaces):" --width=300)
            echo "- $(echo $CONTRIBUTORS | sed 's/ /\n- /g')" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Links")
            echo "## LINKS" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            LINKS=$(zenity --entry --title "README Generator" --text "Add relevant links for your project (separated by spaces):" --width=300)
            LINKS_LIST=($LINKS)
            echo "- ${LINKS_LIST[*]}" | sed 's/ /\n- /g' >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "Acknowledgments")
            echo "## ACKNOWLEDGMENTS" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ACKNOWLEDGMENTS=$(zenity --entry --title "README Generator" --text "Add acknowledgments for your project:" --width=300)
            echo "$ACKNOWLEDGMENTS" >> $WORK_DIR/README.md
            echo "" >> $WORK_DIR/README.md
            ;;
          "License")
            ChooseLicense
            ;;
        esac
        ;;
      1) # No
        continue
        ;;
      -1)
        exit 1
        ;;
    esac
  done
}

RepoCreator() {
  PlatformChooser
  UserChooser
  RepoTypeChooser
  RepoNameChooser
  echo "git@${PLATFORM}.com:$GIT_USER/$REPO_NAME" | wl-copy
  echo "New repository address copied to clipboard." && sleep 1
  $T_EMULATOR -e bash -c "$CLI repo create '$REPO_NAME'" $O_TYPE
  SUCCESS="Repository created: $REPO_NAME"
  FAIL="Failed to create repository: $REPO_NAME"
  if [ $? -eq 0 ]; then
    zenity --info --text="$SUCCESS"
  else
    zenity --error --text="$FAIL"
  fi
}

RepoRemover() {
  PlatformChooser
  RepoNameChooser
  $T_EMULATOR -e bash -c "$CLI repo delete '$REPO_NAME'"
  SUCCESS="Repository deleted: $REPO_NAME"
  FAIL="Failed to delete repository: $REPO_NAME"
  if [ $? -eq 0 ]; then
    zenity --info --text="$SUCCESS"
  else
    zenity --error --text="$FAIL"
  fi
}

Clone() {
  DirectoryChooser
  cd $WORK_DIR
  REPO_NAME=$(zenity --entry --title "Clone" --text "What is the name of the repository you want to clone?" --ok-label="OK" --cancel-label="Cancel")
  if [ -n "$REPO_NAME" ]; then
      git clone "$REPO_NAME"
      echo "Repo cloned: $REPO_NAME"
  else
      echo "No repository name provided."
      exit 1
  fi
}

PRCreator() {
  UserChooser
  PlatformChooser
  RepoNameChooser
  DirectoryChooser
  cd $WORK_DIR
  PR_TITLE=$(zenity --entry --title "PR Creator" --text "What is the title of your pull request?" --ok-label="OK" --cancel-label="Cancel")
  PR_BODY=$(zenity --entry --title "PR Creator" --text "What is the description of your pull request?" --ok-label="OK" --cancel-label="Cancel")
  BRANCH=$(zenity --entry --title "PR Creator" --text "What is the name of your branch?" --ok-label="OK" --cancel-label="Cancel")
  BASE=$(zenity --entry --title "PR Creator" --text "What is the name of your base branch?" --ok-label="OK" --cancel-label="Cancel")
  $CLI pr create --base "$BASE" --head "$GIT_USER:$BRANCH" --title "$PR_TITLE" --body "$PR_BODY"
  echo "PR created!"
}

Contribute() {
  UserChooser
  DirectoryChooser
  cd $WORK_DIR
  OFFICIAL_REPO_NAME=$(zenity --entry --title "Contribute" --text "What is the name of the repository you want to contribute to?" --ok-label="OK" --cancel-label="Cancel")
  git remote add origin $OFFICIAL_REPO_NAME
  FORK=$(zenity --entry --title "Contribute" --text "What is the name of your fork?" --ok-label="OK" --cancel-label="Cancel")
  git remote add fork $FORK
  BRANCH=$(zenity --entry --title "PR Creator" --text "What is the name of your branch?" --ok-label="OK" --cancel-label="Cancel")
  git checkout -b $BRANCH
  COMMIT=$(zenity --entry --title "Contribute" --text "What is the commit message?" --ok-label="OK" --cancel-label="Cancel")
  git add .
  git commit -m $COMMIT
  git push fork $BRANCH
}

ListActions
