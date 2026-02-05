include "game-charmap.inc"
include "macros.inc"

DEF TOO_EARLY_TO_HIT EQU 50
DEF OK_BOUND EQU 8
DEF GOOD_BOUND EQU 4
DEF PERFECT_BOUND EQU 1

/*******************************************************
* HIT MESSAGES
*******************************************************/
SECTION "HitMessage", ROM0

    PerfectStr:: db "PERFECT!"
    GoodStr:: db "GOOD!"
    OkStr:: db "OK"
    MissStr:: db "MISS"

ENDSECTION

/*******************************************************
* HIT HANDLER
* Calculates the accuracy of a input hit
*******************************************************/
SECTION "HitHandler", ROM0

; Returns whether the current tick is +/- in bounds of the beatmap tick
; @param a: bounds tick
; @param bc: current tick
; @param de: beatmap tick
; @returns a: true/false
/*
function(bounds, current_tick, beatmap_tick){
    upper_bounds = beatmap + bound
    if current > upper_bounds:
        return false

    lower_bounds = beatmap - bound
    if current < lower_bounds:
        return false
    
    return true
}
*/
IsInBounds:
    ld [wScratchA], a

    ld l, a
    xor a
    ld h, a
    add hl, de                  ; hl = upper bounds

.IfUpper:
    ld a, h
    cp b
    jr c, .ReturnFalse          ; return if HIGH(current) > HIGH(upper_bounds)
    ld a, l
    cp c
    jr c, .ReturnFalse          ; return if LOW(current) > LOW(upper_bounds)
.EndIfUpper:

    ld a, [wScratchA]
    ld l, a
    xor a
    ld h, a

	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a                     ; de = lower bounds

.IfLower:
    ld a, b
    cp d
    jr c, .ReturnFalse          ; return if HIGH(upper_bounds) > HIGH(current)
    ld a, c
    cp e
    jr c, .ReturnFalse          ; return if LOW(upper_bounds) > LOW(current)
.EndIfLower

.ReturnTrue:
    ld a, TRUE
    ret

.ReturnFalse:
    ld a, FALSE
    ret


; Handle the current hit
; @param bc: current tick
; @param de: beatmap tick
; @param hl: beatmap struct
HandleHit::

    ; Way too early, don't treat it as a real hit
    push hl
    push bc
    push de
    ld a, TOO_EARLY_TO_HIT
    call IsInBounds
    pop de
    pop bc
    pop hl
.IfTooEarly:
    cp a, TRUE
    jr z, .NotTooEarly
    ret                         ; return silently if the hit was way too early
.NotTooEarly:

    ; Check if perfect
    push hl
    push bc
    push de
    ld a, PERFECT_BOUND
    call IsInBounds
    pop de
    pop bc
    pop hl
.IfPerfect:
    cp a, TRUE
    jr nz, .NotPerfect

    push hl
    push de
    push bc
    ld de, PerfectStr
    ld b, STRLEN("Perfect!")
    call WriteText
    pop bc
    pop de
    pop hl
    
    call NextHit

    ret
.NotPerfect:

    ; Check if good
    push hl
    push bc
    push de
    ld a, GOOD_BOUND
    call IsInBounds
    pop de
    pop bc
    pop hl
.IfGood:
    cp a, TRUE
    jr nz, .NotGood

    push hl
    push de
    push bc
    ld de, GoodStr
    ld b, STRLEN("Good!")
    call WriteText
    pop bc
    pop de
    pop hl
    
    call NextHit

    ret
.NotGood:

    ; Check if ok
    push hl
    push bc
    push de
    ld a, OK_BOUND
    call IsInBounds
    pop de
    pop bc
    pop hl
    .IfOk:
    cp a, TRUE
    jr nz, .NotOk

    push hl
    push de
    push bc
    ld de, OkStr
    ld b, STRLEN("Ok")
    call WriteText
    pop bc
    pop de
    pop hl

    call NextHit

    ret
    .NotOk:

    ; Anything else is a miss
    push hl
    ld de, MissStr
    ld b, STRLEN("Miss")
    call WriteText
    pop hl

    call NextHit
    ret


ENDSECTION

