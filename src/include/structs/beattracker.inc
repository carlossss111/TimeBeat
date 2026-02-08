
; Beat Struct
MACRO STRUCT_BEAT_STREAM
    dw                          ; wHitPtr
    dw                          ; wSpritePtr
    dw                          ; wStartPtr
    dw                          ; wEndPtr
    db                          ; wType
ENDM

DEF BEAT_STREAM_HIT EQU 0
DEF BEAT_STREAM_SPRITE EQU 2
DEF BEAT_STREAM_START EQU 4
DEF BEAT_STREAM_END EQU 6
DEF BEAT_STREAM_TYPE EQU 8
DEF BEAT_STREAM_SIZE EQU 9

; Beat Type Enum
DEF BEAT_SINGLE EQU 0
DEF BEAT_HOLD EQU 1
DEF BEAT_RELEASE EQU 2

