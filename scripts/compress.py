#!/usr/bin/python

# =====================================================================================
# Compresses the bytes in a file with custom run-length compression
# E.g. 'AAABBCDEAAAAA' ==> '[3]A [2]B [0x80|3]CDE [5]A
#
# Usage: python ./compress.py <input_file.bin> <output_file.bin> [word length]
# Author: Daniel R 2026
# =====================================================================================

from io import BufferedReader
import os
import sys

MAX_REPEAT_SIZE = 0x3F
SINGLES_FLAG = 0x80
STAIRS_FLAG = 0x40

def create_stairs(singles: bytes) -> bytes:
    prev = None
    substr = b""
    byte_list = []

    for byte_in in singles:
        if prev == None or byte_in == prev + 1:
            substr += byte_in.to_bytes()

        else:
            byte_list.append(substr)
            substr = byte_in.to_bytes()

        prev = byte_in

    if len(substr) > 0: byte_list.append(substr)

    substr = b""
    outstr = b""
    for item in byte_list:
        if len(item) > 1:
            if len(substr) > 0:
                outstr += ((len(substr)) | SINGLES_FLAG).to_bytes() + substr
                substr = b""

            outstr += (len(item) | STAIRS_FLAG).to_bytes() + item[0].to_bytes()
        else:
            substr += item

    if len(substr) > 0: 
        outstr += ((len(substr)) | SINGLES_FLAG).to_bytes() + substr

    return outstr

def third_pass(passed_bytes: bytes) -> bytes:
    outstr = b""

    i = 0
    while i != len(passed_bytes):
        byte_in = passed_bytes[i]

        if byte_in & SINGLES_FLAG == 0: # regular runlength
            outstr += passed_bytes[i:i+2]
            i += 2
        else: # singles runlength
            singles_len = int(byte_in & ~SINGLES_FLAG)
            outstr += create_stairs(passed_bytes[i+1:i+singles_len+1])
            i += singles_len+ 1

    return outstr

def second_pass(runlength_bytes: bytes, word_length: int) -> bytes:
    singles_size: int = 0
    out_subs: bytes = b""
    out_stream: bytes = b""

    if len(runlength_bytes) % (word_length + 1) != 0:
        print("Error: the second pass did not have a valid run-length input")
        sys.exit(1)

    for pair_raw in (runlength_bytes[pos:pos + word_length+1] for pos in range(0, len(runlength_bytes), word_length+1)):
        pair = { "num": pair_raw[0], "word": pair_raw[1:word_length+1] }

        # Max size
        if singles_size >= MAX_REPEAT_SIZE:
            out_stream += (singles_size | SINGLES_FLAG).to_bytes() + out_subs
            out_subs = b""
            singles_size = 0

        # Normal Pair
        if pair["num"] > 1:
            if singles_size > 0: out_stream += (singles_size | SINGLES_FLAG).to_bytes() + out_subs
            
            out_subs = b""
            out_stream += pair_raw
            singles_size = 0

        # Singles
        else:
            out_subs += pair["word"]
            singles_size += 1

    if singles_size > 0: out_stream += (singles_size | SINGLES_FLAG).to_bytes() + out_subs

    return out_stream

def compress(fp: BufferedReader, word_length: int) -> bytes:
    out_stream: bytes = b""

    repeat_size: int = 0
    last_byte: bytes = fp.read(word_length)
    fp.seek(0)

    while(byte_in := fp.read(word_length)):

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

    compressed_bytes = second_pass(compressed_bytes, word_length)

    if word_length == 1:
        compressed_bytes = third_pass(compressed_bytes)

    with open(output_path, "wb") as wfp:
        wfp.write(compressed_bytes)

    print(f"Finished successfully! Compressed {os.path.getsize(input_path)} bytes into {len(compressed_bytes)} bytes")


if __name__ == "__main__":
    main()

