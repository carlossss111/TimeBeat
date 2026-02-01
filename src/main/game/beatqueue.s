include "metasprites.inc"
include "hardware.inc"


DEF SPRITE_WIDTH EQU 1          ; number of tiles
DEF SPRITE_HEIGHT EQU 1

DEF SPRITE_START_X EQU 20                                    ; starting x position of all sprites
DEF A_BUTTON_START_Y EQU 32
DEF B_BUTTON_START_Y EQU 42
DEF LEFT_BUTTON_START_Y EQU 52
DEF RIGHT_BUTTON_START_Y EQU 62

DEF QUEUE_COUNT EQU 40                                       ; number of metasprites


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
    ButtonMapLeft: db $2
    ButtonMapRight: db $3

ENDSECTION


/*******************************************************
* BEAT CIRCULAR QUEUE 
* For drawing sprites (enqueuing) and deleting sprites
* (dequeuing) during gameplay.
*******************************************************/
SECTION "BeatQueueVars", WRAM0

    wSpriteQueue: ds META_SIZE * QUEUE_COUNT
    wSpriteQueueEnd:

    wEnqueuePtr: dw
    wDequeuePtr: dw
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
; @param hl: VRAM location
InitGameSpriteVRAM::
    ld de, SpriteSheet
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy
    ret


; Initialise the queue pointers to the beginning of the circular queue
; Initialise the OAM pointer to the beginning of shadow OAM
InitBeatSprites::
    ld a, HIGH(wSpriteQueue)    ; set dequeue and enqueue to start of array 
    ld [wEnqueuePtr], a
    ld [wDequeuePtr], a         
    ld a, LOW(wSpriteQueue)
    ld [wEnqueuePtr + 1], a
    ld [wDequeuePtr + 1], a

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

; Returns a starting Y location depending on the type
; @param a: Sprite type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
; @returns c: y position in pixels
GetStartingYPosition:
    cp PAD_A
    jr nz, .IfB
    ld c, A_BUTTON_START_Y
    ret
.IfB:
    cp PAD_B
    jr nz, .IfLeft
    ld c, B_BUTTON_START_Y
    ret
.IfLeft:
    cp PAD_LEFT
    jr nz, .IfRight
    ld c, LEFT_BUTTON_START_Y
    ret
.IfRight:
    ld c, RIGHT_BUTTON_START_Y
    ret


; Spawn a new metasprite on the screen and increment the pointers
; @param a: Sprite type (PAD_A, PAD_B, PAD_LEFT, PAD_RIGHT)
EnqueueBeatSprite::
    push af

    ; Init
    ld a, [wEnqueuePtr]         ; place in memory for metasprite
    ld h, a
    ld a, [wEnqueuePtr + 1]  
    ld l, a

    ld a, [wOAMPtr]             ; place in OAM for real sprite
    ld b, a
    ld a, [wOAMPtr + 1]
    ld c, a

    ld d, SPRITE_WIDTH          ; width
    ld e, SPRITE_HEIGHT         ; height

    call InitMSprite

    ; Draw 
    ld a, [wEnqueuePtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wEnqueuePtr + 1]  
    ld l, a
    
    pop af
    dec sp
    dec sp
    call GetTileIndicesAddress  ; tilemap is now in BC
    
    call ColourMSprite

    ; Position
    ld a, [wEnqueuePtr]         ; place in memory of metasprite
    ld h, a
    ld a, [wEnqueuePtr + 1]  
    ld l, a

    ld b, SPRITE_START_X        ; x position
    pop af
    call GetStartingYPosition   ; y position is now in c

    call PositionMSprite

    ; Increment pointers circularly
    ld a, [wEnqueuePtr]
    ld h, a
    ld a, [wEnqueuePtr + 1]  
    ld l, a

    ld bc, META_SIZE            ; increment OAM ptr by 6
    add hl, bc

    ld a, h
    ld [wEnqueuePtr], a
    ld a, l
    ld [wEnqueuePtr + 1], a

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
    ld a, [wEnqueuePtr]
    cp HIGH(wSpriteQueueEnd)
    jr nz, .EndIf
    ld a, [wEnqueuePtr + 1]  
    cp LOW(wSpriteQueueEnd)
    jr nz, .EndIf

    ld a, HIGH(wSpriteQueue)    ; set enqueue to start of array 
    ld [wEnqueuePtr], a
    ld a, LOW(wSpriteQueue)
    ld [wEnqueuePtr + 1], a

    ld a, HIGH(ShadowOAM)       ; set shadow oam ptr to start of OAM
    ld [wOAMPtr], a
    ld a, LOW(ShadowOAM)
    ld [wOAMPtr + 1], a
.EndIf
    ret


; Deletes a beatsprite and moves the dequeue pointer along
DequeueBeatSprite::
    ld a, [wDequeuePtr]
    ld h, a
    ld a, [wDequeuePtr + 1]
    ld l, a
    push hl                     ; delete sprite data from OAM
    call DeleteMSprite

    pop hl
    ld bc, META_SIZE
    add hl, bc                  ; move dequeue pointer along
    ld a, h
    ld [wDequeuePtr], a
    ld a, l
    ld [wDequeuePtr + 1], a

.IfEndOfArray
    ld a, [wDequeuePtr]
    cp HIGH(wSpriteQueueEnd)
    jr nz, .EndIf
    ld a, [wDequeuePtr + 1]  
    cp LOW(wSpriteQueueEnd)
    jr nz, .EndIf

    ld a, HIGH(wSpriteQueue)    ; set enqueue to start of array 
    ld [wDequeuePtr], a
    ld a, LOW(wSpriteQueue)
    ld [wDequeuePtr + 1], a
.EndIf
    ret


    
   

ENDSECTION

