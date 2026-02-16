include "hardware.inc"

def VBLANK_SCANLINE equ 144
def SCREEN_TILE_WIDTH equ 20
def SCREEN_TILE_HEIGHT equ 18

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
    di
    bit 1, a
    jr nz, VRAMCopy             ; not mode 0 or 1

    ld a,[de]
    ei

    ld [hl+], a
    inc de 
    dec bc
    ld a, b
    or a, c
    jr nz, VRAMCopy

    ret

; Copy a 20x18 tilemap into VRAM safely
; @param bc: length
; @param de: source address
; @param hl: destination address
VRAMCopy20x18::
    ld a, SCREEN_TILE_WIDTH
    push af                     ; a = tile width

.Blank:
    ldh a, [rSTAT]
    di
    bit 1, a
    jr nz, .Blank               ; not mode 0 or 1

    ld a,[de]
    ei

    ld [hl+], a                 ; copy into VRAM

    pop af
    push bc
    dec a
    cp 0
    jr nz, .Skip
.AddToDest:
    ld bc, 12
    add hl, bc                  ; go to next line
    ld a, SCREEN_TILE_WIDTH
.Skip:
    pop bc
    push af

    inc de 
    dec bc
    ld a, b
    or a, c
    jr nz, .Blank

    pop af
    ret


; Copy into VRAM safely and faster (with tradeoff of smaller length)
; @param b: length (up to 255 obviously)
; @param de: source address
; @param hl: destination address
VRAMCopyFast::
    ld c, rSTAT & $FF
.Loop:
    ldh a, [$FF00+c]
    di
    bit 1, a
    jr nz, .Loop                ; not mode 0 or 1

    ld a,[de]
    ei
    ld [hl+], a
    inc de 
    dec b
    jr nz, .Loop
    
    ret

; Loads a particular byte into a block of memory
; @param bc: size of memory
; @param d: value to be filled
; @param hl: desination address
Memset::
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or a, c
    jp nz, Memset               ; loop if remaining length != 0
    ret

; Loads a particular byte into a block of memory, safe for VRAM
; @param bc: size of memory
; @param d: value to be filled
; @param hl: desination address
VRAMMemset::
    ldh a, [rSTAT]
    di                          ; disable interrupts, else the PPU might lock!
    bit 1, a
    jr nz, VRAMMemset           ; not mode 0 or 1

    ld [hl], d
    ei
    inc hl
    dec bc
    ld a, b
    or a, c
    jp nz, VRAMMemset           ; loop if remaining length != 0

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

