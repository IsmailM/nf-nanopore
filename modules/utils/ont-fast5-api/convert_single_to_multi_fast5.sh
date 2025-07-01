#!/bin/sh

fast5_dir="$1"
output_dir="$2"
threads="${3:-1}"  # Default to 1 thread if not specified

if [ -z "$fast5_dir" ]; then
    echo "Usage: $0 <path_to_fast5_directory> <output_directory> <threads>"
    exit 1
fi

found_single_read=false

echo "Checking for single-read FAST5 files in: $fast5_dir"

# Recursively find all fast5 files.
find -L "$fast5_dir" -name "*.fast5" -print0 > temp_fast5_files.txt

# Loop through FAST5 files and check top level names using h5ls
while IFS= read -r -d '' file; do
    top_level=$(h5ls "$file" 2>/dev/null | awk '{print $1}')
    if echo "$top_level" | grep -vq '^read_'; then
        found_single_read=true
        break
    fi
done < temp_fast5_files.txt

if $found_single_read; then
    echo "Single-read FAST5 file found. Converting to multi-read..."
    single_to_multi_fast5 --input_path "$fast5_dir" --save_path "$output_dir" --threads $threads --recursive
else
    echo "No single-read FAST5 files found. No conversion needed."
    cp -r $fast5_dir $output_dir
    echo "Moved existing FAST5 files to $output_dir"
fi
