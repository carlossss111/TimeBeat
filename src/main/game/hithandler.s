include "game-charmap.inc"
include "macros.inc"

DEF TOO_EARLY_TO_HIT EQU 30
DEF MISS_BOUND EQU 20
DEF GOOD_BOUND EQU 6
DEF PERFECT_BOUND EQU 2

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
* function(bounds, current_tick, beatmap_tick){
*     upper_bounds = beatmap + bound
*     if current > upper_bounds:
*         return false
* 
*     lower_bounds = beatmap - bound
*     if current < lower_bounds:
*         return false
*     
*     return true
* }
*/
IsInBounds:
    ldh [hScratchA], a

    ld l, a
    xor a
    ld h, a
    add hl, de                  ; hl = upper bounds

.IfUpper:
    ld a, h
    cp b
    jr c, .ReturnFalse          ; return if HIGH(current) > HIGH(upper_bounds)
    jr nz, .EndIfUpper          ; skip low bit if HIGH(current) != HIGH(upper_bounds)
    ld a, l
    cp c
    jr c, .ReturnFalse          ; return if LOW(current) > LOW(upper_bounds)
.EndIfUpper:

    ldh a, [hScratchA]
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
    jr nz, .EndIfLower          ; skip low bit if HIGH(upper_bounds) != HIGH(current)
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
; @param hl: beatmap struct
/*
* function(current_tick, bm_struct) {
*      if(bm_struct->next == null):
*         return
*     
*     bm_tick = bm_struct->tick
*     if (IsInBounds(TOO_EARLY, current_tick, beatmap_tick)):
*         return 
* 
*     if (IsInBounds(PERFECT, current_tick, beatmap_tick)):
*         print("Perfect!")
*         bm_struct->next()
*         return
* 
*     if (IsInBounds(GOOD, current_tick, beatmap_tick)):
*         print("Good")
*         bm_struct->next()
*         return
* 
*     print("OK")
*     bm_struct->next()
*     return
* }
*/
HandleHit::
    push bc
    push hl
    call HasMoreBeatsToHit
    pop hl
    pop bc
.IfAtFinish:
    cp TRUE
    jr z, .EndIfAtFinish
    ret
.EndIfAtFinish:

    push bc
    push hl
    call GetHitTick             ; de = beatmap tick
    pop hl
    pop bc

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

    call AddPerfectScore

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

    call AddGoodScore

    ret
.NotGood:

    ; Anything else is a miss
    push hl
    ld de, OkStr 
    ld b, STRLEN("Ok")
    call WriteText
    pop hl

    call NextHit

    call AddOKScore

    ret

; Check if a beat has been missed entirely and move on if so
; @param bc: current tick
; @param hl: beatmap struct
/*
* function(current_tick, bm_struct){
*      if(bm_struct->next == null):
*         return
*     
*     bm_tick = bm_struct->tick
*     miss_bound = bm_tick + n
*     if (current_tick <= miss_bound):
*         return
* 
*     bm_struct->next()
*     print("Miss")
* }
*/
HandleMiss::
    push bc
    push hl
    call HasMoreBeatsToHit
    pop hl
    pop bc
.IfAtFinish:
    cp TRUE
    jr z, .EndIfAtFinish
    ret
.EndIfAtFinish:

    push hl
    push bc
    call GetHitTick             ; de = beatmap_tick
    pop bc

    ld h, d
    ld l, e
    ld de, MISS_BOUND
    add hl, de                  ; hl = miss_bound

.ReturnIfBeatmapTickLteMissBound:
    ld a, b
    cp h
    jr z, .LowerBit             ; check lower if UPPER(current) == UPPER(miss_bound)
    jr nc, .EndIf               ; skip if UPPER(current) < UPPER(miss_bound)
    pop hl
    ret                         ; return if UPPER(current) > UPPER(miss_bound)
.LowerBit:
    ld a, c
    cp l
    jr nc, .EndIf               ; skip if LOWER(current) <= LOWER(miss_bound)
    pop hl
    ret                         ; return if LOWER(current) > LOWER(miss_bound)
.EndIf:

    ld b, STRLEN("Miss")
    ld de, MissStr
    call WriteText              ; print text

    pop hl
    call NextHit                ; advance hit tracker
    ret


ENDSECTION

