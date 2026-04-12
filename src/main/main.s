INCLUDE "hardware.inc"
INCLUDE "scenes.inc"
INCLUDE "input.inc"
INCLUDE "scratch.inc"

/*******************************************************
* CARTRIDGE HEADER
* Populated by the rgbfix tool
********************************************************/
SECTION "Header", ROM0[$0100]

	jp EntryPoint

	ds $150 - @, 0

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
    ld [rAUDENA], a             ; disable audio at start (prevents pop)

    call InitDMA                ; loads DMA transfer code into HRAM
    call_InitInput              ; initialise input vars
    call_InitScratchMemory      ; initialise scratch variables

    xor a
    call SetMusicOffset

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
    ld hl, .Switch
    ld b, 0
    add hl, bc                  ; hl = scene enum value + switch starting location
    jp hl                       ; jump to the correct scene via the offset

.Switch:
    call MenuSceneEntrypoint
    jr Main
    call FutureSceneEntrypoint
    jr Main
    call PastSceneEntrypoint
    jr Main
    call PresentSceneEntrypoint
    jr Main
    call SummarySceneEntrypoint
    jr Main

ENDSECTION

