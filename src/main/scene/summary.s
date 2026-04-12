include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "sugar.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "SummaryTileData", ROM0

    BackgroundData: INCBIN "summary.2bpp.rl"
    BackgroundDataEnd:

SECTION "SummaryTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "summary.tilemap.rl"
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
    ld bc, BackgroundDataEnd
    call RlCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd
    call RlCopy

    call PrintScoreCard


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_OFF | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_OFF
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio
    
    call ReloadTrack            ; Maintain the pervious music track but make it quieter
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
    call_GetNewKeys


    ; Loop
    halt
    cp 0
    jr z, MainLoop

.EndLoop:

    call MenuTransitionSound

    ld bc, MENU_SCENE
    ret

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "SummarySceneRenderer", ROM0

; Vram
RenderLoop:
    ldh a, [hIsMusicReady]
    and a
    call nz, hUGE_TickSound     ; play music
    reti

ENDSECTION

