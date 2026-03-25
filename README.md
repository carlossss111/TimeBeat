# Time // Beat

<p align="center">
  <img src="rsc/demo.gif" alt="animated" />
</p>

>The year is 2026 and music is fading from the earth and threatening to plunge humanity into NON-HEARING. To combat this, PROFESSOR PRELUDE has designed the TIMEBEAT GAMEBOY capable of saving the world.<br/><br/>
But still, the device is yet incomplete and the technology he needs to finish it doesn't exist in the present day! He must now use his recently invented TIME MACHINE to travel to the past and future to find the missing components.<br/><br/>
With both components, he can finally build the TIMEBEAT GAMEBOY and play it at the top of CHIME MOUNTAIN to save the world.<br/><br/>
Help the PROFESSOR in his quest - or risk the end of sound!

Written in SM83 assembly (a mix between the i8080 and the Z80) for the original Nintendo Gameboy. 

The goal of the project was to write a short rhythm game, complete with a title screen, score, art and music.

## Compilation

Compile into a .gb using the Makefile. This will require the [RGBDS toolchain](https://rgbds.gbdev.io/) to be installed. I am using version v1.0.x

```
make
```

This is compatible with all Gameboy models (i.e. DMG, CGB, AGB).

## Execution

### Emulation
I used the Emulicious emulator for debugging and the Sameboy emulator for validation, but any emulator should work. Just select the `.gb` file with your preferred software, e.g.

```
sameboy bin/minesweeper.gb
```

### Real Hardware
After running `make`, take the .gb file and load it onto a **32KB** Cartridge that is compatible with **GBxCart RW** and hey presto you have the game running on hardware!

The game might work with larger cartridges, but I have not tried.

## How To Play
### Menu Screen
Select the stage you would like to play.
* Up/Down buttons to select a stage. 
* Left/Right to change the audio offset. 
* START to play the selected stage.

### Game Screen
Press the buttons on the bottom of the screen in time with the music.
* MISS = 0 points
* OK = 25 points
* GOOD = 50 points
* PERFECT = 100 points

### Summary Screen
View the number of hits and the overall score.
* START to continue.

## Credits
* Daniel Robinson (that's me!) - Programmer
* Jonathan Mason - Music, SFX and beatmap composer

Special Thanks to the hard-working maintainers of RGBDS, PanDocs, Emulicious, hUGETracker; fortISSimO; Tilemap Studio; and Aseprite, as-well as those in the RBGDS community who answered my questions along the way.

## Resources
Helpful links related to the project:
* [Pan Docs](https://gbdev.io/pandocs/)
* [RGBDS Assembly Reference](https://rgbds.gbdev.io/docs/master)
* [Hardware Headerfile](https://github.com/gbdev/hardware.inc)
* [HugeTracker](https://nickfa.ro/wiki/HUGETracker)
* [fortISSimO](https://codeberg.org/ISSOtm/fortISSimO)
* [Tilemap Studio](https://github.com/Rangi42/tilemap-studio)
* [Asesprite](https://www.aseprite.org/)
* [Emulicious](https://emulicious.net/)
* [Sameboy](https://sameboy.github.io/)
