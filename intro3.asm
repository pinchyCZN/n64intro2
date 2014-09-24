;command line: asm crazy2 send (org)
;for trainer test: asm crazy2 p test
modikbuffer: EQU $A0260000
INTDESTINATION  EQU $80500000 ;$80500000
gamereturn EQU $80000434

cheatnumber EQU 5

 include regs.asm
base = $80310000
; org ($80310000-$1000)
; DCB $1000,0
 org $80310000


               jal INITVID
               nop
               la      a8,stack
               jal     ModikInit
               nop
            li      a0,modikbuffer
            jal     ModikStartPlay
            nop
            la      a8,stack
            jal     COPYDLlist
            nop



;               jal INITRDP
               nop

               sw      r0,$A4400010  ;clear vi int

               li    d0,171<<24|15<<16|155<<8
               move  d1,d0
               la    a0,cube
               jal   changeobjectcolor
               nop


part1:         jal WTOF
               nop
               jal swapframebuffers
               nop
               jal swapDLlists
               nop
            jal readcontroller2
            nop

            jal updatemod
            nop
            jal controller
            nop
            jal readcontroller1
            nop

            lw  d0,option_num
            li  d1,9
            multu d0,d1
            mflo  d1      ;desired pos
            lw    d2,option_position  ;actual pos
            beq   d1,d2,@skip
            subu  d3,d1,d2
            bltzl  d3,@subpos
            addu  d2,-1
@subpos     bgtzl  d3,@addpos
            addu  d2,1
@addpos
            sw    d2,option_position
@skip


               li   d0,0
               jal  setrendermode
               nop
               li d0,0    ;x
               li d1,0    ;y
               li d2,320   ;width
               li d3,180   ;height
               li d4,$6a246a24|$10001
               jal fillrect
               nop

               li d0,0    ;x
               li d1,180    ;y
               li d2,320   ;width
               li d3,70   ;height
               li d4,$2c2a2c2a|$10001
               jal fillrect
               nop

               jal sprite_init
               nop
               li  d0,0  ;x
               li  d1,94 ;y
               li  d2,320  ;width
               li  d3,180-95  ;height
               jal setscissor
               nop

               jal showoptions
               nop

               li  d0,0  ;x
               li  d1,0 ;y
               li  d2,320  ;width
               li  d3,240  ;height
               jal setscissor
               nop

               jal  dogremlin
               nop
               jal  doscroller
               nop

               jal  dologo
               nop

               jal Sprite_end
               nop

   ;********reset windows*****************
               li  d0,0
               li  d1,0
               li  d2,320
               li  d3,240
               jal setscissor
               nop


               LA  A0,CUBE
               jal dotriangle
               nop
               jal END_displaylist
               nop

               la  a0,cube
               jal addangles
               nop

            j part1
            nop
                                     
EXIT:

            la    a0,TRAINN
            la    a2,TRAINNEND
            li    a1,$A0000180
@storetrain: lw    d1,0(a0)
            sw    d1,0(a1)
            addiu a1,a1,4
            bne   a0,a2,@storetrain
            addiu a0,a0,4

;*******KIL CERTAIN OPTIONS************
        la   a0,statTRN1
        la   a1,trainpointers
        li   d7,cheatnumber-1
@loopy
        lbu  d0,0(a0)
        addu a0,1
        bnez d0,@itsok
        lw   a4,0(a1)
        sw   r0,0(a4)
@itsok  addu a1,4
        bnez d7,@loopy
        addu d7,-1


        ori     t0,r0,$189   ;1+$00000188
        mtc0    t0,r18
        nop
        nop
        mtc0    r0,r19
        nop
        li    sp,$803ffff0
        li    t0,gamereturn
        jr    t0
        nop

adjustcolor:            ;color is in d11 , d10 = temp
                        ;d7=shift amount
             lw    d7,colorshift
             srl   d10,d11,11      ;get red
             subu  d10,d10,d7
             bltzl d10,redbad
             addiu d10,r0,0
             sll   d10,d10,11
redbad:      andi  d11,d11,%11111111111  ;0+5+5+1
             or    d11,d11,d10
             srl   d10,d11,6
             andi  d10,d10,%11111
             subu  d10,d10,d7
             bltzl d10,greenbad
             addiu d10,r0,0
             sll   d10,d10,6
greenbad:    andi  d11,d11,%1111100000111111 ;5+0+5+1
             or    d11,d11,d10
             srl   d10,d11,1
             andi  d10,d10,%11111
             subu  d10,d10,d7
             bltzl d10,bluebad
             addiu d10,r0,0
             sll   d10,d10,1
bluebad:     andi  d11,d11,%1111111111000001 ;5+5+0+1
             or    d11,d11,d10
             jr    ra
             nop

