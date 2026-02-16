include "hardware.inc"

DEF WINDOW_X_OFFSET EQU 7
DEF WINDOW_Y_OFFSET EQU 1
DEF MIDDLE_FIRST_SCANLINE EQU 9
DEF MIDDLE_LAST_SCANLINE EQU 120

DEF MAX_CHARS_IN_STRING EQU 8
DEF TIME_TO_SHOW_STRING EQU 30  ; frames

DEF SCORE_SCREEN_OFFSET EQU 14 
DEF SCORE_NUM_OF_DIGITS EQU 6
DEF FIRST_DIGIT_VRAM EQU $7

DEF LEFT_BTN_POS EQU $43
DEF RIGHT_BTN_POS EQU $47
DEF B_BTN_POS EQU $4c
DEF A_BTN_POS EQU $50

DEF BLANK_EFFECT EQU $0
DEF BTN_EFFECT_LEFT EQU $5
DEF BTN_EFFECT_RIGHT EQU $6

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
    jr nz, BottomScreen         ; wait for hblank

    ldh a, [rLCDC]
    or LCDC_WINDOW
    ldh [rLCDC], a               ; turn on window

    xor a
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, TopScreen
    call SetStatHandler         ; set handler for next STAT interrupt
    ret


; Write text on the top bar at the top right
; @param de: pointer to packed binary-coded-decimal (BCD) number
WriteScore::

    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a                        ; hl = dst vram address
    ld bc, SCORE_SCREEN_OFFSET
    add hl, bc
    ld b, SCORE_NUM_OF_DIGITS / 2  ; b = num bytes
   
.Loop:
    ld a, [de]
    and $F0
    swap a
    add a, FIRST_DIGIT_VRAM
    push af
.HBlank1:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .HBlank1; not mode 0 or 1

    pop af
    ld [hl+], a                 ; copy to VRAM

    ld a, [de]
    and $0F
    add a, FIRST_DIGIT_VRAM
    push af
.HBlank2:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .HBlank2             ; not mode 0 or 1

    pop af
    ld [hl+], a

    inc de
    dec b
    jr nz, .Loop
.EndLoop:
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


/*******************************************************
* BUTTON PRESS EFFECTS
* Draw on the window if a button is pressed/released
********************************************************/
SECTION "ButtonPressEffects", ROM0

; Draws on the two tiles left and right of a button tile on the window
; @param b: Input enum (JOYP_A | JOYP_B | JOYP_LEFT << 4 | JOYP_RIGHT << 4)
; @param d: Tile to draw on the left (BLANK_EFFECT | BTN_EFFECT_LEFT)
; @param e: Tile to draw on the right (BLANK_EFFECT | BTN_EFFECT_LEFT)
RenderButtonEffect:
    ld a, [wTilemapPtr]
    ld h, a
    ld a, [wTilemapPtr + 1]
    ld l, a

.CheckA:
    ld a, JOYP_A
    cp b
    jr nz, .CheckB

    ld bc, A_BTN_POS - 1
    add hl, bc                  ; hl = left of A button tile
    jr .Render

.CheckB:
    ld a, JOYP_B
    cp b
    jr nz, .CheckLeft

    ld bc, B_BTN_POS - 1
    add hl, bc                  ; hl = left of B button tile
    jr .Render

.CheckLeft:
    ld a, JOYP_LEFT << 4
    cp b
    jr nz, .Right

    ld bc, LEFT_BTN_POS - 1
    add hl, bc                  ; hl = left of LEFT button tile
    jr .Render

.Right:
    ld bc, RIGHT_BTN_POS - 1
    add hl, bc                  ; hl = left of RIGHT button tile

.Render:
    di
    ld c, rSTAT & $FF
.WaitForBlank1:
    ldh a, [$FF00+c]
    bit 1, a
    jr nz, .WaitForBlank1       ; not mode 0 or 1

    ld [hl], d                  ; effect added to the left
    ei

    inc hl
    inc hl

    di
    ld c, rSTAT & $FF
.WaitForBlank2:
    ldh a, [$FF00+c]
    bit 1, a
    jr nz, .WaitForBlank2       ; not mode 0 or 1

    ld [hl], e                  ; effect added to the right
    ei

    ret


; Draws an effect around a button
; @param b: Input enum (JOYP_A | JOYP_B | JOYP_LEFT << 4 | JOYP_RIGHT << 4)
DrawButtonEffect::
    ld d, BTN_EFFECT_LEFT
    ld e, BTN_EFFECT_RIGHT
    jr RenderButtonEffect       ; immediate return


; Clears an effect around a button
; @param b: Input enum (JOYP_A | JOYP_B | JOYP_LEFT << 4 | JOYP_RIGHT << 4)
ClearButtonEffect::
    ld d, BLANK_EFFECT
    ld e, BLANK_EFFECT
    jr RenderButtonEffect       ; immediate return


; Clears all effects around a button
ClearAllButtonEffects::
    ld d, BLANK_EFFECT
    ld e, BLANK_EFFECT

    ld b, JOYP_A
    call RenderButtonEffect

    ld b, JOYP_B
    call RenderButtonEffect

    ld b, JOYP_LEFT << 4
    call RenderButtonEffect

    ld b, JOYP_RIGHT << 4
    call RenderButtonEffect
    ret


ENDSECTION

