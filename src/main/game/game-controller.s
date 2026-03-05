include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"


/*******************************************************
* GAME CONTROLLER
* Shared controller logic between all of the game scenes
********************************************************/
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

    ld hl, $9C00
    ld a, EMPTY_TILE
    call InitWindow             ; init the stat interrupts

    call InitScore              ; draw the score after the window
    ret


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
 



ENDSECTION

