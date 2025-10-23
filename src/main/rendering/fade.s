include "hardware.inc"


/*******************************************************
* FADE TRANSITION
* Used to fade-to-black and back again when transitioning VRAM
*
*    int palette = 0b11100100
*
*    for (int i = 0; i < 3; i++) {
*        int lastFrame = realFrame
*        int fadeFrame = 0
*
*        while(fadeFrame < 5) {
*            if (lastFrame != realFrame) {
*                lastFrame = realFrame
*                fadeFrame++
*            }
*        }
*        palette = palette >> 2
*    }
*******************************************************/
SECTION "FadeVars", WRAM0

    DEF FRAMES_PER_FADE EQU 3   ; frames between a palette shift

    wFadeFrame: db              ; counter used while waiting for frames
    wLastFrame: db              ; value of last frame

SECTION "Fade", ROM0

FadeIn::
    ret ;unimplemented

; Internal loop used to fade out
FadeOutInner:
.While:
    ld a, [wFadeFrame]
    ld b, FRAMES_PER_FADE
    cp b
    jp z, .EndWhile             ; while (fadeFrame < 5):

    ld c, a
    ld a, [wLastFrame]
    ld b, a
    ld a, [hFrameCounter]
    cp b
    jp z, .EndIf                ;   if (lastFrame != realFrame):
.If:
    ld [wLastFrame], a          ;       lastFrame = realFrame
    ld a, [wFadeFrame]
    inc a
    ld [wFadeFrame], a          ;       fadeFrame++
.EndIf:                         ;   endif
    jp .While                   ; endwhile
.EndWhile:
    ld a, [rBGP]
    sra a
    sra a
    ld [rBGP], a                ; bitshift palette right twice to darken
    ret

; Fades the screen to black using the palette
FadeOut::
    ld a, %11100100             
        ;  11111001
        ;  11111110
        ;  11111111
    ld [rBGP], a                ; palette = black-dark-light-white
    ld b, 3
    ld c, 0
.For:
    ld a, c
    cp b
    jp z, .EndFor               ; for (i = 0; i < 3; i++):

    xor a
    ld [wFadeFrame], a          ;   fadeFrame = 0
    ld a, [hFrameCounter]
    ld [wLastFrame], a          ;   lastFrame = (current frame)

    push bc
    call FadeOutInner           ;   fadeOutInner()
    pop bc

    inc c                       ; endfor
    jp .For
.EndFor:
    ret

ENDSECTION

