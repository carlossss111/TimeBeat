
MACRO STRUCT_BEAT_STREAM
    dw                          ; wCurrentPtr
    dw                          ; wNextPtr
    dw                          ; wFinishPtr
    db                          ; wType
ENDM

DEF BEAT_STREAM_CURRENT EQU 0
DEF BEAT_STREAM_NEXT EQU 2
DEF BEAT_STREAM_FINISH EQU 4
DEF BEAT_STREAM_TYPE EQU 6
DEF BEAT_STREAM_SIZE EQU 7

