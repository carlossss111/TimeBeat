include "hardware.inc"

DEF FRAMES_PER_SCROLL EQU 4

/*******************************************************
* BACKGROUND SCROLL
* Slowly scrolls the background on a loop
********************************************************/
SECTION "BackgroundScrollVars", HRAM

    hFramesUntilScroll: db

SECTION "BackgroundScroll", ROM0

; Init the frames until next scroll and reset the scroll
InitBackgroundScroll::
    ld a, FRAMES_PER_SCROLL
    ldh [hFramesUntilScroll], a

    xor a
    ld [rSCX], a
    ret
    

; Scroll the background if it is time to do so
ScrollBackground::
    ldh a, [hFramesUntilScroll]
    dec a
.IfTimeToScroll:
    jr z, .ScrollNow
    ldh [hFramesUntilScroll], a
    ret

.ScrollNow:
    ld a, FRAMES_PER_SCROLL
    ldh [hFramesUntilScroll], a
    
    ld a, [rSCX]
    inc a
    ld [rSCX], a

    ret
    
ENDSECTION

