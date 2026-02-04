include "hardware.inc"

/*******************************************************
* WINDOW RENDERING
* Render the game top and bottom window using stat ints
*******************************************************/
SECTION "WindowRenderer", ROM0

; Init the window
InitWindow::
    ld a, 7
    ld [rWX], a                 ; fixes weird alignment issue
    call MiddleScreen
    ret

; Adjust the window position and set interrupt at middle scanlines
TopScreen:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, TopScreen            ; wait for hblank

    ld a, 9
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

    ld a, [rLCDC]
    and ~LCDC_WINDOW
    ld [rLCDC], a               ; turn off window

    ld a, 120
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

    ld a, [rLCDC]
    or LCDC_WINDOW
    ld [rLCDC], a               ; turn on window

    ld a, 0
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, TopScreen
    call SetStatHandler         ; set handler for next STAT interrupt
    ret

ENDSECTION

