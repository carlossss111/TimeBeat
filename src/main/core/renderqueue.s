include "hardware.inc"

/*******************************************************
* RENDER QUEUE
* A cyclical queue of MAX_BYTES length. Once initialized,
* the queue can be added to with positions and tilemaps
* during at ANY time.
*
* These tilemaps can then be transferred to VRAM from the
* queue during a VBlank.
********************************************************/
SECTION "RenderQueueVars", WRAM0

    def MAX_BYTES equ 16 * 4    ; max bytes of cyclical queue (/4 = max no. of tiles per frame)

    wSpHolder: dw               ; holders the original stack pointer addr when in use
    wVramBank: dw               ; which VRAM bank to target ($9800 or $9C00)
    wHead: dw                   ; head of the queue
    wTail: dw                   ; tail of the queue
    wQueueBuffer: ds MAX_BYTES  ; max len = 255 (1 byte)

SECTION "RenderQueue", ROM0

; Initialise the render queue
InitRenderQueue::
    ld a, LOW(TILEMAP0)
    ld [wVramBank], a
    ld a, HIGH(TILEMAP0)
    ld [wVramBank + 1], a       ; store VRAM bank as TILEMAP0 by default
    
    ld a, LOW(wQueueBuffer)
    ld [wHead], a
    ld [wTail], a
    ld a, HIGH(wQueueBuffer)
    ld [wHead + 1], a
    ld [wTail + 1], a           ; init pointers to the start of the buffer
    ret

; Enqueue a tilemap and a screen position to be rendered later
; @param b: tilemap x position
; @param c: tilemap y position 
; @param hl: new tilemap value (e.g. addr to tile graphic)
EnqueueTilemap::
    di                          ; disable interrupts
    push de                     ; keep de state
    ld d, h
    ld e, l
    ld a, [wHead]
    ld l, a
    ld a, [wHead + 1]
    ld h, a                     ; load head address
    
    ld [hl], b                  ; enqueue x position
    inc hl
    ld [hl], c                  ; enqueue y position
    inc hl
    ld [hl], d                  ; enqueue HIGH tilemap value
    inc hl
    ld [hl], e                  ; enqueue LOW tilemap value
    inc hl

    ld bc, ($FFFF - wQueueBuffer - MAX_BYTES + 1)
    ld d, h
    ld e, l
    add hl, bc                  ; add head and starting location
    jr nc, .NoOverflow          ; continue IF we are at the end of the queue
    ld a, LOW(wQueueBuffer)
    ld [wHead], a
    ld a, HIGH(wQueueBuffer)
    ld [wHead + 1], a           ; if we are, set the head to the beginning
    jr .Ret
.NoOverflow
    ld a, e
    ld [wHead], a
    ld a, d
    ld [wHead + 1], a
.Ret
    pop de                      ; restore de register state
    reti                        ; reenable interrupts

; Dequeue all tilemap values and move them into VRAM
; This method should ONLY be called during a VBlank
; @uses hl, de
DequeueTilemapsToVRAM::
    ld [wSpHolder], sp          ; save the stack pointer

    ld a, [wTail]
    ld l, a
    ld a, [wTail + 1]
    ld h, a
    ld sp, hl                   ; point sp to the tail

.DequeueLoopConditions:
    ld hl, sp + 0
    ld a, [wHead]
    cp a, l                     ; if HIGH(sp) == HIGH(head)
    jr nz, .DequeueLoop
    ld a, [wHead + 1]
    cp a, h                     ; && LOW(sp) == LOW(head)
    jr z, .EndLoop              ; then exit the loop
.DequeueLoop:

    pop hl                      ; dequeue position
    ;TODO vram copy here 
    pop de                      ; dequeue tilemap value
    ;TODO vram copy here 

    ld hl, ($FFFF - wQueueBuffer - MAX_BYTES + 1)
    add hl, sp                  ; add head and start addr
    jr nc, .NoOverflow          ; if we are at the end
    ld sp, wQueueBuffer         ; loop sp to the beginning
.NoOverflow
    jr .DequeueLoopConditions
.EndLoop

    ld [wTail], sp              ; update the tail
    
    ld a, [wSpHolder]
    ld l, a
    ld a, [wSpHolder + 1]
    ld h, a
    ld sp, hl                   ; restore stack pointer
    ret
    
ENDSECTION

