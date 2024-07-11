#!/bin/bash

TITLE_WORD_COUNT=3
CLIPBOARD_DIR="$HOME/.clipboard"
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
    message+="  --copy           Copy selected files to clipboard (only allowed extensions)\n"
    message+="  --force-copy     Copy selected files to clipboard (ignoring extensions)\n"
    message+="  --recall         Recall clips from clipboard\n"
    message+="  --clear          Clear selected clips from clipboard\n"
    message+="  --purge          Delete all lines from clipboard\n"
    message+="  --new-clip       Add a new clip from input dialog\n"
    message+="  --help           Display this help message\n\n"
    message+="Clips are stored in $CLIPBOARD_DIR"

    if [[ -t 1 ]]; then
        # If standard output is a terminal, show help in the shell
        echo -e "$message"
    else
        # Otherwise, use Zenity
        zenity --info --text="$message" --title="Help"
    fi
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

    mkdir -p "$CLIPBOARD_DIR"

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
        date_time=$(date '+%Y-%m-%d_%H-%M-%S')
        local first_word
        first_word=$(basename "$file" | awk '{print $1}')

        local content
        content=$(cat "$file")

        local clip_file
        clip_file="$CLIPBOARD_DIR/${date_time}-${first_word}.txt"
        {
            echo "$content"
        } > "$clip_file"
    done
}

recall_from_clipboard() {
  local files
  files=$(zenity --title="Select clip to Recall" --file-selection --multiple --filename=$CLIPBOARD_DIR/)
  if [[ -z "$files" ]]; then
    show_error "No files selected."
    exit 1
  fi
  cat $files | $CLIP_CMD
}

clear_clips() {
  local files
  files=$(zenity --title="Select clip to clear" --file-selection --multiple --filename=$CLIPBOARD_DIR/)
  if [[ -z "$files" ]]; then
    show_error "No files selected."
    exit 1
  fi
  rm $files
}

purge_clipboard() {
    if [[ -d "$CLIPBOARD_DIR" ]]; then
        # Remove all files in the clipboard directory
        rm -f "$CLIPBOARD_DIR"/*.txt
    else
        show_error "Clipboard directory not found."
        exit 1
    fi
}

new_clip() {
    local new_content
    new_content=$(zenity --entry --title "New Clip" --text "Enter the content for the new clip:")
    if [[ -z "$new_content" ]]; then
        show_error "No content entered for new clip."
        exit 1
    fi

    mkdir -p "$CLIPBOARD_DIR"

    local date_time
    date_time=$(date '+%Y-%m-%d_%H-%M-%S')
    local first_word
    first_word=$(echo "$new_content" | awk '{print $1}')

    local clip_file
    clip_file="$CLIPBOARD_DIR/${date_time}-${first_word}.txt"
    {
        echo "$new_content"
    } > "$clip_file"
}

if [[ $# -eq 0 ]]; then
    action=$(zenity --list --radiolist --column "Select" --column "Action" TRUE "copy" FALSE "force-copy" FALSE "recall" FALSE "clear" FALSE "purge" FALSE "new-clip" FALSE "help" --title "Clipboard Manager")
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
            clear_clips
            ;;
        "purge")
            purge_clipboard
            ;;
        "new-clip")
            new_clip
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
        --copy | -c)
            copy_to_clipboard "normal"
            ;;
        --force-copy | -fc)
            copy_to_clipboard "force"
            ;;
        --recall | -r)
            recall_from_clipboard
            ;;
        --clear | -cl)
            clear_clips
            ;;
        --purge | -d)
            purge_clipboard
            ;;
        --new-clip | -nc)
            new_clip
            ;;
        --help | -h)
            show_help
            ;;
        *)
            show_error "Invalid option. Use --help to see available options."
            exit 1
            ;;
    esac
fi

