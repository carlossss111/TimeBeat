
; Save space by turning functions and subroutines into macros where
; appropriate

/*******************************************************
* SCRATCH MEMORY
********************************************************/
; Initialises scratch memory
MACRO call_InitScratchMemory
    xor a
    ld hl, hScratchA
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
ENDM

