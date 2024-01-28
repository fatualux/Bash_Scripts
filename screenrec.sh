#!/bin/bash

# Set the output file name and format
rec_date=$(date +%Y-%m-%d_%H-%M-%S)
output_file="$rec_date.mp4"
flag_file="recording.flag"
pid_file="wf-recorder.pid"

# Function to start the recording
start_recording() {
    if [ -e "$flag_file" ]; then
        echo "Recording is already in progress. Press Ctrl+C to stop."
    else
        touch "$flag_file"
        echo "Recording started. Press Ctrl+C to stop."
        wf-recorder -f "$output_file" -x yuv420p &
        echo $! > "$pid_file"  # Save the PID of the wf-recorder process
    fi
}

# Function to stop the recording
stop_recording() {
    if [ -e "$pid_file" ]; then
        echo "Stopping recording..."
        kill $(cat "$pid_file")  # Terminate the wf-recorder process using its PID
        rm "$pid_file"
        rm "$flag_file"
        echo "Recording stopped. Video saved to $output_file"
    else
        echo "No recording in progress."
    fi
}

# Check if arguments are provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [start|stop]"
    exit 1
fi

# Process command line arguments
case "$1" in
    "start")
        start_recording
        ;;
    "stop")
        stop_recording
        ;;
    *)
        echo "Invalid argument. Usage: $0 [start|stop]"
        exit 1
        ;;
esac
