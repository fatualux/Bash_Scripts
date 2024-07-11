#!/bin/bash

TITLE_WORD_COUNT=3
CLIPBOARD_FILE="$HOME/.clipboard.txt"
MAX_FILE_SIZE=$((10 * 1024 * 1024))  # 10 MB
ALLOWED_EXTENSIONS=("txt" "md")

check_command() {
    command -v "$1" >/dev/null 2>&1
}

show_error() {
    local message="$1"
    if check_command zenity; then
        zenity --error --text="$message" --title="Error"
    else
        echo "Error: $message"
    fi
}

show_help() {
    local message="Usage: $0 [OPTION]\n\n"
    message+="Options:\n"
    message+="  --copy         Copy selected files to clipboard (only allowed extensions)\n"
    message+="  --force-copy   Copy selected files to clipboard (ignoring extensions)\n"
    message+="  --recall       Recall clips from clipboard\n"
    message+="  --clear N      Clear the last N lines from clipboard\n"
    message+="  --purge        Delete all lines from clipboard\n"
    message+="  --help         Display this help message\n\n"
    message+="Clips are stored in $CLIPBOARD_FILE"
    zenity --info --text="$message" --title="Help"
}

if ! check_command zenity; then
    show_error "Zenity is not installed. Please install zenity and try again."
    exit 1
fi

if check_command xclip; then
    CLIP_CMD="xclip -selection clipboard"
elif check_command wl-copy; then
    CLIP_CMD="wl-copy"
else
    show_error "Neither xclip nor wl-clipboard is installed. Please install one of them and try again."
    exit 1
fi

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
        {
            echo "[$date_time]"
            echo "$content"
            echo "---END OF CLIP---"
        } >> "$CLIPBOARD_FILE"
    done
}

recall_from_clipboard() {
    if [[ ! -f "$CLIPBOARD_FILE" ]]; then
        show_error "Clipboard file not found."
        exit 1
    fi

    local lines
    lines=$(grep -n '^\[.*\]' "$CLIPBOARD_FILE" | awk -v count="$TITLE_WORD_COUNT" '{for (i=2; i<=count+1; i++) printf $i " "; print "..."}')

    local selection
    selection=$(echo "$lines" | zenity --list --column="Clips" --title="Select Clip")

    if [[ -z "$selection" ]]; then
        show_error "No clip selected."
        exit 1
    fi

    local line_number
    line_number=$(echo "$selection" | cut -d: -f1)

    local content
    content=$(sed -n "${line_number},/---END OF CLIP---/p" "$CLIPBOARD_FILE" | sed '/---END OF CLIP---/d')
    echo "$content" | $CLIP_CMD
}

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
    total_lines=$(grep -c '^\[.*\]' "$CLIPBOARD_FILE")

    if (( num_lines > total_lines )); then
        show_error "Number of lines to clear exceeds total lines in clipboard file."
        exit 1
    fi

    sed -i "1,${num_lines}d" "$CLIPBOARD_FILE"
}

purge_clipboard() {
    if [[ -f "$CLIPBOARD_FILE" ]]; then
        > "$CLIPBOARD_FILE"
    fi
}

if [[ $# -eq 0 ]]; then
    action=$(zenity --list --radiolist --column "Select" --column "Action" TRUE "copy" FALSE "force-copy" FALSE "recall" FALSE "clear" FALSE "purge" FALSE "help" --title "Clipboard Manager")
    case "$action" in
        "copy")
            copy_to_clipboard "normal"
            ;;
        "force-copy")
            copy_to_clipboard "force"
            ;;
        "recall")
            recall_from_clipboard
            ;;
        "clear")
            num_lines=$(zenity --entry --title "Clear Clipboard" --text "Enter the number of clips to clear:")
            clear_lines "$num_lines"
            ;;
        "purge")
            purge_clipboard
            ;;
        "help")
            show_help
            ;;
        *)
            show_error "Invalid option."
            exit 1
            ;;
    esac
else
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
fi
