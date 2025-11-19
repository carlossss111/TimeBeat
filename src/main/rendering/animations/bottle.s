include "macros.inc"
include "hardware.inc"


SECTION "BottleFrames", ROM0

; Frame 1
BottleF1:
    LOAD_ANIM $90, 14, 11
    LOAD_ANIM $91, 15, 11
    LOAD_ANIM $92, 16, 11
    LOAD_ANIM $93, 17, 11
    LOAD_ANIM $94, 1, 12
    LOAD_ANIM $95, 2, 12
    LOAD_ANIM $96, 4, 12
    LOAD_ANIM $97, 5, 12
    LOAD_ANIM $98, 6, 12
    LOAD_ANIM $99, 13, 12
    LOAD_ANIM $9a, 14, 12
    LOAD_ANIM $9b, 15, 12
    LOAD_ANIM $9c, 16, 12
    LOAD_ANIM $9f, 1, 13
    LOAD_ANIM $a0, 2, 13
    LOAD_ANIM $a1, 3, 13
    LOAD_ANIM $a2, 4, 13
    LOAD_ANIM $a3, 5, 13
    LOAD_ANIM $a4, 6, 13
    LOAD_ANIM $aa, 1, 14
    LOAD_ANIM $ab, 2, 14
    LOAD_ANIM $ac, 3, 14
    LOAD_ANIM $ad, 4, 14
    ret

; Frame 2
BottleF2:
    LOAD_ANIM $06, 4, 12
    LOAD_ANIM $06, 5, 12
    LOAD_ANIM $c8, 1, 12
    LOAD_ANIM $c9, 2, 12
    LOAD_ANIM $ca, 1, 13
    LOAD_ANIM $cb, 2, 13
    LOAD_ANIM $cc, 3, 13
    LOAD_ANIM $cd, 4, 13
    LOAD_ANIM $ce, 5, 13
    LOAD_ANIM $cf, 6, 13
    LOAD_ANIM $d0, 4, 14
    LOAD_ANIM $d1, 15, 11
    LOAD_ANIM $d2, 16, 11
    LOAD_ANIM $d3, 17, 11
    LOAD_ANIM $d4, 14, 12
    LOAD_ANIM $d5, 15, 12
    LOAD_ANIM $d6, 16, 12
    LOAD_ANIM $e1, 6, 12
    ret

; Frame 3
BottleF3:
    LOAD_ANIM $29, 4, 14
    LOAD_ANIM $d7, 3, 13
    LOAD_ANIM $d8, 4, 13
    LOAD_ANIM $d9, 5, 13
    LOAD_ANIM $da, 6, 13
    LOAD_ANIM $db, 14, 11
    LOAD_ANIM $dc, 15, 11
    LOAD_ANIM $dd, 16, 11
    LOAD_ANIM $de, 14, 12
    LOAD_ANIM $df, 15, 12
    LOAD_ANIM $e0, 16, 12
    LOAD_ANIM $e1, 6, 12
    LOAD_ANIM $e2, 5, 12
    ret

SECTION "BottleAnimationVars", WRAM0

    wNextFrame: db

SECTION "BottleAnimation", ROM0

InitBottleAnimation::
    xor a
    ld [wNextFrame], a
    ret

AnimateBottle::
    ld a, [wNextFrame]
    ld hl, .Switch
    rla
    rla
    rla
    rla                         ; a * 16
    ld c, a
    ld b, 0
    add hl, bc                  ; calculate switch address
    jp hl
    
.Switch
    call BottleF1               ; 3 bytes
    ld hl, wNextFrame           ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 7
        nop                     ; 7 bytes padding
    ENDR

    call BottleF2
    ld hl, wNextFrame
    inc [hl]
    jr .SwitchEnd
    FOR V, 7
        nop
    ENDR

    call BottleF3
    ld hl, wNextFrame
    ld [hl], 0
    jr .SwitchEnd
    FOR V, 7
        nop     
    ENDR
    ld a, [wNextFrame]
    inc a      
    ld [wNextFrame], a
    jr .SwitchEnd

.SwitchEnd
    ret

ENDSECTION

