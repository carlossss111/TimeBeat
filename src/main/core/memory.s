include "hardware.inc"

def VBLANK_SCANLINE equ 144
def SCREEN_TILE_WIDTH equ 20
def SCREEN_TILE_HEIGHT equ 18

/*******************************************************
* MEMORY TRANSFER
* While there is no 'stdlib', here are general util funcs
********************************************************/
SECTION "MemoryFunctions", ROM0

; Copy into VRAM safely 
; @param bc: length
; @param de: source address
; @param hl: destination address
VRAMCopy::
    di
    ldh a, [rSTAT]
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

; Copy into VRAM safely and faster (with tradeoff of smaller length)
; @param b: length (up to 255 obviously)
; @param de: source address
; @param hl: destination address
VRAMCopyFast::
    ld c, rSTAT & $FF
.Loop:
    di
    ldh a, [$FF00+c]
    bit 1, a
    jr nz, .Loop                ; not mode 0 or 1

    ld a,[de]
    ei
    ld [hl+], a
    inc de 
    dec b
    jr nz, .Loop
    
    ret


; Loads a particular byte into a block of memory, safe for VRAM
; @param bc: size of memory
; @param d: value to be filled
; @param hl: desination address
VRAMMemset::
    di                          ; disable interrupts, else the PPU might lock!
    ldh a, [rSTAT]
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

; Copy into VRAM incrementally
; @param b: length 
; @param d: value to start with and increment from
; @param hl: destination address
VRAMStairsCopy::
    ld c, rSTAT & $FF
.Loop:
    di
    ldh a, [$FF00+c]
    bit 1, a
    jr nz, .Loop                ; not mode 0 or 1

    ld [hl], d
    inc d                       ; increment d !!!!
    ei
    inc hl
    dec b
    jr nz, .Loop

    ret


ENDSECTION

