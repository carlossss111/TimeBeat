include "hardware.inc"

DEF WINDOW_X_OFFSET EQU 7
DEF WINDOW_Y_OFFSET EQU 1
DEF MIDDLE_FIRST_SCANLINE EQU 9
DEF MIDDLE_LAST_SCANLINE EQU 120

DEF MAX_CHARS_IN_STRING EQU 8
DEF TIME_TO_SHOW_STRING EQU 60  ; frames

/*******************************************************
* WINDOW RENDERING
* Render the game top and bottom window using stat ints
*******************************************************/
SECTION "WindowRendererVars", WRAM0

    wTilemapPtr: dw             ; pointer to tilemap in use
    wEmptyTile: db              ; tile index for empty tile
    wTextFade: db               ; countdown for when to clean text

SECTION "WindowRenderer", ROM0

; Init the window
; @param hl: pointer to tilemap in use
; @param a: tile index for an empty tile
InitWindow::
    ld [wEmptyTile], a
    ld a, h
    ld [wTilemapPtr], a
    ld a, l
    ld [wTilemapPtr + 1], a

    ld a, WINDOW_X_OFFSET       ; fixes weird alignment issue
    ld [rWX], a
    ld a, WINDOW_Y_OFFSET       ; good for the vibes
    ld [rWY], a

    call MiddleScreen
    ret

; Adjust the window position and set interrupt at middle scanlines
TopScreen:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, TopScreen            ; wait for hblank

    ld a, MIDDLE_FIRST_SCANLINE 
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, MiddleScreen
    call SetStatHandler         ; set handler for next STAT interrupt
    ret

; Turn off the window and set the next interrupt at the bottom part of the screen
MiddleScreen:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, MiddleScreen         ; wait for hblank

    ldh a, [rLCDC]
    and ~LCDC_WINDOW
    ldh [rLCDC], a               ; turn off window

    ld a, MIDDLE_LAST_SCANLINE
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, BottomScreen
    call SetStatHandler         ; set handler for next STAT interrupt
    ret

; Turn on the window, adjust the position, and set next interrupt for top of screen
BottomScreen:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, BottomScreen         ; wait for hblank

    ldh a, [rLCDC]
    or LCDC_WINDOW
    ldh [rLCDC], a               ; turn on window

    xor a
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, TopScreen
    call SetStatHandler         ; set handler for next STAT interrupt
    ret

; Clears text displayed to the screen
ClearText::
    ld bc, MAX_CHARS_IN_STRING 
    ld a, [wEmptyTile]
    ld d, a
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    call VRAMMemset
    ret

; Write text on the top bar
; @param de: source string
; @param b: length (max 8)
WriteText::
    push de
    push bc
    call ClearText              ; clear existing text
    pop bc
    pop de

    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a
    call VRAMCopyFast           ; print new message
    
    ld a, TIME_TO_SHOW_STRING
    ld [wTextFade], a

    ret

; Clear text thats been there for too long
ClearOldText::
    ld a, [wTextFade]
    dec a
    ld [wTextFade], a           ; decrement text fade counter

    cp 0
    jp nz, .EndIf
.If:
    call ClearText              ; clear the text
    ld a, TIME_TO_SHOW_STRING
    ld [wTextFade], a           ; reset counter
.EndIf:
    ret

ENDSECTION

