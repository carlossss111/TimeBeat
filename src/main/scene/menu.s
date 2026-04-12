include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "metasprite.inc"


DEF ARROW_WIDTH EQU 2
DEF ARROW_HEIGHT EQU 1
DEF ARROW_X_0 EQU $58
DEF ARROW_Y_0 EQU $40
DEF ARROW_X_1 EQU $58
DEF ARROW_Y_1 EQU $5c
DEF ARROW_X_2 EQU $58
DEF ARROW_Y_2 EQU $78

DEF LINES_TO_RAISE_BY EQU 2
DEF TOP_SCANLINE_TO_RAISE EQU 0
DEF BOTTOM_SCANLINE_TO_RAISE EQU 40
DEF TITLE_FRAMES EQU 20

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "MenuTileData", ROM0

    BgdDataFirstHalf: INCBIN "menu[first].2bpp.rl"
    BgdDataFirstHalfEnd:
    BgdDataSecondHalf: INCBIN "menu[second].2bpp.rl"
    BgdDataSecondHalfEnd:

SECTION "MenuTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "menu.tilemap.rl"
    BackgroundTilemapEnd:

    WindowTilemap: INCBIN "offset.tilemap.rl"
    WindowTilemapEnd:

SECTION "MenuSpritesheet", ROM0

    ArrowData: INCBIN "menu_arrow.2bpp.rl"
    ArrowDataEnd:

    ArrowSpritesheet: db $0, $1

SECTION "MenuSpriteStruct", WRAM0
    
    ArrowStruct: STRUCT_METASPRITE

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the scene 
********************************************************/
SECTION "MenuSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
MenuSceneEntrypoint::
    xor a
    ldh [hIsMusicReady], a
    xor a
    ld [wTitleYPosition], a
    ld a, TITLE_FRAMES
    ld [wTitleFrames], a

    call InitMenuWindow

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations
    call SetVBlankInterrupt
    call SetStatInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM
    call InitDMA


    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette

    ld hl, $8000

    ld de, ArrowData
    ld hl, $8000
    ld bc, ArrowDataEnd
    call RlCopy                 ; load spritesheet

    ld hl, ArrowStruct
    ld bc, ShadowOAM
    ld d, ARROW_WIDTH
    ld e, ARROW_HEIGHT
    call InitMSprite            ; initialise sprite

    ld hl, ArrowStruct
    ld bc, ArrowSpritesheet
    call ColourMSprite          ; set the spritesheet
    
    ld hl, ArrowStruct
    ld b, ARROW_X_0
    ld c, ARROW_Y_0
    call PositionMSprite
 

    ;; Background ;;

    ld de, BgdDataFirstHalf
    ld hl, $9000
    ld bc, BgdDataFirstHalfEnd
    call RlCopy

    ld de, BgdDataSecondHalf
    ld hl, $8800
    ld bc, BgdDataSecondHalfEnd
    call RlCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd
    call RlCopy


    ;; Animation ;;

    xor a
    call ReqStatOnScanline
    ld hl, ScreenYRaise
    call SetStatHandler


    ;; Window ;;

    ld de, WindowTilemap
    ld hl, $9c00
    ld bc, WindowTilemapEnd
    call RlCopy


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_WIN_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD


    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    ld de, MenuMusic
    call PlayTrack
    call VolumeUp


    ;;
    
    ld a, FUTURE_SCENE
    ld [wSelected], a
    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "MenuSceneVars", WRAM0

    wSelected: db

SECTION "MenuSceneMain", ROM0

; Arrow up
GoUp:
    ld hl, ArrowStruct
    ld bc, META_Y
    add hl, bc
    ld a, [hl]

    cp ARROW_Y_1
    jr z, .ToTop
    cp ARROW_Y_2
    jr z, .ToMiddle
    jr .End

.ToMiddle:
    ld a, PAST_SCENE
    ld [wSelected], a

    ld hl, ArrowStruct
    ld b, ARROW_X_1
    ld c, ARROW_Y_1
    call PositionMSprite
    jr .End

