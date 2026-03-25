include "hardware.inc"

DEF TIME_TO_SHOW_STRING EQU 60

DEF WINDOW_X_OFFSET EQU 7
DEF WINDOW_Y_OFFSET EQU $80
DEF TEXT_X EQU 0
DEF TEXT_Y EQU 0

DEF PLUS_MINUS_TILE_LOC EQU $9c0d
DEF COUNTER_TILE_LOC EQU $9c0e
DEF ZERO EQU $8e

DEF PLUS EQU $8d
DEF MINUS EQU $8c

/*******************************************************
* MENU WINDOW
* Render the 'OFFSET +/-N' window
*******************************************************/
SECTION "MenuWindowVars", WRAM0

    wDisplayCountdown: db

SECTION "MenuWindow", ROM0

; Init the number of frames to display the menu window for
InitMenuWindow::
    ld a, WINDOW_X_OFFSET
    ld [rWX], a
    ld a, WINDOW_Y_OFFSET
    ld [rWY], a

    xor a
    ld [wDisplayCountdown], a

    ret


; Load up the display countdown so the offset is shown on a vblank
ShowMenuWindow::
    ld a, TIME_TO_SHOW_STRING
    ld [wDisplayCountdown], a
    ret

; Hide the display
HideMenuWindow::
    xor a
    ld [wDisplayCountdown], a
    ret


; Render the offset +/-
RenderOffset:
    call GetMusicOffset         ; bc = offset (2s-complement)

    ld a, b
    cp 0
    jr nz, .IsNegative
.IsPositive:
    di
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .IsPositive          ; not mode 0 or 1

    ld a, c
    add ZERO                    ; a = tile index of 0 + number
    ld [COUNTER_TILE_LOC], a    ; load tile into VRAM
 
    ld a, PLUS
    ld [PLUS_MINUS_TILE_LOC], a

    reti

.IsNegative:
    di
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .IsNegative          ; not mode 0 or 1

    ld a, c
    xor $ff                     ; negate
    add ZERO + 1                ; a = tile index of 1 + number
    ld [COUNTER_TILE_LOC], a    ; load tile into VRAM
 
    ld a, MINUS
    ld [PLUS_MINUS_TILE_LOC], a

    reti


; Render the menu window, call on every vblank
RenderMenuWindow::
    ld a, [wDisplayCountdown]
.If:
    cp 0
    jr z, .CountdownOver
.StillCounting:
    dec a
    ld [wDisplayCountdown], a

    call RenderOffset

    ldh a, [rLCDC]
    or LCDC_WINDOW
    ldh [rLCDC], a               ; turn on window

    jr .EndIf

.CountdownOver:
    ldh a, [rLCDC]
    and ~LCDC_WINDOW
    ldh [rLCDC], a               ; turn off window

.EndIf:

    ret

ENDSECTION

