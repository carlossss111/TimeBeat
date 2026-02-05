
/*******************************************************
* TICKS
* Used for tracking the time since a beatmap started
*******************************************************/
SECTION "Tick", HRAM

    hTick:: dw

SECTION "TickFunctions", ROM0

; Initialises the tick counter
; @param bc: value to initialise to
InitTick::
    ld a, b
    ldh [hTick], a
    ld a, c
    ldh [hTick + 1], a
    ret

; Increments the tick counter
IncTick::
    ldh a, [hTick]
    ld h, a
    ldh a, [hTick + 1]
    ld l, a
    inc hl
    ld a, h
    ldh [hTick], a
    ld a, l
    ldh [hTick + 1], a
    ret
 
ENDSECTION


