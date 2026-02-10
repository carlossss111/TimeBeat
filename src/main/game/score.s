
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

SECTION "Score", ROM0

; Initialise the score to 0
InitScore::
    xor a
    ldh [hScore], a
    ldh [hScore + 1], a
    ldh [hScore + 2], a
    
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


; Add an OK score
AddOKScore::
    ld b, OK_SCORE_U
    ld c, OK_SCORE_L
    call AddScore
    ret
    

; Add a good score
AddGoodScore::
    ld b, GOOD_SCORE_U
    ld c, GOOD_SCORE_L
    call AddScore
    ret


; Add a perfect score
AddPerfectScore::
    ld b, PERFECT_SCORE_U
    ld c, PERFECT_SCORE_L
    call AddScore
    ret

ENDSECTION

