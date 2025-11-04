include "metasprites.inc"

/*******************************************************
* METASPRITES
* Controls metasprites locations and spritesheets.
* Writes to Shadow OAM.
********************************************************/
SECTION "MetaSprites", ROM0

; Renders to the screen using a DMA transfer
RenderMSprite::
    ret

; Sets the current tile indices
; @param hl: metasprite ptr
; @param bc: ptr to array of tile indices (1 byte wide)
/**
* function(*meta, *spritesheet){
*     i = 0
*     j = 0
*     var *sprite = meta->sprite_arr
* 
*     do {
*         sprite->index = *spritesheet
*         spritesheet++
*         sprite++
* 
*         i++
*         if (i == meta->width) {
*             i = 0
*             j = 0
*         }
*     } while(j != meta->height)
* }
**/
ColourMSprite::

    ld a, b
    ld [ScratchC], a
    ld a, c
    ld [ScratchC + 1], a        ; Index Ptr

    push hl
    ld d, 0
    ld e, META_SPRITE_PTR
    add hl, de
    ld b, [hl]
    inc hl
    ld c, [hl]
    pop hl                      ; bc = sprite_arr

    xor a
    ld [ScratchA], a            ; i = 0
    ld [ScratchB], a            ; j = 0

.Do:

    push hl
    ld a, [ScratchC]
    ld h, a
    ld a, [ScratchC + 1]
    ld l, a                     ; hl = index_ptr
    ld a, [hl]                  ; a = index

    push af
    inc hl                      ; index++
    ld a, h
    ld [ScratchC], a
    ld a, l
    ld [ScratchC + 1], a
    pop af

    pop hl
    
    push hl
    ld h, b
    ld l, c
    ld d, 0
    ld e, SPR_IND
    add hl, de                  ; hl = sprite.index
    ld [hl], a                  ; a = sprite->index = index
    pop hl

    inc bc
    inc bc
    inc bc
    inc bc                      ; sprite++
    ld a, [ScratchA]
    inc a
    ld [ScratchA], a            ; i++
    
.If:
    push hl
    ld a, [ScratchA]
    ld d, 0
    ld e, META_WIDTH
    add hl, de
    cp [hl]                     ; i == width
    jp nz, .EndIf

    xor a
    ld [ScratchA], a            ; i = 0
    ld a, [ScratchB]            
    inc a
    ld [ScratchB], a            ; j++
.EndIf:
    pop hl
    
    push hl
    ld a, [ScratchB]            ; j
    ld d, 0
    ld e, META_HEIGHT
    add hl, de
    ld d, [hl]                  ; d = meta->height
    pop hl
    cp d
    jp nz, .Do                  ; while (j != meta->height)
.EndLoop:
    ret

    ret

; Positions metasprite in shadow WRAM, moving the sprites to the correct location
; @param hl: metasprite ptr
; @param b: new x position
; @param c: new y position
/*
function(*meta, x, y) {
    meta->x = x
    meta->y = y

    i = 0
    j = 0
    var *sprite = meta->sprite_arr
    do {
        sprite->x = i + meta->x
        sprite->y = j + meta->y
        sprite++

        i++
        if (i == meta->width) {
            i = 0
            j++
        }
    } while (j != meta->height)
    
}
*/
PositionMSprite::
    push hl
    ld d, 0
    ld e, META_X
    add hl, de                  ; hl = metasprite.x
    ld [hl], b                  ; meta->x = x
    pop hl

    push hl
    ld d, 0
    ld e, META_Y
    add hl, de                  ; hl = metasprite.y
    ld [hl], b                  ; meta->y = y
    pop hl

    push hl
    ld d, 0
    ld e, META_SPRITE_PTR
    add hl, de
    ld b, [hl]
    inc hl
    ld c, [hl]
    pop hl                      ; bc = sprite_arr

    xor a
    ld [ScratchA], a            ; i = 0
    ld [ScratchB], a            ; j = 0
.Do:
    
    push hl
    ld d, 0
    ld e, META_X
    add hl, de
    ld d, [hl]                  ; d = meta->x
    ld a, [ScratchA]            ; a = i
    add d                       ; a = i + meta->x
    pop hl
    
    push hl
    ld h, b
    ld l, c
    ld d, 0
    ld e, SPR_X
    add hl, de                  ; hl = sprite.x
    ld [hl], a                  ; a = sprite->x = i + meta->x
    pop hl

    push hl
    ld d, 0
    ld e, META_Y
    add hl, de
    ld d, [hl]                  ; d = meta->y
    ld a, [ScratchB]            ; a = j
    add d                       ; a = j + meta->y
    pop hl
    
    push hl
    ld h, b
    ld l, c
    ld d, 0
    ld e, SPR_Y
    add hl, de                  ; hl = sprite.y
    ld [hl], a                  ; a = sprite->y = j + meta->y
    pop hl

    inc bc
    inc bc
    inc bc
    inc bc                      ; sprite++
    ld a, [ScratchA]
    inc a
    ld [ScratchA], a            ; i++
    
.If:
    push hl
    ld a, [ScratchA]
    ld d, 0
    ld e, META_WIDTH
    add hl, de
    cp [hl]                     ; i == width
    jp nz, .EndIf

    xor a
    ld [ScratchA], a            ; i = 0
    ld a, [ScratchB]            
    inc a
    ld [ScratchB], a            ; j++
.EndIf:
    pop hl
    
    push hl
    ld a, [ScratchB]
    ld d, 0
    ld e, META_HEIGHT
    add hl, de
    ld d, [hl]                  ; d = meta->height
    pop hl
    cp d
    jp nz, .Do                  ; while (j != meta->height)
.EndLoop:
    ret

; Moves the metasprite relative to it's current location
; @param hl: ptr to metasprite
; @param b: movement in x direction
; @param c: movement in y direction
MoveMSprite::
    push hl

    ld d, 0
    ld e, META_X
    add hl, de                  ; hl = metasprite.x

    ld a, b
    add [hl]
    ld b, a                     ; b = metasprite->x + change_in_x

    inc hl                      ; hl = metasprite.y
    ld a, c
    add [hl]
    ld c, a                     ; c = metasprite->y + change_in_y
    
    pop hl
    call PositionMSprite        ; reposition the sprite

    ret


; Initialises a metasprite structure
; @param hl: pointer to metasprite
; @param bc: pointer to shadow sprite list
; @param d: width
; @param e: height
InitMSprite::
    ; While using constants would be safer, incr hl is way more space efficient
    ld [hl], 168                ; x position (hidden)
    inc hl
    ld [hl], 0                  ; y position
    inc hl
    ld [hl], d                  ; width
    inc hl
    ld [hl], e                  ; height
    inc hl
    ld [hl], b                  ; high bit of ptr to sprite arr
    inc hl
    ld [hl], c                  ; low bit of ptr to sprite arr
    ret

ENDSECTION

