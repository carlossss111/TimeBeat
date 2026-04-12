include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"
include "input.inc"

DEF DELAY_BEFORE_MUSIC_CUTOFF EQU 55


/*******************************************************
* GAME CONTROLLER
* Shared controller logic between all of the game scenes
********************************************************/
SECTION "GameWindowTiles", ROM0

    WindowTiles:: INCBIN "window_full.2bpp.rl"
    WindowTilesEnd::

SECTION "GameWindowTilemap", ROM0

    DEF EMPTY_TILE EQU $0

    WindowTilemap: INCBIN "window.tilemap.rl"
    WindowTilemapEnd:

SECTION "GameController", ROM0

; Init the score window
InitGameWindow::

    ld de, WindowTilemap
    ld hl, $9C00
    ld bc, WindowTilemapEnd
    call RlCopy

    call InitWindow             ; init the stat interrupts

    call InitScore              ; draw the score after the window
    ret


; Init interrupts, palette and sprites
; Should be called before doing anything else
PreGameEntrypointInit::

    ;; Interrupts ;;

    xor a
    ldh [hIsMusicReady], a

    call SetVBlankInterrupt
    call SetStatInterrupt
    ei


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM
    call FadeOut                ; fade to black

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette

    ld hl, $8000
    call InitGameSpriteVRAM     ; set spritesheets (VRAM = $8000)
    jp InitBeatSprites          ; init circular queue
    ;ret


; Init scroll, window, LCD and audio
; @param hl: music track
PostGameEntrypointInit::
    push hl

    ;; Scroll ;;

    call InitBackgroundScroll

    
    ;; Window ;;

    call InitGameWindow


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio ;;

    pop de
    call PlayTrack
    call VolumeUp

    ld hl, GameRenderLoop
    call SetVBlankHandler       ; set background animations

    xor a
    ld b, a
    ld c, a
    jp InitTick                 ; initialise tick counter
    ;ret


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
SpawnBeats::

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
CheckInput::
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
CheckRelease::
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

/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/

SECTION "GameLoopVars", HRAM

    hBeatStreamA:: STRUCT_BEAT_STREAM
    hBeatStreamB:: STRUCT_BEAT_STREAM
    hBeatStreamLeft:: STRUCT_BEAT_STREAM
    hBeatStreamRight:: STRUCT_BEAT_STREAM

SECTION "GameLoop", ROM0

; Main game loop
MainGameLoop::
    ; Update button presses
    call UpdateInput

    ; Spawn the beats!
    ld hl, hBeatStreamA
    call SpawnBeats
    ld hl, hBeatStreamB
    call SpawnBeats
    ld hl, hBeatStreamLeft
    call SpawnBeats
    ld hl, hBeatStreamRight
    call SpawnBeats

    ; Handle inputs
    call_GetNewKeys

    push af
    ld b, JOYP_A
    ld hl, hBeatStreamA
    call CheckInput
    pop af
    push af
    ld b, JOYP_B
    ld hl, hBeatStreamB
    call CheckInput
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, hBeatStreamLeft
    call CheckInput
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, hBeatStreamRight
    call CheckInput
    pop af

    call_GetReleasedKeys

    push af
    ld b, JOYP_A
    ld hl, hBeatStreamA
    call CheckRelease
    pop af
    push af
    ld b, JOYP_B
    ld hl, hBeatStreamB
    call CheckRelease
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, hBeatStreamLeft
    call CheckRelease
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, hBeatStreamRight
    call CheckRelease
    pop af

    ; Check for missed beats
    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a

    push bc
    ld hl, hBeatStreamA
    call HandleMiss
    pop bc
    push bc
    ld hl, hBeatStreamB
    call HandleMiss
    pop bc
    push bc
    ld hl, hBeatStreamLeft
    call HandleMiss
    pop bc
    push bc
    ld hl, hBeatStreamRight
    call HandleMiss
    pop bc

    ; Check if at end of beatmap
    ld hl, hBeatStreamA
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, hBeatStreamB
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, hBeatStreamLeft
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, hBeatStreamRight
    call HasMoreBeatsToHit
    cp TRUE
    jr nz, .EndLoop
.EndIfAtFinish:

    ; Loop
    halt
    jp MainGameLoop
.EndLoop:
    ld b, DELAY_BEFORE_MUSIC_CUTOFF
    call WaitForFrames

    call ClearAllButtonEffects

    call VolumeOff
    call EndSequence 

    call FadeOut

    call UnsetStatInterrupt
    call UnsetVBlankInterrupt
    call InitBackgroundScroll

    ld bc, SUMMARY_SCENE
    ret

; Render animations into VRAM using the render-queue
GameRenderLoop::
    ldh a, [hIsMusicReady]
    and a
    call nz, hUGE_TickSound     ; play music

    call RenderToOAM            ; render sprites

    ei                          ; allow stat register
    call IncTick                ; increment tick counter once every frame
    call MoveBeatSprites        ; move all sprites
    call ClearOldText           ; clear old text
    call ScrollBackground

    ret



ENDSECTION

