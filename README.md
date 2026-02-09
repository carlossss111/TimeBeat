# Time // Beat
A Rhythm Game for the Gameboy! 

>The year is 2026 and music is fading from the earth and threatening to plunge humanity into NON-HEARING. To combat this, PROFESSOR PRELUDE has designed the TIMEBEAT GAMEBOY capable of saving the world.<br/><br/>
But still, the device is yet incomplete and the technology he needs to finish it doesn't exist in the present day! He must now use his recently invented TIME MACHINE to travel to the past and future to find the missing components. In 5000 AD he must break into a spaceport to get a QUANTUM STABILISER. He must then travel to 65,000,000BC and avoid dinosaurs and find a MILLENNIUM STONE.<br/><br/>
With both components, he can finally build the TIMEBEAT GAMEBOY and play it at the top of CHIME MOUNTAIN to save the world.<br/><br/>
Help the PROFESSOR in his quest - or risk the end of sound!

Written in SM83 assembly (a mix between the i8080 and the Z80) for the original Nintendo Gameboy. 

The goal of the project is to write a short rhythm game, complete with a title screen, score, art and music.

## Compiling

Compile into a .gb using the Makefile. This will require the [RGBDS toolchain](https://rgbds.gbdev.io/) to be installed. I am using version v1.0.x

```
make
```

## Compatibility

This game is intended for the Gameboy DMG, and would therefore be compatible with the CGB and the GBA. It can be treated as a 'grey cartridge'.

## Usage

### Emulation
For a 1-1 experience emulating the gameboy I used and recommend [Sameboy](https://github.com/LIJI32/SameBoy). It has [very good accuracy](https://daid.github.io/GBEmulatorShootout/) and allows you to easily apply effects to the screen to make it look closer to the real thing.

For debugging I used and recommend [Emulicious](https://emulicious.net/). It has extensive tools that show memory, registers, tilemaps, objects and palettes. It can be used to step through the program and and stop at breakpoints hit by either the PC or by any memory access.

Any other Gameboy emulator should work. These ones can be run with the following commands:
```
sameboy bin/minesweeper.gb
emulicious bin/minesweeper.gb
```

### Real Hardware
After running `make`, take the .gb file and load it onto a **32KB Cartridge** that is compatible with **GBxCart RW** and hey presto you have the game!

See: https://www.gbxcart.com/

## Libraries and Tools
I am using the hUGE library v6.1.x for audio.
Available here: https://nickfa.ro/wiki/hUGETracker

## Resources
* [Pan Docs](https://gbdev.io/pandocs/)
* [Assembly Reference](https://rgbds.gbdev.io/docs/master)
* [CC0 Hardware Headerfile](https://github.com/gbdev/hardware.inc)
* [Asesprite](https://www.aseprite.org/)
* [Tilemap Studio](https://github.com/Rangi42/tilemap-studio)

