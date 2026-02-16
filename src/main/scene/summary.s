include "hardware.inc"
include "scenes.inc"
include "macros.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "SummaryTileData", ROM0

    BackgroundData: INCBIN "summary.2bpp"
    BackgroundDataEnd:

SECTION "SummaryTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "summary.tilemap"
    BackgroundTilemapEnd:

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the scene 
********************************************************/
SECTION "SummarySceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
SummarySceneEntrypoint::
    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations
    call SetVBlankInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Background ;;

    ld de, BackgroundData
    ld hl, $9000
    ld bc, BackgroundDataEnd - BackgroundData
    call VRAMCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd - BackgroundTilemap
    call VRAMCopy20x18


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_OFF | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_OFF
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    di
    ld hl, FutureMusic
    call hUGE_init              ; set music track
    ei
    call Quiet


    ;;


    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "SummarySceneMain", ROM0

; Main program 
MainLoop:
    call UpdateInput
    call GetNewKeys

    ; Loop
    halt
    jp MainLoop

.EndLoop:

    ld bc, FUTURE_SCENE
    ret

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "SummarySceneRenderer", ROM0

; Vram
RenderLoop:
    call hUGE_dosound           ; play music
    reti

ENDSECTION

