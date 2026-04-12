
/*******************************************************
* GENERAL INTERRUPT
* Shared code called between both VBlank and Stat interrupts
* (I'm really pushing for space here aren't I!)
********************************************************/

SECTION "GeneralInterruptCode", ROM0

; Rawdogging for some extra bytes
; Do not CALL, only jump to at the end of the handler 
HandlerSelectorPop::
    pop hl
    ld a, h
    ldh [hScratchC], a
    ld a, l
    ldh [hScratchC + 1], a

    pop hl
    ld a, h
    ldh [hScratchB], a
    ld a, l
    ldh [hScratchB + 1], a

    pop hl
    ld a, h
    ldh [hScratchA], a
    ld a, l
    ldh [hScratchA + 1], a

    pop hl                      ; restore all register states
    pop de
    pop bc
    pop af
    
    reti
  

; Called by interrupt
; Doesn't do anything except implicitly wake up the CPU from the halt instr
DefaultHandler::
    ret

ENDSECTION

