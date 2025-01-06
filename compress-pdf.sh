#!/bin/bash

# Function to display an error
show_error() {
    zenity --error --text="$1"
    exit 1
}

# Check for required dependencies
if ! command -v zenity &> /dev/null; then
    show_error "Zenity is not installed. Please install it and try again."
fi

if ! command -v gs &> /dev/null; then
    show_error "Ghostscript is not installed. Please install it and try again."
fi

# Ask the user to select one or more PDF files
input_pdfs=$(zenity --file-selection --title="Select PDF files to compress" --multiple --separator="|")

# Check if any files have been selected
if [ -z "$input_pdfs" ]; then
    show_error "No files selected."
fi

# Ask the user to select the compression quality
quality=$(zenity --scale --text="Select the compression quality level (1-10)" --min-value=1 --max-value=10 --value=5)

# Check if a quality level has been selected
if [ -z "$quality" ]; then
    show_error "No quality level selected."
fi

# Define the compression level based on the quality
if [ "$quality" -le 1 ]; then
    pdf_settings="/screen"
elif [ "$quality" -le 3 ]; then
    pdf_settings="/ebook"
elif [ "$quality" -le 6 ]; then
    pdf_settings="/printer"
else
    pdf_settings="/prepress"
fi

# Create output directory
output_dir="COMPRESSED_PDF"
mkdir -p "$output_dir"

# Loop through each selected PDF and compress it
IFS='|'
for input_pdf in $input_pdfs; do
    # Define the output file name (same as input name)
    output_pdf="$output_dir/$(basename "$input_pdf")"

    # Compress the PDF
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=$pdf_settings -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output_pdf" "$input_pdf"

    # Check if the compression was successful
    if [ $? -ne 0 ]; then
        show_error "Error compressing the PDF file: $input_pdf"
    fi

    # Display success message
    filesize=$(stat -c%s "$output_pdf")
    filesize_mb=$(echo "scale=2; $filesize / 1048576" | bc)
    zenity --info --text="Compression successful: The compressed file is $filesize_mb MB"
done

zenity --info --text="All selected PDFs have been compressed successfully."
