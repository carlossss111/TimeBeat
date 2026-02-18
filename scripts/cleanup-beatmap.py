import sys

NUM_OF_BEATS_IN_ORDER = 64

def panic(problem: str):
    print(problem, file=sys.stderr)
    exit(1)

def main():
    if len(sys.argv) != 4:
        panic("Usage: python <script> <read_path> <write_path> <tempo>")

    read_path = sys.argv[1]
    write_path = sys.argv[2]
    tempo = sys.argv[3]

    full_str = ""
    
    counter = -64
    with open(read_path, "r") as fp:
        for line in fp:
            if "Order Row" in line:
                full_str += line
                counter += NUM_OF_BEATS_IN_ORDER
                continue

            if len(line) < 2 or line[0] == '#':
                full_str += line
                continue

            # Tempo
            raw_num = line.split(" ")[0]
            acc_num = (counter + int(raw_num)) * int(tempo)
            words = line.split(" ")[1:]
            rest_of_str = " ".join(words)

            # Ampersand
            rest_of_str = rest_of_str.replace("& ",f"\n{acc_num}\t")

            # Hold release
            rest_of_str = rest_of_str.replace("(hold)"," HOLD")
            rest_of_str = rest_of_str.replace("(release)"," RELEASE")

            full_str += str(acc_num) + "\t" + rest_of_str

    with open(write_path, "w") as fp:
        fp.write(full_str)

    print(f"Written to {write_path}")


if __name__ == "__main__":
    main()

