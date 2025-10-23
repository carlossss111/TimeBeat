include "hardware.inc"


/*******************************************************
* FADE TRANSITION
* Used to fade-to-black and back again when transitioning VRAM
*******************************************************/
SECTION "FadeVars", WRAM0

    DEF TRANSITIONS EQU 3       ; 3 palette shifts
    DEF FRAMES_PER_FADE EQU 3   ; frames between a palette shift


SECTION "Fade", ROM0

FadeIn::
    ld b, TRANSITIONS 
    ld c, 0
    ld d, %10010011             ; palette we want to use to shift left
.For:
    ld a, c
    cp b
    jp z, .EndFor               ; for (i = 0; i < 3; i++):

    push de
    push bc
    ld b, FRAMES_PER_FADE
    call WaitForFrames          ;   waitForFrames(num_to_wait)
    pop bc
    pop de

    ld a, [rBGP]
    sla d                       ;   shift d left and set carry flag
    rla                         ;   rotate a left and set the low bit as the carry
    sla d                       ;   
    rla                         ;   
    ld [rBGP], a                ;   store bitshifted palette

    inc c                       ; endfor
    jp .For
.EndFor:
    ret

; Fades the screen to black using the palette
FadeOut::
    ld a, %11100100             
        ;  11111001
        ;  11111110
        ;  11111111
    ld [rBGP], a                ; palette = black-dark-light-white
    ld b, TRANSITIONS
    ld c, 0
.For:
    ld a, c
    cp b
    jp z, .EndFor               ; for (i = 0; i < 3; i++):

    push bc
    ld b, FRAMES_PER_FADE
    call WaitForFrames          ;   waitForFrames(num_to_wait)
    pop bc

    ld a, [rBGP]
    sra a
    sra a
    ld [rBGP], a                ;   bitshift palette right twice to darken

    inc c                       ; endfor
    jp .For
.EndFor:
    ret

ENDSECTION

