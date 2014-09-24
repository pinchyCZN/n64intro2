swapframebuffers:

            lui a0,$A440
            lw  d0,frame  
            lw  d1,frame2 
            sync
            sw  d0,frame2 
            sw  d1,frame  
            sw  d1,4(a0)  ;display frame2
            jr ra
            nop


swapDLlists
               lw      d0,frame2
       ;get what DL list to display and send to RDP
       ;d0 contains address of screen
               lw      d1,whatDLlist
               lw      a0,RDPlist1
               beqz    d1,@other
               nop
               lw      a0,RDPList2
@other:     ; ******a0 contains start of DL list
               addiu   a1,a0,(SetCimg-RDP_start)
               addiu   a2,a0,(SetCimg1-RDP_start)
               addiu   a3,a0,(SetZimg-RDP_start)
               sw      d0,0(a1) ;SetCimg
               lw      d1,Zimg
               sw      d0,0(a2) ;SetCimg1
               sw      d1,0(a3) ;SetZimg
        ;       la      a0,RDP_start
               lw      a1,RDPendaddy

               sw      ra,-4(a8)
               jal     RDP_command
               nop
               lw      ra,-4(a8)

               lw     d1,whatDLlist
               xori   d1,d1,1   ;swap lists
               lw      a0,RDPlist1
               beqz    d1,@other2
               nop
               lw      a0,RDPList2
@other2:
               addiu   a0,a0,(beginRDPcommand-RDP_start)
               sw      a0,RDPendaddy
               sw      d1,whatDLlist
               jr      ra
               nop


frame: DW $80400000-(320*240*2)*2 ;       $80330500
frame2: DW $80400000-(320*240*2)  ;$80370500
Zimg:   DW $80400000-(320*240*2)*3
whatDLlist: DW 0
RDPList1: DW RDP_start|$A0000000
RDPList2: DW (RDP_start+(10000*8))|$A0000000   ;10000 commands

RDPendaddy: DW RDP_end



RDP_command:   lui     a3,$A410
               addiu   d0,r0,1
               sw      d0,$C(a3)
               nop
@DPfinish:
             lw      d0,MI_INTR_REG     ; # get rcp interrupt register
             andi    d0,0x3f            ; # look at 6 bits only
             andi    d1,d0,MI_INTR_DP
;             bnez    d1,@DPfinish
             nop
;             li      d1,MI_CLR_DP_INTR
;             sw      d1,MI_BASE_REG
               sw      a0,0(a3)      ;DPcommand start
               sw      a1,4(a3)      ;DPcommand end
               nop
               jr   ra
               nop
End_displaylist:
               lw    a0,RDPendaddy
               li    d0,$E9000000   ;RDPFullSync
               sw    d0,0(a0)
               sw    r0,4(a0)
               addiu a0,a0,8
               sw    a0,RDPendaddy
               jr ra
               nop

INITRDP:


             lw      d0,MI_INTR_REG     ; # get rcp interrupt register
             andi    d0,0x3f                         # look at 6 bits only
             andi    d1,d0,MI_INTR_DP
;             bnez    d1,INITRDP
             nop

;             li      d1,MI_CLR_DP_INTR
;             sw      d1,MI_BASE_REG

               jr ra
               nop

COPYDLlist:    lw      a0,RDPlist2  ;dest
;               lw      a1,RDPlist1  ;dest
               la      a2,RDP_start|$A0000000 ;source
               la      d0,((RDP_end-RDP_start)/4)+1

@DLcopy:       lw      d1,0(a2)    ;source
               addiu   a2,a2,4
               sw      d1,0(a0)    ;dest
               addiu   a0,a0,4
;               sw      d1,0(a1)    ;dest
;               addiu   a1,a1,4
               bnez    d0,@DLcopy
               addiu   d0,d0,-1
               jr      ra
               nop

system_reset:
               jal INITRDP
               nop
@here:         j   @here
               nop
