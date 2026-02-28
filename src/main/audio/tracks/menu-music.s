; Generated from /home/daniel/Repos/timebeat/rsc/music/menu.uge on 2026-02-28 10:50:34 UTC
; Song: 
; Artist: 
; Comment: 
; Expected playback method: VBlank

REDEF fortISSimO_VERSION equs /* Generated with teNOR version: */ "1.0.5"
INCLUDE "fortISSimO.inc"

SECTION "MenuMusicTrack", ROM0

menu::
	db 5 ; Tempo (ticks/row)
	db (4 - 1) * 2 ; Max index into order "columns"
	dw .dutyInstrs, .waveInstrs, .noiseInstrs
	dw .routine
	dw .waves
	db HIGH(.mainCellCatalog), HIGH(.subpatCellCatalog)

.ch1  dw .dutyPtrn0 , .dutyPtrn4 , .dutyPtrn8 , .dutyPtrn12,
.ch2  dw .dutyPtrn1 , .dutyPtrn5 , .dutyPtrn9 , .dutyPtrn13,
.ch3  dw .wavePtrn2 , .wavePtrn6 , .wavePtrn10, .wavePtrn14,
.ch4  dw .noisePtrn3 , .noisePtrn7 , .noisePtrn11, .noisePtrn15,


.dutyPtrn1
.dutyPtrn5
.dutyPtrn13
.dutyPtrn9
	db   5, 21, 14, 21,  5, 21, 14, 21, 14, 21,  4, 21, 14, 21,  4, 21,  4, 21, 21, 21,  7, 21, 21, 21,  4, 21, 21, 21, 25, 21, 21, 21,  5, 21, 14, 21,  5, 21, 14, 21, 14, 21,  4, 21, 14, 21,  4, 21,  4, 21, 21, 21, 24, 21, 21, 21, 19, 21, 21, 21,  4
.dutyPtrn0
.wavePtrn2
.wavePtrn6
	db  21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21
.noisePtrn15
.noisePtrn11
.noisePtrn7
.noisePtrn3
	db   1, 21, 21, 21, 15, 21, 21, 21,  1, 21, 22, 21, 15, 21, 21, 21,  1, 21, 21, 21, 15, 21, 21, 21, 21, 21, 22, 21, 15, 21, 15, 21,  1, 21, 21, 21, 15, 21, 21, 21,  1, 21, 22, 21, 15, 21, 21, 21,  1, 21, 21, 21, 15, 21, 21, 21, 21, 21, 22, 21, 15, 21, 15, 10
.dutyPtrn8
.dutyPtrn4
.dutyPtrn12
	db  16, 21,  2, 21, 17, 21, 11, 21, 21, 21, 16, 21, 21, 21, 16, 21, 21, 21, 21, 21, 16, 21, 21, 21, 16, 21, 21, 21, 16, 21, 21, 21, 16, 21,  2, 21, 17, 21, 11, 21, 21, 21, 20, 21, 21, 21,  2, 21, 21, 21, 21, 21,  8, 21, 21, 21,  6, 21, 21, 21, 23, 21, 21, 21
.wavePtrn14
	db  19, 21, 21, 21, 21, 21, 21, 21, 13, 21, 21, 21, 21, 21, 21, 21,  9, 21, 10, 21,  9, 21, 10, 21,  9, 21, 21, 18, 12, 21, 10, 21, 19, 21, 21, 21, 21, 21, 21, 21, 13, 21, 21, 21, 21, 21, 21, 21,  0, 21, 21, 21,  0, 10, 21, 21, 13, 21, 10, 21,  3, 21, 10, 21
.wavePtrn10
	db  19, 21, 21, 21, 21, 21, 21, 21, 13, 21, 21, 21, 21, 21, 21, 21,  9, 21, 10, 21,  9, 21, 10, 21,  9, 21, 21, 18, 12, 21, 10, 21, 19, 21, 21, 21, 21, 21, 21, 21, 13, 21, 21, 21, 21, 21, 21, 21,  0, 21, 21, 21, 21, 21, 21, 21, 13, 21, 10, 21,  3, 21, 10, 21

	ds align[8]
.mainCellCatalog
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1a,$00,$00,$00,$80,$00,$00,$00,
	ds align[8]
	db $10,$10,$20,$10,$10,$10,$20,$10,$20,$10,$0e,$20,$10,$10,$10,$20,$20,$20,$01,$10,$20,$00,$1c,$20,$10,$10,
	ds align[8]
	db $07,$2b,$13,$03,$1b,$22,$0a,$18,$07,$00,$5a,$18,$05,$0a,$1f,$39,$16,$1b,$5a,$16,$11,$5a,$2b,$0f,$13,$1d,

.noiseInst2Subpattern
	db   2,  1
.noiseInst1Subpattern
	db   2,  0

	ds align[8]
.subpatCellCatalog
	db $00,$00,$00,
	ds align[8]
	db $10,$10,$10,
	ds align[8]
	db $2c,$34,$b4,

assert LAST_NOTE == 72, "LAST_NOTE == {LAST_NOTE}"
assert PATTERN_LENGTH == 64, "PATTERN_LENGTH == {PATTERN_LENGTH}"

.dutyInstrs
:; Duty instrument 9: Arp
	db 2 << 4 | 1 << 3 | 4 ; Sweep (NR10)
	db %10 << 6 | 12 ; Duty & length (NRx1)
	db 15 << 4 | 0 << 3 | 3 ; Volume & envelope (NRx2)
	dw 0 ; Subpattern pointer
	db $80 | 1 << 6 ; Retrigger bit, and length enable (NRx4)
assert DUTY_INSTR_SIZE == 6 && @ - :- == 6
:; Duty instrument 8: Duty 75% plink
	db 0 << 4 | 1 << 3 | 0 ; Sweep (NR10)
	db %11 << 6 | 0 ; Duty & length (NRx1)
	db 15 << 4 | 0 << 3 | 1 ; Volume & envelope (NRx2)
	dw 0 ; Subpattern pointer
	db $80 | 0 << 6 ; Retrigger bit, and length enable (NRx4)
assert DUTY_INSTR_SIZE == 6 && @ - :- == 6

.waveInstrs
:; Wave instrument 1: Bass
	db 0 ; Length (NR31)
	db %10 << 5 ; Output level (NR32)
	dw 0 ; Subpattern pointer
	db $80 | 0 << 6 ; Retrigger bit, and length enable (NRx4)
	db 0 << 4 ; Wave ID
assert WAVE_INSTR_SIZE == 6 && @ - :- == 6

.noiseInstrs
:; Noise instrument 1: Kick
	db 11 << 4 | 0 << 3 | 1 ; Volume & envelope (NR42)
	dw .noiseInst1Subpattern ; Subpattern pointer
	db 0 << 7 | 1 << 6 | 48 ; LFSR width (NR43), length enable (NR44), and length (NR41)
assert NOISE_INSTR_SIZE == 4 && @ - :- == 4
:; Noise instrument 2: Snare
	db 6 << 4 | 0 << 3 | 3 ; Volume & envelope (NR42)
	dw .noiseInst2Subpattern ; Subpattern pointer
	db 0 << 7 | 0 << 6 | 0 ; LFSR width (NR43), length enable (NR44), and length (NR41)
assert NOISE_INSTR_SIZE == 4 && @ - :- == 4

.waves
	db $00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, ; Originally #1

.routine

ENDSECTION

