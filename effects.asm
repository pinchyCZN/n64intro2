spritefade:    ;d0= input brightness 0->$FF
               ;if <0 then o , if >$FF then $FF
               bltzl d0,@make0
               move  d0,r0
@make0:        li    d1,$FF
               subu  d2,d1,d0  ;$FF-brightness
               bltzl d2,@makemax
               li    d0,$FF
@makemax:      lw    a0,RDPendaddy
               sll   d1,d0,24       ;R
               sll   d2,d0,16       ;G
               or    d1,d2
               sll   d3,d0,8        ;B
               or    d1,d3
               or    d1,d0          ;ALPHA
               li    d5,$FA000000
               sw    d5,0(a0)
               sw    d1,4(a0)
               addu  a0,8
               sw    a0,RDPendaddy
               jr ra
               nop
                        
setrendermode:   ;d0-> rendering mode 0=FILL, 1=1CYC , 2=2CYC
                 sll d0,3   ;8 byte offset
                 lw  a0,RDPendaddy
                 la  a1,@RENDERMODE
                 addu a1,d0
                 li   d7,$E7000000
                 sw   d7,0(a0)
                 sw   r0,4(a0)
                 lw   d1,0(a1)
                 sw   d1,8(a0)
                 lw   d2,4(a1)
                 sw   d2,12(a0)
                 addu a0,16
                 sw   a0,RDPendaddy
                 jr ra
                 nop

@RENDERMODE:

         DW $EFB92CBF ;0 ;FILL
         DW $0F0A4000    ;$0C182078 

         DW $EF990000 ;1
         DW $88000000


changeobjectcolor:    ;d0->color1  , d1= color2
                      ;a0 -> pointer to object
                 lw   d2,-9*4(a0)   ;number of faces
@next
                 addu a0,14*4    ;space betwwen each face 
                 sw   d0,-4(a0)
                 addu d2,-1
                 beqz d2,@exit
                 addu a0,14*4
                 sw   d1,-4(a0)
                 addu d2,-1
                 bnez d2,@next
                 nop
@exit            jr ra
                 nop

fillrect:       ;d0=x d1=y              copper effect!!
                ;d2=width d3=height
                ;d4 = color
                bltz d2,@exit
                nop
                bltz d3,@exit
                addu d8,d0,d2     ;x+height
                blez d8,@exit
                addu d7,d1,d3     ;y+width
                blez d7,@exit
                addu d8,d0,-320
                bgez d8,@exit     ;x>320?
                addu d7,d1,-240
                bgez d7,@exit     ;y>240
                nop

             ;fill color = 5|5|5|1 rgba
                lw    a0,RDPendaddy
                li    d8,$E7000000
                sw    d8,0(a0)
                sw    r0,4(a0)
                addu  a0,8
                li    d7,$F7000000   ;setfill color
                sw    d7,0(a0)
                sw    d4,4(a0)

                li    d7,$F6000000    ;fillrect
                addu  d5,d0,d2      ;x+width
                addu  d6,d5,-320
                bgtzl  d6,@make320
                li    d5,320
@make320        sll   d5,14    ;lrx<<14
                or    d7,d5

                addu  d6,d1,d3   ;y+height
                addu  d8,d6,-240
                bgtzl d8,@make240
                li    d6,240
@make240        sll   d6,2       ;lry<<2
                or    d7,d6
                sw    d7,8(a0)

                bltzl d0,@make0
                li    d0,0
@make0          bltzl d1,@make02
                li    d1,0
@make02

                sll   d0,14      ;x
                sll   d1,2       ;y
                or    d0,d1
                sw    d0,12(a0)
                addu  a0,16
                sw    a0,RDPendaddy
@exit           jr  ra
                nop

setscissor:    ; d0=topleft_x  d1=topleft_y
               ; d2=width      d3=height
               bltzl d0,@make0
               li    d0,0
@make0         bltzl d1,@make02
               li    d1,0
@make02        
               lw    a0,RDPendaddy
               li    d6,$E7000000
               sw    d6,0(a0)
               sw    r0,4(a0)
               addu  a0,8
               li    d7,$ED000000  ;setscissor
               sll   d6,d0,12+2    ;ulx
               or    d7,d6
               sll   d5,d1,2    ;uly
               or    d7,d5
               sw    d7,0(a0)    ;word1
               addu  d0,d2       ;lrx
               addu  d4,d0,-320
               bgtzl d4,@make320 ;?out of bounds
               li    d0,320
@make320       sll   d0,12+2
               addu  d1,d3       ;lry
               addu  d4,d1,-240
               bgtzl d4,@make240 ;?out of bounds
@make240       li    d1,240
               sll   d1,2
               or    d0,d1
               sw    d0,4(a0)
               addu  a0,8
               sw    a0,RDPendaddy
               jr ra
               nop

setblendcolor:     ;d0= color
               lw   a0,RDPendaddy
               li   d1,$E7000000
               sw   d1,0(a0)
               sw   ra,4(a0)
               li   d2,$F9000000
               sw   d2,8(a0)
               sw   d0,12(a0)
               addu a0,16
               sw   a0,RDPendaddy
               jr ra
               nop
