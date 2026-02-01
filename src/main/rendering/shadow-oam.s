include "hardware.inc"

/*******************************************************
* SHADOW OAM
* Free-access memory that gets copied to VRAM when its safe
********************************************************/
SECTION "ShadowOAM", WRAM0 [$C000]

    ShadowOAM:: ds 160
    ShadowOAMEnd:

ENDSECTION


/*******************************************************
* HRAM RENDERER
* Renders from ShadowOAM to real OAM, must be in HRAM
********************************************************/
SECTION "OAMRenderer", HRAM
    
    ; Takes 160 cycles to load from Shadow OAM to real OAM
    RenderToOAM:: ds $A

ENDSECTION


/*******************************************************
* OAM FUNCTIONS
* Utility functions to init OAM and shadow OAM
********************************************************/
SECTION "ShadowOAMFunctions", ROM0

; This code is not called directly! It is copied into HRAM because DMA is not available from ROM
HramCode:
    LOAD "RenderToOAM", HRAM
HramLocation:
    ld a, HIGH(ShadowOAM)
    ldh [$FF46], a              ; start DMA transfer (starts right after instruction)
    ld a, 40                    ; delay for a total of 4×40 = 160 M-cycles
.Wait                           ; 
    dec a                       ; 1 M-cycle
    jr nz, .Wait                ; 3 M-cycles
    ret
    ENDL
.End

; Load DMA code into HRAM
InitDMA::
    ld bc, HramCode.End - HramCode
    ld de, HramCode
    ld hl, RenderToOAM
    call Memcpy
    
; Fill shadow OAM with null bytes
ClearShadowOAM::
    ld hl, ShadowOAM
    ld b, ShadowOAMEnd - ShadowOAM
.For:
    xor a
    ld [hl+], a
    dec b
    jp nz, .For
    ret

ENDSECTION

