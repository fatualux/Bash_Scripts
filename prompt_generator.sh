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

# Function to prompt the user to select multiple choices
select_multiple_choices() {
    local prompt="$1"
    local choices_list="$2"

    # Use yad to display the list of choices
    options=$(echo "$choices_list" | tr ',' '\n' | yad --list --column="$prompt" --separator='' --height=300 --width=300 --multiple)

    # Check if at least one option was selected
    if [ -n "$options" ]; then
        # Add a comma and a space after every option
        formatted_options=$(echo "$options" | sed 's/$/, /' | tr -d '\n')
        formatted_options="${formatted_options%, }"  # Remove the trailing comma and space
        echo "Selected $prompt options: $formatted_options"
        export "${prompt^^}"="$formatted_options"  # Convert prompt to uppercase and export the variable
    else
        echo "No $prompt options selected. Exiting..."
        exit 1
    fi
}

# Updated functions to use select_multiple_choices

choose_image() {
    image_list=$(jq -r '.[] | select(.name == "Image") | .choice' "$DIR/prompt.json")
    select_multiple_choices "image" "$image_list"
}

choose_style() {
    style_list=$(jq -r '.[] | select(.name == "Style") | .choice' "$DIR/prompt.json")
    select_multiple_choices "style" "$style_list"
}

choose_light() {
    light_list=$(jq -r '.[] | select(.name == "Light") | .choice' "$DIR/prompt.json")
    select_multiple_choices "light" "$light_list"
}

add_custom() {
    custom_list=$(jq -r '.[] | select(.name == "Custom") | .choice' "$DIR/prompt.json")
    select_multiple_choices "custom" "$custom_list"
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
