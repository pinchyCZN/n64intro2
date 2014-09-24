
INITVID:            addiu   t0,r0,8  ;init video RUTINE
                    lui     at,$BFC0
                    sw      t0,$07FC(at) ;CLEAR BUTTONS??
                    lui     t0,$A440
                    li      t1,$00013006
                    sw      t1,0(t0)   ;STATUS REG=$0001.3006
                    lw      t1,frame       ;ORIGIN=frame
                    sw      t1,4(t0)
                    li      t1,$0140
                    sw      t1,$8(t0)   ;WIDTH=140

           ;****TEST IF PAL AND INIT ACCORDINGLY******
                    lw      t1,($A0000300)
                    beqz    t1,pal_init
 ; b pal_init
                    nop
           ;****continue with NTSC init*********
                    li      t1,$200
                    sw      t1,$C(t0)   ;INTERUPT AT LINE 200
                    li      t1,0
                    sw      t1,$10(t0)   ;CLEAR INTERUPT TO 0
                    li      t1,$03E52239
                    sw      t1,$14(t0)   ;VIDEO TIMING=03E5.2239
                    li      t1,$20D
                    sw      t1,$18(t0)   ;V_SYNC=020D
                    li      t1,$C15
                    sw      t1,$1C(t0)   ;H_SYNC=0C15
                    li      t1,$0C150C15
                    sw      t1,$20(t0)   ;H_SYNC_LEAP=0C15
                    li      t1,$006C02EC
                    sw      t1,$24(t0)   ;H_VID=006C.02EC(640 PIXELS)
                    li      t1,$002501FF
                    sw      t1,$28(t0)   ;V_VID=0025.01FF
                    li      t1,$000E0204
                    sw      t1,$2C(t0)   ;V_BURST=000E.0204
                    li      t1,$200
                    sw      t1,$30(t0)   ;X_SCALE=0200
                    li      t1,$400
                    sw      t1,$34(t0)   ;Y_SCALE=0400
                    jr      ra
                    nop
pal_init:
                    li      t1,0
                    SH      t1,(VI_INT_RASTER+2)|($A<<28)
                    sw      t1,$C(t0)   ;INTERUPT AT LINE 200
                    li      t1,$18E
                    sw      t1,$10(t0)     
                    li      t1,$4541E3A
                    sw      t1,$14(t0)
                    li      t1,$271
                    sw      t1,$18(t0)
                    li      t1,$170C69
                    sw      t1,$1C(t0)
                    li      t1,$C6F0C6D
                    sw      t1,$20(t0)
                    li      t1,$800300
                    sw      t1,$24(t0)
                    li      t1,$5F0239
                    sw      t1,$28(t0)
                    li      t1,$9026B
                    sw      t1,$2C(t0)
                    li      t1,$200
                    sw      t1,$30(t0)
                    li      t1,$400
                    sw      t1,$34(t0)
                    jr      ra
                    nop

storeINT            la    a0,INThandler
                    li    a1,$A0000180
                    addiu d0,r0,30  ;number of words
@storeloop:         lw    d1,0(a0)
                    addiu a0,a0,4
                    sw    d1,0(a1)
                    sync
                    cache $10,0(a1)
                    addiu a1,a1,4
                    bne   d0,r0,@storeloop
                    addiu d0,d0,-1
                    jr ra
                    nop

INThandler:
      obj $80000180
               li   a0,base
               jr   a0
               nop
      objend

       DCB 32*4,0
stack: nop
       nop
