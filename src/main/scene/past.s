include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"

DEF START_ANIM_LENGTH EQU 100

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "PastTileData", ROM0

    BgdDataFirstHalf: INCBIN "past[first].2bpp.rl"
    BgdDataFirstHalfEnd:
    BgdDataSecondHalf: INCBIN "past[second].2bpp.rl"
    BgdDataSecondHalfEnd:

SECTION "PastTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "past.tilemap.rl"
    BackgroundTilemapEnd:

SECTION "PastTracks", ROM0

    BeatTrackA: INCBIN "past.bin.a"
    BeatTrackAEnd:
    BeatTrackB: INCBIN "past.bin.b"
    BeatTrackBEnd:
    BeatTrackLeft: INCBIN "past.bin.l"
    BeatTrackLeftEnd:
    BeatTrackRight: INCBIN "past.bin.r"
    BeatTrackRightEnd:

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the game scene 
********************************************************/
SECTION "PastSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
PastSceneEntrypoint::
    xor a
    ldh [hIsMusicReady], a

    call SetVBlankInterrupt
    call SetStatInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette

    ld hl, $8000
    call InitGameSpriteVRAM     ; set spritesheets (VRAM = $8000)
    call InitBeatSprites        ; init circular queue

    
    ;; Game ;;
    
    ld a, PAD_A
    ld hl, hBeatStreamA
    ld bc, BeatTrackA
    ld de, BeatTrackAEnd
    call InitBeatStream

    ld a, PAD_B
    ld hl, hBeatStreamB
    ld bc, BeatTrackB
    ld de, BeatTrackBEnd
    call InitBeatStream

    ld a, PAD_LEFT
    ld hl, hBeatStreamLeft
    ld bc, BeatTrackLeft
    ld de, BeatTrackLeftEnd
    call InitBeatStream

    ld a, PAD_RIGHT
    ld hl, hBeatStreamRight
    ld bc, BeatTrackRight
    ld de, BeatTrackRightEnd
    call InitBeatStream


    ;; Background ;;

    ld de, WindowTiles
    ld hl, $9000
    ld bc, WindowTilesEnd
    call RlCopy

    ld de, BgdDataFirstHalf
    ld hl, $9000 + 480
    ld bc, BgdDataFirstHalfEnd
    call RlCopy

    ld de, BgdDataSecondHalf
    ld hl, $8800
    ld bc, BgdDataSecondHalfEnd
    call RlCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd
    call RlCopy

    call InitBackgroundScroll

    
    ;; Window

    call InitGameWindow


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    ld de, PastMusic 
    call PlayTrack
    call VolumeUp 

    
    ;;

    ld hl, GameRenderLoop
    call SetVBlankHandler       ; set background animations

    xor a
    ld b, a
    ld c, a
    call InitTick               ; initialise tick counter


    ;; Start text

    ld a, START_ANIM_LENGTH
    ld b, START_ANIM_LENGTH
    ld c, START_ANIM_LENGTH
    call StartSequence


    ;; Play!

    jp MainGameLoop             ; immediate return

ENDSECTION

