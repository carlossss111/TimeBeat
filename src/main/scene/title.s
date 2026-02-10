include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "metasprites.inc"


/*******************************************************
* TITLE DATA
* Tilemap and tiles
********************************************************/
SECTION "TitleTileData", ROM0

    SplashData: INCBIN "splash.2bpp"
    SplashDataEnd:

SECTION "TitleTileMap", ROM0

    SplashTilemap: INCBIN "splash.tilemap"
    SplashTilemapEnd:

ENDSECTION


/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises the screen
; @uses all registers
TitleEntrypoint::
    call SetVBlankInterrupt
    call SetStatInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette


    ;; Background ;;

    ld de, SplashData              ; load first half of tiles into VRAM
    ld hl, $9000
    ld bc, SplashDataEnd - SplashData ;16 * 128
    call VRAMCopy

    ;ld de, SplashData + (16 * 128) ; load second half of tiles into VRAM
    ;ld hl, $8800
    ;ld bc, SplashDataEnd - (SplashData + 16 * 128)
    ;call VRAMCopy

    ld de, SplashTilemap           ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, SplashTilemapEnd - SplashTilemap
    call VRAMCopy


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_OFF
    ld [rLCDC], a               ; setup LCD


    call FadeIn                 ; fade back in after loading everything

    
    ;; Audio

    di
    ld hl, MenuMusic
    call hUGE_init              ; set music track
    ei
    ld b, 3
    call SlideUpVolume


    ;;

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations


    jp TitleLoop

ENDSECTION


/*******************************************************
* TITLE LOOP
* Computes input here
********************************************************/
SECTION "TitleMain", ROM0

; Loop until the player presses start
TitleLoop:
    halt                        ; run this loop at 60fps (more is waste of battery)

    call GetCurrentKeys         ; return current keypress in register a
    and a, JOYP_START           ; check if start
    jr z, TitleLoop             ; if button not pressed, loop again


    ld b, 0                     ; channel 1
    ld c, 1                     ; mute
    call hUGE_mute_channel

    ld a, $30
    ld [rNR10], a
    ld a, $80
    ld [rNR11], a
    ld a, $f1
    ld [rNR12], a
    ;ld a, $e5
    ld a, $ef
    ld [rNR13], a
    ;ld a, $84
    ld a, $86
    ld [rNR14], a

    ld b, $0f
    call WaitForFrames          ; let the effect play out

    ld b, 0                     ; channel 1
    ld c, 0                     ; release
    call hUGE_mute_channel


/*
    ld b, 3
    call SlideDownVolume

.wait:
    call GetCurrentKeys 
    and a, JOYP_START    
    jr z, .wait 

    di
    ld hl, SampleTwo 
    call hUGE_init          
    ei
    ld b, 3
    call SlideUpVolume

.wait2:
    call GetCurrentKeys       
    and a, JOYP_START          
    jr z, .wait2 

    ld b, 3
    call SlideDownVolume

.wait3:
    call GetCurrentKeys       
    and a, JOYP_START          
    jr z, .wait3

    di
    ld hl, GameMusic 
    call hUGE_init          
    ei
    ld b, 3
    call SlideUpVolume
*/

    jr TitleLoop             ; if button not pressed, loop again
.EndLoop:

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "TitleRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call hUGE_dosound           ; play music
    call RenderToOAM            ; render sprites
    ret

ENDSECTION

