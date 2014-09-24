TRAINN:
     OBJ $80000180

                    nop
                    mfc0    k0,r14
                    nop
                    add     k0,k0,4
                    li      k1,$80000010
                    sd      d0,0(k1)       ;dont use d5!!!
                    sd      d1,8(k1)
                    sd      a0,16(k1)
                    sd      at,24(k1)
                   LI     A0,$80150000
                   li     d0,$6400
TRAIN1             sh     d0,$02AA(A0) ;p1 ENERGY
TRAIN2             SH     D0,$02AE(A0) ;P1 SHEILD
                   LI     D1,$3200
TRAIN3             SH     D1,$02B2(A0) ;P1 JETPACK
TRAIN4             SH     R0,$292A(A0) ;NO SHEILD P2
                   LHU    D0,$BFC007C4
                   BNE    D0,CONT_Z|CONT_L|CONT_R,HERE123
                   LI     D1,1
TRAIN5             SH     D1,$2926(A0) ;1 HIT DEATH P2
HERE123

INTreturn:
                    mtc0    r0,r18
                    ld      d0,0(k1)       
                    ld      d1,8(k1)
                    ld      a0,16(k1)
                    ld      at,24(k1)
                    jr      k0
                    nop
   cnop 0,8
   OBJEND
TRAINNEND:


