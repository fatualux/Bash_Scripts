#!/bin/bash

# Configuration
TITLE_WORD_COUNT=3
CLIPBOARD_FILE="$HOME/.clipboard.txt"
MAX_FILE_SIZE=$((10 * 1024 * 1024))  # 10 MB
ALLOWED_EXTENSIONS=("txt" "md")

# Function to check for required commands
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display error messages
show_error() {
    local message="$1"
    if check_command zenity; then
        zenity --error --text="$message" --title="Error"
    else
        echo "Error: $message"
    fi
}

# Function to display help message
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --copy         Copy selected files to clipboard (only allowed extensions)"
    echo "  --force-copy   Copy selected files to clipboard (ignoring extensions)"
    echo "  --recall       Recall clips from clipboard"
    echo "  --clear N      Clear the last N lines from clipboard"
    echo "  --purge        Delete all lines from clipboard"
    echo "  --help         Display this help message"
    echo ""
    echo "Clips are stored in $CLIPBOARD_FILE"
}

# Check if zenity is installed
if ! check_command zenity; then
    show_error "Zenity is not installed. Please install zenity and try again."
    exit 1
fi

# Check if xclip or wl-clipboard is installed
if check_command xclip; then
    CLIP_CMD="xclip -selection clipboard"
elif check_command wl-copy; then
    CLIP_CMD="wl-copy"
else
    show_error "Neither xclip nor wl-clipboard is installed. Please install one of them and try again."
    exit 1
fi

# Function to validate file extension
validate_extension() {
    local file="$1"
    local ext="${file##*.}"
    for valid_ext in "${ALLOWED_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$valid_ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to handle the --copy operation
copy_to_clipboard() {
    local force="$1"
    local files
    files=$(zenity --file-selection --multiple --title="Select Files to Copy")
    if [[ -z "$files" ]]; then
        show_error "No files selected."
        exit 1
    fi

    IFS='|' read -ra file_array <<< "$files"

    for file in "${file_array[@]}"; do
        if [[ "$force" != "force" ]] && ! validate_extension "$file"; then
            show_error "Invalid file extension for file: $file"
            exit 1
        fi

        if [[ ! -f "$file" ]]; then
            show_error "File not found: $file"
            exit 1
        fi

        local file_size
        file_size=$(stat -c%s "$file")
        if (( file_size > MAX_FILE_SIZE )); then
            show_error "File is too large: $file"
            exit 1
        fi

        local date_time
        date_time=$(date '+%Y-%m-%d %H:%M:%S')
        local content
        content=$(cat "$file")

        echo "$content" | $CLIP_CMD
        echo "[$date_time] $content" >> "$CLIPBOARD_FILE"
    done
}

# Function to handle the --recall operation
recall_from_clipboard() {
    if [[ ! -f "$CLIPBOARD_FILE" ]]; then
        show_error "Clipboard file not found."
        exit 1
    fi

    local lines
    lines=$(awk -v count="$TITLE_WORD_COUNT" '{for (i=1; i<=count; i++) printf $i " "; print "..."}' "$CLIPBOARD_FILE" | awk '{print NR ": " $0}')

    local selection
    selection=$(echo "$lines" | zenity --list --column="Lines" --title="Select Clip")

    if [[ -z "$selection" ]]; then
        show_error "No clip selected."
        exit 1
    fi

    local line_number
    line_number=$(echo "$selection" | cut -d: -f1)

    local content
    content=$(sed "${line_number}q;d" "$CLIPBOARD_FILE")
    echo "$content" | $CLIP_CMD
}

# Function to clear the last N lines from the clipboard file
clear_lines() {
    local num_lines="$1"
    if ! [[ "$num_lines" =~ ^[0-9]+$ ]]; then
        show_error "Invalid number of lines: $num_lines"
        exit 1
    fi

    if [[ ! -f "$CLIPBOARD_FILE" ]]; then
        show_error "Clipboard file not found."
        exit 1
    fi

    local total_lines
    total_lines=$(wc -l < "$CLIPBOARD_FILE")

    if (( num_lines > total_lines )); then
        show_error "Number of lines to clear exceeds total lines in clipboard file."
        exit 1
    fi

    head -n -"$num_lines" "$CLIPBOARD_FILE" > "$CLIPBOARD_FILE.tmp" && mv "$CLIPBOARD_FILE.tmp" "$CLIPBOARD_FILE"
}

# Function to purge all lines from the clipboard file
purge_clipboard() {
    if [[ -f "$CLIPBOARD_FILE" ]]; then
        > "$CLIPBOARD_FILE"
    fi
}

# Main logic
case "$1" in
    --copy)
        copy_to_clipboard "normal"
        ;;
    --force-copy)
        copy_to_clipboard "force"
        ;;
    --recall)
        recall_from_clipboard
        ;;
    --clear)
        clear_lines "$2"
        ;;
    --purge)
        purge_clipboard
        ;;
    --help)
        show_help
        ;;
    *)
        show_error "Invalid option. Use --help to see available options."
        exit 1
        ;;
esac
