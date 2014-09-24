

showoptions:
              li   d0,20   ;xpos
              li   d1,117  ;initial y
              lw   d7,option_position
              subu d1,d7   ;move up  y
              li   d6,8
              sw   d6,width
              sw   d6,height
              li   d5,$10000
              sw   d5,xscale
              sw   d5,yscale
              la   a0,traintxt
           sw ra,0(a8)    

@textloop
              lbu  d3,0(a0)
              addu a0,1
              beqz d3,@finished
              li   d4,1
              bne  d3,d4,@nolinefeed
              nop
              lbu  d3,0(a0)
              addu a0,1
              addu d1,9   ;next line
              li   d0,20  ;reset xpos
          bgt  d1,200,@finished

@nolinefeed
              addu d3,-32
              beqz d3,@skipnull
              sll  d3,7    ;7=8x8  |9=16x16
              la   d5,raw8fonts
              addu d5,d3
              sw   d5,spritepointer
              sw   d0,xposition
              sw   d1,yposition
              sw   d0,-4(a8)
              sw   d1,-8(a8)
              sw   a0,-12(a8)

              jal  dosprite
              nop
              lw   d0,-4(a8)
              lw   d1,-8(a8)
              lw   a0,-12(a8)
@skipnull
              addu d0,8      ;next xpos

              b    @textloop
              nop
@finished      
              li   d0,20-10   ;xpos        ;draw the pointer
              li   d1,117  ;initial y
              sw   d0,xposition
              sw   d1,yposition
              la   a0,raw8fonts+(('>'-32)<<7)
              sw   a0,spritepointer
              jal  dosprite
              nop
     ;draw either yes or no
              la   a3,statTRN1
              li    d0,176     ;initial xpos
              li    d1,117  ;initial y
              lw    d7,option_position
              subu  d1,d7   ;move up  y

@statloop
              sw    d1,yposition
              lbu   d4,0(a3)
              addu  a3,1
              la    a0,strno
              beqz  d4,@itsno
              nop
              la    a0,stryes

@itsno
              lbu   d5,0(a0)
              addu  a0,1
              beq   d5,1,@finished1
              addu  d5,-32
              sll   d5,7    ;for 8x8
              la    a1,raw8fonts
              addu  a1,d5
              sw    a1,spritepointer
              sw    d0,xposition
              sw    d1,-4(a8)
              sw    a3,-8(a8)
              sw    a0,-12(a8)
              sw    d0,-16(a8)
              jal   dosprite
              nop
              lw    d1,-4(a8)
              lw    a3,-8(a8)
              lw    a0,-12(a8)
              lw    d0,-16(a8)
              addu  d0,8    ;next xpos
              b     @itsno
              nop
@finished1    li    d0,176  ;reset xpos
              addu  d1,9    ;next ypos
              la    a0,endstatTRN
              bne   a0,a3,@statloop
              nop

              lw   ra,0(a8)
              jr   ra
              nop

option_num dw 0
option_position: dw 0


traintxt:
          DB "UNLIMITED ENERGY P1",1
          DB "UNLIMITED SHEILD P1",1
          DB "UNLIMITED JET P1   ",1
          DB "NO SHEILD P2       ",1
          DB "L+R+Z 1 HIT DEAD P2",0,0,0

 CNOP 0,4
stryes: DB "YES",1
strno:  DB "NO",1

