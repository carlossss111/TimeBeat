include "hardware.inc"

DEF FRAMES_PER_SCROLL EQU 4

/*******************************************************
* BACKGROUND SCROLL
* Slowly scrolls the background on a loop
********************************************************/
SECTION "BackgroundScrollVars", WRAM0

    wFramesUntilScroll: db

SECTION "BackgroundScroll", ROM0

; Init the frames until next scroll and reset the scroll
InitBackgroundScroll::
    ld a, FRAMES_PER_SCROLL
    ld [wFramesUntilScroll], a

    xor a
    ld [rSCX], a
    ret
    

; Scroll the background if it is time to do so
ScrollBackground::
    ld a, [wFramesUntilScroll]
    dec a
.IfTimeToScroll:
    jr z, .ScrollNow
    ld [wFramesUntilScroll], a
    ret

.ScrollNow:
    ld a, FRAMES_PER_SCROLL
    ld [wFramesUntilScroll], a
    
    ld a, [rSCX]
    inc a
    ld [rSCX], a

    ret
    
ENDSECTION

