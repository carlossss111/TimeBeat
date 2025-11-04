include "hardware.inc"

/*******************************************************
* SHADOW OAM
* Free-access memory that gets copied to VRAM when its safe
********************************************************/
SECTION "ShadowOAM", WRAM0

    ShadowOAM:: ds 160
    ShadowOAMEnd:

SECTION "ShadowOAMFunctions", ROM0
    
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

