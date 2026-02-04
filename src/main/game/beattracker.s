include "macros.inc"
include "beattracker.inc"

DEF HOLD_BIT EQU $80            ; high bit
DEF TICK_BITS EQU $3F           ; all other bits

DEF TICKS_TO_CROSS_SCREEN EQU $90 ; probably


/*******************************************************
* BEAT TRACK VARIABLES AND CONSTS
*
* Each beat track is an array of 2-byte values.
* The highest (15th) bit indicates a HOLD (otherwise release).
* The 14th bit is reserved for future use.
* The bits 0-13 represent the ticks since the start of the track.
*
* There are 3 pointers.
* CurrentPtr - for pointing to the upcoming beat for the player to hit.
* NextPtr - for pointing to the upcoming sprite for the game to spawn.
* FinishPtr - constant pointer for measuring the length of the beat track.

* BEAT TRACKER
* As described above, each beattrack can be ran through
* and functions called depending on the value at each ptr.
********************************************************/
SECTION "BeatTracker", ROM0


; Initialises all the pointers and variables for the beat tracker
; @param hl: pointer to beatstream struct
; @param a: button type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @param bc: location in memory where the beat track begins
; @param de: location in memory where the beat track ends
InitBeatStream::
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl                      ; current_ptr = bc

    ld [hl], b
    inc hl
    ld [hl], c
    inc hl                      ; next_ptr = bc

    ld [hl], d
    inc hl
    ld [hl], e                  ; finish_ptr = de
    inc hl

    ld [hl], a                  ; type = a
    ret


; Gets the 'tick' value pointed to by the NextPtr
; Subtracts by the time it takes to cross the screen
; @param hl: pointer to beatstream struct
; @returns bc: next value needing to trigger a sprite change
GetNextTick::
    ld bc, BEAT_STREAM_NEXT
    add hl, bc
    ld a, [hl+]
    ld c, [hl]
    ld h, a
    ld l, c
    
    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]

    ld hl, -TICKS_TO_CROSS_SCREEN
    add hl, bc                  ; subtract ticks to cross screen
    jr c, .NoUnderflow
    ld bc, 0                    ; handle underflows (unlikely!)
    ret

.NoUnderflow:
    ld b, h
    ld c, l
    ret


; Gets the 'ticks' value pointed to by the CurrentPtr
; @param hl: pointer to beatstream struct
; @returns bc: current value the player needs to hit
GetCurrentTick::
    ld bc, BEAT_STREAM_CURRENT
    add hl, bc
    ld a, [hl+]
    ld c, [hl]
    ld h, a
    ld l, c
 
    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]
    ret


; Increments the NextPtr
; @param hl: pointer to beatstream struct
AdvanceNext::
    ld bc, BEAT_STREAM_NEXT
    add hl, bc
    push hl
    ld b, [hl]
    inc hl
    ld c, [hl]
 
    inc bc                      ; 2 bytes
    inc bc

    pop hl
    ld [hl], b
    inc hl
    ld [hl], c
    ret


; Increments the CurrentPtr 
; @param hl: pointer to beatstream struct
AdvanceCurrent::
    ld bc, BEAT_STREAM_CURRENT
    add hl, bc
    push hl
    ld b, [hl]
    inc hl
    ld c, [hl]
 
    inc bc                      ; 2 bytes
    inc bc

    pop hl
    ld [hl], b
    inc hl
    ld [hl], c
    ret


; Return 1 if at end
; @param hl: pointer to beatstream struct
; @param a: TRUE or FALSE
IsNextPtrAtEnd::
    push hl
    ld bc, BEAT_STREAM_NEXT
    add hl, bc
    ld b, [hl]
    inc hl
    ld c, [hl]
 
    pop hl
    ld de, BEAT_STREAM_FINISH
    add hl, de
    ld d, [hl]
    inc hl
    ld e, [hl]
 
    ld a, d
    cp b
    jp nz, .False
    ld a, e
    cp c
    jp nz, .False
.True:
    ld a, TRUE
    ret
    
.False:
    ld a, FALSE
    ret
    

ENDSECTION