colorshift: DW $1F       ;make color darkest
statTRN1:
 REPT  cheatnumber
 DB 1
 ENDR
endstatTRN
 cnop 0,4
trainpointers
 DW TRAIN1,TRAIN2,TRAIN3,TRAIN4,TRAIN5                      


 cnop 0,4
 NOP
 NOP
WTOF:
               lw      d3,$A4300008
               andi    d3,$8
               bnez    d3,RASTER_TOO_OLD   
               lui     a0,$A440     ;wait for TOF
ZBAC:          lw      d1,$10(a0)
VI_INT_RASTER  ADDIU   d0,r0,$200
               bne    d0,d1,ZBAC
               nop
RASTER_TOO_OLD                  
               sw      r0,$A4400010
               jr      ra
               nop
addangles:
         li    d8,3

         addiu a0,a0,-4*6
@loop:
         lw    d0,0(a0)       ;vadd
         lw    d1,4*3(a0)      ;vinklar
         addu  d0,d0,d1       ;x+[x]
         andi  d0,d0,511      ;keep <511
         sw    d0,4*3(a0)
         addiu d8,d8,-1
         bnez  d8,@loop
         addiu a0,a0,4
         jr ra
         nop


 ;*******include files***************
 cnop 0,4
 include musak.asm
 cnop 0,4
 include sprite2.asm
 cnop 0,4
 include triangle.asm
 include trainn.asm
 include controller.asm
 include RDP.asm
 include inits.asm
 include effects.asm
 include text.asm
 include anim.asm
 
obj3lightscale: DW 56
obj3zoom:    DW 180
obj3count:   DW 12
obj3xcenter: DW 240
obj3ycenter: DW 60
obj3Vadds:   DW 2,1,1
obj3Vinklar: DW 0,0,0
cube:
 include cube.asm





sinuslist:
 incbin sinus


 CNOP 0,8
RDP_start:

           dw  $EF080CFF   ; RDPSetOtherMode
           dw  $00000000

           dw  $EF880CFF   ; RDPSetOtherMode
           dw  $00000000

           dw  $ED000000   ; SetScissor
           dw  $005003C0

           ;dw  $EF880CBF
           DW $EF890CFF;$EF892CFF;$EF892CBF  ; RDPSetOtherMode
           dw  $00000000

           DW $EF892CFF
           DW $0
           DW $EF892CBF
           DW $0

           DW $FC26A004  SetCombine
           DW $1FFC93FC

           dw  $E7000000   ; RDPPipeSync
           dw  $00000000

           dw  $FF10013F   ; SetCimg
SetCimg:   dw  $80400000-(320*240*2)

           dw  $E7000000   ; RDPPipeSync
           dw  $00000000

           dw  $EFB92CBF ; RDPSetOtherMode
           dw  $00000000

           dw  $EFB92CBF  ; RDPSetOtherMode
           dw  $0F0A4000

           dw  $F7000000   ; SetFillColor
           dw  $00010001   ;ALPHA??

           dw  $F64FC3BC   ; FillRect
           dw  $00000000   

           dw  $C0000000   ; Noop
           dw  $00000000

           dw  $E7000000   ; RDPPipeSync
           dw  $00000000 

           dw  $FF10013F   ; SetCimg
SetZimg:   dw  $00400000-(320*240*2)*3

           dw  $F7000000   ; SetFillColor
           dw  $FFFCFFFC

           dw  $F64FC3BC   ; FillRect
           dw  $00000000

           dw  $C0000000   ; Noop
           dw  $00000000

           dw  $E7000000   ; RDPPipeSync
           dw  $00000000

  dw $EF992CBF
  dw $0F0A4000
  dw $EF992CBF
  dw $0C182078

           dw  $FF10013F   ; SetCimg
SetCimg1:  dw  $80400000-(320*240*2)

           dw  $FE000000   ; SetZimg
           dw  $80400000-(320*240*2)*3

beginRDPcommand:
                   dw $E7000000
                   dw 0
                   REPT 2
                   dw $EF892CBF
                   dw $0C182078
                   ENDR
                   REPT 4
                   dw $EF812CBF
                   dw $0C182078
                   ENDR

                   REPT 2
                   dw $EF802CBF
                   dw $0C182078
                   ENDR

                   REPT 1
                   dw $EF802CBF 
                   dw $0F0A7008 
                   ENDR
           ; end sprite init

           dw $EF802CBF
           dw $00504240
 
          dw  $E7000000   ; RDPPipeSync
          dw  $00000000


            dw $FA000000   ;SetPrimColor
            dw $FFFFFFFF

            dw $fc11fe23
            dw $fffff3f9



           dw  $C0000000   ; Noop        
           dw  $00000000

           dw  $C0000000   ; Noop
           dw  $00000000


     dw    $E9000000
     dw    $00000000
RDP_end:   nop
