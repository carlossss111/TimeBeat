
DEF SINGLES_BIT EQU $80
DEF STAIRS_BIT EQU $40

/*******************************************************
* COMPRESSED MEMORY TRANSFER
* Data comes in as custom runlength bytes.
*
* If the high bit is 1, then the following n bytes are uncompressed:
* e.g. '$82 ABC' -> 'ABC'
*
* Else if the second bit is 1, then the following n bytes are compressed incrementally:
* e.g. '$43 A' -> 'ABC'
*
* Else then the following n bytes are rl compressed:
* e.g. '$02 A' -> 'AA'
*
* The first two bytes store the length of the uncompressed string.
********************************************************/

SECTION "Compression", ROM0

; Copy a compressed buffer from one location to another and decompress
; @param de: source address
; @param bc: source address end
; @param hl: destination address
RlCopy::
    ld a, [de]                  ; a = indicator byte

    push af
    and SINGLES_BIT
    jr nz, .ElseSingles

    pop af
    push af
    and STAIRS_BIT
    jr nz, .IfStairs

.IfRunlength:
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

    ld a, b
    cp d
    jr nz, RlCopy
    ld a, c
    cp e
    jr nz, RlCopy
    jr .EndIf

.IfStairs:
    pop af                      ; a = indicator byte
    inc de                      ; de = ptr to source byte

    push bc
    push de

    and ~STAIRS_BIT
    ld b, a                     ; @param c: size of memory
    
    ld a, [de]                  
    ld d, a                     ; @param d: value to start with
                                
    call VRAMStairsCopy         ; hl = ptr to next part of dest

    pop de
    pop bc

    inc de                      ; de = ptr to next pair

    ld a, b
    cp d
    jr nz, RlCopy
    ld a, c
    cp e
    jr nz, RlCopy
    jr .EndIf

.ElseSingles:
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

    ld a, b
    cp d
    jr nz, RlCopy
    ld a, c
    cp e
    jr nz, RlCopy
    ;jr .Endif

.EndIf:
    ret   


ENDSECTION

