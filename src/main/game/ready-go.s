include "metasprite.inc"

DEF SHADOWOAM_OFFSET EQU 80

DEF READY_WIDTH EQU 9
DEF READY_HEIGHT EQU 2
DEF READY_X EQU 55
DEF READY_Y EQU 75
DEF READY_FRAMES EQU 200

DEF MIDDLE_FRAMES EQU 255

DEF GO_WIDTH EQU 4
DEF GO_HEIGHT EQU 2
DEF GO_X EQU 74
DEF GO_Y EQU 75
DEF GO_FRAMES EQU 200

DEF FINISH_WIDTH EQU 4
DEF FINISH_HEIGHT EQU 2
DEF FINISH_X EQU 74
DEF FINISH_Y EQU 75
DEF FINISH_FRAMES EQU 200

/*******************************************************
* READY, GO, FINISH TEXT
* Shows text as sprites
********************************************************/
SECTION "ReadyGoFinishTiles", ROM0
    
    ReadyTiles: INCBIN "ready.tilemap"
    GoTiles: INCBIN "go.tilemap"
    FinishTiles: INCBIN "finish.tilemap"

SECTION "ReadyGoFinishStructs", WRAM0

    ReadySprite: STRUCT_METASPRITE
    GoSprite: STRUCT_METASPRITE
    FinishSprite: STRUCT_METASPRITE

SECTION "ReadyGoFinish", ROM0

; Prints the 'READY?' to the screen
; @returns hl: pointer to sprite struct
PrintReady:
    ld hl, ReadySprite
    ld bc, ShadowOAM + SHADOWOAM_OFFSET 
    ld d, READY_WIDTH 
    ld e, READY_HEIGHT
    call InitMSprite

    ld hl, ReadySprite
    ld bc, ReadyTiles
    call ColourMSprite
    
    ld hl, ReadySprite
    ld b, READY_X
    ld c, READY_Y
    push hl
    call PositionMSprite
    pop hl

    ret


; Prints the 'GO!' to the screen
; @returns hl: pointer to sprite struct
PrintGo:
    ld hl, GoSprite
    ld bc, ShadowOAM + SHADOWOAM_OFFSET 
    ld d, GO_WIDTH
    ld e, GO_HEIGHT
    call InitMSprite

    ld hl, GoSprite
    ld bc, GoTiles
    call ColourMSprite
    
    ld hl, GoSprite 
    ld b, GO_X
    ld c, GO_Y
    push hl
    call PositionMSprite
    pop hl

    ret
   

; Prints the 'FINISH' to the screen
; @returns hl: pointer to sprite struct
PrintFinish:
    ld hl, FinishSprite
    ld bc, ShadowOAM + SHADOWOAM_OFFSET 
    ld d, FINISH_WIDTH
    ld e, FINISH_HEIGHT
    call InitMSprite

    ld hl, FinishSprite
    ld bc, FinishTiles
    call ColourMSprite
    
    ld hl, FinishSprite 
    ld b, FINISH_X
    ld c, FINISH_Y
    push hl
    call PositionMSprite
    pop hl

    ret


; Prints 'READY' and 'GO' to the screen on a timer
; This function is blocking
StartSequence::
    call PrintReady             ; Ready?
    
    push hl
    ld b, READY_FRAMES
    call WaitForFrames
    call WaitForFrames
    pop hl

    call DeleteMSprite

    ld b, MIDDLE_FRAMES
    call WaitForFrames

    call PrintGo                ; Go!

    push hl
    ld b, GO_FRAMES
    call WaitForFrames
    call WaitForFrames
    pop hl

    call DeleteMSprite
    ret


; Prints 'FIN.' to the screen
; This function is blocking
EndSequence::
    ld b, 100                   ; extra frames incase sprites still being cleaned up
    call WaitForFrames

    call PrintFinish

    ld b, FINISH_FRAMES
    call WaitForFrames
    call WaitForFrames

    ret
    
    
ENDSECTION

