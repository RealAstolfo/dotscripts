#!/bin/bash

# Check if cdrecord is installed
if ! command -v cdrecord &> /dev/null; then
    echo "cdrecord is not installed. Please install it before running this script."
    exit 1
fi

# Check if a file was provided as an argument
#if [ $# -ne 1 ]; then
#    echo "Usage: $0 <input_file>"
#    exit 1
#fi

input_file="$1"
cd_writer="$2"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: The input file does not exist."
    exit 1
fi

# Get the CD's capacity in bytes
cd_capacity_bytes=$(cdrecord -minfo dev=$cd_writer 2>/dev/null | grep "writable size" | awk '{print $NF}')
cd_capacity_mb=$(((cd_capacity_bytes / 512) - 2))

# Get the size of the input file in megabytes
file_size_mb=$(du -m "$input_file" | cut -f1)

# Check if the file is larger than a CD's capacity
if [ "$file_size_mb" -le "$cd_capacity_mb" ]; then
    # If the file is smaller than or equal to a CD, write it to a CD
    echo "Writing $input_file to CD..."
    cdrecord dev=$cd_writer "$input_file"
else
    # If the file is larger than a CD, split and write it to multiple CDs
    split_size_mb="$cd_capacity_mb"
    split -d -b "${split_size_mb}M" "$input_file" "$input_file.part-"

    part_number=1
    while [ -e "$input_file.part-$part_number" ]; do
        echo "Writing $input_file.part-$part_number to CD $part_number..."
        cdrecord dev=$cd_writer "$input_file.part-$part_number"
        rm -f "$input_file.part-$part_number"
        ((part_number++))
    done
fi

echo "Done."
