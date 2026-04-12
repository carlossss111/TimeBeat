
DEF OK_SCORE_U EQU $00
DEF OK_SCORE_L EQU $25

DEF GOOD_SCORE_U EQU $00
DEF GOOD_SCORE_L EQU $50

DEF PERFECT_SCORE_U EQU $01
DEF PERFECT_SCORE_L EQU $00

/*******************************************************
* SCORE
* Score Handling using binary coded decimal (BCD)
********************************************************/
SECTION "ScoreCountVars", HRAM

    hStart:
    hScore: ds 3                ; 6 digits, 3 bytes
    hMissCount: dw              ; 2 digits, 2 bytes
    hOkCount: dw
    hGoodCount: dw
    hPerfectCount: dw
    hEnd:

SECTION "Score", ROM0

; Initialise the score to 0
InitScore::
    ld bc, hEnd - hStart        ; initialise all as zero
    ld d, 0
    ld hl, hStart
    call VRAMMemset
       
    ld de, hScore
    jp WriteScore
    ;ret


; Add BCD int to the score and draw to the window
; @param b: bcd upper 2 digits to add
; @param c: bcd lower 2 digits to add
AddScore:
    ldh a, [hScore + 2]
    add c                       ; add to lower 2 digits
    daa                         ; bcd
    ldh [hScore + 2], a

    ldh a, [hScore + 1]
    adc b                       ; add to upper 2 digits
    daa                         ; bcd
    ldh [hScore + 1], a

    ldh a, [hScore]
    adc 0                       ; add carry flag
    daa                         ; bcd
    ldh [hScore], a

    ld de, hScore
    jp WriteScore
    ;ret


; Increment the hit counter, BCD format
; @param bc: pointer to counter
IncCount:
    ld d, 1

    inc bc
    ld a, [bc]
    add d                       ; add to lower 2 digits
    daa                         ; bcd
    ld [bc], a

    dec bc
    ld a, [bc]
    adc 0                       ; add carry to upper 2 digits
    daa                         ; bcd
    ld [bc], a
    
    ret


; Print the scorecard on the summary page
PrintScoreCard::
    ldh a, [hMissCount]
    ld b, a
    ldh a, [hMissCount + 1]
    ld c, a
    call PrintScoreCardMiss

    ldh a, [hOkCount]
    ld b, a
    ldh a, [hOkCount + 1]
    ld c, a
    call PrintScoreCardOK

    ldh a, [hGoodCount]
    ld b, a
    ldh a, [hGoodCount + 1]
    ld c, a
    call PrintScoreCardGood

    ldh a, [hPerfectCount]
    ld b, a
    ldh a, [hPerfectCount + 1]
    ld c, a
    call PrintScoreCardPerfect
    
    ld bc, hScore
    jp PrintScoreCardTotal
    ;ret


; Add a miss score
AddMissScore::
    ld bc, hMissCount
    jp IncCount
    ;ret


; Add an OK score
AddOKScore::
    ld bc, hOkCount
    call IncCount

    ld b, OK_SCORE_U
    ld c, OK_SCORE_L
    jp AddScore
    ;ret


; Add a good score
AddGoodScore::
    ld bc, hGoodCount
    call IncCount

    ld b, GOOD_SCORE_U
    ld c, GOOD_SCORE_L
    jp AddScore
    ;ret


; Add a perfect score
AddPerfectScore::
    ld bc, hPerfectCount
    call IncCount

    ld b, PERFECT_SCORE_U
    ld c, PERFECT_SCORE_L
    jp AddScore
    ;ret

ENDSECTION

