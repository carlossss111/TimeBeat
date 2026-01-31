include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "metasprites.inc"


/*******************************************************
* SCENE DATA
* Tilemaps, tiles and beats
********************************************************/
SECTION "FutureSprites", ROM0

    SpriteSheet: INCBIN "buttons.2bpp"
    SpriteSheetEnd:

SECTION "FutureSpriteMaps", ROM0

    TileA: db $0
    TileB: db $1
    TileLeft: db $2
    TileRight: db $3

SECTION "FutureMetasprites", WRAM0

    AButton: STRUCT_METASPRITE

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the game scene 
********************************************************/
SECTION "FutureSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
FutureSceneEntrypoint::
    call SetVBlankInterrupt
    call SetStatInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette

    ld de, SpriteSheet
    ld hl, $8000
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy

    ld hl, AButton              ; sprite
    ld bc, ShadowOAM            ; OAM location
    ld d, 1                     ; width
    ld e, 1                     ; height
    call InitMSprite

    ld hl, AButton              ; sprite
    ld bc, TileA                ; tilemap
    call ColourMSprite
    
    ld hl, AButton              ; sprite
    ld b, 12                    ; x
    ld c, 22                    ; y
    call PositionMSprite


    ;; Background ;;

    /* TODO */


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD


    call FadeIn                 ; fade back in after loading everything

    
    ;; Audio

    di
    ld hl, ProofOfConcept 
    call hUGE_init              ; set music track
    ei
    ld b, 3
    call SlideUpVolume


    ;;

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations


    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "FutureSceneMain", ROM0

; Loop until the player presses start
MainLoop:
    halt                        ; run this loop at 60fps (more is waste of battery)
    jr MainLoop                 ; if button not pressed, loop again
.EndLoop:

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "FutureSceneRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call hUGE_dosound           ; play music
    call RenderToOAM            ; render sprites
    ret

ENDSECTION

