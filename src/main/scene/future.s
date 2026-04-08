include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"

DEF START_ANIM_LENGTH EQU 150

/*******************************************************
* SCENE DATA
* Tilemap and tiles
*******************************************************/
SECTION "FutureTileData", ROM0

    BackgroundData: INCBIN "future_tiles_combined.2bpp.rl" ; shoutout to cat
    BackgroundDataEnd:

SECTION "FutureTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "beatmap.tilemap.rl"
    BackgroundTilemapEnd:

SECTION "FutureTracks", ROM0

    BeatTrackA: INCBIN "future.bin.a"
    BeatTrackAEnd:
    BeatTrackB: INCBIN "future.bin.b"
    BeatTrackBEnd:
    BeatTrackLeft: INCBIN "future.bin.l"
    BeatTrackLeftEnd:
    BeatTrackRight: INCBIN "future.bin.r"
    BeatTrackRightEnd:

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the game scene 
********************************************************/
SECTION "FutureSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
FutureSceneEntrypoint::
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

    ld de, BackgroundData
    ld hl, $9000
    ld bc, BackgroundDataEnd
    call RlCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd
    call RlCopy

    call InitBackgroundScroll


    ;; Window ;;

    call InitGameWindow


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    ld de, FutureMusic
    call PlayTrack

    ld b, 3
    call SlideUpVolume

    
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

    jp MainGameLoop             ; immediate ret

ENDSECTION

