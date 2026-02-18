include "metasprite.inc"
include "hardware.inc"
include "beattracker.inc"

DEF SPRITE_START_Y_SINGLE EQU 8        ; starting sprite positions
DEF SPRITE_START_Y_HOLD EQU 0
DEF SPRITE_START_Y_RELEASE EQU 8

DEF B_BUTTON_START_X EQU 96 + 8
DEF A_BUTTON_START_X EQU 128 + 8
DEF LEFT_BUTTON_START_X EQU 24 + 8
DEF RIGHT_BUTTON_START_X EQU 56 + 8

DEF SPRITE_SPEED EQU 1          ; px per frame

DEF QUEUE_COUNT EQU 40          ; number of metasprites

DEF SPRITE_WIDTH EQU 1
DEF SPRITE_HEIGHT EQU 1
DEF SPR_SINGLE_WIDTH EQU 1      ; sprite sizes
DEF SPR_SINGLE_HEIGHT EQU 1
DEF SPR_HOLD_RELEASE_WIDTH EQU 1
DEF SPR_HOLD_RELEASE_HEIGHT EQU 2


/*******************************************************
* BEAT SPRITES
* Tile indices for each metasprite
*******************************************************/
SECTION "BeatSprites", ROM0

    SpriteSheet: INCBIN "game_sprites_combined.2bpp"
    SpriteSheetEnd:

SECTION "BeatSpriteMaps", ROM0

    ButtonMapA: db $0
    ButtonMapB: db $1
    ButtonMapLeft: db $2
    ButtonMapRight: db $3

    ButtonMapAHold: db $c, $4
    ButtonMapBHold: db $c, $5
    ButtonMapLeftHold: db $c, $6
    ButtonMapRightHold: db $c, $7

    ButtonMapARelease: db $8, $d
    ButtonMapBRelease: db $9, $d
    ButtonMapLeftRelease: db $a, $d
    ButtonMapRightRelease: db $b, $d

ENDSECTION


/*******************************************************
* BEAT CIRCULAR QUEUE 
* For drawing sprites (enqueuing) and deleting sprites
* (dequeuing) during gameplay.
*******************************************************/
SECTION "BeatQueueVars", WRAM0

    wSpriteQueue: ds META_SIZE * QUEUE_COUNT
    wSpriteQueueEnd:

    wHeadPtr: dw
    wTailPtr: dw
    wOAMPtr: dw

ENDSECTION


/*******************************************************
* BEAT QUEUE OPERATIONS
* Enqueuing sprites, dequeuing sprites, etc.
* Sprites should be enqueued some time before each beat,
* and dequeued when it leaves the screen.
*******************************************************/
SECTION "BeatQueue", ROM0

; Copy the sprite data into VRAM
; @param hl: VRAM locatio2
InitGameSpriteVRAM::
    ld de, SpriteSheet
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy
    ret


; Initialise the queue pointers to the beginning of the circular queue
; Initialise the OAM pointer to the beginning of shadow OAM
InitBeatSprites::
    ld a, HIGH(wSpriteQueue)    ; set dequeue and enqueue to start of array 
    ld [wHeadPtr], a
    ld [wTailPtr], a         
    ld a, LOW(wSpriteQueue)
    ld [wHeadPtr + 1], a
    ld [wTailPtr + 1], a

    ld a, HIGH(ShadowOAM)       ; set shadow oam ptr
    ld [wOAMPtr], a
    ld a, LOW(ShadowOAM)
    ld [wOAMPtr + 1], a
    ret


; Returns tilemap size
; @param a: type of sprite (BEAT_SINGLE, BEAT_HOLD, BEAT_RELEASE)
; @returns d: width
; @returns e: height
GetTileIndexSize:
    cp BEAT_SINGLE
    jr nz, .IfHoldRelease
    ld d, SPR_SINGLE_WIDTH
    ld e, SPR_SINGLE_HEIGHT
    ret
.IfHoldRelease:
    ld d, SPR_HOLD_RELEASE_WIDTH
    ld e, SPR_HOLD_RELEASE_HEIGHT
    ret
    

