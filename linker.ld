
ROM0
    ; Interrupts
    ORG $0040
    "VBlankInterrupt"
    ORG $0048
    "StatInterrupt"

    ; Cartridge Header
    ORG $0100
    "Header"

    ; Init
    ORG $150
    "Init"
    ; Main Functions
    "MainLoop"
    "MemoryFunctions"
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
    "ScratchVars"
    "Tick"

    ORG $FFFE
    "FrameCounter"

