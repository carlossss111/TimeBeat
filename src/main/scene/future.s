include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "metasprites.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "FutureTileData", ROM0

    BackgroundData: INCBIN "beatmap.2bpp"
    BackgroundDataEnd:

SECTION "FutureTileMap", ROM0

    BackgroundTilemap: INCBIN "beatmap.tilemap"
    BackgroundTilemapEnd:

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

    ld hl, $8000
    call InitGameSpriteVRAM     ; set spritesheets (VRAM = $8000)
    call InitBeatSprites        ; init circular queue

    
    ;; Game ;;
    
    ld hl, FutureBeatTrack
    ld bc, FutureBeatTrackEnd
    call InitBeatTracker        ; init array of beats on the Future Track


    ;; Background ;;

    ld de, BackgroundData       ; load first half of tiles into VRAM
    ld hl, $9000
    ld bc, BackgroundDataEnd - BackgroundData
    call VRAMCopy

    ;ld de, SplashData + (16 * 128) ; load second half of tiles into VRAM
    ;ld hl, $8800
    ;ld bc, SplashDataEnd - (SplashData + 16 * 128)
    ;call VRAMCopy

    ld de, BackgroundTilemap ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd - BackgroundTilemap
    call VRAMCopy



    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    di
    ld hl, BeatTest
    call hUGE_init              ; set music track
    ei
    ld b, 3
    call SlideUpVolume

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations

    call InitTick               ; initialise tick counter

    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "FutureSceneMain", ROM0

; Loop until the player presses start
/**
* function(ticks){
* 
*     if (beat_tracker->next->ticks == ticks) {
*         enqueue_next_sprite();
*         beat_tracker->advance_next()
*     }
*     move_sprites()
* 
*     ticks++
* }
*/
MainLoop:

.IfAtEndOfSprites:
    call IsNextPtrAtEnd
    cp TRUE
    jp z, .EndIf                ; if at end, skip more enqueues

.IfTimeForNextSprite:
    call GetNextTick            ; bc = next tick on tracker
    ldh a, [hTick]              ; check if tick on current beat >= time ticks
    cp b
    jr c, .EndIf
    ldh a, [hTick + 1]
    cp c
    jr c, .EndIf

    ld a, PAD_A                 ; TODO: PLACEHOLDER
    call EnqueueBeatSprite      ; enqueue sprite
    call AdvanceNext            ; advance next pointer on beatmap

.EndIf:
    call MoveBeatSprites        ; move all sprites

    halt                        ; VSync to 60FPS
    jr MainLoop
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
    call IncTick                ; increment tick counter once every frame
    ret

ENDSECTION

