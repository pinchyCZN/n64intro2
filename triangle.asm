tricmdsize = 112

dotriangle:
               sw    a0,object
               lw    d8,-4*11(a0)
               sw    d8,lightscale
               lw    d9,-4*9(a0)
               sw    d9,objectcount
               move  a4,a0
;               lw    d9,objectcount     ;number of triangles
               addiu d8,r0,0     ;triangle counter
               addiu a8,a8,-4*3    ;save 3 registers
               sw   a4,0(a8)
               sw   d9,4(a8)
               sw   ra,8(a8)

vertexloop:
            blez    d9,endupdatevertex
            lw      a4,0(a8) 
            addiu   a4,a4,18*2     ;point to normal data
            jal     normal
            nop
            lw      d0,12(a4)        ;get z limit from vertex data
            subu    d0,d2,d0        ;Znormal-zlimit
;            b nexttriangle
;            nop
          ;  bgtz    d0,showtriangle
            bgtz    d0,nexttriangle  ;skip if Zlimit<Znormal
            nop
            
showtriangle:

            lw      d0,16(a4)        ;rgba for this triangle
            lw      a1,RDPendaddy   ;pointer to triangle command
            move    a2,a1
            li      d8,(tricmdsize/4)-1
@clearloop:
            sw      r0,0(a2)
            addiu   a2,a2,4
            bne     d8,r0,@clearloop
            addiu   d8,d8,-1

            li      d1,$CD
;            LI  D1,$CF
            sb      d1,0(a1)         ;triangle shade,zbuff
            jal     light
            nop

            lw      a4,0(a8) 
            addiu   a9,r0,3         ;number of points
               jal rotate
               nop

;**** arrange coordinates according to y values and insert into
;**** check list a0=checkdata (all done in checklist!)
sortvertex:
           la   a0,checkdata
           addiu a0,a0,2     ;get to z value
           addiu d0,r0,2     ;maxrow
           srl   d1,d0,1     ;maxrow/2 d1=offset
topdo:     subu  d2,d0,d1    ;maxrow-offset d2=limit
doloop:    addiu d3,r0,-1    ;d3=switch  = false(0) or neg
           addiu d4,r0,0     ;d4=row
FOR:       sll   d9,d4,2     ;get to z offset
           addu  a9,a0,d9
           lh    d5,0(a9)    ;get z1
           sll   d9,d1,2     ;get offset z2
           addu  a10,a9,d9   
           lh    d6,0(a10)    ;get z2   (a10 pointer)
           subu  d7,d5,d6
           bgez  d7,itsbigger
           nop
           addiu a9,a9,-2
           lw    d5,0(a9)
           addiu a10,a10,-2
           lw    d6,0(a10)
           sw    d5,0(a10)    ;swap row with row+offset
           sw    d6,0(a9)
           addu  d3,r0,d4     ;switch=row
itsbigger: subu  d9,d2,d4     ;limit-row
           bgtz  d9,FOR       ;skip if limit reached
           addiu d4,d4,1      ;row = row+1
           subu  d2,d3,d1     ;Limit=switch-offset
           bgez  d3,doloop
           nop
           srl   d1,d1,1
           bgtz  d1,topdo
           nop
;make sure p1 is assigned to higher x value vertice' IF P1=P2
           la    a0,checkdata
           lh    d0,2(a0)     ;y1
           lh    d1,6(a0)     ;y2
           bne   d0,d1,p1p2ok ;is y1=y2??
           lh    d2,0(a0)     ;x1
           lh    d3,4(a0)     ;x2
           subu  d4,d2,d3     ;x1-x2
           bgtz  d4,p1p2ok
           lw    d0,0(a0)
           lw    d1,4(a0)
           sw    d0,4(a0)
           sw    d1,0(a0)     ;swap p1 / p2

p1p2ok:
           lh    d0,6(a0)   ;y2    **make p3 higher if p2+p3 on same line
           lh    d1,10(a0)  ;y3
           bne   d0,d1,x3bigger
           lh    d0,4(a0)   ;x2
           lh    d1,8(a0)   ;x3
           subu  d2,d0,d1  ;x2-x3
           bltz  d2,x3bigger   ;x3 > x2 all ok, do nuthin
           lw    d3,4(a0)
           lw    d4,8(a0)
           sw    d3,8(a0)
           sw    d4,4(a0)      ;swap x3<->x2

x3bigger:  
;insert vertices into Triangle command   (a0=checklist)        
          
           lw   a1,RDPendaddy
               lh    d0,2(a0)   ;y1
               sll   d0,d0,2
               sh    d0,2(a1)
               lh    d1,6(a0)   ;y2
               sll   d1,d1,2
               sh    d1,4(a1)   
               lh    d2,10(a0)  ;y3
               sll   d2,d2,2
               sh    d2,6(a1)
               lh    d0,0(a0)   ;x1
               sh    d0,16(a1)
               lh    d1,4(a0)  ;x2
               sh    d1,8(a1)
               lh    d2,8(a0)  ;x3
               sh    d2,24(a1)
               sh    d2,16(a1)   ;move x3->x1


