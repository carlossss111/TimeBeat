
; Save space by turning functions and subroutines into macros where
; appropriate

/*******************************************************
* INPUT
********************************************************/
; Updates the inputs and returns current key
; @returns a: current keypress
MACRO call_GetCurrentKeys
    ldh a, [hCurKeys]
ENDM

; Updates the inputs and returns new key
; @returns a: new keypress
MACRO call_GetNewKeys
    ldh a, [hNewKeys]
ENDM

; Updates the inputs and returns released key
; @returns a: new keypress
MACRO call_GetReleasedKeys
    ldh a, [hRelKeys]
ENDM

