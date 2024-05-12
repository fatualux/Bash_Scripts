#!/bin/bash
# A bash script to interact with tesseract-ocr
# Dependencies: bash zenity tesseract imagemagick (https://github.com/tesseract-ocr/tesseract)

################################ FUNCTIONS ################################

# Function to preprocess the image before OCR
PreprocessImage() {
    local input_file="$1"
    local output_file="$2"
    # Rescaling the image to 300 DPI
    convert "$input_file" -density 300 -units pixelsperinch "$output_file"

    # Binarization using adaptive thresholding
    convert "$output_file" -threshold 50% "$output_file"

    # Noise removal using Gaussian blur
    convert "$output_file" -blur 0x1 "$output_file"

    # Deskewing the image
    convert "$output_file" -deskew 40% "$output_file"
}

# Function to select the language for OCR
SelectLanguage() {
    local lang=$(zenity --list --text "Which language to translate from?" \
        --column "Language" --width=820 --height=460 --hide-header \
        "English" "French" "Spanish" "German" "Italian" "Japanese" "Hindi" "Russian" "Chinese")
    case $lang in
        "English") export LANG="eng" ;;
        "French") export LANG="fra" ;;
        "Spanish") export LANG="spa" ;;
        "German") export LANG="deu" ;;
        "Italian") export LANG="ita" ;;
        "Japanese") export LANG="jpn" ;;
        "Hindi") export LANG="hin" ;;
        "Russian") export LANG="rus" ;;
        "Chinese") export LANG="chi-tra" ;;
    esac
}

# Function to select the output format
SelectOutput() {
    local output=$(zenity --list --text "Select output format:" \
        --column "Output" --width=820 --height=460 --hide-header \
        "Text" "PDF" "HOCR" "TSV")
    case $output in
        "Text") export OUTPUT="txt" ;;
        "PDF") export OUTPUT="pdf" ;;
        "HOCR") export OUTPUT="hocr" ;;
        "TSV") export OUTPUT="tsv" ;;
    esac
}

# Function to select the page segmentation method
SelectSegmentation() {
    local segmentation=$(zenity --list --text "Select page segmentation method:" \
        --column "Segmentation" --width=820 --height=460 --hide-header \
        "Orientation and script detection (OSD) only" \
        "Automatic page segmentation with OSD" \
        "Automatic page segmentation (No OSD or OCR)" \
        "Fully automatic page segmentation (No OSD, default)" \
        "Assume a single column of text of variable sizes" \
        "Assume a single uniform block of vertically aligned text" \
        "Assume a single uniform block of text" \
        "Treat the image as a single text line" \
        "Treat the image as a single word" \
        "Treat the image as a single word in a circle" \
        "Treat the image as a single character" \
        "Find as much text as possible in no particular order" \
        "Sparse text with OSD" \
        "Treat the image as a single text line")
    case $segmentation in
        "Orientation and script detection (OSD) only") export PAGE_SEGMENTATION="0" ;;
        "Automatic page segmentation with OSD") export PAGE_SEGMENTATION="1" ;;
        "Automatic page segmentation (No OSD or OCR)") export PAGE_SEGMENTATION="2" ;;
        "Fully automatic page segmentation (No OSD, default)") export PAGE_SEGMENTATION="3" ;;
        "Assume a single column of text of variable sizes") export PAGE_SEGMENTATION="4" ;;
        "Assume a single uniform block of vertically aligned text") export PAGE_SEGMENTATION="5" ;;
        "Assume a single uniform block of text") export PAGE_SEGMENTATION="6" ;;
        "Treat the image as a single text line") export PAGE_SEGMENTATION="7" ;;
        "Treat the image as a single word") export PAGE_SEGMENTATION="8" ;;
        "Treat the image as a single word in a circle") export PAGE_SEGMENTATION="9" ;;
        "Treat the image as a single character") export PAGE_SEGMENTATION="10" ;;
        "Find as much text as possible in no particular order") export PAGE_SEGMENTATION="11" ;;
        "Sparse text with OSD") export PAGE_SEGMENTATION="12" ;;
        "Treat the image as a single text line") export PAGE_SEGMENTATION="13" ;;
    esac
}

# Function to select the OCR engine
SelectOcrEngine() {
    local engine=$(zenity --list --text "Select OCR Engine:" \
        --column "Engine" --width=820 --height=460 --hide-header \
        "Legacy engine only" \
        "Neural nets LSTM engine only" \
        "Legacy + LSTM engines (Default)" \
        "Layered LSTM engine only")
    case $engine in
        "Legacy engine only") export OCR_ENGINE="0" ;;
        "Neural nets LSTM engine only") export OCR_ENGINE="1" ;;
        "Legacy + LSTM engines (Default)") export OCR_ENGINE="2" ;;
        "Layered LSTM engine only") export OCR_ENGINE="3" ;;
    esac
}

# Function to perform OCR on the preprocessed image
PerformOCR() {
    local input_file="$1"
    local output_file="$2"
    local lang="$3"
    local page_segmentation="$4"
    local ocr_engine="$5"
    local output_format="$6"

    tesseract "$input_file" "$output_file" -l "$lang" --psm "$page_segmentation" --oem "$ocr_engine" "$output_format"
}

# Main function
Main() {
    # Select input files
    local input_files=$(zenity --file-selection --multiple --separator=" " --file-filter=""*.png" "*.jpg" "*.jpeg"")
    # Preprocess and OCR each selected file
    for input_file in $input_files; do
        # Preprocess the image
        local preprocessed_file="${input_file%.*}_preprocessed.png"
        PreprocessImage "$input_file" "$preprocessed_file"
        # Select OCR parameters
        SelectLanguage
        SelectSegmentation
        SelectOcrEngine
        SelectOutput
        # Perform OCR on the preprocessed image
        PerformOCR "$preprocessed_file" "${input_file%.*}" "$LANG" "$PAGE_SEGMENTATION" "$OCR_ENGINE" "$OUTPUT"
        # Remove the preprocessed image after OCR
        rm "$preprocessed_file"
    done

    zenity --info --text="OCR process completed."
}

# Call the main function
Main