; Returns a tilemap address
; @param a: Sprite button type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @param b: Sprite action type (BEAT_SINGLE, BEAT_HOLD, BEAT_RELEASE)
; @returns bc: address of tilemap
GetTileIndicesAddress:
    ldh [hScratchA], a

    cp PAD_A
    jr nz, .IfB                 ; Check if A

    ld a, BEAT_HOLD             ; Return sprite of action type
    cp b
    jr z, .HoldA
    ld a, BEAT_RELEASE
    cp b
    jr z, .ReleaseA
.SingleA:
    ld bc, ButtonMapA
    ret
.HoldA:
    ld bc, ButtonMapAHold
    ret
.ReleaseA:
    ld bc, ButtonMapARelease
    ret

.IfB:
    ldh a, [hScratchA]
    cp PAD_B
    jr nz, .IfLeft

    ld a, BEAT_HOLD             ; Return sprite of action type
    cp b
    jr z, .HoldB
    ld a, BEAT_RELEASE
    cp b
    jr z, .ReleaseB
.SingleB:
    ld bc, ButtonMapB
    ret
.HoldB:
    ld bc, ButtonMapBHold
    ret
.ReleaseB:
    ld bc, ButtonMapBRelease
    ret

.IfLeft:
    ldh a, [hScratchA]
    cp PAD_LEFT
    jr nz, .IfRight

    ld a, BEAT_HOLD             ; Return sprite of action type
    cp b
    jr z, .HoldLeft
    ld a, BEAT_RELEASE
    cp b
    jr z, .ReleaseLeft
.SingleLeft:
    ld bc, ButtonMapLeft
    ret
.HoldLeft:
    ld bc, ButtonMapLeftHold
    ret
.ReleaseLeft:
    ld bc, ButtonMapLeftRelease
    ret

.IfRight:
    ld a, BEAT_HOLD             ; Return sprite of action type
    cp b
    jr z, .HoldRight
    ld a, BEAT_RELEASE
    cp b
    jr z, .ReleaseRight
.SingleRight:
    ld bc, ButtonMapRight
    ret
.HoldRight:
    ld bc, ButtonMapRightHold
    ret
.ReleaseRight:
    ld bc, ButtonMapRightRelease
    ret


; Returns a starting X location depending on the type
; @param a: Sprite type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @returns b: x position in pixels
GetStartingXPosition:
    cp PAD_A
    jr nz, .IfB
    ld b, A_BUTTON_START_X
    ret
.IfB:
    cp PAD_B
    jr nz, .IfLeft
    ld b, B_BUTTON_START_X
    ret
.IfLeft:
    cp PAD_LEFT
    jr nz, .IfRight
    ld b, LEFT_BUTTON_START_X
    ret
.IfRight:
    ld b, RIGHT_BUTTON_START_X
    ret

