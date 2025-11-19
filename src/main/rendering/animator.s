include "macros.inc"

DEF MAX_WORDS EQU 10            ; max animations
DEF MAX_BYTES EQU MAX_WORDS * 2

DEF FRAMES_PER_ANIM EQU 16      ; must be divisble by rightshifts!
DEF BITSHIFTS_PER_ANIM EQU 4    ; bits before the divisor

/*******************************************************
* ANIMATOR
* Maintains a list of function pointers.
* Call Animate() once per main loop to call them at the
* correct time.
********************************************************/
SECTION "AnimatorVars", WRAM0

    Animations: ds MAX_BYTES
    NumOfAnimations: db 

SECTION "Animator", ROM0

; Clears the animations array and sets the size to 0
InitAnimator::
    ld bc, MAX_BYTES
    ld d, 0
    ld hl, Animations
    call Memset                 ; set all array content to 0

    xor a
    ld [NumOfAnimations], a     ; set size variable to 0

    ret

; Adds a function pointer to the animations list
; @param bc: function pointer
AddAnimation::
    ld hl, Animations
    ld d, 0
    ld a, [NumOfAnimations]
    sla a
    ld e, a
    add hl, de                  ; go to right place on array

    ld [hl], b
    inc hl
    ld [hl], c                  ; insert funcptr into array

    inc d
    ld a, d
    ld [NumOfAnimations], a     ; array size ++

    ret

; Returns 1 if the frame is divisible by FRAMES_PER_ANIM
; Returns 0 otherwise
; @param a: current frame number
; @param b: bitshifts per animation
; @returns a: true or false
IsAnimationFrame:
.DivisibleLoop:
    rra                         ; right shift frame counter
    jp nc, .Continue            ; if we have a carry, the number is not divisible
    xor a
    ret
.Continue:
    dec b                       ; decrement bitshifts per animation
    jp nz, .DivisibleLoop       ; and loop if there are more shifts to do
    ld a, TRUE
    ret

; Checks if we are on an animation frame, if we are, animate!
Animate::
    ld a, [hFrameCounter]
    ld b, BITSHIFTS_PER_ANIM
    ld de, 0
    call IsAnimationFrame
    cp TRUE
    jp z, .AnimationFrameLoop   ; confirm it is an animation frame,
    ret                         ; otherwise return early

.AnimationFrameLoop
    ld a, [NumOfAnimations]
    cp e
    jp z, .AnimationEnd         ; check that we havent called all animations
    push de

    sla e
    ld hl, Animations
    add hl, de
    ld d, [hl]
    inc hl
    ld e, [hl]
    ld h, d
    ld l, e

    ld bc, .Ret
    push bc
    jp hl                       ; call function pointer

.Ret:
    pop de
    inc e

    jp .AnimationFrameLoop
.AnimationEnd:
    ret

ENDSECTION

