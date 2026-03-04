
DEF SINGLES_BIT EQU $80

/*******************************************************
* COMPRESSED MEMORY TRANSFER
* Data comes in as custom runlength bytes.
*
* If the high bit is 0, then the following n bytes are rl compressed:
* e.g. '$02 A' -> 'AA'
*
* If the high bit is 1, then the following n bytes are uncompressed:
* e.g. '$82 ABC' -> 'ABC'
*
* The first two bytes store the length of the uncompressed string.
********************************************************/

SECTION "Compression", ROM0

; Copy a compressed buffer from one location to another and decompress
; @param de: source address
; @param hl: destination address
RlCopy::
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]
    ld c, a
    inc de                      ; bc = uncompressed length

.Loop:
    ld a, [de]                  ; a = indicator byte
    push af
    and SINGLES_BIT
    jr nz, .Else

.IfCompressed:
    pop af                      ; a = indicator byte
    inc de                      ; de = ptr to source byte

    push bc
    push de

    ld c, a
    xor a                       
    ld b, a                     ; @param bc: size of memory
    
    ld a, [de]                  
    ld d, a                     ; @param d: value to be filled
                                
    call VRAMMemset             ; hl = ptr to next part of dest

    pop de
    pop bc

    inc de                      ; de = ptr to next pair

    dec bc
    dec bc                      ; bc -= 2 bytes
    ld a, b
    cp 0
    jr nz, .Loop
    ld a, c
    cp 0
    jr nz, .Loop
    jr .EndIf

.Else:
    pop af                      ; a = indicator byte
    inc de                      ; de = ptr to start of source substring

    push bc

    and ~SINGLES_BIT
    ld c, a
    xor a                       
    ld b, a                     ; @param bc: size of memory

    ld a, c
    ldh [hScratchA], a

    call VRAMCopy               ; copy chunk into memory

    pop bc

    push de
    ldh a, [hScratchA]          ; e = memory decremented by
    ld e, a
    ld a, c
    sub e
    ld c, a
    ld a, b
    sbc 0
    ld b, a 
    dec bc                      ; bc -= n bytes
    pop de

    ld a, b
    cp 0
    jr nz, .Loop
    ld a, c
    cp 0
    jr nz, .Loop
    ;jr .Endif

.EndIf:
    ret   


ENDSECTION

