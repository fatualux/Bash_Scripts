#!/bin/bash

# Check dependencies
check_dependencies() {
    if ! command -v yad &> /dev/null; then
        echo "Error: yad is not installed. Please install yad to proceed."
        exit 1
    fi
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg is not installed. Please install ffmpeg to proceed."
        exit 1
    fi
}

# Function to split audio file based on silence detection
split_audio() {
    # Set initial start time
    start_time="00:00:00"

    # Set output directory for split tracks
    output_dir=$(dirname "$1")/SPLIT

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Set output file name suffix
    suffix=0

    # Extract filename and extension
    filename=$(basename -- "$1")
    ext="${filename##*.}"
    filename="${filename%.*}"

    # Set the command for ffmpeg
    initcmd="ffmpeg -nostdin -hide_banner -i $1 -af silencedetect=d=0.1 -f null - 2>&1 | awk '/silence_end/ {print \$4,\$5}' | awk '{S=\$2;printf \"%d:%02d:%02d\\n\",S/(60*60),S%(60*60)/60,S%60}' | sed '1d'"

    # Read the silence intervals from the provided file
    while read -r end_time; do
        echo "Processing segment $((suffix+1))"
        echo "Start time: $start_time, End time: $end_time"
        ffmpeg -nostdin -hide_banner -i "$1" -ss "$start_time" -to "$end_time" -c copy "$output_dir/${filename}_${suffix}.${ext}"
        ((suffix++))
        start_time=$end_time
    done < <(eval "$initcmd")

    echo "Splitting complete. Split tracks saved in $output_dir"
}

# Check dependencies
check_dependencies

# Display file chooser dialog using yad
selected_file=$(yad --file --title="Choose Audio File")

# Check if user canceled the selection
if [ $? -ne 0 ]; then
    echo "File selection canceled."
    exit 0
fi

# Split the selected audio file based on silence detection
split_audio "$selected_file"
