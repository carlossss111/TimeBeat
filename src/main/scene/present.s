include "hardware.inc"
include "scenes.inc"
include "macros.inc"
include "beattracker.inc"

/*******************************************************
* SCENE DATA
* Tilemap and tiles
********************************************************/
SECTION "PresentTileData", ROM0

    BackgroundData: INCBIN "future_tiles_combined.2bpp.rl" 
    BackgroundDataEnd:

SECTION "PresentTileMap", ROM0

    DEF EMPTY_TILE EQU $0

    BackgroundTilemap: INCBIN "beatmap.tilemap.rl"
    BackgroundTilemapEnd:

SECTION "PresentTracks", ROM0

    BeatTrackA: INCBIN "present.bin.a"
    BeatTrackAEnd:
    BeatTrackB: INCBIN "present.bin.b"
    BeatTrackBEnd:
    BeatTrackLeft: INCBIN "present.bin.l"
    BeatTrackLeftEnd:
    BeatTrackRight: INCBIN "present.bin.r"
    BeatTrackRightEnd:

SECTION "PresentBeats", WRAM0

    BeatStreamA: STRUCT_BEAT_STREAM
    BeatStreamB: STRUCT_BEAT_STREAM
    BeatStreamLeft: STRUCT_BEAT_STREAM
    BeatStreamRight: STRUCT_BEAT_STREAM

ENDSECTION


/*******************************************************
* SCENE ENTRYPOINT
* Initialises the game scene 
********************************************************/
SECTION "PresentSceneEntrypoint", ROM0

; Entrypoint for the game screen, initialises the screen
PresentSceneEntrypoint::
    xor a
    ldh [hIsMusicReady], a

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
    
    ld a, PAD_A
    ld hl, BeatStreamA
    ld bc, BeatTrackA
    ld de, BeatTrackAEnd
    call InitBeatStream

    ld a, PAD_B
    ld hl, BeatStreamB
    ld bc, BeatTrackB
    ld de, BeatTrackBEnd
    call InitBeatStream

    ld a, PAD_LEFT
    ld hl, BeatStreamLeft
    ld bc, BeatTrackLeft
    ld de, BeatTrackLeftEnd
    call InitBeatStream

    ld a, PAD_RIGHT
    ld hl, BeatStreamRight
    ld bc, BeatTrackRight
    ld de, BeatTrackRightEnd
    call InitBeatStream


    ;; Background ;;

    ld de, BackgroundData
    ld hl, $9000
    ld bc, BackgroundDataEnd
    call RlCopy

    ld de, BackgroundTilemap
    ld hl, TILEMAP0
    ld bc, BackgroundTilemapEnd
    call RlCopy

    call InitBackgroundScroll

    
    ;; Window

    call InitGameWindow


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    call FadeIn                 ; fade back in after loading everything

   
    ;; Audio

    di

	xor a
	ldh [hUGE_MutedChannels], a
    ld de, PresentMusic 
    call hUGE_SelectSong        ; start music
    ld a, 1
    ldh [hIsMusicReady], a

    ei

    ld b, 3
    call SlideUpVolume

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations

    xor a
    ld b, a
    ld c, a
    call InitTick               ; initialise tick counter


    ;; Start text

    ;TODO FIX
    ;call StartSequence


    jp MainLoop

ENDSECTION


/*******************************************************
* MAIN LOOP
* Computes input here
********************************************************/
SECTION "PresentSceneMain", ROM0

; Main program loop wahhey
MainLoop:
    ; Update button presses
    call UpdateInput

    ; Spawn the beats!
    ld hl, BeatStreamA
    call SpawnBeats
    ld hl, BeatStreamB
    call SpawnBeats
    ld hl, BeatStreamLeft
    call SpawnBeats
    ld hl, BeatStreamRight
    call SpawnBeats

    ; Handle inputs
    call GetNewKeys

    push af
    ld b, JOYP_A
    ld hl, BeatStreamA
    call CheckInput
    pop af
    push af
    ld b, JOYP_B
    ld hl, BeatStreamB
    call CheckInput
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, BeatStreamLeft
    call CheckInput
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, BeatStreamRight
    call CheckInput
    pop af

    call GetReleasedKeys

    push af
    ld b, JOYP_A
    ld hl, BeatStreamA
    call CheckRelease
    pop af
    push af
    ld b, JOYP_B
    ld hl, BeatStreamB
    call CheckRelease
    pop af
    push af
    ld b, JOYP_LEFT << 4
    ld hl, BeatStreamLeft
    call CheckRelease
    pop af
    push af
    ld b, JOYP_RIGHT << 4
    ld hl, BeatStreamRight
    call CheckRelease
    pop af

    ; Check for missed beats
    ldh a, [hTick]
    ld b, a
    ldh a, [hTick + 1]
    ld c, a

    push bc
    ld hl, BeatStreamA
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamB
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamLeft
    call HandleMiss
    pop bc
    push bc
    ld hl, BeatStreamRight
    call HandleMiss
    pop bc

    ; Check if at end of beatmap
    ld hl, BeatStreamA
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamB
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamLeft
    call HasMoreBeatsToHit
    cp TRUE
    jr z, .EndIfAtFinish
    ld hl, BeatStreamRight
    call HasMoreBeatsToHit
    cp TRUE
    jr nz, .EndLoop
.EndIfAtFinish:

    ; Loop
    halt
    jp MainLoop
.EndLoop:

    call ClearAllButtonEffects

    call EndSequence 

    ld b, 3
    call SlideDownVolume
    call FadeOut

    call UnsetStatInterrupt
    call UnsetVBlankInterrupt
    call InitBackgroundScroll

    ld bc, SUMMARY_SCENE
    ret

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "PresentSceneRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    ldh a, [hIsMusicReady]
    and a
    call nz, hUGE_TickSound     ; play music

    call RenderToOAM            ; render sprites

    ei                          ; allow stat register
    call IncTick                ; increment tick counter once every frame
    call MoveBeatSprites        ; move all sprites
    call ClearOldText           ; clear old text
    call ScrollBackground

    ret

ENDSECTION

