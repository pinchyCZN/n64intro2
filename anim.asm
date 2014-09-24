
dogremlin:
        sw   ra,0(a8)
        lhu  d7,animcounter+2
        li   d8,32*24*2
        multu d8,d7
        mflo  d7
        la   a0,rawgremlin
        addu a0,d7  ;what cell
        lw   d0,scrollposition   ;320-40  ;x
        addu d0,-50     ;make slightly ahead
        li   d1,240-57  ;y
        li   d2,$1e000
        sw   d0,xposition
        sw   d1,yposition
        sw   a0,spritepointer
        sw   d2,xscale
        sw   d2,yscale
        li   d3,32   ;width/height
        sw   d3,width
        li   d4,24
        sw   d4,height
        jal  dosprite
        nop
        lw   d0,animdelay
        addu d0,1
        sw   d0,animdelay
        bne  d0,10,@skipanim
        sw   r0,animdelay
        lhu  d2,animcounter
        addu d2,1
        beql d2,6,@resetcounter
        li   d2,0
@resetcounter
        la   a1,animcycle
        addu a1,d2    ;waht next cell
        lbu  d3,0(a1)
        sh   d3,animcounter+2
        sh   d2,animcounter
@skipanim
        lw   ra,0(a8)
        jr ra
        nop

animcounter  dw 0
animdelay dw 0
animcycle db 0,1,2,3,2,1    ;6

 cnop 0,8
rawgremlin
  incbin "gremlin.aa"

logoxpos: dw 0

dologo:
         sw  ra,0(a8)
         la  a0,rawlogo
         li  d0,100  ;width
         li  d1,19   ;height
         sw  d0,width
         sw  d1,height
         lw  d4,position
         lw  d0,logoxpos
         andi d4,%100
         beqz d4,@nomove
         nop
         li   d0,-4

@nomove  addu d0,4
         sw  d0,logoxpos 
         sw  d0,xposition
         li  d1,30    ;inital y
         li  d7,2-1   ;do twice
@loopy
         sw  d1,yposition
         sw  a0,spritepointer
         sw  a0,-4(a8)
         sw  d1,-8(a8)
         sw  d7,-12(a8)
         jal dosprite
         nop
         lw  a0,-4(a8)
         lw  d1,-8(a8)
         lw  d7,-12(a8)
         addu a0,100*2*19
         addu d1,19
         bnez d7,@loopy
         addu d7,-1

         lw   ra,0(a8)
         jr ra
         nop
 cnop 0,8
rawlogo:
  incbin "cznlogo.aa"

  cnop 0,4
