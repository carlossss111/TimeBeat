INCLUDE "hardware.inc"
INCLUDE "scenes.inc"

/*******************************************************
* CARTRIDGE HEADER
* Populated by the rgbfix tool
********************************************************/
SECTION "Header", ROM0[$0100]

	jp EntryPoint

	ds $150 - @, 0

ENDSECTION

SECTION "FillerBefore", ROM0[$0000]
    ds $40

SECTION "FillerMiddle", ROM0[$0047]
    ds $01

SECTION "FillerAfter", ROM0[$004f]
    ds $100 - $4f

ENDSECTION

/*******************************************************
* INITIALISATION
* Copies memory to where it needs to be
********************************************************/
SECTION "Init", ROM0

; Global entrypoint for the program
EntryPoint:
    ld sp, StackStart           ; set stack pointer

    xor a
    ld [rAUDENA], a             ; NR52 enable audio
    ld a, $FF
    ld [rAUDTERM], a            ; NR51 set sound panning to neutral
    ld a, $00
    ld [rAUDVOL], a             ; NR50 set master volume

    call InitDMA                ; loads DMA transfer code into HRAM
    call InitInput              ; initialise input vars
    call InitScratchMemory      ; initialise scratch variables

    di                          ; disable interrupts for the main loop
    call InitVBlankHandling     ; init interrupt handling vars for later
    call InitStatHandling       ; init stat handling too

    ld bc, MENU_SCENE         ; first scene to load on program startup
    jp Main                     ; jump to the main loop

ENDSECTION


/*******************************************************
* MAIN LOOP
* The main event loop for the program
********************************************************/
SECTION "MainLoop", ROM0

; Main loop that each game state returns to upon finishing
; @param bc: scene to load
Main:
    ld a, c
    cp a, SWITCH_SIZE + 1       ; compare if bc is within the right range
    jr nc, .SwitchEnd           ; if bc > switch size then we skip the switch
    
    ld hl, .Switch
    xor b
    add hl, bc                  ; hl = scene enum value + switch starting location
    jp hl                       ; jump to the correct scene via the offset

.Switch:
    call TitleEntrypoint
    jr .SwitchEnd
    call MenuSceneEntrypoint
    jr .SwitchEnd
    call FutureSceneEntrypoint
    jr .SwitchEnd
    call PastSceneEntrypoint
    jr .SwitchEnd
    call SummarySceneEntrypoint
    jr .SwitchEnd

.SwitchEnd
    jp Main                     ; while True


TitleEntrypoint:
    ret                         ; unimplemented

ENDSECTION

