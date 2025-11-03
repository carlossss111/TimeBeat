
def COLOUR_PALETTE equ %00011011
def TRUE equ 1
def FALSE equ 0

MACRO LOAD_ANIM
    ld a, \1
    ld [TILEMAP0 + \2 + (\3 * 32)], a
ENDM

