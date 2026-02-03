include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"
include "game-charmap.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "FutureTileData", ROM0

    BackgroundData: INCBIN "beatmap.2bpp"
    BackgroundDataEnd:

SECTION "FutureTileMap", ROM0

    BackgroundTilemap: INCBIN "beatmap.tilemap"
    BackgroundTilemapEnd:

SECTION "FutureText", ROM0

    DEF EMPTY_SPACE EQU $1f
    PerfectStr: db "PERFECT!"
    GoodStr: db "GOOD!"
    OkStr: db "OK!"
    MissStr: db "MISS"

SECTION "FutureBeats", WRAM0

    BeatStreamA: STRUCT_BEAT_STREAM
    BeatStreamB: STRUCT_BEAT_STREAM
    BeatStreamLeft: STRUCT_BEAT_STREAM
    BeatStreamRight: STRUCT_BEAT_STREAM

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the game scene 
********************************************************/
SECTION "FutureSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
FutureSceneEntrypoint::
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
    ld hl, BeatStreamA
    ld bc, FutureBeatTrackA
    ld de, FutureBeatTrackAEnd
    call InitBeatStream

    ld a, PAD_B
    ld hl, BeatStreamB
    ld bc, FutureBeatTrackB
    ld de, FutureBeatTrackBEnd
    call InitBeatStream

    ld a, PAD_LEFT
    ld hl, BeatStreamLeft
    ld bc, FutureBeatTrackLeft
    ld de, FutureBeatTrackLeftEnd
    call InitBeatStream

    ld a, PAD_RIGHT
    ld hl, BeatStreamRight
    ld bc, FutureBeatTrackRight
    ld de, FutureBeatTrackRightEnd
    call InitBeatStream


    ;; Background ;;

    ld de, BackgroundData       ; load first half of tiles into VRAM
    ld hl, $9000
    ld bc, BackgroundDataEnd - BackgroundData
    call VRAMCopy

    ld de, BackgroundTilemap ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd - BackgroundTilemap
    call VRAMCopy


    ;; Window ;;

    ld bc, $240 ; tilemap full height of the screen
    ld d, EMPTY_SPACE
    ld hl, TILEMAP1
    call VRAMMemset

    ld de, PerfectStr
    ld b, STRLEN("Perfect!")
    ld hl, TILEMAP1
    call VRAMCopyFast


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_OFF | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    di
    ld hl, BeatTest
    call hUGE_init              ; set music track
    ei
    ld b, 3
    call SlideUpVolume

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations

    call InitTick               ; initialise tick counter

    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "FutureSceneMain", ROM0

; Spawn beats by reading the beat streams
; @param hl: beat stream pointer
/**
* function(beat_stream){
*     if (beat_stream->next->ticks == ticks) {
*         sprite_type = beat_stream->sprite_type
*         enqueue_next_sprite(sprite_type);
*         beat_tracker->advance_next()
*     }
* 
* }
*/
SpawnBeats:
    push hl

.IfAtEndOfSprites:
    pop hl
    push hl
    call IsNextPtrAtEnd

    cp TRUE
    jp z, .EndIf                ; if at end, skip more enqueues

.IfTimeForNextSprite:
    pop hl
    push hl
    call GetNextTick            ; bc = next tick on tracker

    ldh a, [hTick]              ; check if tick on current beat >= time ticks
    cp b
    jr c, .EndIf
    ldh a, [hTick + 1]
    cp c
    jr c, .EndIf

    pop hl
    push hl
    ld bc, BEAT_STREAM_TYPE
    add hl, bc
    ld a, [hl]                  ; a = sprite type
    call EnqueueBeatSprite      ; enqueue sprite

    pop hl
    push hl
    call AdvanceNext            ; advance next pointer on beatmap

.EndIf:
    pop hl
    ret


; Main program loop wahhey
MainLoop:

    ; Spawn the beats!
    ld hl, BeatStreamA
    call SpawnBeats
    ld hl, BeatStreamB
    call SpawnBeats
    ld hl, BeatStreamLeft
    call SpawnBeats
    ld hl, BeatStreamRight
    call SpawnBeats

    ; Move all sprites
    call MoveBeatSprites        ; move all sprites

    ; Vsync and loop
    halt
    jr MainLoop
.EndLoop:

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "FutureSceneRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call hUGE_dosound           ; play music
    call RenderToOAM            ; render sprites
    call IncTick                ; increment tick counter once every frame

    ret

ENDSECTION

