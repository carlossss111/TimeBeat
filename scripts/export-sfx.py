from enum import Enum
from typing import Optional

TONE_TO_FREQ = {
    "c0": 16.35, "c1": 32.7, "c2": 65.41, "c3": 130.81, "c4": 261.63, "c5": 523.25, "c6": 1046.5, "c7": 2093, "c8": 4186,
    "c#0": 17.32, "c#1": 34.65, "c#2": 69.3, "c#3": 138.59, "c#4": 277.18, "c#5": 554.37, "c#6": 1108.73, "c#7": 2217.46, "c#8": 4434.92,
    "d0": 18.35, "d1": 36.71, "d2": 73.42, "d3": 146.83, "d4": 293.66, "d5": 587.33, "d6": 1174.66, "d7": 2349.32, "d8": 4698.63,
    "d#0": 19.45, "d#1": 38.89, "d#2": 77.78, "d#3": 155.56, "d#4": 311.13, "d#5": 622.25, "d#6": 1244.51, "d#7": 2489, "d#8": 4978,
    "e0": 20.6, "e1": 41.2, "e2": 82.41, "e3": 164.81, "e4": 329.63, "e5": 659.25, "e6": 1318.51, "e7": 2637, "e8": 5274,
    "f0": 21.83, "f1": 43.65, "f2": 87.31, "f3": 174.61, "f4": 349.23, "f5": 698.46, "f6": 1396.91, "f7": 2793.83, "f8": 5587.65,
    "f#0": 23.12, "f#1": 46.25, "f#2": 92.5, "f#3": 185, "f#4": 369.99, "f#5": 739.99, "f#6": 1479.98, "f#7": 2959.96, "f#8": 5919.91,
    "g0": 24.5, "g1": 49, "g2": 98, "g3": 196, "g4": 392, "g5": 783.99, "g6": 1567.98, "g7": 3135.96, "g8": 6271.93,
    "g#0": 25.96, "g#1": 51.91, "g#2": 103.83, "g#3": 207.65, "g#4": 415.3, "g#5": 830.61, "g#6": 1661.22, "g#7": 3322.44, "g#8": 6644.88,
    "a0": 27.5, "a1": 55, "a2": 110, "a3": 220, "a4": 440, "a5": 880, "a6": 1760, "a7": 3520, "a8": 7040,
    "a#0": 29.14, "a#1": 58.27, "a#2": 116.54, "a#3": 233.08, "a#4": 466.16, "a#5": 932.33, "a#6": 1864.66, "a#7": 3729.31, "a#8": 7458.62,
    "b0": 30.87, "b1": 61.74, "b2": 123.47, "b3": 246.94, "b4": 493.88, "b5": 987.77, "b6": 1975.53, "b7": 3951, "b8": 7902.13
}

def panic(problem: str):
    print(problem)
    exit(1)

class SWEEP_DIR(Enum):
    UP = 0
    DOWN = 1

class ENVELOPE_DIR(Enum):
    UP = 1
    DOWN = 0

class Channel:
    pass

