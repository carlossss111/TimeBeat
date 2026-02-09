include "hardware.inc"


/*******************************************************
* INPUT HANDLING
* Get the button and dpad presses
********************************************************/
SECTION "InputVars", HRAM

    hCurKeys: db
    hNewKeys: db
    hRelKeys: db

SECTION "Input", ROM0

; Returns the input as LOW bits
; @param a: button type (JOYP_GET_BUTTONS | JOYP_GET_CTRL_PAD)
; @returns a: user input, NIBBLE_HIGH(a) = $F, NIBBLE_LOW(a) = input
ReadInput:
    ldh [rP1], a            ; set read mode
    call .KnownRet          ; delay 10 cycles
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]             ; read 3 times to stabilise
    or a, $F0  
.KnownRet:
    ret


; Polls the controller for inputs
; Stores changes in hNewKeys
; Stores current in hCurKeys
UpdateInput::
    ld a, JOYP_GET_BUTTONS
    call ReadInput
    ld b, a                     ; b = NIBBLE_HIGH($F) NIBBLE_LOW(button_input)

    ld a, JOYP_GET_CTRL_PAD 
    call ReadInput
    swap a                      ; a = NIBBLE_HIGH(dpad_input) NIBBLE_LOW($F)
                            
    xor b                       
    ld b, a                     ; b = NIBBLE_HIGH(dpad_input) NIBBLE_LOW(button_input)

    ld a, JOYP_GET_NONE
    ldh [rP1], a                ; release the inputs

    ldh a, [hCurKeys]
    xor b
    and b
    ldh [hNewKeys], a           ; hNewKeys = inputs that have changed to ON

    ld a, b
    xor $FF                     ; (eq to a NOT operation)
    ld c, a
    ldh a, [hCurKeys]
    and c
    ldh [hRelKeys], a           ; hRelKeys = inputs that have changed to OFF

    ld a, b   
    ldh [hCurKeys], a           ; hCurKeys = inputs that are ON

    ret


; Updates the inputs and returns current key
; @returns a: current keypress
GetCurrentKeys::
    ldh a, [hCurKeys]
    ret


; Updates the inputs and returns new key
; @returns a: new keypress
GetNewKeys::
    ldh a, [hNewKeys]
    ret


; Updates the inputs and returns released key
; @returns a: new keypress
GetReleasedKeys::
    ldh a, [hRelKeys]
    ret
    


ENDSECTION

