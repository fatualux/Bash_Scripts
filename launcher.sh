#!/bin/bash

# Dependencies:
# - jq: JSON processor (https://stedolan.github.io/jq/)
# - fzf: Fuzzy finder (https://github.com/junegunn/fzf)

# Function to check if dependencies are installed
check_dependencies() {
    local dependencies=("jq" "fzf")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" > /dev/null; then
            echo "Error: $dep is not installed. Please install it before running this script."
            exit 1
        fi
    done
}

# Check if dependencies are installed
check_dependencies

# Get the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read apps.json using jq
apps=$(jq -c '.' "$DIR/apps.json")

# Function to launch an app
launch_app() {
    app=$1
    path=$(jq -r '.path' <<< "$app")
    command=$(jq -r '.command' <<< "$app")
    full_path="$DIR/$path"

    if [ -z "$path" ]; then
        echo "Error: Path not found in app definition - $app"
        return
    fi

    if [ -z "$command" ]; then
        echo "Error: Command not found in app definition - $app"
        return
    fi

    execute_command "$command" "$full_path"
}

# Function to execute the command
execute_command() {
    command=$1
    full_path=$2

    if [ "$path" == "comfyUI" ]; then
        $command alacritty exec sh "$full_path" &
    elif [ -d "$full_path" ] && [ ! -z "$(ls -A "$full_path")" ]; then
        $command "$full_path" &
    elif [ -f "$full_path" ]; then
        $command "$full_path" &
    else
        echo "Error: Invalid path or directory is empty - $full_path"
    fi
}

# Main loop using fzf for app selection
while true; do
    choice=$(jq -r '.[] | .name' <<< "$apps" | fzf --header="App Drawer" --select-1 --exit-0)

    if [ -n "$choice" ]; then
        app=$(jq -c --arg choice "$choice" '.[] | select(.name == $choice)' <<< "$apps")
        launch_app "$app" &
    else
        echo "Operation canceled."
        exit
    fi
done