;***** calculate slopes for the vertices!
;***** and insert into display list
;a0=checkdata, a1=triangle command

               la     a0,checkdata
               lh     d0,10(a0)     ;y3
               lh     d1,6(a0)      ;y2
               subu   d0,d0,d1      ;y3-y2
               lh     d2,8(a0)      ;x3
               lh     d3,4(a0)      ;x2
               subu   d2,d2,d3      ;x3-x2
               beql   d0,r0,nextvertex
               addiu  d0,r0,0       ;make slope = 0 if run=0
               sll    d2,d2,16
               div    d2,d0
               mflo   d0
nextvertex:    sw     d0,28(a1)     ;slope 3->2
               lh     d0,10(a0)    ;y3
               lh     d1,2(a0)     ;y1
               subu   d0,d0,d1     ;y3-y1
               lh     d2,8(a0)     ;x3
               lh     d3,0(a0)     ;x1 
               subu   d2,d2,d3     ;x3-x1
               beql   d0,r0,nextvertex1
               addiu  d0,r0,0
               sll    d2,d2,16
               div    d2,d0
               mflo   d0
nextvertex1:   sw     d0,20(a1)    ;slope 3->1
               lh     d0,6(a0)     ;y2
               lh     d1,2(a0)     ;y1
               subu   d0,d0,d1     ;y2-y1
               lh     d2,4(a0)     ;x2
               lh     d3,0(a0)     ;x1
               subu   d2,d2,d3
               beql   d0,r0,nextvertex2
               addiu  d0,r0,0
               sll    d2,d2,16
               div    d2,d0
               mflo   d0
nextvertex2:   sw     d0,12(a1)    ;slope y2->y1
               lw     d1,20(a1)        ;get slope for y3->y1
               subu   d2,d0,d1
               addiu  d3,r0,$00
               bgez   d2,endvertexshit  ;exit coz slope d0>d1
               sb     d3,1(a1)
               lh     d1,2(a0)
               lh     d2,6(a0)
               beq    d1,d2,checknext  ;exit if y1=y2
               addiu  d0,r0,$80        ;if y2->y1 < y3->y1 change it
               sb     d0,1(a1)
checknext:     nop
endvertexshit:
            lw      d0,RDPendaddy   ;add 1 triangle command to display list
            addiu   d0,d0,tricmdsize  ;176
            sw      d0,RDPendaddy

nexttriangle:
               lw    d9,4(a8)      ;number of traingle
               addiu d9,d9,-1
               sw    d9,4(a8)
               addiu d8,d8,1    ;increment triangle counter
               lw    a4,0(a8)      ;traingle offset
               addu  a4,28*2
               sw    a4,0(a8)
               b vertexloop  ;bgtz  d9,vertexloop
               nop
endupdatevertex:

               lw    ra,8(a8)
               addiu a8,a8,4*3    ;reset stack
               jr ra
               nop

normal:       ;a4=normals data , out d2=z coordinate to check later
            la      a0,ieee32
            addiu   a1,a0,128*4    ;cos
            lw      a3,object
            addiu   a3,a3,-4*3     ;point to angles
            lw  d0,0(a4)     ;Xnormal
            lw  d1,4(a4)     ;Ynormal
            lw  d2,8(a4)     ;Znormal
            lw  d3,0(a3)     ;X.angle
            lw  d4,4(a3)     ;Y.angle
      sll  d3,d3,2   ;word offset
      sll  d4,d4,2   ;for x/y angle
      addu a2,a0,d3  ;a0,a1  pointers to sin cos table
      lwc1 f0,0(a2)  ;sin(x+)
      addu a2,a1,d3
      lwc1 f2,0(a2)  ;cos(x+)
      addu a2,a0,d4
      lwc1 f4,0(a2)  ;sin(y+)
      addu a2,a1,d4
      lwc1 f6,0(a2)  ;cos(y+)
      mtc1 d0,f8    ;Xn
      mtc1 d1,f10    ;Yn
      mtc1 d2,f12    ;Zn
      
      mul.s f14,f0,f10   
      nop
      nop
      mul.s f0,f2,f12
      nop
      add.s f14,f14,f0    ;Z1 save f14
      mul.s f12,f4,f8    ;sin(y+)*Xn
      nop
      nop
      mul.s f0,f6,f14   ;cos(y+)*Z1
      add.s f8,f12,f0
      cvt.w.s f0,f8
      mfc1    d2,f0
      jr ra
      nop


