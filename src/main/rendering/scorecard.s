include "hardware.inc"

DEF FIRST_DIGIT_VRAM EQU $1

DEF PERFECT_INDEX EQU 110
DEF GOOD_INDEX EQU 174
DEF OK_INDEX EQU 238
DEF MISS_INDEX EQU 302

DEF TOTAL_INDEX EQU $184

DEF SCORECARD_TILEMAP EQU TILEMAP0

/*******************************************************
* SCORE CARD
* Print the score on the summary
********************************************************/
SECTION "ScoreCardBigDigits", ROM0

    BigZero: db $24, $25, $30, $31
    BigOne: db $26, $27, $32, $33
    BigTwo: db $28, $29, $34, $35
    BigThree: db $2a, $2b, $36, $37
    BigFour: db $2c, $2d, $38, $39
    BigFive: db $2e, $2f, $3a, $3b
    BigSix: db $3f, $40, $4d, $3b
    BigSeven: db $41, $42, $4e, $4f
    BigEight: db $3f, $43, $4d, $3b
    BigNine: db $2e, $44, $50, $51 

SECTION "ScoreCard", ROM0

; Prints a count on the scorecard
; @param bc: number of hits
; @param de: tile index offset
PrintScoreCardHit:
    ld hl, SCORECARD_TILEMAP
    add hl, de                  ; hl = tilemap index to print at

    ld a, b
    and $0F
    add a, FIRST_DIGIT_VRAM
    push af                     ; a = first digit
.HBlank1:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .HBlank1             ; not mode 0 or 1

    pop af
    ld [hl+], a                 ; copy to VRAM

    ld a, c
    swap a
    and $0F
    add a, FIRST_DIGIT_VRAM     ; a = second digit
    push af
.HBlank2:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .HBlank2             ; not mode 0 or 1

    pop af
    ld [hl+], a                 ; copy to VRAM

    ld a, c
    and $0F
    add a, FIRST_DIGIT_VRAM
    ld c, a                     ; c = third digit
.HBlank3:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .HBlank3             ; not mode 0 or 1

    ld [hl], c                  ; copy to VRAM

    ret


; Prints the miss count on the scorecard
; @param bc: count
PrintScoreCardMiss::
    ld de, MISS_INDEX
    jp PrintScoreCardHit
    ;ret


; Prints the OK count on the scorecard
; @param bc: count
PrintScoreCardOK::
    ld de, OK_INDEX
    jp PrintScoreCardHit
    ;ret


; Prints the good count on the scorecard
; @param bc: count
PrintScoreCardGood::
    ld de, GOOD_INDEX
    jp PrintScoreCardHit
    ;ret


; Prints the perfect count on the scorecard
; @param bc: count
PrintScoreCardPerfect::
    ld de, PERFECT_INDEX
    jp PrintScoreCardHit
    ;ret


; Draws a big number
; @param hl: tile index to start drawing to
; @param de: pointer to 4 big number tiles
DrawBigNumber:
    push de
    push hl
    ld b, 2
    call VRAMCopyFast           ; draw top 2 tiles
    pop hl
    pop de

    inc de
    inc de                      ; next part of digit

    ld c, 32                    ; next row
    ld b, 0
    add hl, bc
    ld b, 2
    jp VRAMCopyFast           ; draw bottom 2 tiles
    ;ret


; Prints the score card total using 6 big digits
; @param bc: pointer to score BCD
/*
function(tilemap, digits) {
    vram_location = tilemap + OFFSET

    while(digits){
        digit = digits->next

        big_number = OFFSET
        big_number += (digit * 4)

        draw(vram_location, big_number)
        vram_location++
    }
}
*/
PrintScoreCardTotal::
    ld hl, SCORECARD_TILEMAP + TOTAL_INDEX

    ld a, 3
    ldh [hScratchA], a          ; loop three times
.LoopDigits:
    ld a, [bc]
    swap a
    and $0F                     ; a = first digit

    ld e, a
    ld d, 4 - 1
.MultiplyBy4:
    add e
    dec d
    jr nz, .MultiplyBy4         ; a = first digit * 4

    push hl
    ld hl, BigZero
    ld d, 0
    ld e, a
    add hl, de
    ld d, h
    ld e, l
    pop hl                      ; de = pointer to big digit
    
    push bc
    push de
    push hl
    call DrawBigNumber          ; draw it!
    pop hl
    pop de
    pop bc

    inc hl
    inc hl                      ; hl next digit along

    ld a, [bc]
    and $0F                     ; a = second digit

    ld e, a
    ld d, 4 - 1
.MultiplyBy4Again:
    add e
    dec d
    jr nz, .MultiplyBy4Again    ; a = second digit * 4

    push hl
    ld hl, BigZero
    ld d, 0
    ld e, a
    add hl, de
    ld d, h
    ld e, l
    pop hl                      ; de = pointer to big digit
    
    push bc
    push de
    push hl
    call DrawBigNumber          ; draw it again!
    pop hl
    pop de
    pop bc
    
    inc bc                      ; bc = pointer to next two digits
    inc hl
    inc hl                      ; hl next digit along
    
    ldh a, [hScratchA]
    dec a
    ldh [hScratchA], a
    cp 0
    jr nz, .LoopDigits
.EndLoop:
    
    ret


ENDSECTION

