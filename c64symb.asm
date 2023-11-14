
CBM_STATUS      = $90                   ; Bit6=1 ==> End of File! Bit7=1 ==> Device not present

CBM_ERROR       = $A437                 ; Error handling

CBM_KPREND      = $EA7E                 ; CLEAR INTERUPT FLAGS, RESTORE REGISTERS
CBM_START       = $FCE2                 ; Start (Hardware reset)
CBM_SECND       = $FF93                 ; send SA after LISTEN
CBM_UNLSN       = $FFAE                 ; send UNLISTEN out IEEE
CBM_LISTN       = $FFB1                 ; send LISTEN out IEEE
CBM_SETLFS      = $FFBA                 ; set file parameters
CBM_SETNAM      = $FFBD                 ; Set file name
CBM_OPEN        = $FFC0                 ; OPEN Vector
CBM_CLOSE       = $FFC3                 ; CLOSE Vector
CBM_CHKIN       = $FFC6                 ; Set input file
CBM_CHKOUT      = $FFC9                 ; Set Output
CBM_CLRCHN      = $FFCC                 ; Restore I/O Vector
CBM_CHRIN       = $FFCF                 ; Input Vector
CBM_CHROUT      = $FFD2                 ; Output Vector
CBM_LOAD        = $FFD5                 ; call the load function
CBM_GETIN       = $FFE4                 ; get character from input device