greets
          DB "   CZN BRINGS YOU   ",2
          DB " BIO FREAKS +5      ",1
          DB " TRAINED BY DESTOP  ",2
          DB "   ON 5/06/99       ",1
          DB "   CODE: DESTOP     ",2
          DB " MODPLAYER: TITANIK ",1
          DB " GREETS FLY OUT TO  ",2
          DB " NAGRA,WILDFIRE,LAC ",1
          DB " JOVIS,DATAWIZ,JL   ",2
          DB " WT-RIKER,RENDERMAN ",1
          DB "    NOP,DEMO,IMMO   ",2
          DB "   TWINSEN,REFRIED  ",1
          DB "   STUMBLE,WIDGET   ",2
          DB "   PUREVIL,HARTEC   ",1
          DB "   ACTRAISER,SNAKE  ",2
          DB "DX,LAXITY,C4,ZILMAR ",1
          DB "ANARKO,SISPEO,LOOM  ",2
          DB " SPUUG,NANCYY,MEMIR ",1

          DB " PIPS,HECTIC,ZYOP   ",1
          DB " AND ALL THE OTHER  ",2
          DB "    COOL PEEPL      ",1
          DB " GROUPS: TRSI,TSF   ",2
          DB " DEXTROSE,BLACKBAG  ",1
          DB "   EURASIA,NBC      ",2
          DB " TEXT RESTARTS NOW! ",0,0,0
 cnop 0,8
raw8fonts:
 incbin c64font1.til
 cnop 0,4
greetspointer: dw greets
nextline: dw 0
scrolldelay dw 0
scrollposition: dw 400
scrollstatus: dw 0       ;0 scroll left|1= wait|2=scrollleft some more
doscroller:
             sw  ra,0(a8)

             lw a1,greetspointer
             lw d0,scrollposition
          li   d1,240-55  ;y
          sw   d1,yposition
          li   d2,16
          sw   d2,height
          sw   d2,width
          li   d3,$10000  ;scale
          sw   d3,xscale
          sw   d3,yscale

@nextpos
    ;      bgt  d0,320,@noscrolltext

          lbu  d2,0(a1)
          ble  d2,1,@noscrolltext

          bne  d2,2,@nonextline
          li   d3,240-55+16+8      ;nextline
          sw   d3,yposition
          lw   d0,scrollposition   ;same start x
          lbu  d2,1(a1)     ;nextletter
          addu a1,1
@nonextline
          sw   d0,xposition
          addu d2,-32
          beqz d2,@skipnull
          sll  d2,9   ;for 16x16
          la   a0,scrollfonts
          addu a0,d2
          sw   a0,spritepointer
          sw   a1,-4(a8)
          sw   d0,-8(a8)
          jal  dosprite
          nop
          lw   a1,-4(a8)
          lw   d0,-8(a8)
@skipnull
          addu d0,16     ;next xpos
          addu a1,1      ;next letter
          b    @nextpos
          nop
@noscrolltext
          lbu  d1,0(a1)
          la   a0,greets
          beqz d1,@resetpointer
          nop
          addu a0,a1,1
@resetpointer
          sw   a0,nextline

  ;******check scroll status*******8
          lw    d0,scrollposition

          lbu   d4,scrollstatus
          beq   d4,1,@resetpos?    ;skip all this
          li    d5,2
          beq   d5,d4,@holdstill
          nop
          bgtz  d0,@holdstill
          nop
          li    d4,1
          sb    d4,scrollstatus
@holdstill

          bgt   d0,-340,@resetpos?
          nop
          sb    r0,scrollstatus  
          li    d0,320+52        ;reset x pos
          sw    d0,scrollposition
          lw    a2,nextline      ;point to next line
          sw    a2,greetspointer

@resetpos?

          bne  d4,1,@moveout?
          lw   d3,scrolldelay
          addu d3,1
          sw   d3,scrolldelay
          bne  d3,300,@moveout?      ;dealy!!!!!!
          nop
          li   d1,2            ;slide out
          sw   r0,scrolldelay
          sb   d1,scrollstatus
@moveout?

          lbu  d1,scrollstatus
          beqzl d1,@dothis
          addu  d0,-2    ;speed
          beq   d1,1,@dothis   ;nuthin
          li    d4,2
          beql  d1,d4,@dothis  ;move quick speed!!!
          addu  d0,-8
@dothis   sw    d0,scrollposition

          lw    ra,0(a8)
          jr    ra
          nop

 cnop 0,8
scrollfonts:
 incbin "font16_2.aa"
 cnop 0,4
