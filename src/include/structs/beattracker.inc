
MACRO STRUCT_BEAT_STREAM
    dw                          ; wHitPtr
    dw                          ; wSpritePtr
    dw                          ; wEndPtr
    db                          ; wType
ENDM

DEF BEAT_STREAM_HIT EQU 0
DEF BEAT_STREAM_SPRITE EQU 2
DEF BEAT_STREAM_END EQU 4
DEF BEAT_STREAM_TYPE EQU 6
DEF BEAT_STREAM_SIZE EQU 7