; AKA - EnqueueBeatSprite
; Spawn a new metasprite on the screen and increment the pointers
; @param a: Sprite button type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @param b: Sprite action type (BEAT_SINGLE, BEAT_HOLD, BEAT_RELEASE)
SpawnBeatSprite:: 
    push af
    push bc

    ; Init
    ld a, [wHeadPtr]            ; place in memory for metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    ld a, b                     ; param = sprite action type
    call GetTileIndexSize       ; d = width, e = height

    ld a, [wOAMPtr]             ; place in OAM for real sprite
    ld b, a
    ld a, [wOAMPtr + 1]
    ld c, a

    call InitMSprite

    ; Draw 
    ld a, [wHeadPtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a
    
    pop bc
    pop af
    push bc
    push af
    call GetTileIndicesAddress  ; tilemap is now in BC
    
    call ColourMSprite

    ; Position
    ld a, [wHeadPtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    pop af
    pop bc
    push bc
    push af
    ld a, b
    cp BEAT_HOLD                ; hold beat has to start higher up
    jr z, .IfHoldStart
.IfRegularStart:
    ld c, SPRITE_START_Y_SINGLE ; y position
    jr .EndIfStart
.IfHoldStart:
    ld c, SPRITE_START_Y_HOLD   ; y position
.EndIfStart:
    pop af
    call GetStartingXPosition   ; x position is now in b

    call PositionMSprite

    ; Increment pointers circularly
    ld a, [wHeadPtr]
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    ld bc, META_SIZE            ; increment queue ptr by 6
    add hl, bc

    ld a, h
    ld [wHeadPtr], a
    ld a, l
    ld [wHeadPtr + 1], a

    ld a, [wOAMPtr]
    ld h, a
    ld a, [wOAMPtr+ 1]  
    ld l, a

    pop bc
    ld a, BEAT_SINGLE
    cp b
    jr z, .IfSmallSprite
.IfBigSprite:
    ld bc, OBJ_SIZE * (SPR_HOLD_RELEASE_WIDTH * SPR_HOLD_RELEASE_HEIGHT)
    jr .EndIfSpr
.IfSmallSprite:
    ld bc, OBJ_SIZE * (SPR_SINGLE_WIDTH * SPR_SINGLE_HEIGHT)
.EndIfSpr:
    add hl, bc                  ; increase OAM ptr by sprite size
    ld a, h
    ld [wOAMPtr], a
    ld a, l
    ld [wOAMPtr + 1], a

.IfEndOfSpriteQueue:
    ld a, [wHeadPtr]
    cp HIGH(wSpriteQueueEnd)    ; check if at end of queue
    jr nz, .EndIfQueue
    ld a, [wHeadPtr + 1]  
    cp LOW(wSpriteQueueEnd)
    jr nz, .EndIfQueue
    ld a, HIGH(wSpriteQueue)    ; set enqueue to start of array 
    ld [wHeadPtr], a
    ld a, LOW(wSpriteQueue)
    ld [wHeadPtr + 1], a
.EndIfQueue:

.IfEndOfOAM:
    ld a, [wOAMPtr]
    cp HIGH(ShadowOAMEnd)       ; check if at end of shadow OAM
    jr nz, .EndIfOAM
    ld a, [wOAMPtr + 1]
    cp LOW(ShadowOAMEnd) - 4    ; 2 bytes, so check the OAM before too
    jr c, .EndIfOAM
    ld a, HIGH(ShadowOAM)       ; set shadow oam ptr to start of OAM
    ld a, HIGH(ShadowOAM)       ; set shadow oam ptr to start of OAM
    ld [wOAMPtr], a
    ld a, LOW(ShadowOAM)
    ld [wOAMPtr + 1], a
.EndIfOAM:
    ret


; Deletes a beatsprite and moves the dequeue pointer along
DequeueBeatSprite:
    ld a, [wTailPtr]
    ld h, a
    ld a, [wTailPtr + 1]
    ld l, a
    push hl                     ; delete sprite data from OAM
    call DeleteMSprite

    pop hl
    ld bc, META_SIZE
    add hl, bc                  ; move dequeue pointer along
    ld a, h
    ld [wTailPtr], a
    ld a, l
    ld [wTailPtr + 1], a

.IfEndOfArray:
    ld a, [wTailPtr]
    cp HIGH(wSpriteQueueEnd)
    jr nz, .EndIf
    ld a, [wTailPtr + 1]  
    cp LOW(wSpriteQueueEnd)
    jr nz, .EndIf

    ld a, HIGH(wSpriteQueue)    ; set enqueue to start of array 
    ld [wTailPtr], a
    ld a, LOW(wSpriteQueue)
    ld [wTailPtr + 1], a
.EndIf:
    ret


; Loop through the queue and move all sprites right
MoveBeatSprites::
    ld a, [wTailPtr]
    ld h, a
    ld a, [wTailPtr + 1]
    ld l, a                     ; hl starts at tail

.While:                         ; while hl != head
    ld a, [wHeadPtr]
    cp h
    jr nz, .Inner
    ld a, [wHeadPtr + 1]
    cp l
    jr z, .EndWhile
.Inner:

    push hl
    ld b, 0                     ; x movement
    ld c, SPRITE_SPEED          ; y movement
    call MoveMSprite            ; takes hl as metasprite ptr
    pop hl


    push hl
.IfOffscreen:
    ld bc, META_Y
    add hl, bc
    ld a, [hl]
    cp SCREEN_HEIGHT_PX + (SPRITE_HEIGHT * 16) 
    jp c, .EndIf                ; compare if position > edge of screen

    call DequeueBeatSprite      ; delete sprites off the screen

.EndIf:
    pop hl

    ld bc, META_SIZE
    add hl, bc                  ; hl++


    ld a, h
    cp HIGH(wSpriteQueueEnd)
    jr nz, .While
    ld a, l
    cp LOW(wSpriteQueueEnd)
    jr nz, .While               ; Check that we don't need to roll over to the start of the queue

    ld hl, wSpriteQueue         ; If we do, roll over
    
    jr .While
.EndWhile:
    ret

ENDSECTION

