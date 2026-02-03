include "metasprites.inc"
include "hardware.inc"


DEF SPRITE_WIDTH EQU 1          ; number of tiles
DEF SPRITE_HEIGHT EQU 1

DEF SPRITE_START_Y EQU 0        ; starting x position of all sprites
DEF A_BUTTON_START_X EQU 96 + 8
DEF B_BUTTON_START_X EQU 128 + 8
DEF LEFT_BUTTON_START_X EQU 24 + 8
DEF RIGHT_BUTTON_START_X EQU 56 + 8

DEF SPRITE_SPEED EQU 1          ; px per frame

DEF QUEUE_COUNT EQU 40          ; number of metasprites


/*******************************************************
* BEAT SPRITES
* Tile indices for each metasprite
*******************************************************/
SECTION "BeatSprites", ROM0

    SpriteSheet: INCBIN "buttons.2bpp"
    SpriteSheetEnd:

SECTION "BeatSpriteMaps", ROM0

    ButtonMapA: db $0
    ButtonMapB: db $1
    ButtonMapLeft: db $3
    ButtonMapRight: db $2

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


; Returns a tilemap address
; @param a: Sprite type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @returns bc: address of tilemap
GetTileIndicesAddress:
    cp PAD_A
    jr nz, .IfB
    ld bc, ButtonMapA
    ret
.IfB:
    cp PAD_B
    jr nz, .IfLeft
    ld bc, ButtonMapB
    ret
.IfLeft:
    cp PAD_LEFT
    jr nz, .IfRight
    ld bc, ButtonMapLeft
    ret
.IfRight:
    ld bc, ButtonMapRight
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


; Spawn a new metasprite on the screen and increment the pointers
; @param a: Sprite type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
EnqueueBeatSprite::
    push af

    ; Init
    ld a, [wHeadPtr]         ; place in memory for metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    ld a, [wOAMPtr]             ; place in OAM for real sprite
    ld b, a
    ld a, [wOAMPtr + 1]
    ld c, a

    ld d, SPRITE_WIDTH          ; width
    ld e, SPRITE_HEIGHT         ; height

    call InitMSprite

    ; Draw 
    ld a, [wHeadPtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a
    
    pop af
    dec sp
    dec sp
    call GetTileIndicesAddress  ; tilemap is now in BC
    
    call ColourMSprite

    ; Position
    ld a, [wHeadPtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    pop af
    call GetStartingXPosition   ; x position is now in b
    ld c, SPRITE_START_Y        ; y position

    call PositionMSprite

    ; Increment pointers circularly
    ld a, [wHeadPtr]
    ld h, a
    ld a, [wHeadPtr + 1]  
    ld l, a

    ld bc, META_SIZE            ; increment OAM ptr by 6
    add hl, bc

    ld a, h
    ld [wHeadPtr], a
    ld a, l
    ld [wHeadPtr + 1], a

    ld a, [wOAMPtr]
    ld h, a
    ld a, [wOAMPtr+ 1]  
    ld l, a

    ld bc, OBJ_SIZE * (SPRITE_WIDTH * SPRITE_HEIGHT)
    add hl, bc                  ; increase OAM ptr by sprite size

    ld a, h
    ld [wOAMPtr], a
    ld a, l
    ld [wOAMPtr + 1], a

.IfEndOfArray
    ld a, [wHeadPtr]
    cp HIGH(wSpriteQueueEnd)
    jr nz, .EndIf
    ld a, [wHeadPtr + 1]  
    cp LOW(wSpriteQueueEnd)
    jr nz, .EndIf

    ld a, HIGH(wSpriteQueue)    ; set enqueue to start of array 
    ld [wHeadPtr], a
    ld a, LOW(wSpriteQueue)
    ld [wHeadPtr + 1], a

    ld a, HIGH(ShadowOAM)       ; set shadow oam ptr to start of OAM
    ld [wOAMPtr], a
    ld a, LOW(ShadowOAM)
    ld [wOAMPtr + 1], a
.EndIf
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

.IfEndOfArray
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
.EndIf
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
    jr .While
.EndWhile:
    ret

ENDSECTION

