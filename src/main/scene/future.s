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

    BeatTrackA: INCBIN "future.bin.a"
    BeatTrackAEnd:
    BeatTrackB: INCBIN "future.bin.b"
    BeatTrackBEnd:
    BeatTrackLeft: INCBIN "future.bin.l"
    BeatTrackLeftEnd:
    BeatTrackRight: INCBIN "future.bin.r"
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

    call InitBackgroundScroll


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

    call InitScore              ; draw the score after the window


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    di
    ld hl, FutureMusic
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


    ;; Start text

    call StartSequence


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
    jp nz, .EndIf               ; if at end, skip more enqueues

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


; Handle the player pressing a key
; @param a: actual input
; @param b: input enum to check
; @param hl: pointer to corresponding beatstream
CheckInput:
    and b
    jr nz, .IfPressed
    ret
    
.IfPressed:
    push hl
    call DrawButtonEffect       ; draw on the window
    pop hl

    push hl
    call GetHitBeatType
    pop hl
    cp BEAT_RELEASE             ; only HIT and HOLD beats should register here
    jr z, .IfBeatTypeWasRelease
 
    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a                     ; get current tick
    call HandleHit              ; handle the hit
    ret

.IfBeatTypeWasRelease:
    ret


; Handle the player releasing a key
; @param a: actual input
; @param b: input enum to check
; @param hl: pointer to corresponding beatstream
CheckRelease:
    and b
    jr nz, .IfReleased
    ret

.IfReleased:
    push hl
    call ClearButtonEffect       ; draw on the window
    pop hl

    push hl
    call GetHitBeatType
    pop hl
    cp BEAT_RELEASE             ; only RELEASE beats should register here
    jr nz, .IfBeatTypeWasNotRelease

    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a                     ; get current tick
    call HandleHit              ; handle the hit

    ret

.IfBeatTypeWasNotRelease:
    ret
 

; Main program loop wahhey
MainLoop:
    ; Update button presses
    call UpdateInput

    ; Spawn the beats!
    ld hl, BeatStreamA
    call SpawnBeats
    ld hl, BeatStreamB
    call SpawnBeats
    ld hl, BeatStreamLeft
    call SpawnBeats
    ld hl, BeatStreamRight
    call SpawnBeats

    ; Handle inputs
    call GetNewKeys

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

    call GetReleasedKeys

    push af
    ld b, JOYP_A
    ld hl, BeatStreamA
    call CheckRelease
    pop af
    push af
    ld b, JOYP_B
    ld hl, BeatStreamB
    call CheckRelease
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, BeatStreamLeft
    call CheckRelease
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, BeatStreamRight
    call CheckRelease
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

    call ClearAllButtonEffects

    call EndSequence 

    ld b, 3
    call SlideDownVolume
    call FadeOut

    call UnsetStatInterrupt
    call UnsetVBlankInterrupt
    call InitBackgroundScroll

    ld bc, FUTURE_SCENE
    ;ld bc, SUMMARY_SCENE
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
    call ScrollBackground

    ret

ENDSECTION

