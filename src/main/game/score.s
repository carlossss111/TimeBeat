
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
SECTION "ScoreVars", HRAM

    hScore: ds 3                ; 6 digits, 3 bytes

SECTION "CountVars", WRAM0

    wMissCount: dw              ; 2 digits, 2 bytes
    wOkCount: dw
    wGoodCount: dw
    wPerfectCount: dw

SECTION "Score", ROM0

; Initialise the score to 0
InitScore::
    xor a
    ldh [hScore], a
    ldh [hScore + 1], a
    ldh [hScore + 2], a

    ld [wMissCount], a
    ld [wMissCount + 1], a
    
    ld [wOkCount], a
    ld [wOkCount + 1], a

    ld [wGoodCount], a
    ld [wGoodCount + 1], a

    ld [wPerfectCount], a
    ld [wPerfectCount + 1], a
    
    ld de, hScore
    call WriteScore

    ret


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
    call WriteScore
    
    ret


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
    ld a, [wMissCount]
    ld b, a
    ld a, [wMissCount + 1]
    ld c, a
    call PrintScoreCardMiss

    ld a, [wOkCount]
    ld b, a
    ld a, [wOkCount + 1]
    ld c, a
    call PrintScoreCardOK

    ld a, [wGoodCount]
    ld b, a
    ld a, [wGoodCount + 1]
    ld c, a
    call PrintScoreCardGood

    ld a, [wPerfectCount]
    ld b, a
    ld a, [wPerfectCount + 1]
    ld c, a
    call PrintScoreCardPerfect

    ret


; Add a miss score
AddMissScore::
    ld bc, wMissCount
    call IncCount
    ret


; Add an OK score
AddOKScore::
    ld bc, wOkCount
    call IncCount

    ld b, OK_SCORE_U
    ld c, OK_SCORE_L
    call AddScore

    ret
    

; Add a good score
AddGoodScore::
    ld bc, wGoodCount
    call IncCount

    ld b, GOOD_SCORE_U
    ld c, GOOD_SCORE_L
    call AddScore

    ret


; Add a perfect score
AddPerfectScore::
    ld bc, wPerfectCount
    call IncCount

    ld b, PERFECT_SCORE_U
    ld c, PERFECT_SCORE_L
    call AddScore

    ret

ENDSECTION

