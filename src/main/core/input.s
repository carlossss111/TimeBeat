include "hardware.inc"

SECTION "InputVars", WRAM0
    wCurKeys: db
    wNewKeys: db

SECTION "Input", ROM0

; Polls the controller for inputs
; Stores changes in wNewKeys
; Stores current in wCurKeys
; @uses b
UpdateInput:
    ld a, JOYP_GET_BUTTONS  ; select BUTTON read mode
    call .onenibble         ; get button reads
    ld b, a                 ; store in register b

    ld a, JOYP_GET_CTRL_PAD ; select DPAD read mode
    call .onenibble         ; get dpad reads
    swap a                  ; swap high nibble with low nibble
                            ; the high nibble will contain dpad reads and low will be 1111
    xor a, b                ; now in one byte: high nibble = dpad, low nibble = button
    ld b, a                 ; move back to register b

    ld a, JOYP_GET_NONE     ; select NO read mode
    ld [rP1], a             ; release the inputs

    ld a, [wCurKeys]        ; current keys ptr
    xor a, b                ; get keys that changed state
    and a, b                ; with that, get keys that changed to pressed only
    ld [wNewKeys], a        ; store newly pressed keys
    ld a, b   
    ld [wCurKeys], a        ; store all currently pressed keys
    ret                     ; DONE

.onenibble
    ldh [rP1], a            ; set read mode
    call .knownret          ; waste 10 cycles
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]             ; read 3 times to stabilise, 3rd time should be reliable
    or a, $F0               ; high nibble = 1111, low nibble = input reads
.knownret
    ret

; Updates the inputs and returns current key as bc
; @returns a: current keypress
GetCurrentKeys::
    call UpdateInput
    ld a, [wCurKeys]
    ret

; Updates the inputs and returns new key as bc
; @returns a: new keypress
GetNewKeys::
    call UpdateInput
    ld a, [wNewKeys]
    ret


ENDSECTION

