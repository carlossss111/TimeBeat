#!/bin/bash

#
#  Exports images created in asesprites to bitmaps and DMG tilemaps
#

set -e

readonly COLOUR_PALETTE='#9bbc0f,#8bac0f,#306230,#0f380f;'

if [ -z "$1" ]; then
    echo 'Usage: ./export-image.sh <images/file_name.ase> [-t|--tilemap]'
    exit 1
fi

full_path="$1"
path=$(dirname "$full_path")
file_name_ext=$(basename -- "$full_path")
file_name="${file_name_ext%.*}"

png_path="$path/../images/$file_name.png"
bpp_path="$path/../bitmaps/$file_name.2bpp"
map_path="$path/../tilemaps/$file_name.tilemap"
tmp_path="/tmp/placeholder.png"

# Export image
aseprite -b "$full_path" --save-as "$png_path"

# Remove transparency because it does not play well with -u option
magick "$png_path" -background '#9bbc0f' -alpha remove -alpha off "$tmp_path"

# Create bitmap and tilemap
if [ "$2" == '-t' ] || [ "$2" == '--tilemap' ]; then
    rgbgfx "$tmp_path" -c "$COLOUR_PALETTE" -u -o "$bpp_path" -t "$map_path"
    echo "Created images/$file_name.png, bitmaps/$file_name.2bpp and tilemaps/$file_name.tilemap."
    tilemapstudio "$map_path" "$bpp_path" dmg &
else
    rgbgfx "$tmp_path" -c "$COLOUR_PALETTE" -u -o "$bpp_path"
    echo "Created images/$file_name.png and bitmaps/$file_name.2bpp."
fi

