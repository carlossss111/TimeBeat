
/*******************************************************
* SCRATCH VARIABLES
* Scratch variables for regular local usage
********************************************************/
SECTION "ScratchVars", HRAM

    hScratchA:: dw 
    hScratchB:: dw
    hScratchC:: dw

SECTION "Scratch", ROM0

; Clears scratch variables
InitScratchMemory::
    xor a
    ldh [hScratchA], a
    ldh [hScratchA + 1], a
    ldh [hScratchB], a
    ldh [hScratchB + 1], a
    ldh [hScratchC], a
    ldh [hScratchC + 1], a
    ret

ENDSECTION

