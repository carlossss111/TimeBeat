include "macros.inc"

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
********************************************************/
SECTION "BeatTracks", ROM0

    FutureBeatTrack:: INCBIN "example.bin.a"
    FutureBeatTrackEnd::

    PresentBeatTrack::
    PresentBeatTrackEnd::
    
    PastBeatTrack::
    PastBeatTrackEnd::

SECTION "BeatPtrs", WRAM0

    wCurrentPtr: dw
    wNextPtr: dw
    wFinishPtr: dw

ENDSECTION

/*******************************************************
* BEAT TRACKER
* As described above, each beattrack can be ran through
* and functions called depending on the value at each ptr.
********************************************************/
SECTION "BeatTracker", ROM0

; Initialises all the pointers and variables for the beat tracker
; @param hl: location in memory where the beat track begins
; @param bc: location in memory where the beat track ends
InitBeatTracker::
    ld a, h
    ld [wCurrentPtr], a
    ld a, l
    ld [wCurrentPtr + 1], a

    ld a, h
    ld [wNextPtr], a
    ld a, l
    ld [wNextPtr + 1], a

    ld a, b
    ld [wFinishPtr], a
    ld a, c
    ld [wFinishPtr + 1], a
    ret


; Gets the 'tick' value pointed to by the NextPtr
; Subtracts by the time it takes to cross the screen
; @returns bc: next value needing to trigger a sprite change
GetNextTick::
    ld a, [wNextPtr]
    ld h, a
    ld a, [wNextPtr + 1]
    ld l, a

    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]

    ; TODO: Need to tweak what happens if a beatmap is too early
    ld hl, -TICKS_TO_CROSS_SCREEN
    add hl, bc                  ; subtract ticks to cross screen
    jr c, .NoUnderflow
    ld bc, 0                    ; handle underflows
    ret

.NoUnderflow:
    ld b, h
    ld c, l
    ret


; Gets the 'ticks' value pointed to by the CurrentPtr
; @returns bc: current value the player needs to hit
GetCurrent::
    ld a, [wCurrentPtr]
    ld h, a
    ld a, [wCurrentPtr + 1]
    ld l, a

    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]
    ret


; Increments the NextPtr
AdvanceNext::
    ld a, [wNextPtr]
    ld h, a
    ld a, [wNextPtr + 1]
    ld l, a

    inc hl                      ; 2 bytes
    inc hl

    ld a, h
    ld [wNextPtr], a
    ld a, l
    ld [wNextPtr + 1], a
    ret


; Increments the CurrentPtr 
AdvanceCurrent::
    ld a, [wCurrentPtr]
    ld h, a
    ld a, [wCurrentPtr + 1]
    ld l, a

    inc hl                      ; 2 bytes
    inc hl

    ld a, h
    ld [wCurrentPtr], a
    ld a, l
    ld [wCurrentPtr + 1], a
    ret


; Return 1 if at end
; @param a: TRUE or FALSE
IsNextPtrAtEnd::
    ld a, [wNextPtr]
    ld h, a
    ld a, [wNextPtr + 1]
    ld l, a

    ld a, [wFinishPtr]
    cp h
    jp nz, .False
    ld a, [wFinishPtr + 1]
    cp l
    jp nz, .False
.True:
    ld a, TRUE
    ret
    
.False:
    ld a, FALSE
    ret
    

ENDSECTION

