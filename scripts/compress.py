#!/usr/bin/python

# =====================================================================================
# Compresses the bytes in a file with simple run-length compression
#
# Usage: python ./compress.py <input_file.bin> <output_file.bin> [word length]
# Author: Daniel R 2026
# =====================================================================================

from io import BufferedReader
import os
import sys

MAX_REPEAT_SIZE = 0xFF

def compress(fp: BufferedReader, word_length: int) -> bytes:
    out_stream: bytes = b""

    repeat_size: int = 0
    last_byte: bytes = fp.read(word_length)
    fp.seek(0)

    while(byte_in := fp.read(word_length)):

        if byte_in == b"\n" or byte_in == b"\r":
            continue

        if byte_in == last_byte and repeat_size != MAX_REPEAT_SIZE:
            repeat_size += 1
        else:
            out_stream += repeat_size.to_bytes() + last_byte
            last_byte = byte_in
            repeat_size = 1

    out_stream += repeat_size.to_bytes() + last_byte
            
    return out_stream

def main():
    if len(sys.argv) != 3 and len(sys.argv) != 4:
        print("Usage: python export-beatmap.py <input_file.txt> <output_file.bin> <word length>")
        exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    word_length = int(sys.argv[3]) if len(sys.argv) == 4 else 1

    with open(input_path, "rb") as rfp:
        compressed_bytes: bytes = compress(rfp, word_length)

    with open(output_path, "wb") as wfp:
        wfp.write(compressed_bytes)

    print(f"Finished successfully! Compressed {os.path.getsize(input_path)} bytes into {len(compressed_bytes)} bytes")


if __name__ == "__main__":
    main()

