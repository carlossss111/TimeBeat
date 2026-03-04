
/*******************************************************
* WAIT
* Wait functions
********************************************************/
SECTION "Wait", ROM0

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

