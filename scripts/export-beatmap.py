import sys
from typing import List

COMMENT = '#'
CONTROL_MAP = {"A": 0x0, "B": 0x1, "LEFT": 0x2, "RIGHT": 0x3}
HOLD_RELEASE = {"HOLD": 0x0, "RELEASE": 0x1}

MIN_TICKS = 144
MAX_TICKS = 0x3FFF

def panic(problem: str):
    print(problem, file=sys.stderr)
    exit(1)

class BinaryBeatArray:
    
    def __init__(self):
        self.binary_arr = b""

    def append(self, text_arr: List, line_no: int):
        if len(text_arr) == 0:
            return
        if len(text_arr) > 3:
            panic(f"Could not parse line {line_no}, too many symbols")
        if not text_arr[0].isdigit():
            panic(f"Could not parse line {line_no}, could not read ticks as an integer")
        if text_arr[1] not in CONTROL_MAP.keys():
            panic(f"Could not parse line {line_no}, could not read control type")
        if len(text_arr) == 3 and text_arr[2] not in HOLD_RELEASE.keys():
            panic(f"Could not parse line {line_no}, could not read hold/release keyword")

        # The tick time is 14 bits
        beat = int(text_arr[0])
        if beat > 0x3FF:
            panic(f"Too many ticks on line {line_no}! Must be 14 bits")
        if beat < MIN_TICKS:
            panic(f"Too few ticks on line {line_no}! Must be more than {MIN_TICKS}")

        # The hold/release functionality is uppermost bit
        if len(text_arr) == 3:
            beat |= HOLD_RELEASE[text_arr[2]] << 15

        self.binary_arr += beat.to_bytes(2, "big")

def remove_comments(text: str) -> str:
    if COMMENT not in text:
        return text

    found_idx = text.index(COMMENT)
    return text[:found_idx]

def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: python export-beatmap.py <input_file.txt> <output_file.bin>")
        exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    left_stream = BinaryBeatArray()
    right_stream = BinaryBeatArray()
    a_stream = BinaryBeatArray()
    b_stream = BinaryBeatArray()

    with open(input_path, "r") as rfp:
        line_no = 1

        for line in rfp:
            line = remove_comments(line)
            symbols = line.strip().split()

            if len(symbols) == 0:
                continue

            if symbols[1] == "A": 
                a_stream.append(symbols, line_no)
            elif symbols[1] == "B": 
                b_stream.append(symbols, line_no)
            elif symbols[1] == "LEFT": 
                left_stream.append(symbols, line_no)
            elif symbols[1] == "RIGHT": 
                right_stream.append(symbols, line_no)
            else:
                panic(f"Could not parse line {line_no}, could not read control type")

            line_no += 1

    with open(f"{output_path}.a", "wb") as wfp:
        wfp.write(a_stream.binary_arr)
        print("Written A BUTTON stream.")

    with open(f"{output_path}.b", "wb") as wfp:
        wfp.write(b_stream.binary_arr)
        print("Written B BUTTON stream.")
        
    with open(f"{output_path}.l", "wb") as wfp:
        wfp.write(left_stream.binary_arr)
        print("Written LEFT stream")

    with open(f"{output_path}.r", "wb") as wfp:
        wfp.write(right_stream.binary_arr)
        print("Written RIGHT stream")

    print("Finished successfully!")

if __name__ == "__main__":
    main()

