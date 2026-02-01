include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "metasprites.inc"


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

    ld hl, $8000
    call InitGameSpriteVRAM     ; set spritesheets (VRAM = $8000)
    call InitBeatSprites        ; init circular queue


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

    ld a, PAD_A
    call EnqueueBeatSprite
    ld a, PAD_B
    call EnqueueBeatSprite
    ld a, PAD_LEFT
    call EnqueueBeatSprite
    ld a, PAD_RIGHT
    call EnqueueBeatSprite
    halt
    halt
    halt
    halt

    call DequeueBeatSprite
    call DequeueBeatSprite
    call DequeueBeatSprite
    call DequeueBeatSprite
    call DequeueBeatSprite

.end
    jp .end

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

