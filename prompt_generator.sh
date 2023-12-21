#!/bin/bash

# Dependencies:
# - jq: JSON processor (https://stedolan.github.io/jq/)
# - yad: GUI dialog (https://github.com/v1cont/yad)

# Function to check if dependencies are installed
check_dependencies() {
    local dependencies=("jq" "yad")
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
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read JSON_FILE.json using jq
JSON_FILE=$(jq -c '.' "$DIR/prompt.json")

WORKDIR=$HOME/.virtualenv/PromptGenerator

input_subject() {
    subject=$(yad --entry --title="Input Subject" --text="What is the subject of your prompt?")
    export SUBJECT=$subject
}

input_action() {
    action=$(yad --entry --title="Input Action" --text="What is $SUBJECT doing?")
    export ACTION=$action
}

# Use yad to get the type of image from the .json file
choose_image() {
    image_list=$(jq -r '.[] | select(.name == "Image") | .choice' "$DIR/prompt.json")

    # Use yad to display the list of images vertically
    option=$(echo "$image_list" | tr ',' '\n' | yad --list --column="Image" --separator='' --height=300 --width=300)

    # Check if a valid option was selected
    if [ -n "$option" ]; then
        echo "Selected image option: $option"
        export IMAGE=$option
    else
        echo "No option selected. Exiting..."
        exit 1
    fi
}

choose_style() {
    style_list=$(jq -r '.[] | select(.name == "Style") | .choice' "$DIR/prompt.json")
    option=$(echo "$style_list" | tr ',' '\n' | yad --list --column="Style" --separator='' --height=300 --width=300)

    if [ -n "$option" ]; then
        echo "Selected style option: $option"
        export STYLE="$option style"
    else
        echo "No option selected. Exiting..."
        exit 1
    fi
}

choose_light() {
    light_list=$(jq -r '.[] | select(.name == "Light") | .choice' "$DIR/prompt.json")
    option=$(echo "$light_list" | tr ',' '\n' | yad --list --column="Light" --separator='' --height=300 --width=300)

    if [ -n "$option" ]; then
        echo "Selected light option: $option"
        export LIGHT=$option
    else
        echo "No option selected. Exiting..."
        exit 1
    fi
}

add_custom() {
    custom_list=$(jq -r '.[] | select(.name == "Custom") | .choice' "$DIR/prompt.json")
    options=$(echo "$custom_list" | tr ',' '\n' | yad --list --column="Custom" --separator='' --height=300 --width=300)

    # Check if at least one option was selected
    if [ -n "$options" ]; then
        echo "Selected custom options: $options"

        # Store the selected options in an array
        IFS=$'\n' read -r -a custom_array <<< "$options"

        # Join the array elements into a string
        CUSTOM=$(IFS=, ; echo "${custom_array[*]}")

        # Example of using the concatenated variable
        export CUSTOM
    else
        echo "No options selected. Exiting..."
        exit 1
    fi
}

launch_generator() {
    ACTIVATE_SCRIPT="$WORKDIR/bin/activate"

    # Check if the activation script exists
    if [ -e "$ACTIVATE_SCRIPT" ]; then
        # Execute the activation script in the current shell session
        cd "$WORKDIR" && source "$ACTIVATE_SCRIPT"

        # Construct the prompt and export it
        export PROMPT="$IMAGE of $SUBJECT $ACTION, $STYLE, $LIGHT, $CUSTOM"

        # Execute the streamlit run command
        streamlit run "$WORKDIR/app.py"
    else
        echo "Error: Activation script not found. Exiting..."
        exit 1
    fi
}

paste_to_clipboard() {
    # Construct the prompt
    PROMPT="$IMAGE of $SUBJECT $ACTION, $STYLE, $LIGHT, $CUSTOM"

    # Check if wl-copy is available
    if command -v wl-copy >/dev/null 2>&1; then
        # Copy the prompt to the clipboard using wl-copy
        wl-copy < <(echo "$PROMPT")
        echo "Prompt copied to clipboard."
    else
        echo "Error: wl-copy not found. Please install it to copy the prompt to the clipboard."
    fi
}

# Call the input functions
input_subject
input_action
choose_image
choose_style
choose_light
add_custom

# Call the paste_to_clipboard function
paste_to_clipboard

# Call the launch_generator function
launch_generator
