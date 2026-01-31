
DEF HOLD_BIT EQU $80            ; high bit
DEF TICK_BITS EQU $3F           ; all other bits

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

    FutureBeatTrack: INCBIN "example.bin.a"
    FutureBeatTrackEnd:

    PresentBeatTrack:
    PresentBeatTrackEnd:
    
    PastBeatTrack:
    PastBeatTrackEnd:

SECTION "BeatPtrs", WRAM0

    CurrentPtr: dw
    NextPtr: dw
    FinishPtr: dw

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
    ld [CurrentPtr], a
    ld a, l
    ld [CurrentPtr + 1], a

    ld a, h
    ld [NextPtr], a
    ld a, l
    ld [NextPtr + 1], a

    ld a, b
    ld [FinishPtr], a
    ld a, c
    ld [FinishPtr + 1], a
    ret

; Gets the 'ticks' value pointed to by the NextPtr
; @returns bc: next value needing to trigger a sprite change
GetNextTicks::
    ld a, [NextPtr]
    ld h, a
    ld a, [NextPtr + 1]
    ld l, a

    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]
    ret

; Gets the 'ticks' value pointed to by the CurrentPtr
; @returns bc: current value the player needs to hit
GetCurrent::
    ld a, [CurrentPtr]
    ld h, a
    ld a, [CurrentPtr + 1]
    ld l, a

    ld a, [hl]                  ; high 6 bits
    and a, TICK_BITS
    ld b, a
    
    inc hl                      ; low 8 bits
    ld c, [hl]
    ret

; Increments the NextPtr
AdvanceNext::
    ld a, [NextPtr]
    ld h, a
    ld a, [NextPtr + 1]
    ld l, a

    inc hl                      ; 2 bytes
    inc hl

    ld a, h
    ld [NextPtr], a
    ld a, l
    ld [NextPtr + 1], a
    ret

; Increments the CurrentPtr 
AdvanceCurrent::
    ld a, [CurrentPtr]
    ld h, a
    ld a, [CurrentPtr + 1]
    ld l, a

    inc hl                      ; 2 bytes
    inc hl

    ld a, h
    ld [CurrentPtr], a
    ld a, l
    ld [CurrentPtr + 1], a
    ret

ENDSECTION

