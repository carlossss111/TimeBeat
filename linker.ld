
ROM0
    ; Interrupts
    ORG $0000
    "FillerBefore"
    "VBlankInterrupt"
    "FillerMiddle"
    "StatInterrupt"
    "FillerAfter"

    ; Cartridge Header
    ORG $0100
    "Header"

    ; Init
    ORG $150
    "Init"

    ; Main Functions
    ORG $174
    "MainLoop"
    "StandardLibrary"
    "VBlankHandler"
    "StatHandler"

    ; Drivers
    ORG $794A
    "Sound Driver"


WRAM0
    ; Large Arrays
    ORG $C000
    "ShadowOAM"
    "BeatQueueVars"

    ; Driver variables
    ORG $D017
    "Music driver RAM"

    ; 4kb Stack (way more than needed)
    ORG $D060
    "Stack"


HRAM
    ORG $FF80
    "RenderToOAM"
    "OAMRenderer"
    "Scratch"
    "Tick"

    ORG $FFFE
    "FrameCounter"