class Square(Channel):

    def __init__(self) -> None:
        super()

        # NR10 Sweep                                # 1 unused bit
        self._sweep_time: Optional[int] = None      # 3 bits
        self._sweep_dir: Optional[int] = None       # 1 bit
        self._sweep_size: Optional[int] = None      # 3 bit

        # NR11 Channel length & duty
        self._duty: Optional[int]           = None  # 2 bits
        self._channel_length: Optional[int] = 0x00  # 6 bits

        # NR12 Volume and envelope
        self._initial_vol: Optional[int] = None     # 4 bits 
        self._env_dir: Optional[int]    = None      # 1 bit
        self._env_change: Optional[int]  = None     # 3 bits

        # NR13 & NR14 Period                        # 3 unused bits
        self._period: Optional[int] = None          # 11 bits
        self._trigger: Optional[int] = True         # 1 bit
        self._length_enable: Optional[int] = False  # 1 bit

    @property
    def rNR10(self) -> Optional[int]:
        if (self._sweep_time is None 
                or self._sweep_dir is None 
                or self._sweep_size is None):
            return None

        register = 0
        register |= (self._sweep_time << 4)
        register |= (self._sweep_dir << 3)
        register |= (self._sweep_size)
        return register

    @property
    def rNR11(self) -> Optional[int]:
        if self._duty is None or self._channel_length is None:
            return None

        register = 0
        register |= (self._duty << 6)
        register |= (self._channel_length)
        return register

    @property
    def rNR12(self) -> Optional[int]:
        if (self._initial_vol is None
                or self._env_dir is None
                or self._env_change is None):
            return None

        register = 0
        register |= (self._initial_vol << 4)
        register |= (self._env_dir << 3)
        register |= (self._env_change)
        return register
        
    @property
    def rNR13(self) -> Optional[int]:
        if self._period is None:
            return None

        register = (self._period & 0xFF)
        return register

    @property
    def rNR14(self) -> Optional[int]:
        if (self._period is None
                or self._length_enable is None
                or self._trigger is None):
            return None

        register = 0
        register |= (self._trigger << 7)
        register |= (self._length_enable << 6)
        register |= (self._period >> 8)
        return register

    # 7.8 m/s per bit
    def set_sweep_time(self, user_in: str) -> None:
        if len(user_in) == 0:
            self._sweep_time = 0
            return

        sweep_time = float(user_in)
        self._sweep_time = int(sweep_time / float(7.8))

        if self._sweep_time < 0x0 or self._sweep_time > 0x7:
            panic("Sweep time must be 3 bits")

    # Sweep increases (up) or decreases (down)
    def set_sweep_dir(self, user_in: str) -> None:
        if user_in.upper() == "UP":
            self._sweep_dir = SWEEP_DIR.UP.value
        elif user_in.upper() == "DOWN":
            self._sweep_dir = SWEEP_DIR.DOWN.value
        else:
            panic("Sweep dir should be 'UP/down'")

    # not fully sure this one is right
    def set_sweep_size(self, user_in: str) -> None:
        self._sweep_size = int(user_in)

        if self._sweep_size < 0x0 or self._sweep_size > 0x7:
            panic("Sweep size should be 3 bits")
    
    # 12.5%, 25%, 50% or 75%
    def set_duty(self, user_in: str) -> None:
        duty_freq = float(user_in.replace("%",""))
        self._duty = int(duty_freq / float(12.5)) >> 1

        if self._duty < 0x0 or self._duty > 0x7:
            panic("Duty must be 3 bits")

    # 0-15
    def set_initial_vol(self, user_in: str) -> None:
        self._initial_vol = int(user_in)
        
        if self._initial_vol < 0x0 or self._initial_vol > 0x0F:
            panic("Initial envelope volume must be 4 bits")

    # Increases (up) or decreases (down)
    def set_envelope_dir(self, user_in: str) -> None:
        if user_in.upper() == "UP":
            self._env_dir = ENVELOPE_DIR.UP.value
        elif user_in.upper() == "DOWN":
            self._env_dir = ENVELOPE_DIR.DOWN.value
        else:
            panic("Envelope direction should be 'UP/down'")

    # 0-7
    def set_envelope_change(self, user_in: str) -> None:
        self._env_change = int(user_in)

        if self._env_change < 0x0 or self._env_change > 0x7:
            panic("Envelope change (aka sweep pace) must be 3 bits")

    # period = 2048 - (131072/tone-frequency)
    def set_period(self, user_in: str) -> None:
        user_in = user_in.lower()
        if user_in not in TONE_TO_FREQ.keys():
            panic("Note not recognised in the frequency lookup table")

        freq: float = TONE_TO_FREQ[user_in]

        self._period = 2048 - int(float(131072)/freq)

        if self._period < 0 or self._period > 0x7FF:
            panic("Period must be 11 bits long")

    # print binary values
    def __repr__(self) -> str:
        return str({
            "self": "<Square>", 
            "sweep_time": bin(self._sweep_time)         if self._sweep_time is not None else None, 
            "sweep_dir": bin(self._sweep_dir)           if self._sweep_dir is not None else None,
            "sweep_size": bin(self._sweep_size)         if self._sweep_size is not None else None, 
            "duty": bin(self._duty)                     if self._duty is not None else None,
            "channel_length": bin(self._channel_length) if self._channel_length is not None else None,
            "initial_vol": bin(self._initial_vol)       if self._initial_vol is not None else None,
            "env_dir": bin(self._env_dir)               if self._env_dir is not None else None,
            "env_change": bin(self._env_change)         if self._env_change is not None else None,
            "trigger": bin(self._trigger)               if self._trigger is not None else None,
            "length_enable": bin(self._length_enable)   if self._length_enable is not None else None,
            "period": bin(self._period)                 if self._period is not None else None,
            "rNR10": bin(self.rNR10)                    if self.rNR10 is not None else None,
            "rNR11": bin(self.rNR11)                    if self.rNR11 is not None else None,
            "rNR12": bin(self.rNR12)                    if self.rNR12 is not None else None,
            "rNR13": bin(self.rNR13)                    if self.rNR13 is not None else None,
            "rNR14": bin(self.rNR14)                    if self.rNR14 is not None else None})
        

def main() -> None:
    square = Square()

    print("Tone?")
    square.set_period(input())

    print("Envelope start volume?")
    square.set_initial_vol(input())

    print("Envelope direction?")
    square.set_envelope_dir(input())

    print("Envelope change?")
    square.set_envelope_change(input())

    print("Sweep time? (Leave blank for 'Off')")
    square.set_sweep_time(input())

    print("Sweep direction?")
    square.set_sweep_dir(input())

    print("Sweep size?")
    square.set_sweep_size(input())

    print("Duty %?")
    square.set_duty(input())

    print(square)
    print("")

    if (square.rNR10 is None 
        or square.rNR11 is None
        or square.rNR12 is None
        or square.rNR13 is None
        or square.rNR14 is None):
        print("Failed to generate all registers")
        exit(1)

    print(
    f"""
    ld a, ${hex(square.rNR10)[2:]}
    ld [rNR10], a
    ld a, ${hex(square.rNR11)[2:]}
    ld [rNR11], a
    ld a, ${hex(square.rNR12)[2:]}
    ld [rNR12], a
    ld a, ${hex(square.rNR13)[2:]}
    ld [rNR13], a
    ld a, ${hex(square.rNR14)[2:]}
    ld [rNR14], a
    """
    )

if __name__ == "__main__":
    main()

