include "hUGE.inc"

SECTION "MenuMusic Song Data", ROMX

MenuMusic::
db 5
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 8
order1: dw P0,P4,P4,P4
order2: dw P1,P1,P1,P1
order3: dw P0,P0,P10,P10
order4: dw P3,P3,P3,P3

P0:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P1:
 dn A#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn A#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F_5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn A#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn G_5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D#5,9,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P3:
 dn G_6,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$000
 dn ___,0,$000
 dn G_6,1,$C08
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$C08
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn G_6,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$000
 dn ___,0,$000
 dn G_6,1,$C08
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_6,1,$C08
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$000
 dn A_7,2,$000
 dn ___,0,$E00

P4:
 dn A#4,8,$000
 dn ___,0,$000
 dn G_4,8,$000
 dn ___,0,$000
 dn D#5,8,$000
 dn ___,0,$000
 dn C_5,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#4,8,$000
 dn ___,0,$000
 dn G_4,8,$000
 dn ___,0,$000
 dn D#5,8,$000
 dn ___,0,$000
 dn C_5,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F_4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#3,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D#4,8,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P10:
 dn A#4,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#3,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_3,1,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn C_3,1,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn C_3,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$11A
 dn F_3,1,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn A#4,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#3,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#3,1,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn D#3,1,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000

itNoiseSP1:
 dn ___,0,$000
 dn 22,2,$000
 dn 5,0,$000
 dn 5,0,$000
 dn 5,0,$000
 dn 5,0,$000
 dn 5,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,1,$000

itNoiseSP2:
 dn ___,0,$000
 dn 26,2,$000
 dn 44,0,$000
 dn 44,0,$000
 dn 44,0,$000
 dn 44,0,$000
 dn 44,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,1,$000

duty_instruments:
itSquareinst1:
db 8
db 0
db 240
dw 0
db 128

itSquareinst2:
db 8
db 64
db 240
dw 0
db 128

itSquareinst3:
db 8
db 128
db 240
dw 0
db 128

itSquareinst4:
db 8
db 192
db 240
dw 0
db 128

itSquareinst5:
db 8
db 0
db 241
dw 0
db 128

itSquareinst6:
db 8
db 64
db 241
dw 0
db 128

itSquareinst7:
db 8
db 128
db 241
dw 0
db 128

itSquareinst8:
db 8
db 192
db 241
dw 0
db 128

itSquareinst9:
db 44
db 140
db 243
dw 0
db 192



wave_instruments:
itWaveinst1:
db 0
db 64
db 1
dw 0
db 128



noise_instruments:
itNoiseinst1:
db 177
dw itNoiseSP1
db 112
ds 2

itNoiseinst2:
db 99
dw itNoiseSP2
db 0
ds 2



routines:
__hUGE_Routine_0:

__end_hUGE_Routine_0:
ret

__hUGE_Routine_1:

__end_hUGE_Routine_1:
ret

__hUGE_Routine_2:

__end_hUGE_Routine_2:
ret

__hUGE_Routine_3:

__end_hUGE_Routine_3:
ret

__hUGE_Routine_4:

__end_hUGE_Routine_4:
ret

__hUGE_Routine_5:

__end_hUGE_Routine_5:
ret

__hUGE_Routine_6:

__end_hUGE_Routine_6:
ret

__hUGE_Routine_7:

__end_hUGE_Routine_7:
ret

__hUGE_Routine_8:

__end_hUGE_Routine_8:
ret

__hUGE_Routine_9:

__end_hUGE_Routine_9:
ret

__hUGE_Routine_10:

__end_hUGE_Routine_10:
ret

__hUGE_Routine_11:

__end_hUGE_Routine_11:
ret

__hUGE_Routine_12:

__end_hUGE_Routine_12:
ret

__hUGE_Routine_13:

__end_hUGE_Routine_13:
ret

__hUGE_Routine_14:

__end_hUGE_Routine_14:
ret

__hUGE_Routine_15:

__end_hUGE_Routine_15:
ret

waves:
wave0: db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
wave1: db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255