rotate:   ;in a4=vertex data, a9=number of points
            la     a0,ieee32      ;sin
            addiu  a1,a0,128*4    ;cos
            lw      a3,object
         ;   addiu   a3,a3,-4*3    ;point angles
            la      a5,checkdata
rotateloop: lw  d0,0(a4)     ;Xcoords  
            lw  d1,4(a4)     ;Y
            lw  d2,8(a4)     ;Z
            lw  d3,-4*3(a3)     ;Xangles
            lw  d4,-4*2(a3)     ;Y
            lw  d5,-4(a3)       ;Z 
   sll  d3,d3,2
   sll  d4,d4,2
   sll  d5,d5,2
   addu   a2,a0,d3
   lwc1   f0,0(a2)
   addu   a2,a1,d3
   lwc1   f2,0(a2)
   addu   a2,a0,d4
   lwc1   f4,0(a2)
   addu   a2,a1,d4
   lwc1   f6,0(a2)
   addu   a2,a0,d5
   lwc1   f8,0(a2)
   addu   a2,a1,d5
   lwc1   f10,0(a2)
   mtc1   d0,f12
   mtc1   d1,f14
   mtc1   d2,f16
   mul.s  f18,f16,f0
   nop
   nop
   mul.s  f20,f14,f2
   nop
   sub.s  f18,f20,f18
   mul.s  f20,f14,f0
   nop
   nop
   mul.s  f22,f16,f2
   nop
   add.s  f20,f20,f22
   mul.s  f22,f20,f4
   nop
   nop
   mul.s  f24,f12,f6
   nop
   sub.s  f22,f24,f22
   mul.s  f24,f12,f4
   nop
   nop
   mul.s  f26,f20,f6
   nop
   add.s  f16,f24,f26
   mul.s  f12,f18,f8
   nop
   nop
   mul.s  f14,f22,f10
   nop
   sub.s  f12,f14,f12
   mul.s  f28,f22,f8
   nop
   nop
   mul.s  f30,f18,f10
   add.s  f14,f28,f30
   cvt.w.s  f0,f12
   cvt.w.s  f2,f14
   cvt.w.s  f4,f16
   mfc1    d0,f0
   mfc1    d1,f2
   mfc1    d2,f4

      addiu d2,d2,256    ;make values 0<z<512
      andi  d2,d2,511    ;weed out shit
      beql  d2,r0,@skip
      addiu d2,r0,1


      lw    d3,-4*10(a3)  ;zoom
@skip:
      mult  d3,d0     ;x*zoom
      mflo  d0
      nop
      nop
      div   d0,d2     ;/z
      mflo  d0        ;projected x
      nop
      nop
      mult  d3,d1     ;y*zoom
      mflo  d1
      nop
      nop
      div   d1,d2     ;/z
      mflo  d1        ;projected y
      lw     d3,-4*8(a3)    ;xcenter
      lw     d4,-4*7(a3)    ;ycenter
     addu  d0,d0,d3  ;recenter x
     addu  d1,d1,d4  ;recenter y
      sh     d0,0(a5)
      sh     d1,2(a5)
      addiu  a5,a5,4     ;next vertex in checklist
      addiu  a4,a4,12    ;next vertex in original list
      addiu  a9,a9,-1
      bne    a9,r0,rotateloop
      nop
      jr ra
      nop



light:   ;lightsource this triangle
         ;a1=pointer to triangle command
         ;d0=what color for this triangle
         ;d2=the z distance from lightsource

         addiu a1,a1,$20   ;offset color parameters in command
         li    d3,2   ;rgb
         li    d4,24  ;shift amount
         li    d5,$18080  ;modulo
lightloop:
         srlv  d8,d0,d4
         andi  d8,d8,$FF
         multu d8,d5
         mflo  d8
         srl   d8,d8,16
         sh    d8,0(a1)
         addiu a1,a1,2
         addiu d4,d4,-8
         bnez  d3,lightloop
         addiu d3,d3,-1

         lw    d8,lightscale
         li    d9,$4c999          ;$30408
;         negu  d7,d2     ;0 > -127 
         addu d7,d2,d8  
         blezl d7,@limit
         li    d9,0

         multu d9,d7      ;$30408* -zdistance
         mflo  d9
         srl   d9,d9,16
         li    d6,$17F
         subu  d6,d6,d9
         blezl d6,@limit
         li    d9,$17F
@limit:  sh    d9,0(a1)
         jr ra
         nop

lightscale: dw 70   ;higher#=darker , lower#=bright
                     ;108 is good
object: DW 0
objectcount: DW 0

checkdata: dcb 4*4,0

ieee32:
 incbin ieee32.bin
