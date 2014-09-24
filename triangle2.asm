tricmdsize = 112

dotriangle:
               sw    a0,object
               lw    d8,-4*11(a0)
               sw    d8,lightscale
               lw    d9,-4*9(a0)
               sw    d9,objectcount
               move  a4,a0
               addiu d8,r0,0     ;triangle counter
               addiu a8,a8,-4*3    ;save 4 registers
               sw   a4,0(a8)    ;start of data
               sw   d9,4(a8)
               sw   ra,8(a8)
;               jal  calcmatrix
;               nop
vertexloop:
            blez    d9,endupdatevertex
            nop
            lw      a4,0(a8)
            addiu   a4,3*3*2     ;point to normal data
            jal     normal
            nop
            lb      d0,3(a4)        ;get z limit from vertex data
            subu    d0,d2,d0        ;Znormal-zlimit

            bgtz    d0,nexttriangle  ;skip if Zlimit<Znormal
            nop
            
showtriangle:

            lw      d0,4+2(a4)        ;rgba for this triangle
            lw      a1,RDPendaddy   ;pointer to triangle command
            move    a2,a1
            li      d8,(tricmdsize/4)-1
@clearloop:
            sw      r0,0(a2)
            addiu   a2,a2,4
            bne     d8,r0,@clearloop
            addiu   d8,d8,-1
            li      d1,$CD     ;triangle command
            sb      d1,0(a1)         ;triangle shade,zbuff
            jal     light
            nop

            lw      a4,0(a8)       ;where data begins
            li      a9,3-1         ;number of points
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
               lw    a4,0(a8)
               addiu a4,3*3*2+4+2+4     ;point to next vertex data
               sw    a4,0(a8)
               b vertexloop  ;bgtz  d9,vertexloop
               nop
endupdatevertex:

               lw    ra,8(a8)
               addiu a8,a8,4*3    ;reset stack
               jr ra
               nop


normal:       ;a4=normals data , out d2=z coordinate to check later
            la      a0,sinuslist
            addiu   a1,a0,254   ;cos
            lw      a3,object


            lb  d0,0(a4)     ;Xnormal
            lb  d1,1(a4)     ;Ynormal
            lb  d2,2(a4)     ;Znormal
            lw  d3,-4*3(a3)     ;X.angle
            lw  d4,-4*2(a3)     ;Y.angle

      sll  d3,d3,1   ;word offset
      sll  d4,d4,1   ;for x/y angle
      addu a2,a0,d3  ;a0,a1  pointers to sin cos table
      lh   d5,0(a2)  ;sin(x+)
      addu a2,a1,d3
      lh   d6,0(a2)  ;cos(x+)
      addu a2,a0,d4
      lh   d7,0(a2)  ;sin(y+)
      addu a2,a1,d4
      lh   d8,0(a2)  ;cos(y+)
      
      mult  d5,d1         ;sin[x]*Yn
      mflo  d5
      nop
      nop
      mult  d6,d2         ;cos[x]*Zn
      mflo  d6
      addu  d5,d6         ;Z1 save f14
      sra   d5,14
      mult  d7,d0        ;sin(y+)*Xn
      mflo  d7
      nop
      nop
      mult  d8,d5       ;cos(y+)*Z1
      mflo  d8
      addu  d8,d7
      sra   d2,d8,14
      jr ra
      nop




rotate:   ;in a4=vertex data, a9=number of points
            la      a0,sinuslist
            addiu   a1,a0,254    ;cos
            lw     a3,object
            la      a5,checkdata
