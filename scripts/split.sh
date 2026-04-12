#!/bin/bash

# =====================================================================================
# Splits 2bpp bitmaps into a first and second half to fit in vram
#
# Usage: ./split.sh <image.2bpp>
# Author: Daniel R 2026
# =====================================================================================

set -e

#readonly BYTES_BEFORE=480 # bytes of tiles from other places in VRAM, offset
readonly BYTES_BEFORE=0

if [ -z "$1" ]; then
    echo 'Usage: ./split.sh <image.2bpp>'
    exit 1
fi

full_path="$1"
path=$(dirname "$full_path")
file_name_ext=$(basename -- "$full_path")
file_name="${file_name_ext%.*}"

full_size=$(wc -c "$full_path" | cut -d ' ' -f 1)

part_one_path="$path/../bitmaps/$file_name[first].2bpp"
part_one_size=$((2048 - BYTES_BEFORE))
part_two_path="$path/../bitmaps/$file_name[second].2bpp"
part_two_size=$((full_size - part_one_size))

if [ "$full_size" -le "$part_one_size" ]; then
    echo "Size is $full_size, file does not need to be split to fit in VRAM."
    exit 1
fi

cat "$full_path" | head -c "$part_one_size" > "$part_one_path"
cat "$full_path" | tail -c "$part_two_size" > "$part_two_path"

echo "Created $part_one_path and $part_two_path."
echo "Part 1 size = $part_one_size, Part 2 size = $part_two_size"

