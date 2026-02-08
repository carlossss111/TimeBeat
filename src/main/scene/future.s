include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "FutureTileData", ROM0

    BackgroundData: INCBIN "future_tiles_combined.2bpp" ; shoutout to cat
    BackgroundDataEnd:

SECTION "FutureTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "beatmap.tilemap"
    BackgroundTilemapEnd:

    WindowTilemap: INCBIN "window.tilemap"
    WindowTilemapEnd:

SECTION "FutureTracks", ROM0

    BeatTrackA: INCBIN "example.bin.a"
    BeatTrackAEnd:
    BeatTrackB: INCBIN "example.bin.b"
    BeatTrackBEnd:
    BeatTrackLeft: INCBIN "example.bin.l"
    BeatTrackLeftEnd:
    BeatTrackRight: INCBIN "example.bin.r"
    BeatTrackRightEnd:

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
    ld bc, BeatTrackA
    ld de, BeatTrackAEnd
    call InitBeatStream

    ld a, PAD_B
    ld hl, BeatStreamB
    ld bc, BeatTrackB
    ld de, BeatTrackBEnd
    call InitBeatStream

    ld a, PAD_LEFT
    ld hl, BeatStreamLeft
    ld bc, BeatTrackLeft
    ld de, BeatTrackLeftEnd
    call InitBeatStream

    ld a, PAD_RIGHT
    ld hl, BeatStreamRight
    ld bc, BeatTrackRight
    ld de, BeatTrackRightEnd
    call InitBeatStream


    ;; Background ;;

    ld de, BackgroundData
    ld hl, $9000
    ld bc, BackgroundDataEnd - BackgroundData
    call VRAMCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd - BackgroundTilemap
    call VRAMCopy


    ;; Window ;;

    ld b, 20
    ld de, WindowTilemap
    ld hl, $9C00
    call VRAMCopyFast

    ld b, 20
    ld de, WindowTilemap + 20
    ld hl, $9C20
    call VRAMCopyFast

    ld b, 20
    ld de, WindowTilemap + 40
    ld hl, $9C40
    call VRAMCopyFast

    ld d, EMPTY_TILE
    ld bc, $9FFF - $9C60
    ld hl, $9C60
    call VRAMMemset

    ld hl, $9C00
    ld a, EMPTY_TILE
    call InitWindow             ; init the stat interrupts


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
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

    xor a
    ld b, a
    ld c, a
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

.IfAtEndOfSprites:
    push hl
    call HasMoreSpritesToSpawn
    pop hl

    cp TRUE
    jp z, .EndIf                ; if at end, skip more enqueues

.IfTimeForNextSprite:
    push hl
    call GetSpriteTick          ; bc = next tick on tracker
    pop hl

    ldh a, [hTick]              ; check if tick on current beat >= time ticks
    cp b
    jr c, .EndIf
    ldh a, [hTick + 1]
    cp c
    jr c, .EndIf

    push hl
    call GetSpriteBeatType      
    ld b, a                     ; b = beat type (SINGLE/HOLD/RELEASE)
    pop hl

    push hl
    ld de, BEAT_STREAM_TYPE
    add hl, de 
    ld a, [hl]                  ; a = sprite type
    call SpawnBeatSprite        ; enqueue sprite
    pop hl

    push hl
    call NextSprite             ; advance next pointer on beatmap
    pop hl

.EndIf:
    ret


; Handle the player input
; @param a: actual input
; @param b: input enum to check
; @param hl: pointer to corresponding beatstream
CheckInput:
    and b
    jr nz, .IfPressed
    ret
    
.IfPressed:
    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a                     ; get current tick

    push hl
    call HandleHit              ; handle the hit
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

    ; Get inputs
    call GetNewKeys

    ; Handle inputs
    push af
    ld b, JOYP_A
    ld hl, BeatStreamA
    call CheckInput
    pop af
    push af
    ld b, JOYP_B
    ld hl, BeatStreamB
    call CheckInput
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, BeatStreamLeft
    call CheckInput
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, BeatStreamRight
    call CheckInput
    pop af

    ; Check for missed beats
    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a

    push bc
    ld hl, BeatStreamA
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamB
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamLeft
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamRight
    call HandleMiss
    pop bc

    ; Check if at end of beatmap
    ld hl, BeatStreamA
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamB
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamLeft
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamRight
    call HasMoreBeatsToHit
    cp TRUE
    jr nz, .EndLoop
.EndIfAtFinish:

    ; Loop
    halt
    jp MainLoop
.EndLoop:

    ld b, 255 
    call WaitForFrames
    ld b, 3
    call SlideDownVolume
    ld b, 255 
    call WaitForFrames
    call FadeOut

    ld bc, FUTURE_SCENE         ; todo
    ret
    ret

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

    ei                          ; allow stat register
    call IncTick                ; increment tick counter once every frame
    call MoveBeatSprites        ; move all sprites
    call ClearOldText           ; clear old text

    ret

ENDSECTION

