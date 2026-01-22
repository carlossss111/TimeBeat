include "hardware.inc"

/*******************************************************
* AUDIO FUNCTIONS
* Simple multi-purpose audio functions
********************************************************/
SECTION "AudioFunctions", ROM0

; Fade the volume out until its muted
; @param b: frames between volume decrease (speed)
SlideDownVolume::
    ld a, $77
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $55
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $44
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $33
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $22
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $11
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $00
    ld [rAUDVOL], a
    call WaitForFrames

    xor a
    ld [rAUDENA], a

    ret

; Fade the volume in its max
; @param b: frames between volume increase (speed)
SlideUpVolume::
    ld a, $80
    ld [rAUDENA], a
    ld a, $FF
    ld [rAUDTERM], a

    ld a, $00
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $11
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $22
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $33
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $44
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $55
    ld [rAUDVOL], a
    call WaitForFrames
    ld a, $77
    ld [rAUDVOL], a

    ret

ENDSECTION