.ToTop:
    ld a, FUTURE_SCENE
    ld [wSelected], a

    ld hl, ArrowStruct
    ld b, ARROW_X_0
    ld c, ARROW_Y_0
    call PositionMSprite
    ;jr .End

.End:
    call MenuSelectSound
    ret


; Arrow down
GoDown:
    ld hl, ArrowStruct
    ld bc, META_Y
    add hl, bc
    ld a, [hl]

    cp ARROW_Y_0
    jr z, .ToMiddle
    cp ARROW_Y_1
    jr z, .ToBottom
    jr .End

.ToMiddle:
    ld a, PAST_SCENE
    ld [wSelected], a

    ld hl, ArrowStruct
    ld b, ARROW_X_1
    ld c, ARROW_Y_1
    call PositionMSprite
    jr .End

.ToBottom:
    ld a, PRESENT_SCENE
    ld [wSelected], a

    ld hl, ArrowStruct
    ld b, ARROW_X_2
    ld c, ARROW_Y_2
    call PositionMSprite
    ;jr .End

.End:
    call MenuSelectSound
    ret


; Main program 
MainLoop:
    call UpdateInput

    call GetNewKeys

    ; Future scene
    push af
    ld b, JOYP_UP << 4
    and b
    jr z, .EndIfUp
.IfUp:
    call GoUp
.EndIfUp:
    pop af

    ; Past scene
    push af
    ld b, JOYP_DOWN << 4
    and b
    jr z, .EndIfDown
.IfDown:
    call GoDown
.EndIfDown:
    pop af

    ; Inc offset
    push af
    ld b, JOYP_RIGHT << 4
    and b
    jr z, .EndIfRight
.IfRight:
    call IncMusicOffset
    call ShowMenuWindow
    call MenuOffsetSound
.EndIfRight:
    pop af

    ; Dec offset
    push af
    ld b, JOYP_LEFT << 4
    and b
    jr z, .EndIfLeft
.IfLeft:
    call DecMusicOffset
    call ShowMenuWindow
    call MenuOffsetSound
.EndIfLeft:
    pop af

    ; Loop
    halt

    ; Check for exit
    ld b, JOYP_START
    and b
    jr z, MainLoop

.EndLoop:
    call HideMenuWindow
    call MenuTransitionSound

    ld b, 0
    ld a, [wSelected]           ; reinit
    ld c, a
    ret

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "MenuSceneRednererVars", WRAM0

    wTitleYPosition: db
    wTitleFrames: db

SECTION "MenuSceneRenderer", ROM0

; Vram
RenderLoop:
    ldh a, [hIsMusicReady]
    and a
    call nz, hUGE_TickSound     ; play music

    call RenderToOAM            ; draw sprites

    call RenderMenuWindow       ; render menu window

    ld a, [wTitleFrames]
    cp a, 0
    jr nz, .Skip                ; every n frames...

    ld a, [wTitleYPosition]
    cp a, 0
    jr nz, .Lower               ; check position of the title
.Raise:
    ld a, LINES_TO_RAISE_BY     ; either raise it
    ld [wTitleYPosition], a
    jr .EndIf

.Lower:
    xor a
    ld [wTitleYPosition], a     ; or lower it
    ;jr .EndIf

.EndIf:
    ld a, TITLE_FRAMES
    ld [wTitleFrames], a

.Skip:
    dec a
    ld [wTitleFrames], a
    reti


; Raises screen up a bit, called as a STAT interrupt handler
; Sets the place for the next STAT handler
ScreenYRaise:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, ScreenYRaise         ; wait for HBlank

    ld a, [wTitleYPosition]
    ld [rSCY], a                ; raise screen Y

    ld a, BOTTOM_SCANLINE_TO_RAISE
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, ScreenYLower
    call SetStatHandler         ; set handler for next STAT interrupt

    ret


; Lowers screen down, called as a STAT interrupt handler
; Sets the place for the next STAT handler
ScreenYLower:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, ScreenYLower         ; wait for HBlank

    xor a
    ld [rSCY], a                ; lower screen Y

    ld a, TOP_SCANLINE_TO_RAISE
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, ScreenYRaise
    call SetStatHandler         ; set handler for next STAT interrupt

    ret

ENDSECTION

