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

    ;BackgroundData: INCBIN "future_tiles_combined.2bpp.rl" ; shoutout to cat
    ;BackgroundDataEnd:

SECTION "FutureTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    ;BackgroundTilemap: INCBIN "beatmap.tilemap.rl"
    ;BackgroundTilemapEnd:

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

    ;; Sprites & Interrupts ;;

    call PreGameEntrypointInit


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

    ;ld de, BackgroundData
    ;ld hl, $9000
    ;ld bc, BackgroundDataEnd
    ;call RlCopy

    ;ld de, BackgroundTilemap
    ;ld hl, TILEMAP0
    ;ld bc, BackgroundTilemapEnd
    ;call RlCopy


    ;; Audio, Window, LCD ;;

    ld hl, FutureMusic 
    call PostGameEntrypointInit


    ;; Start text ;;

    ld a, START_ANIM_LENGTH
    ld b, START_ANIM_LENGTH
    ld c, START_ANIM_LENGTH
    call StartSequence


    ;; Play! ;;

    jp MainGameLoop             ; immediate ret
    ;ret

ENDSECTION

