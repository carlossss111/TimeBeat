include "hardware.inc"

def VBLANK_SCANLINE equ 144

/*******************************************************
* STDLIB
* While there is no 'stdlib', here are general util funcs
********************************************************/
SECTION "StandardLibrary", ROM0

; Copy a buffer from one location to another
; @param bc: length of the buffer
; @param de: source address
; @param hl: destination address
Memcpy::
    ld a, [de]
    ld [hl+], a                 ; load byte from src into dest
    inc de                      ; inc source ptr
    dec bc                      ; dec length
    ld a, b
    or a, c
    jp nz, Memcpy               ; loop if remaining length != 0
    ret

ENDSECTION

