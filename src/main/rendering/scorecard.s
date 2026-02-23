include "hardware.inc"

DEF FIRST_DIGIT_VRAM EQU $1

DEF PERFECT_INDEX EQU 110
DEF GOOD_INDEX EQU 174
DEF OK_INDEX EQU 238
DEF MISS_INDEX EQU 302

/*******************************************************
* SCORE CARD
* Print the score on the summary
********************************************************/
SECTION "ScoreCardVars", WRAM0

    wTilemapPtr: dw             ; pointer to tilemap in use

SECTION "ScoreCard", ROM0

; Init the scorecard
; @param hl: pointer to tilemap in use
InitScoreCard::
    ld a, h
    ld [wTilemapPtr], a
    ld a, l
    ld [wTilemapPtr + 1], a
    ret


; Prints a count on the scorecard
; @param hl: tile index location
; @param bc: number of hits
PrintScoreCardHit:
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
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    ld de, MISS_INDEX
    add hl, de
    call PrintScoreCardHit

    ret


; Prints the OK count on the scorecard
; @param bc: count
PrintScoreCardOK::
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    ld de, OK_INDEX
    add hl, de
    call PrintScoreCardHit

    ret


; Prints the good count on the scorecard
; @param bc: count
PrintScoreCardGood::
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    ld de, GOOD_INDEX
    add hl, de
    call PrintScoreCardHit

    ret


; Prints the perfect count on the scorecard
; @param bc: count
PrintScoreCardPerfect::
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    ld de, PERFECT_INDEX
    add hl, de
    call PrintScoreCardHit

    ret


PrintScoreCardTotal::
    ret

ENDSECTION

