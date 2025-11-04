include "hardware.inc"
include "enums.inc"
include "macros.inc"
include "metasprites.inc"


/*******************************************************
* TITLE DATA
* Tilemap and tiles
********************************************************/
SECTION "TitleTileData", ROM0

    SplashData: INCBIN "alchemical_anarchy.2bpp"
    SplashDataEnd:


SECTION "TitleTileMap", ROM0

    SplashTilemap: INCBIN "alchemical_anarchy.tilemap"
    SplashTilemapEnd:

ENDSECTION

/*******************************************************
* TITLE METASPRITES
* Sprite structs
********************************************************/
SECTION "TitleSpriteData", ROM0

    SpriteSheet: INCBIN "sparkles.2bpp"
    SpriteSheetEnd:

SECTION "TitleSpriteMap", ROM0

    Sparkles1Indices: db $00, $01, $02, $03, $04, $05

SECTION "TitleMetasprites", WRAM0
    
    Sparkles1: STRUCT_METASPRITE

ENDSECTION

/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises the screen
; @uses all registers
TitleEntrypoint::
    call SetVBlankInterruptOnly ; set the VBlank interrupt
    ei

    call FadeOut                ; fade to black

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21
    ld [rLCDC], a               ; setup LCD

    call ClearShadowOAM         ; initialise shadow OAM

    ld de, SpriteSheet
    ld hl, $8000
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy

    ld hl, Sparkles1            ; sprite
    ld bc, ShadowOAM            ; place to shadow at
    ld d, 2                     ; width
    ld e, 3                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles1            ; sprite
    ld bc, Sparkles1Indices     ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles1            ; sprite
    ld b, 0                     ; x
    ld c, 0                     ; y
    call PositionMSprite

    ld de, SplashData           ; load first half of tiles into VRAM
    ld hl, $9000
    ld bc, 16 * 128
    call VRAMCopy

    ld de, SplashData + (16 * 128) ; load second half of tiles into VRAM
    ld hl, $8800
    ld bc, SplashDataEnd - (SplashData + 16 * 128)
    call VRAMCopy

    ld de, SplashTilemap        ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, SplashTilemapEnd - SplashTilemap
    call VRAMCopy

    call FadeIn                 ; fade back in after loading everything

    call InitAllTitleAnimations
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
; @uses all registers
TitleLoop:
    halt                        ; run this loop at 60fps (more is waste of battery)
    
    call GetCurrentKeys         ; return current keypress in register a
    and a, JOYP_START           ; check if start
    jp z, TitleLoop             ; if button not pressed, loop again

.exit:
    ld bc, GAME_SCENE           ; set next scene
    di                          ; disable interrupts
    ret                         ; return to main loop

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "TitleRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call AnimateBottle
    ret

ENDSECTION