rotateloop:
            lh   d0,0(a4)     ;Xcoords
            lh   d1,2(a4)     ;Y
            lh   d2,4(a4)     ;Z
            lw   d3,-4*3(a3)     ;Xangles
            lw   d4,-4*2(a3)     ;Y
            lw   d5,-4(a3)       ;Z 

      sll  d3,d3,1   ;rotate 3 points with 3 angles
      sll  d4,d4,1   ;d0-d2  points (x,y,z)
      sll  d5,d5,1   ;d3-d5  angles (dx,dy,dz)
      addu a2,a0,d3  ;a0,a1  pointers to sin cos table
      lh   d6,0(a2)   ;sin(+x)
     mult d2,d6
     mflo d9         ;z*sin(+x)
      addu a2,a1,d3
      lh   d7,0(a2)   ;cos(+x)
     mult d1,d7
     mflo d10        ;y*cos(+x)
      subu d9,d10,d9  ;y*cos(+x)-z*sin(+x)
      sra  d9,d9,14   ;Y1/$4000
     mult d1,d6
     mflo d6         ;y*sin(+x)
      nop
      nop
     mult d2,d7
     mflo d7         ;z*cos(+x)
      addu d3,d7,d6   ;z*cos(+x)+ysin(+x)
      sra  d3,d3,14   ;Z1 /$4000
      addu a2,a0,d4
      lh   d6,0(a2)   ;sin(+y)
     mult d3,d6
     mflo d8         ;Z1*sin(+y)
      addu a2,a1,d4
      lh   d7,0(a2)   ;cos(+y)
     mult d0,d7
     mflo d10        ;x*cos(+y)
      subu d4,d10,d8  ;x*cos(+y)-z*sin(+y)
      sra  d4,d4,14   ;X2 /$4000
     mult d0,d6
     mflo d6         ;z*sin(+y)
      nop
      nop
     mult d3,d7
     mflo d7         ;Z1*cos(+y)
      addu d2,d7,d6   ;x*sin(+y) + Z1*cos(+y)
      sra  d2,d2,14   ;final z coordinate
      addu a2,a0,d5
      lh   d6,0(a2)   ;sin(+z)
     mult d6,d9
     mflo d10        ;Y1 * sin(+z)
      addu a2,a1,d5
      lh   d7,0(a2)   ;cos(+z)
     mult d7,d4
     mflo d11        ;X2 * cos(+z)
      subu d0,d11,d10 ;X2*cos(+z)-Y1*sin(+z)
      sra  d0,d0,14   ;final X coordinate
     mult d4,d6
     mflo d6         ;X2*sin(+z)
      nop
      nop
     mult d9,d7
     mflo d7         ;Y1*cos(+z)
      addu d1,d6,d7   ;X2*sin(+z)+Y1*cos(+z)
      sra  d1,d1,14   ;final y coordinate

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
      addiu  a4,a4,3*2    ;next vertex in original list
      bne    a9,r0,rotateloop
      addiu  a9,a9,-1
      jr ra
      nop

checkdata:
      dcb  4*4,0



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



;s1 equr f0
;c1 equr f2
;s2 equr f4
;c2 equr f6
;s3 equr f8
;c3 equr f10

  if (1=0)
calcmatrix:
           lw    a0,object
           lw    d0,-4*3(a0)  ;x
           lw    d1,-4*2(a0)  ;y
           lw    d2,-4*1(a0)  ;z
           sll   d0,2
           sll   d1,2
           sll   d2,2
           la     a1,ieee32      ;sin
           addiu  a2,a1,128*4    ;cos
           addu  a3,a1,d0
           lwc1  f0,0(a3)   ;s1
           addu  a3,a2,d0
           lwc1  f2,0(a3)   ;c1
           addu  a3,a1,d1
           lwc1  f4,0(a3)   ;s2
           addu  a3,a2,d1
           lwc1  f6,0(a3)   ;c2
           addu  a3,a1,d2
           lwc1  f8,0(a3)   ;s3
           addu  a3,a2,d2
           lwc1  f10,0(a3)   ;c3
   ;f0-f10= s/c 1.2.3
           mul.s f12,f6,f10 ;c2xc3
           nop
           swc1  f12,XX
           mul.s f14,f10,f4 ;c3xs2
           nop
           nop
           mul.s f14,f0 ;@xs1
           nop
           neg.s f14
           mul.s f12,f8,f2 ;s3xc1
           sub.s f16,f14,f12  ;-@-s3xc1
           swc1  f16,XY
           mul.s f12,f8,f0  ;s3xs1
           nop              
           nop          
           mul.s f18,f10,f2 ;c3xc1
           nop
           nop
           mul.s f18,f4     ;@xs2
           sub.s f20,f12,f18
           swc1  f20,XZ
           mul.s f18,f8,f6   ;s3xc2
           neg.s f18
           swc1  f18,YX

           mul.s f12,f2,f10  ;c1xc3
           nop
           nop
           mul.s f14,f0,f4  ;s1xs2
           nop
           nop
           mul.s f14,f8     ;@xs3
           sub.s f14,f12
           swc1  f14,YY
           mul.s f18,f0,f10 ;s1xc3
           nop
           nop
           mul.s f16,f8,f4  ;s3xs2
           swc1  f4,ZX
           nop
           mul.s f16,f2     ;@xc1
           add.s f18,f16
           swc1  f18,YZ

           mul.s f12,f0,f6  ;s1xc2
           swc1  f12,ZY
           mul.s f14,f2,f6  ;c1xc2
           swc1  f14,ZZ


           jr ra
           nop

 endif

