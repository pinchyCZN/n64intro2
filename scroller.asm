scrtime dw 0
scrspacing dw 16
scrspeed: dw 2
scrpointer dw 0
fontsize:  DW 9
fonts:     DW pdxfont
charsline: DW 22
fontxscale: dw $10000
fontyscale: DW $10000
fontsinus: dw 0
scrollerfreq: dw $1000

text: db "                           DESTOP PRESENTS HIS DEMO FOR THE"
      DB " PRESENCE OF MIND 99 COMPETITION  ...    PLEASE NOTE THAT"
      DB " FOR THIS ENTIRE DEMO THAT *EVERYTHING* IS DONE WITH HARDWARE, "
      DB "BUT WHAT MAKE IT DIFFERENT FROM THE OTHERS IS THAT ITS WRITTEN"
      DB " ENTIRELY IN HAND-CODED MIPS ASM!!!     I REPEAT - NO DEVKIT USED - "
      DB " IT TOOK A GREAT DEAL OF WORK TO REVERSE THE RDP AND NEARLY EVERY FUNCTION OF IT IS USED"
      DB " IF YOU ARE SEEING THIS DEMO YOU HAVE THE RAM EXPANSION PACK AND PROBABLY A V64 BACKUP UNIT"
      DB " , IT SEEMS IT DOESNT LIKE TO WORK ON CD64...  HAY WILDFIRE ITS NICE TO SEE YOU"
      DB " STILL MAKING TRAINERS.. BE PATIENT SOME DOCS ARE COMING, JUST NEED A REST FIRST"
      DB "  NOTE: NO RSP IS USED IN THE CALCULATIONS OF TRIANGLES     YO TITANIK WHERE YOU BEEN DUDE.. I LIKE YOUR MOD PLAYER .. I MADE A FEW ADJUSTMENTS "
      DB " HOPE TO HEAR FROM YOU SOON..   I WOULD LIKE TO SAY HELLO TO ALL THE FRIENDLY PEOPLE"
      DB " IN N64SCENE THAT I HAVE MET OVER THE SHORT TIME I HAVE BEEN HERE                 "
      DB " LOOK OUT NOW   <--- TEXT RESTARTS",0,0,0
 cnop 0,4

scroller:
              lw    d1,scrspacing
              la    a1,width
              sw    d1,0(a1)
              sw    d1,4(a1)
              la    a2,fontxscale
              lw    d0,0(a2)    ;fx
              lw    d1,4(a2)    ;fy
              sw    d0,16(a1)   ;sx
              sw    d1,20(a1)   ;sy

              la    a0,text
              lW    d10,charsline        ;number of chars
              lw    d0,scrpointer
              addu  a0,a0,d0
              li    d2,0        ;x start position on screen
              lw    d1,scrtime
              subu  d2,d2,d1      ;current x position

nextletter:
              lbu   d8,0(a0)
              bnez  d8,@noreset
              nop
              la    a0,text       ;reset scroller
              lbu   d8,0(a0)
@noreset:
              lw    d7,fontsize  ;8=7,16=9,32=11

              addiu d8,d8,-32
              sllv  d8,d8,d7
              lw    d6,fonts
              addu  d6,d6,d8
              sw    d6,spritepointer
              sw    d2,xposition       ;xpos of sprite

              la    a2,sinuslist
              lw    d3,fontsinus
;  li d6,$5000
              
              addu  d3,d2
              andi  d3,$1FF
              lw    d6,scrollerfreq
              mult  d6,d3
              mflo  d3
              srl   d3,16-4
              andi  d3,$1FF
SCROLLERAMPLITUDE:
              li    d4,24      ;amplitude
              sll   d3,d3,1  ;hword offset
              addu  a3,a2,d3
              lh    d3,0(a3)
              multu d3,d4        ;sin*24
              mflo  d3           
              sra   d3,d3,14
scrollerypos
              addu  d3,193
              sw    d3,yposition

              lw    d4,fontsinus
              li    d3,$10000/2      ;amplitude of 1
              sll   d4,1           ;fontsinus x2
              addu  a3,a2,d4
              lh    d4,0(a3)
              multu d4,d3
              mflo  d4
              sra   d4,14
              addu  d4,$18000        ;yscale between 1 , 2
;              lw    d4,fontyscale
              sw    d4,yscale

              sw    a0,-4(a8)
              sw    d2,-8(a8)
              sw    d10,-12(a8)
              sw    ra,-16(a8)
              jal   dosprite
              nop
              lw    a0,-4(a8)
              lw    d2,-8(a8)
              lw    d10,-12(a8)
              lw    ra,-16(a8)
              addiu a0,a0,1     ;increment text pointer
              lw    d8,scrspacing
              addu  d2,d2,d8
              addiu d10,d10,-1
              bnez  d10,nextletter
              nop


              lw    d1,scrtime
              lw    d2,scrspeed
              addu  d1,d1,d2      ;time=time+speed
              lw    d3,scrspacing

              subu  d4,d3,d1      ;spacing-time
              bgtz  d4,@updatetime
              nop

              subu  d1,d1,d3      ;time=time-spacing
              lw    d8,scrpointer
              addiu d8,d8,1
              la    a0,text
              addu  a0,a0,d8
              lbu   d9,0(a0)
              beql  d9,r0,@noresetpointer
              li    d8,0
@noresetpointer 
              sw    d8,scrpointer
@updatetime         
              sw    d1,scrtime

              lw    d3,fontsinus
              addiu d3,5
              andi  d3,d3,$1FF
              sw    d3,fontsinus

              jr ra
              nop
 cnop 0,8
pdxfont:
 incbin  font16nn.aa
; incbin  font16_2.aa
 cnop 0,4
