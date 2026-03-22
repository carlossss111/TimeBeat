# How to prepare 2bpp files
1. Export to a 2bpp file: `./export-image.sh <image.ase>`
2. Split into VRAM chunks: `./split.sh <image.2bpp>`
3. Compress: `./compress.py <image.2bpp> <image.2bpp.rl>`
4. Include in the code and use the `RlCopy` function
5. Profit

# How to prepare tilemap files
1. Export to a 2bpp file: `./export-image.sh <image.ase> -t`
2. Shift the Tile IDs by $1e if they are game tiles (i.e. if the window tiles are loaded before in VRAM)
3. Compress: `./compress.py <image.tilemap> <image.tilemap.rl>
4. Include in the code and use the `RlCopy` function
5. Profit

