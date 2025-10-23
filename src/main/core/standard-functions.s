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

; Copy into VRAM safely 
; @param bc: length
; @param de: source address
; @param hl: destination address
VRAMCopy::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, VRAMCopy             ; not mode 0 or 1

    ld a,[de]
    ld [hl+], a
    inc de 
    dec bc
    ld a, b
    or a, c
    jr nz, VRAMCopy
    ret

; Copy into VRAM safely and faster (with tradeoff of smaller length)
; @param b: length (up to 255 obviously)
; @param de: source address
; @param hl: destination address
VRAMCopyFast::
    ld c, rSTAT & $FF
.Loop:
    ldh a, [$FF00+c]
    bit 1, a
    jr nz, .Loop                ; not mode 0 or 1

    ld a,[de]
    ld [hl+], a
    inc de 
    dec b
    jr nz, .Loop
    ret

; Halt for n frames before returning
; @param b: number of frames to halt for
WaitForFrames::
    xor a
.While:
    cp b
    jp z, .EndWhile
    halt                        ; wait for next frame
    inc a
    jp .While
.EndWhile:
    ret


ENDSECTION

