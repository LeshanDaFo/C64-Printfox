; ###############################################################
; #                                                             #
; #  PRINTFOX SOURCE CODE                                       #       
; #  Version 1.3b1 (2023.11.14)                                 #
; #  Copyright (c) 2023 Claus Schlereth                         #
; #                                                             #  
; #  This source code is based on the Printfox v1.2             #
; #                                                             #
; #  Printfox 1.2 was programmed by Hans Haberl in 1987         #
; #  (c) 1987 by  SCANNTRONIC                                   #
; #                                                             #
; #  More information about Printfox can be found at:           #
; #  https://www.c64-wiki.de/wiki/Printfox                      #
; #                                                             #
; #  This source code can be found at:                          #
; #  https://github.com/LeshanDaFo/C64-PrintFox                 #
; #                                                             #
; #  This version of the source code is under MIT License       #
; ###############################################################

; This source code need a fixed address for the char set at $3800
; in general, all code before this address is freely relocateable
; except the extension and printer jump-in addresses
; to keep the compatiblity to this printer routines, the code is kept as original as possible.
;
; the existing extensions for Printfox 1.2 are not checked, 
; and therefore the proper work of theese extensions can not be guaranteed at this time.
;
; other memory information
; the init routine after the char set is used only at start-up, 
; everything after the label 'textstart' will be ovewritten by inserted text later on.
;
; this also means every code insert between the char set end, and this label will reduce the available text memory
; to keep as much free memory as possible for text input, some part of the new code was also put into free areas.
; theese areas are from L1B4E to L0B80, and from L37DF to L37FF,
; i could not found any use for this sections, and Printfox 1.3 did not show any abnormalities.
;
; If you can find any problems, or abnormalities, please report this immediately



!source "c64symb.asm"

; select the version here
VERSION = 1.3


!if VERSION = 1.2 {
    !to"build/fox1.2.prg",cbm
}
!if VERSION = 1.3 {
    !to"build/fox1.3.prg",cbm
}

; Start address
*=$0801

; Basic Stub -----------
!by $0D,$08
!by $C2,$07
!by $9E
!pet "(2063)"
!by $00,$00,$00
; Basic Stub end -------
    
    JMP Init_PF

; ---------------------------------
; Text command C= G
; ---------------------------------
L0812
    JMP L081E
L0815
    JMP L09B5
L0818
    JMP L1A6F                       ; fill area $7F40 to 7F7F with $00
L081B
    JMP L0D38
L081E
    LDX #$FE
    TXS
    JSR L19A4
L0824
    JSR L0836
    JSR L0DAB
    JSR L0F4D
    LDA $D028
    STA $D029
    JMP L0824
---------------------------------
L0836
    JSR CBM_GETIN                   ; get character from input device
    BEQ L084D
    LDA $028D
    LDX $CB
    STA $23
    TXA
    LDX #$20                        ; amount of possible keys
L0845
    CMP L0864,X
    BEQ L084E
    DEX
    BPL L0845
L084D
    RTS
---------------------------------
L084E
    TXA
    TAY
    ASL
    TAX
    LDA L0885+1,X
    PHA
    LDA L0885,X
    PHA
    LDA $23
    LSR
    ROR
    STA $15
    TYA
    BIT $15
    RTS

; Graphic mode keytable
L0864
    !by $12,$25,$2A,$11
    !by $14,$29,$22,$24 
    !by $2C,$16,$3C,$0D
    !by $0A,$1A,$0E,$33 
    !by $04,$05,$21,$39
    !by $36,$02,$07,$06 
    !by $38,$3B,$08,$0B
    !by $26,$17,$1E,$09 
    !by $03

; Graphic mode key commands
L0885
    !word L08C7-1   ; Graphic D
    !word L0E36-1   ; Graphic K
    !word L0BE4-1   ; Graphic L
    !word L08D6-1   ; Graphic R
    
L088D
    !word L08D6-1   ; Graphic C
    !word L091E-1   ; Graphic P
    !word L08D6-1   ; Graphic J
    !word L08D6-1   ; Graphic M

L0895
    !word L0B33-1   ; Graphic .
    !word L0965-1   ; Graphic T 
    !word L1645-1   ; Graphic SPACE
    !word L0C06-1   ; Graphic S

L089D    
    !word L08D6-1   ; Graphic A
    !word L08D6-1   ; Graphic G
    !word L08D6-1   ; Graphic E
    !word L098B-1   ; Graphic CLR/HOME

L08A5    
    !word L0AFD-1   ; Graphic F1/F2
    !word L0B05-1   ; Graphic F3/F4
    !word L096B-1   ; Graphic I
    !word L19A4-1   ; Graphic ARROW LEFT

L08AD
    !word L14F6-1   ; Graphic ARROW UP
    !word L09FB-1   ; Graphic CURSOR L/R
    !word L09FB-1   ; Graphic CURSOR UP/DOWN
    !word L0B17-1   ; Graphic F5/F6

L08B5
    !word L09D8-1   ; Graphic 1
    !word L09D8-1   ; Graphic 2
    !word L09D8-1   ; Graphic 3
    !word L09D8-1   ; Graphic 4

L08BD
    !word L1489-1   ; Graphic O
    !word L1489-1   ; Graphic X
    !word L1489-1   ; Graphic U
    !word L0B5E-1   ; Graphic W

L08C5
    !word L0F2F-1   ; Graphic F7/F8

; ---------------------------------
; Graphic command D, SHIFT D
; ---------------------------------
L08C7
    BPL L08D6                       ; if shift was not pressed
    LDA #$01                        ; else load accu with 1
    BNE L08D6                       ; go handle key press

L08CD
    BCC L08D2                       ; if C= was not pressed
    JMP L1B83                       ; else go clear line, and go back
---------------------------------
; save the key, remove the last caller address
; and go handle normal key press
L08D2
    TAX
    PLA
    PLA
    TXA

; ---------------------------------
; Graphic commands R,C,J,M,A,G,E
; ---------------------------------
; handle key press additonal for D,L,S,P
; if C= was not pressed together
L08D6
    PHA
    JSR L0AA3
    JSR L0B2D                       ; switch dot grid
    PLA
L08DE
    LDX #$00
    STX $3A
    STX $42
    STX $39
L08E6
    STA $2B
    TAX
    LDA L0900,X
    BIT $31
    BMI L08F2
    AND #$F7
L08F2
    STA $D015
    LDA L090F,X
    STA $3B
    JSR L1A0C
    JMP L0DAF
---------------------------------
L0900
    !by $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A 
    !by $00,$00,$00,$0B,$0B,$0A,$0A 
L090F
    !by $00,$01,$00,$00,$00,$01,$00,$00 
    !by $00,$00,$00,$02,$02,$02,$02 

; ---------------------------------
; Graphic command P, C= P
; ---------------------------------
L091E

    JSR L08CD                       ; check C= key, prepare screen if found

!if VERSION = 1.2 {
    JSR L0AA3
    LDA #$00
    STA $39
}
!if VERSION = 1.3 {
    JSR ask_print
    NOP
    NOP
    BCS L0951 
}

    LDA #$15                        ; msg. No. "Programmdiskette einlegen"
    LDY #$80
    JSR L1B89
    BCS L0951
    LDX #<L095E                     ; "printer"
    LDY #>L095E
    LDA #$07
    JSR CBM_SETNAM                  ; Set file name
    LDY #$01

!if VERSION = 1.2 {
    LDA #$08
}
!if VERSION = 1.3 {
    LDA $BA
}

    TAX
    JSR CBM_SETLFS                  ; set file parameters
    LDA #$00
    JSR CBM_LOAD                    ; call the load function
    LDA #$00
    JSR L1B8F
    BCS L0957

!if VERSION = 1.2 {
    JSR $6000
}
!if VERSION = 1.3 {
    JSR L6000
}

L0951
    JSR L0B2D                       ; switch dot grid
    JMP L19A4
---------------------------------
L0957
    JSR CBM_GETIN                   ; get character from input device
    BEQ L0957
    BNE L0951

L095E
!tx "PRINTER"
; ---------------------------------
; Graphic command T
; ---------------------------------
L0965
    JSR L0AA3
    JMP L1B80

; ---------------------------------
; Graphic command I
; ---------------------------------
; invert area $6000 - $7F40
L096B
    LDA #$60                        ; start at $6000
    STA $04         
    LDY #$00
    STY $03
    LDX #$1F                        ; page amount (set end to $7F00)
L0975
    DEY
    LDA ($03),Y
    EOR #$FF
    STA ($03),Y
    TYA
    BNE L0975
    INC $04
    DEX
    BMI L098A
    BNE L0975
    LDY #$40                        ; load #$40 to increase end to $7F40
    BNE L0975
L098A
    RTS

; ---------------------------------
; Graphic command CLR/HOME, C= CLR/HOME
; ---------------------------------
L098B
    BCS L09A6                       ; if C= was pressed
    BMI L0999                       ; if SHIFT was pressed

; command CLR/HOME
; set cursor position 0
    LDA #$00
    STA $2E
    STA $2C
    STA $2D
    BEQ L09A3                       ; (jmp)

; command SHIFT CLR/HOME
; set cursor position $1ff
L0999
    LDA #$FF
    STA $2E
    STA $2C
    LDA #$01
    STA $2D
L09A3
    JMP L0DAF

; command C= CLR/HOME
; delete screen
L09A6
    JSR L09AF
    JSR L0ABB
    JMP L0B2D                       ; switch dot grid
---------------------------------
L09AF
    LDA #$60
    LDX #$1F
    BNE L09BC

L09B5
    JSR L0B21                       ; switch to RAM ($34)
; clear area $8000 - FD00
    LDA #$80     ; $8000
    LDX #$7D
L09BC
    STA $04
    LDY #$00
    STY $03
    TYA
L09C3
    DEY
    STA ($03),Y
    CPY #$00
    BNE L09C3
    INC $04
    DEX
    BMI L09D5
    BNE L09C3
    LDY #$40
    BNE L09C3
L09D5
    JMP L0B27                       ; switch to ROM ($37)

; ---------------------------------
; Graphic commands 1,2,3,4
; ---------------------------------
; switch to different screens
L09D8
    AND #$03
    PHA
    JSR L0AA3
    PLA
    TAX
    LDA L09F1,X
    STA $33
    LDA L09F6,X
    STA $34
    JSR L0AB8
    JSR L0E58
    RTS
---------------------------------
L09F1
    !by $00,$00,$19,$19,$00

L09F6
    !by $00,$28,$00,$28,$00

; ---------------------------------
; Graphic commands
; CURSOR L/R
; CURSOR UP/DOWN
; ---------------------------------
L09FB
    AND #$01
    ASL
    STA $15
    LDA $23
    AND #$01
    ORA $15
    STA $3C
    JSR L0AA3
    LSR $32
L0A0D
    LDY $3C
    TYA
    LSR
    TAX
    LDA L0A36,Y
    CMP $33,X
    BEQ L0A31
    LDA $33,X
    CLC
    ADC L0A3A,Y
    STA $33,X
    JSR L0AB8
    JSR L0E58
    LDA $CB
    CMP #$02
    BEQ L0A0D
    CMP #$07
    BEQ L0A0D
L0A31
    ASL $32
    JMP L0B2D                       ; switch dot grid
---------------------------------
L0A36
    !by $19,$00,$28,$00
L0A3A
    !by $01,$FF,$01,$FF

L0A3E
    LDA #$00
    BEQ L0A47
L0A42
    JSR L0B2D                       ; switch dot grid
    LDA #$01
L0A47
    LDX #$33
    STA $19
    JSR L0AD4
    LDA #$60     ; $6000
    STA $06
    LDA #$00
    STA $05
    JSR L0B21                       ; switch to RAM ($34)
    LDX #$19
L0A5B
    LDY #$00
    SEC
L0A5E
    LDA $19
    BNE L0A6C
L0A62
    DEY
    LDA ($03),Y
    STA ($05),Y
    TYA
    BNE L0A62
    BEQ L0A74
L0A6C
    DEY
    LDA ($05),Y
    STA ($03),Y
    TYA
    BNE L0A6C
L0A74
    BCC L0A7F
    INC $04
    INC $06
    LDY #$40
    CLC
    BCC L0A5E
L0A7F
    LDA $03
    ADC #$80
    STA $03
    LDA $04
    ADC #$01
    STA $04
    LDA $05
    ADC #$40
    STA $05
    BCC L0A95
    INC $06
L0A95
    DEX
    BNE L0A5B
    JSR L0B27    ; switch to ROM ($37)
    LDA $19
    BNE L0AA2
    JSR L0B2D                       ; switch dot grid
L0AA2
    RTS
---------------------------------
L0AA3
    JSR L0A42
    LDA $42
    CMP #$02
    BNE L0AB7
    JSR L0ABB
    LDA $D015
    AND #$FB
    STA $D015
L0AB7
    RTS
---------------------------------
L0AB8
    JSR L0A3E
; fill graphic area ($5C00 - $6000) with color from $35
; inverted color in high nibble
; and normal color in low nibble
L0ABB
    LDA #$5C     ; $5C00
    LDX #$04     ; 4 pages
    STA $04
    LDY #$00
    STY $03
    LDA $35      ; color
L0AC7
    STA ($03),Y
    INY
    BNE L0AC7
    INC $04
    DEX
    BNE L0AC7
    JMP L19F1
---------------------------------
L0AD4
    JSR L0AE2
    JSR L1625
    LDA #$80     ; $8000 ?
    CLC
    ADC $04
    STA $04
    RTS
---------------------------------
L0AE2
    LDA #$00
    STA $04
    LDA $00,X
    ASL
    ASL
    ADC $00,X
    LDY #$04
L0AEE
    ASL
    ROL $04
    DEY
    BNE L0AEE
    ADC $01,X
    BCC L0AFA
    INC $04
L0AFA
    STA $03
    RTS

; ---------------------------------
; Graphic command F1/F2
; ---------------------------------
L0AFD
    LDA $35
    CLC
    ADC #$10
    JMP L0B12

; ---------------------------------
; Graphic F3/F4
; ---------------------------------
L0B05
    LDA $35
    TAX
    AND #$F0
    STA $15
    INX
    TXA
    AND #$0F
    ORA $15
L0B12
    STA $35
    JMP L0ABB

; ---------------------------------
; Graphic command F5/F6
; ---------------------------------
L0B17
    INC $D020
    INC $D027
    INC $D02A
    RTS
---------------------------------
; switch RAM on
L0B21
    SEI
    LDA #$34
    STA $01
    RTS
---------------------------------
; switch ROM on
L0B27
    LDA #$37
    STA $01
    CLI
    RTS

; ---------------------------------
; switch off dot grid
; ---------------------------------
dot_off
L0B2D
    BIT $32                         ; check if dot grid is on
    BPL ++                          ; return if off
    BMI rev_grid                    ; else switch off

; ---------------------------------
; Graphic command .
; ---------------------------------
; switch on/off dot grid
L0B33
    LDA $32
    EOR #$80                        ; invert dot grid value
    STA $32
rev_grid
    LDA #$60     ; $6000
    STA $04
    LDA #$00
    STA $03
    LDX #$1F     ; $7F00
    LDY #$F8
-   LDA ($03),Y
    EOR #$80
    STA ($03),Y
    TYA
    SEC
    SBC #$08
    TAY
    BCS -
    INC $04
    DEX
    BMI ++
    BNE -
    LDY #$38    ; rest to $7F40
    BNE -
++  RTS

; ---------------------------------
; Graphic command W
; ---------------------------------
L0B5E
    JSR L0AA3
    LDA #$80     ; $8000
    STA $04
    LDA #$60     ; $6000
    STA $06
    STA $08
    LDA #$00
    STA $03
    STA $05
    LDA #$04
    STA $07
    LDA #$32
    STA $1C
    JSR L0B21    ; switch to RAM ($34)
L0B7C
    LDA #$28
    STA $1D
L0B80
    LDY #$06
L0B82
    LDA ($03),Y
    INY
    ORA ($03),Y
    STA $15
    AND #$55
    ASL
    ORA $15
    LDX #$04
L0B90
    ASL
    ROL $1F
    ASL
    DEX
    BNE L0B90
    TYA
    EOR #$09
    TAY
    AND #$08
    BNE L0B82
    TYA
    LSR
    TAY
    LDA $1F
    STA ($05),Y
    DEY
    TYA
    ASL
    TAY
    BPL L0B82
    LDA $05
    CLC
    ADC #$08
    STA $05
    BCC L0BB7
    INC $06
L0BB7
    LDA $03
    CLC
    ADC #$10
    STA $03
    BCC L0BC2
    INC $04
L0BC2
    DEC $1D
    BNE L0B80
    JSR L0BD4
    DEC $1C
    BNE L0B7C
    JSR L0B27                       ; switch to ROM ($37)
    JSR L0B2D                       ; switch dot grid
    RTS
---------------------------------
L0BD4
    LDX #$01
L0BD6
    LDA $07,X
    TAY
    LDA $05,X
    STA $07,X
    TYA
    STA $05,X
    DEX
    BPL L0BD6
    RTS

; ---------------------------------
; Graphic command L, C= L
; ---------------------------------
L0BE4
    JSR L08CD                       ; check C= key, prepare screen if found

!if VERSION = 1.2 {
    JSR L1B8C                       ; read dir, select file
}
!if VERSION = 1.3 {
    JSR ask_gload
}

    BEQ L0C36
    LDA #$12                        ; msg. No. "Mischen (j/n)?"
    LDX #$4E                        ; "N"
    LDY #$4A                        ; "J"
    JSR L1B89
    BCS L0C36
    STA $39
    LDY #$00
    JSR L1B92
    BCS L0C27
    JSR L0C39
    JMP L0C27

; ---------------------------------
; Graphic command S, C= S
; ---------------------------------
L0C06
    JSR L08CD                       ; check C= key, prepare screen if found
    LDA #$10                        ; msg. No. "<G>esamtbild oder <B>ildschirm?"
    LDX #$47                        ; "G"
    LDY #$42                        ; "B"

!if VERSION = 1.2 {
    JSR L1B89
}    
!if VERSION = 1.3 {
    JSR ask_gsave
}

    BCS L0C36
    STA $13
    LDA #$0F                        ; msg. No. "Name:"
    JSR L1B86
    BCS L0C36
    LDY #$01
    JSR L1B92
    BCS L0C27
    JSR L0C39
L0C27
    JSR L1B95
    LDA #$00
    JSR L1B8F
    BCC L0C36
L0C31
    JSR CBM_GETIN                    ; get character from input device
    BEQ L0C31
L0C36
    JMP L19A7
---------------------------------
L0C39
    JSR L1A7A                       ; save area $7F40 to 7F7F to $03c0
    JSR L0AA3
    LDA $26
    BEQ L0C82
    LDA $0430
    CMP #$30
    BEQ L0C70
    LDY $13
    LDA L0CAF,Y
    JSR CBM_CHROUT                  ; Output Vector
    TYA
    JSR L0CB1
    LDA #$9B
    JSR CBM_CHROUT                  ; Output Vector
    LDA #$00
    JSR CBM_CHROUT                  ; Output Vector
    LDX $13
    LDA L0CAD,X
    JSR CBM_CHROUT                  ; Output Vector
    LDA $35
    JSR CBM_CHROUT                  ; Output Vector
    JMP L0B2D                       ; switch dot grid
---------------------------------
L0C70
    LDA #$00
    JSR CBM_CHROUT                  ; Output Vector
    LDA #$20
    JSR CBM_CHROUT                  ; Output Vector
    LDA #$81
    JSR L0CB1
    JMP L0B2D
---------------------------------
L0C82
    JSR CBM_CHRIN                   ; Input Vector
    LDY #$00
    CMP #$47
    BEQ L0C95
    INY
    CMP #$42
    BEQ L0C95
    JSR CBM_CHRIN                   ; Input Vector
    LDY #$81
L0C95
    STY $13
    TYA
    JSR L0D38
    LDY $13
    BEQ L0CA9
    JSR L19F1
    JSR L1A86                       ; restore area $7F40 to 7F7F from $03c0
    JSR L0B2D                       ; switch dot grid
    RTS
---------------------------------
L0CA9
    JSR L0AB8
    RTS
---------------------------------
L0CAD
    BPL L0CB3

L0CAF
!by $47,$42

L0CB1
    STA $19
L0CB3
    AND #$7F
    TAY
    ASL
    TAX
    LDA L0DA2,X
    STA $03
    LDA L0DA3,X
    STA $04
    LDX L0DA8,Y
    LDY #$00
    LDA ($03),Y
    STA $1F
    INY
L0CCC
    LDA #$00
    STA $21
    STA $22
L0CD2
    JSR L0B21                       ; switch to RAM ($34)
    LDA ($03),Y
    PHA
    JSR L0B27                       ; switch to ROM ($37)
    PLA
    INC $21
    BNE L0CE2
    INC $22
L0CE2
    CPX #$00
    BEQ L0D01
    INY
    BNE L0CEC
    INC $04
    DEX
L0CEC
    BIT $19
    BMI L0CF4
    CMP $1F
    BEQ L0CD2
L0CF4
    PHA
    JSR L0D07
    PLA
    STA $1F
    LDA $90
    BEQ L0CCC
    BNE L0D06
L0D01
    JSR L0D07
    LDA #$00
L0D06
    RTS
---------------------------------
L0D07
    BIT $19
    BMI L0D2E
    LDA #$9B
    CMP $1F
    BEQ L0D1B
    LDA $21
    CMP #$05
    LDA $22
    SBC #$00
    BCC L0D2E
L0D1B
    LDA #$9B
    JSR CBM_CHROUT                  ; Output Vector
    LDA $21
    JSR CBM_CHROUT                  ; Output Vector
    LDA $22
    JSR CBM_CHROUT                  ; Output Vector
    LDA #$01
    STA $21
L0D2E
    LDA $1F
L0D30
    JSR CBM_CHROUT                  ; Output Vector
    DEC $21
    BNE L0D30
    RTS
---------------------------------
L0D38
    STA $19
    AND #$7F
    TAY
    ASL
    TAX
    LDA L0DA2,X
    STA $03
    LDA L0DA3,X
    STA $04
    LDX L0DA8,Y
    LDY $39
    LDA L15F9,Y
    STA L0D7D
    LDY #$00
L0D56
    LDA #$01
    STA $21
    LDA #$00
    STA $22
    JSR CBM_CHRIN                   ; Input Vector
    BIT $19
    BMI L0D76
    CMP #$9B
    BNE L0D76
    JSR CBM_CHRIN                   ; Input Vector
    STA $21
    JSR CBM_CHRIN                   ; Input Vector
    STA $22
    JSR CBM_CHRIN                   ; Input Vector
L0D76
    STA $1F
    JSR L0B21                       ; switch to RAM ($34)
L0D7B
    LDA $1F
L0D7D
    ORA ($03),Y
    STA ($03),Y
    INY
    BNE L0D89
    INC $04
    DEX
    BEQ L0D97
L0D89
    LDA $21
    BNE L0D8F
    DEC $22
L0D8F
    DEC $21
    BNE L0D7B
    LDA $22
    BNE L0D7B
L0D97
    JSR L0B27                       ; switch to ROM ($37)
    TXA
    BEQ L0DA1
    LDA $90
    BEQ L0D56
L0DA1
    RTS
---------------------------------
L0DA2
    !by $00
L0DA3
    !by $80,$00,$60,$78,$60
L0DA8
    !by $7D,$20,$20

L0DAB
    BIT $7C
    BPL L0DDF
L0DAF
    PHP
    SEI
    JSR L0DE0
    LDA $2E
    STA $D001
    STA $D003
    LDA $2C
    STA $D000
    STA $D002
    LDA $2D
    ASL
    ORA $2D
    STA $15
    LDA $D010
    AND #$FC
    ORA $15
    STA $D010
    LDA $7C
    AND #$7F
    STA $7C
    PLP
    JSR L0E58
L0DDF
    RTS
---------------------------------
L0DE0
    JSR L0E24
L0DE3
    LDA L0E2A,X
    CMP $2E
    BCC L0DEC
    STA $2E
L0DEC
    LDA L0E2B,X
    CMP $2E
    BCS L0DF5
    STA $2E
L0DF5
    LDA $2D
    BNE L0E04
    LDA L0E2C,X
    CMP $2C
    BCC L0E0D
    STA $2C
    BCS L0E0D
L0E04
    LDA L0E2D,X
    CMP $2C
    BCS L0E0D
    STA $2C
L0E0D
    LDA $2E
    SEC
    SBC L0E2A,X
    STA $0D
    LDA $2C
    SEC
    SBC L0E2C,X
    STA $0B
    LDA $2D
    SBC #$00
    STA $0C
    RTS
---------------------------------
L0E24
    LDA $3B
    ASL
    ASL
    TAX
    RTS
---------------------------------
L0E2A
    !by $28
L0E2B
    !by $EF
L0E2C
    !by $0E
L0E2D
    !by $4D,$29,$EE,$0F

    JMP $E532
    CLC
    RTI

; ---------------------------------
; Graphic command K, SHIFT K
; ---------------------------------
L0E36
    PHP
    LDA $31
    EOR #$80
    AND #$80
    PLP
    BPL L0E42                       ; if shift key was not pressed
    ORA #$40
L0E42
    STA $31
    ASL
    BCS L0E50
    LDA $D015
    AND #$F7
    STA $D015
    RTS
---------------------------------
L0E50
    LDA $D015
    ORA #$08
    STA $D015
L0E58
    BIT $31
    BPL L0EB6
    PHP
    SEI
    LDX #$00
    JSR L0DE3
    PLP
    LDX #$15
    LDA $34
    JSR L0EB7
    LDA $0D
    LDX #$00
    BIT $31
    BVC L0E7C
    CLC
    ADC #$90
    PHA
    TXA
    ADC #$01
    TAX
    PLA
L0E7C
    STA $0B
    STX $0C
    LDA $33
    LDX #$2D
    JSR L0EB7
    LDA #$3C
    STA $D006
    LDA $2D
    LSR
    LDA $2C
    ROR
    LSR
    STA $15
    LDA $2E
    LSR
    LSR
    ADC $15
    PHA
    LDA $D007
    LSR
    LSR
    LSR
    LSR
    STA $15
    PLA
    SEC
    SBC $15
    LDX #$E8
    BCC L0EB3
    CMP #$64
    BCC L0EB3
    LDX #$36
L0EB3
    STX $D007
L0EB6
    RTS
---------------------------------
L0EB7
    ASL
    ASL
    ASL
    ROL $15
    CLC
    ADC $0B
    STA $0B
    LDA $15
    AND #$01
    ADC $0C
    STA $0C
    STX $03
    LDX #$00
L0ECD
    LDA #$00
    LDY #$10
L0ED1
    ROL $0B
    ROL $0C
    ROL
    CMP #$0A
    BCC L0EDC
    SBC #$0A
L0EDC
    DEY
    BNE L0ED1
    ROL $0B
    ROL $0C
    ORA #$30
    STA $0200,X
    INX
    CPX #$03
    BNE L0ECD
    DEX
L0EEE
    LDA $0200,X
    CMP #$30
    BNE L0EFD
    LDA #$20
    STA $0200,X
    DEX
    BNE L0EEE
L0EFD
    PHP
    SEI
    LDA #$33
    STA $01
    LDX #$02
L0F05
    LDA $0200,X
    ASL
    ASL
    ASL
    STA $05
    LDA #$D1
    STA $06
    TXA
    PHA
    LDY #$07
    LDX $03
L0F17
    LDA ($05),Y
    STA $7FC0,X
    DEX
    DEX
    DEX
    DEY
    BPL L0F17
    INC $03
    PLA
    TAX
    DEX
    BPL L0F05
    LDA #$37
    STA $01
    PLP
    RTS
; ---------------------------------
; Graphic command F7/F8
; ---------------------------------
L0F2F
    BMI L0F40
L0F31
    PHP
    SEI
    LDX #$02
L0F35
    LDA $36,X
    STA $2C,X
    DEX
    BPL L0F35
    PLP
    JMP L0DAF
---------------------------------
L0F40
    PHP
    SEI
    LDX #$02
L0F44
    LDA $2C,X
    STA $36,X
    DEX
    BPL L0F44
    PLP
    RTS
---------------------------------
L0F4D
    LDA $24
    AND #$10
    BEQ L0F64
    SEI
    JSR L0DE0
    CLI
    LDA $2B
    ASL
    TAX
    LDA L0F65+1,X
    PHA
    LDA L0F65,X
    PHA
L0F64
    RTS
---------------------------------
L0F65
!word L0F83-1
!word L0FAC-1
!word L10FC-1
!word L119E-1
!word L11DE-1
!word L139F-1
!word L1340-1
!word L1490-1 
!word L0F64-1
!word L0F64-1
!word L0F64-1
!word L0FCB-1
!word L0FCE-1
!word L1015-1
!word L0FD2-1 

L0F83
    JSR L105A
    LDA $028D
    LSR
    ROR $19
    LDY #$00
L0F8E
    LDA $03
    AND #$07
    BEQ L0F96
    LDA $12
L0F96
    EOR $12
    AND $32
    EOR $19
    ASL
    LDA $12
    BCC L0FA7
    EOR #$FF
    AND ($03),Y
    BCS L0FA9
L0FA7
    ORA ($03),Y
L0FA9
    STA ($03),Y
    RTS
---------------------------------
L0FAC
    LDA #$03
    STA $22
L0FB0
    LDX #$03
L0FB2
    JSR L0F83
    INC $0D
    DEX
    BNE L0FB2
    DEC $0D
    DEC $0D
    DEC $0D
    INC $0B
    BNE L0FC6
    INC $0C
L0FC6
    DEC $22
    BNE L0FB0
    RTS
---------------------------------
L0FCB
    JSR L0FD2
L0FCE
    LDA #$00
    BEQ L0FD4
L0FD2
    LDA #$80
L0FD4
    STA $19
    LDA $0D
    PHA
    LDX #$00
L0FDB
    JSR L105A
    LDA #$18
    STA $17
    LDY #$00
L0FE4
    LDA $7F40,X
    STA $0200,Y
    INX
    INY
    CPY #$03
    BNE L0FE4
    LDY #$00
L0FF2
    BIT $19
    BMI L1001
    ROL $0202
    ROL $0201
    ROL $0200
    BCC L1004
L1001
    JSR L0F8E
L1004
    JSR L10A2
    DEC $17
    BNE L0FF2
    INC $0D
    CPX #$3F
    BNE L0FDB
    PLA
    STA $0D
    RTS
---------------------------------
L1015
    LDA $D015
    ORA #$01
    STA $D015
    JSR L0B2D                       ; switch dot grid
    JSR L102D
    JSR L0B2D                       ; switch dot grid
    LDA #$0C
    STA $2B
    JMP L1A5E
---------------------------------
L102D
    LDX #$00
L102F
    JSR L105A
    LDA #$18
    STA $17
    LDY #$00
L1038
    CLC
    LDA ($03),Y
    AND $12
    BEQ L1040
    SEC
L1040
    ROL $7F42,X
    ROL $7F41,X
    ROL $7F40,X
    JSR L10A2
    DEC $17
    BNE L1038
    INC $0D
    INX
    INX
    INX
    CPX #$3F
    BNE L102F
    RTS
---------------------------------
L105A
    LDA #$03
    STA $04
    LDA $0D
    AND #$F8
    STA $03
    ASL
    ROL $04
    ASL
    ROL $04
    CLC
    ADC $03
    BCC L1071
    INC $04
L1071
    ASL
    ROL $04
    ASL
    ROL $04
    ASL
    ROL $04
    STA $03
    LDA $0D
    AND #$07
    STA $18
    LDA $0B
    AND #$F8
    CLC
    ADC $18
    ADC $03
    STA $03
    LDA $0C
    ADC $04
    STA $04
L1093
    LDA $0B
    AND #$07
    TAY
    LDA #$00
    SEC
L109B
    ROR
    DEY
    BPL L109B
    STA $12
    RTS
---------------------------------
L10A2
    LSR $12
    BCC L10AC
    ROR $12
    TYA
    ADC #$08
    TAY
L10AC
    RTS
---------------------------------
L10AD
    JSR L1A5E
    LDA $3A
    EOR #$01
    STA $3A
    BEQ L10E7
L10B8
    LDX #$02
L10BA
    LDA $0B,X
    STA $0F,X
    DEX
    BPL L10BA
    JSR L0F40
    LDA $D002
    STA $D004
    LDA $D003
    STA $D005
    LDA $D010
    PHA
    AND #$02
    ASL
    STA $15
    PLA
    AND #$FB
    ORA $15
    STA $D010
    PLA
    PLA
    LDA #$04
    BNE L10EF
L10E7
    JSR L0AA3
    JSR L0B2D                       ; switch dot grid
    LDA #$00
L10EF
    STA $15
    LDA $D015
    AND #$FB
    ORA $15
    STA $D015
    RTS
---------------------------------
L10FC
    JSR L10AD
L10FF
    JSR L0F83
    LDA $0D
    PHA
    LDA $0B
    PHA
    LDA $0C
    PHA
    LDA $0F
    SEC
    SBC $0B
    PHA
    LDA $10
    SBC $0C
    STA $0203
    BCS L1125
    PLA
    EOR #$FF
    ADC #$01
    PHA
    LDA #$00
    SBC $0203
L1125
    STA $0201
    STA $0205
    PLA
    STA $0200
    STA $0204
    LDA $11
    CLC
    SBC $0D
    BCC L113D
    EOR #$FF
    ADC #$FE
L113D
    STA $0202
    ROR $0203
    SEC
    SBC $0200
    TAX
    LDA #$FF
    SBC $0201
    STA $21
    BCS L1157
L1151
    ASL
    ASL
    ROL
    JSR L1319
L1157
    LDA $0204
    ADC $0202
    STA $0204
    LDA $0205
    SBC #$00
    JMP L1185
---------------------------------
L1168
    LDA $0203
    BCS L1151
    ASL
    ROL
    ASL
    EOR #$02
    JSR L1301
    CLC
    LDA $0204
    ADC $0200
    STA $0204
    LDA $0205
    ADC $0201
L1185
    STA $0205
    PHP
    JSR L0F83
    PLP
    INX
    BNE L1168
    INC $21
    BNE L1168
    PLA
    STA $0C
    PLA
    STA $0B
    PLA
    STA $0D
    RTS
---------------------------------
L119E
    JSR L10AD
    LDA $11
    PHA
    LDA $0D
    STA $11
    JSR L10FF
    PLA
    STA $11
    LDA $0B
    PHA
    LDA $0C
    PHA
    LDA $0F
    STA $0B
    LDA $10
    STA $0C
    JSR L10FF
    PLA
    STA $0C
    PLA
    STA $0B
    LDA $0D
    PHA
    LDA $11
    STA $0D
    JSR L10FF
    PLA
    STA $0D
    LDA $0B
    STA $0F
    LDA $0C
    STA $10
    JSR L10FF
    RTS
---------------------------------
L11DE
    JSR L10AD
    LDX #$02
L11E3
    LDA $0B,X
    STA $0208,X
    DEX
    BPL L11E3
    LDA #$00
    STA $1F
    JSR L128F
    LDA $0201
    BNE L11FD
    LDA $0200
    LSR
    BEQ L125F
L11FD
    JSR L0F83
    JSR L1260
    STA $19
    JSR L12FF
    PHP
    LDA #$02
    JSR L128F
    PLP
    ROL
    ASL
    EOR $19
    JSR L1301
    JSR L1317
    PHP
    LDA #$04
    JSR L128F
    PLP
    ROL
    EOR $19
    JSR L1319
    SEC
    LDA $0202
    SBC $0204
    LDA $0203
    SBC $0205
    BCS L124E
    JSR L12FF
    BCS L1253
L123A
    LDA $1F
    BNE L125F
    LDA #$FF
    STA $1F
    LDX #$02
L1244  LDA $0208,X
    STA $0B,X
    DEX
    BPL L1244
    BMI L11FD
L124E
    JSR L1317
    BCC L123A
L1253
    LDX #$02
L1255
    LDA $0B,X
    CMP $0208,X
    BNE L11FD
    DEX
    BPL L1255
L125F
    RTS
---------------------------------
L1260
    SEC
    LDA $0B
    SBC $0F
    TAY
    LDA $0C
    SBC $10
    PHP
    ROL $15
    PLP
    TYA
    BCS L1275
    EOR #$FF
    ADC #$01
L1275
    STA $0207
    SEC
    LDA $11
    SBC $0D
    PHP
    ROL $15
    PLP
    BCS L1287
    EOR #$FF
    ADC #$01
L1287
    STA $0206
    LDA $15
    EOR $1F
    RTS
---------------------------------
L128F
    PHA
    JSR L1260
    LDA $0206
    LDX #$00
    JSR L12DB
    LDA $0207
    LDX #$02
    JSR L12DB
    PLA
    TAX
    CLC
    LDA $03
    ADC $05
    STA $0200,X
    LDA $04
    ADC $06
    STA $0201,X
    TXA
    BEQ L12DA
    LDA $0200,X
    SEC
    SBC $0200
    PHA
    LDA $0201,X
    SBC $0201
    BCS L12D3
    TAY
    PLA
    EOR #$FF
    ADC #$01
    PHA
    TYA
    EOR #$FF
    ADC #$00
L12D3
    STA $0201,X
    PLA
    STA $0200,X
L12DA
    RTS
---------------------------------
L12DB
    PHA
    TAY
    LDA #$08
    STA $21
    LDA #$00
    STA $03,X
L12E5
    ASL $03,X
    ROL $04,X
    TYA
    ASL
    TAY
    BCC L12F9
    PLA
    PHA
    CLC
    ADC $03,X
    STA $03,X
    BCC L12F9
    INC $04,X
L12F9
    DEC $21
    BNE L12E5
    PLA
    RTS
---------------------------------
L12FF
    LDA $19
L1301
    AND #$02
    BEQ L130D
    LDA $0D
    BEQ L133E
    DEC $0D
    SEC
    RTS
---------------------------------
L130D
    LDA $0D
    CMP #$C7
    BEQ L133E
    INC $0D
    SEC
    RTS
---------------------------------
L1317
    LDA $19
L1319
    LSR
    BCC L132C
    LDA $0B
    ORA $0C
    BEQ L133E
    LDA $0B
    BNE L1328
    DEC $0C
L1328
    DEC $0B
    SEC
L132B
    RTS
---------------------------------
L132C
    LDA $0C
    BEQ L1336
    LDA $0B
    CMP #$3F
    BEQ L133E
L1336
    INC $0B
    BNE L133C
    INC $0C
L133C
    SEC
    RTS
---------------------------------
L133E
    CLC
    RTS
---------------------------------
L1340
    LDA #$0A
    STA $20
L1344
    LDX #$03
L1346
    LDA $0B,X
    STA $0F,X
    DEX
    BPL L1346
    LDA $A2
    LSR
    LDX $D012
    JSR L1393
    PHA
    LDA $D012
    EOR $A2
    LDX $A2
    JSR L1393
    ADC $0D
    STA $0D
    CMP #$C8
    PLA
    BCS L1385
    BPL L136E
    DEC $0C
L136E
    ADC $0B
    STA $0B
    BCC L1376
    INC $0C
L1376
    LDA $0C
    BMI L1385
    BEQ L1382
    LDA $0B
    CMP #$40
    BCS L1385
L1382
    JSR L0F83
L1385
    LDX #$03
L1387
    LDA $0F,X
    STA $0B,X
    DEX
    BPL L1387
    DEC $20
    BNE L1344
    RTS
---------------------------------
L1393
    STX $15
    LSR
    EOR $15
    AND #$0F
    BCC L139E
    EOR #$FF
L139E
    RTS
---------------------------------
L139F
    LDA $028D
    STA $23
    LSR
    LDA #$00
    STA $19
    INC $0D
    ADC $0D
    STA $11
    JSR L0AA3
    JSR L13B8
    JMP L0B2D                       ; switch dot grid
---------------------------------
L13B8
    TSX
    STX $05
L13BB
    TSX
    CPX #$1C
    BCC L1427
    LDA $15
    PHA
    LDA $16
    PHA
    LDA $0B
    PHA
    LDA $0C
    PHA
    LDA $0D
    STA $15
    LDA $11
    STA $16
L13D4
    JSR L1317
    BCC L141B
    JSR L1428
    BCC L141B
    LDA $0D
    PHA
    LDA $11
    PHA
L13E4
    JSR L1428
    BCC L13EE
    JSR L13BB
    BCC L13E4
L13EE
    PLA
    STA $16
    PLA
    STA $15
    LDA $19
    EOR #$01
    STA $19
    JSR L1317
L13FD
    JSR L1428
    BCC L1407
    JSR L13BB
    BCC L13FD
L1407
    LDA $19
    EOR #$01
    STA $19
    JSR L1317
    JSR CBM_GETIN                    ; get character from input device
    CMP #$B3
    BNE L13D4
    LDX $05
    TXS
    RTS
---------------------------------
L141B
    PLA
    STA $0C
    PLA
    STA $0B
    PLA
    STA $16
    PLA
    STA $15
L1427
    RTS
---------------------------------
L1428
    LDA $15
    STA $0D
    LDA $16
    STA $11
L1430
    JSR L105A
    LDY #$00
    AND ($03),Y
    BNE L1480
    LDA $0B
    EOR $0D
    AND $23
    LSR
    BCS L1480
L1442
    LDA $0D
    BEQ L1453
    DEC $0D
    JSR L105A
    LDY #$00
    AND ($03),Y
    BEQ L1442
    INC $0D
L1453
    LDA $0D
    TAX
L1456
    JSR L105A
    LDY #$00
    AND ($03),Y
    BNE L1476
    LDA $0B
    EOR $0D
    AND $23
    LSR
    BCS L146E
    LDA $12
    ORA ($03),Y
    STA ($03),Y
L146E
    INC $0D
    LDA $0D
    CMP #$C8
    BNE L1456
L1476
    DEC $0D
    LDA $0D
    STA $11
    STX $0D
    SEC
    RTS
---------------------------------
L1480
    INC $0D
    LDA $11
    CMP $0D
    BCS L1430
    RTS

; ---------------------------------
; Graphic commands O,X,U
; ---------------------------------
L1489
    AND #$03
    TAX
    INX
    STX $39
    RTS
---------------------------------
L1490
    JSR L1A5E
    LDY $42
    CPY #$03
    BNE L149B
    LDY #$00
L149B
    TYA
    ASL
    TAX
    LDA $0B
    LSR $0C
    ROR
    LSR
    LSR
    STA $44,X
    LDA $0D
    LSR
    LSR
    LSR
    STA $43,X
    INY
    STY $42
    DEY
    BNE L14B7
    JSR L10B8
L14B7
    DEY
    BEQ L14BD
    JMP L1561
---------------------------------
L14BD
    LDX #$01
L14BF
    LDA $43,X
    SEC
    SBC $45,X
    BCS L14D2
    LDA $43,X
    TAY
    LDA $45,X
    STA $43,X
    TYA
    STA $45,X
    BCC L14BF
L14D2
    STA $4B,X
    DEX
    BPL L14BF
    LDX #$00
    JSR L15FD
    STY $4F
    STA $50
    LDA $33
    STA $4D
    LDA $33
    CLC
    ADC $45
    STA $45
    LDA $34
    STA $4E
    ADC $46
    STA $46
    JMP L1534

; ---------------------------------
; Graphic command ARROW UP
; ---------------------------------
L14F6
    BPL L1519
    JSR L0ABB
    LDA $33
    STA $45
    STA $4D
    LDA $34
    STA $46
    STA $4E
    LDA #$18
    STA $4B
    LDA #$27
    STA $4C
    LDA #$5C
    STA $50
    LDA #$00
    STA $4F
    BEQ L152B
L1519
    LDA $30
    BEQ L155D
    JSR L0AA3
    LDA $4D
    STA $33
    LDA $4E
    STA $34
    JSR L0AB8
L152B
    LDA #$07
    JSR L08DE
    LDA #$02
    STA $42
L1534
    LDA #$01
    STA $30
    LDA $4F
    STA $03
    LDA $50
    STA $04
    LDA $35
    EOR #$88
    LDX $4B
L1546
    LDY $4C
L1548
    STA ($03),Y
    DEY
    BPL L1548
    PHA
    LDA $03
    CLC
    ADC #$28
    STA $03
    PLA
    BCC L155A
    INC $04
L155A
    DEX
    BPL L1546
L155D
    RTS
---------------------------------
L155E
    DEC $42
    RTS
---------------------------------
L1561
    LDA $47
    CLC
    ADC $4B
    STA $49
    CMP #$19
    BCS L155E
    LDA $48
    CLC
    ADC $4C
    STA $4A
    CMP #$28
    BCS L155E
    JSR L0ABB
    JSR L0A42
    LDA $D015
    AND #$FB
    STA $D015
L1585
    LDX #$02
    JSR L15FD
    AND #$0F
    STA $06
    STA $0A
    STY $05
    STY $09
    LDX #$45
    JSR L0AD4
    LDA $03
    STA $07
    LDA $04
    STA $08
    LDA $4B
    STA $1C
    JSR L0B21                       ; switch to RAM ($34)
    LDX $39
    LDA L15F9,X
    STA L15B6
L15B0
    LDY #$00
    LDX $4C
L15B4
    LDA ($03),Y
L15B6
    ORA ($05),Y
    STA ($05),Y
    INY
    BNE L15C1
    INC $04
    INC $06
L15C1
    TYA
    AND #$07
    BNE L15B4
    DEX
    BPL L15B4
    LDA $07
    CLC
    ADC #$80
    STA $07
    STA $03
    LDA $08
    ADC #$02
    STA $08
    STA $04
    LDA $09
    CLC
    ADC #$40
    STA $09
    STA $05
    LDA $0A
    ADC #$01
    STA $0A
    STA $06
    DEC $1C
    BPL L15B0
    JSR L0B27                       ; switch to ROM ($37)
    LDA #$00
    STA $39
    JMP L0B2D                       ; switch dot grid
---------------------------------
L15F9
    BIT $11
    EOR ($31),Y
L15FD
    LDA $45,X
    LDY $46,X
L1601
    STA $1C
    STY $1D
    LDX #$00
    STX $04
    ASL
    ASL
    CLC
    ADC $1C
    ASL
    ASL
    ROL $04
    ASL
    ROL $04
    ADC $1D
    BCC L161B
    INC $04
L161B
    STA $03
    TAY
    LDA $04
    ORA #$5C
    STA $04
    RTS
---------------------------------
L1625
    LDY #$03
L1627
    LDX #$06
L1629
    ASL $03,X
    ROL $04,X
    DEX
    DEX
    BPL L1629
    DEY
    BNE L1627
    RTS
---------------------------------
    LDY #$03
L1637
    LDX #$06
L1639
    LSR $04,X
    ROR $03,X
    DEX
    DEX
    BPL L1639
    DEY
    BNE L1637
    RTS

; ---------------------------------
; Graphic command SPACE
; ---------------------------------
L1645
    LDA #$8B
    STA $D011
    SEI
    LDA #$02
    STA $3B
    JSR L0DAF
    JSR L0F40
    JSR L0DE0
    CLI
    JSR L0AA3
    LDA $2B
    CMP #$0B
    BCC L167F
    LDA #$8C
    STA $D001
    STA $D005
    LDA #$14
    STA $D000
    STA $D004
    LDA #$0D
    STA $D010
    LDA #$05
    STA $D015
    JMP L16F2
---------------------------------
L167F
    JSR L1A7A                       ; save area $7F40 to 7F7F to $03c0
    JSR L102D
    LDA $45
    PHA
    LDA $46
    PHA
    LDA $4B
    PHA
    LDA $4C
    PHA
    LDA #$10
    SEC
    SBC $36
    TAY
    LDA #$01
    SBC $37
    TYA
    BCS L16A0
    LDA #$00
L16A0
    CMP #$C8
    BCC L16A6
    LDA #$C8
L16A6
    AND #$F8
    TAX
    CLC
    ADC $36
    STA $D000
    STA $D002
    STA $D004
    LDA $D001
    STA $D005
    LDY #$08
    LDA $37
    ADC #$00
    BEQ L16C5
    LDY #$0F
L16C5
    STY $D010
    LDA #$07
    STA $D015
    TXA
    LSR
    LSR
    LSR
    STA $15
    LDA #$00
    STA $47
    LDA #$19
    STA $48
    SEC
    SBC $15
    CLC
    ADC $34
    STA $46
    LDA $33
    STA $45
    LDA #$18
    STA $4B
    LDA #$0E
    STA $4C
    JSR L1585
L16F2
    LDA #$02
    JSR L1A0C
    LDA #$FF
    LDY #$3F
L16FB
    STA $7FC0,Y
    DEY
    BPL L16FB
    LDA #$FF
    STA $5FFA
    JSR L1963
    JSR L18C1
    LDA #$BB
    STA $D011
    JSR L1A5E
L1714
    JSR L1754
    JSR L1835
    JSR L1884
    LDA $CB
    CMP #$3C
    BNE L1714
    LDA #$00
    STA $C6
    LSR $32
    JSR L0AB8
    SEI
    JSR L0F31
    JSR L0DE0
    CLI
    LDA $2B
    CMP #$0B
    BCS L174C
    JSR L0FCB
    JSR L1A86                       ; restore area $7F40 to 7F7F from $03c0
    PLA
    STA $4C
    PLA
    STA $4B
    PLA
    STA $46
    PLA
    STA $45
L174C
    ASL $32
    JSR L0B2D                       ; switch dot grid
    JMP L19A7
---------------------------------
L1754
    JSR CBM_GETIN                   ; get character from input device
    BNE L175A
    RTS
---------------------------------
L175A
    LDA $CB
    CMP #$24
    BNE L1785
    LDY #$3C
L1762
    LDA $7F40,Y
    JSR L1826
    STA $0382,Y
    LDA $7F42,Y
    JSR L1826
    STA $0380,Y
    LDA $7F41,Y
    JSR L1826
    STA $0381,Y
    DEY
    DEY
    DEY
    BPL L1762
    JMP L1818
---------------------------------
L1785
    CMP #$16
    BNE L179D
    LDY #$00
    LDX #$3E
L178D
    LDA $7F40,Y
    JSR L1826
    STA $0380,X
    INY
    DEX
    BPL L178D
    JMP L1818
---------------------------------
L179D
    CMP #$11
    BNE L17E5
    LDA #$02
    STA $22
L17A5
    LDY $22
    STY $1E
    LDX L199E,Y
    LDA L19A1,Y
    STA $1A
    LDA #$03
    STA $21
L17B5
    LDA #$08
    STA $1B
L17B9
    LDY $1A
    TXA
    PHA
    LDA #$00
L17BF
    ROL $7F40,X
    ROR
    INX
    INX
    INX
    DEY
    BNE L17BF
    LDY $1E
    STA $0380,Y
    INY
    INY
    INY
    STY $1E
    PLA
    TAX
    DEC $1B
    BNE L17B9
    INX
    DEC $21
    BNE L17B5
    DEC $22
    BPL L17A5
    JMP L1818
---------------------------------
L17E5
    CMP #$2C
    BNE L17F2
    LDA $2F
    EOR #$02
    STA $2F
    JMP L191E
---------------------------------
L17F2
    CMP #$21
    BNE L1806
    LDY #$3E
L17F8
    LDA $7F40,Y
    EOR #$FF
    STA $7F40,Y
    DEY
    BPL L17F8
    JMP L191E
---------------------------------
L1806
    CMP #$33
    BNE L1817
    LDA $028D
    AND #$01
    BEQ L1817
    JSR L1A6F                       ; fill area $7F40 to 7F7F with $00
    JSR L191E
L1817
    RTS
---------------------------------
L1818
    LDY #$3E
L181A
    LDA $0380,Y
    STA $7F40,Y
    DEY
    BPL L181A
    JMP L191E
---------------------------------
L1826
    STA $16
    STY $15
    LDY #$08
L182C
    ROL $16
    ROR
    DEY
    BNE L182C
    LDY $15
    RTS
---------------------------------
L1835
    BIT $7C
    BPL L1870
    LDA $1F
    LDY #$50
    STA ($03),Y
L183F
    JSR L0DE0
    LDX #$03
L1844
    LSR $0C
    ROR $0B
    LSR $0D
    DEX
    BNE L1844
    LDY $0B
    CPY #$17
    BCC L1857
    LDY #$17
    STY $0B
L1857
    LDA $0D
    CMP #$14
    BCC L1861
    LDA #$14
    STA $0D
L1861
    JSR L1601
    LDY #$50
    LDA ($03),Y
    STA $1F
    LDA $7C
    AND #$7F
    STA $7C
L1870
    LDA $1F
    AND #$0F
    STA $15
    LDA $D028
    ASL
    ASL
    ASL
    ASL
    ORA $15
    LDY #$50
    STA ($03),Y
    RTS
---------------------------------
L1884
    LDA $24
    AND #$10
    BEQ L18C0
    JSR L1093
    LDA $0B
    LSR
    LSR
    LSR
    LDY #$03
    CLC
L1895
    ADC $0D
    DEY
    BNE L1895
    TAY
    LDA $12
    LDX $028D
    BNE L18AC
    ORA $7F40,Y
    STA $7F40,Y
    LDA #$01
    BNE L18B6
L18AC
    EOR #$FF
    AND $7F40,Y
    STA $7F40,Y
    LDA #$00
L18B6
    ORA $2F
    TAX
    LDA $3E,X
    STA $1F
    JSR L1870
L18C0
    RTS
---------------------------------
L18C1
    LDY #$27
    LDA $2B
    CMP #$0B
    BCS L18CB
    LDY #$18
L18CB
    STY $1D
    LDA #$5C
    STA $04
    LDA #$00
    STA $03
    LDX #$19
    LDA $D020
    JSR L1993
    STA $18
L18DF
    LDY $1D
L18E1
    STA ($03),Y
    DEY
    BPL L18E1
    TAY
    LDA $03
    CLC
    ADC #$28
    STA $03
    BCC L18F2
    INC $04
L18F2
    TYA
    DEX
    BNE L18DF
    LDA $18
    AND #$F0
    STA $18
    LDA $35
    AND #$0F
    STA $D029
    ORA $18
    STA $40
    JSR L1993
    STA $3E
    LDA $35
    LSR
    LSR
    LSR
    LSR
    STA $D027
    ORA $18
    STA $41
    JSR L1993
    STA $3F
L191E
    LDA #$3E
    STA $21
    LDA #$70
    STA $03
    LDA #$5F
    STA $04
L192A
    LDY #$02
L192C
    LDX $21
    LDA $7F40,X
    STA $0380,Y
    DEC $21
    DEY
    BPL L192C
    LDY #$17
L193B
    LSR $0380
    ROR $0381
    ROR $0382
    LDA #$00
    ROL
    ORA $2F
    TAX
    LDA $3E,X
    STA ($03),Y
    DEY
    BPL L193B
    SEC
    LDA $03
    SBC #$28
    STA $03
    BCS L195C
    DEC $04
L195C
    LDA $21
    BPL L192A
    JMP L183F
---------------------------------
L1963
    LDA #$60
    STA $04
    LDA #$00
    STA $03
    LDX #$19
L196D
    LDY #$C0
L196F
    DEY
    TYA
    AND #$07
    BEQ L197B
    EOR #$07
    BEQ L197B
    LDA #$7E
L197B
    EOR #$FF
    STA ($03),Y
    TYA
    BNE L196F
    LDA $03
    CLC
    ADC #$40
    STA $03
    LDA $04
    ADC #$01
    STA $04
    DEX
    BNE L196D
    RTS
---------------------------------
L1993
    AND #$0F
    STA $15
    ASL
    ASL
    ASL
    ASL
    ORA $15
    RTS
---------------------------------
L199E
    !by $27,$0F,$00
L19A1
    !by $08,$08,$05

; ---------------------------------
; Graphic command ARROW LEFT
; ---------------------------------
L19A4
    JSR L0AB8
L19A7
    LDA #$00
    STA $3A
    STA $42
    STA $39
    JSR L19BA
    LDA $2B
    JSR L08E6
    JMP L1A5E
---------------------------------
L19BA
    LDA #$BB
    STA $D011
    LDA #$78
    STA $D018
    LDA $DD00
    AND #$FC
    ORA #$02
    STA $DD00
    LDA $D020
    STA $D027
    STA $D02A
    LDA #$00
    LDX #$0E
L19DB
    STA $7FF0,X
    DEX
    BPL L19DB
    LDX #$00
    STX $D017
    STX $D01D
    STX $D01C
    STX $D01B
    STA $24
L19F1
    LDA #$FD
    STA $5FF8
    LDA #$FE
    STA $5FF9
    STA $5FFA
    LDA #$FF
    STA $5FFB
    LDA $D010
    ORA #$08
    STA $D010
    RTS
---------------------------------
L1A0C
    TAX
    LDY L1A39,X
    LDX #$00
L1A12
    LDA L1A3C,Y
    STA $03
    BEQ L1A38
L1A19
    LDA L1A3D,Y
    STA $7F80,X
    INX
    LDA L1A3E,Y
    STA $7F80,X
    INX
    LDA L1A3F,Y
    STA $7F80,X
    INX
    DEC $03
    BNE L1A19
    INY
    INY
    INY
    INY
    BNE L1A12
L1A38
    RTS
---------------------------------
L1A39
    !by $00,$00,$15
L1A3C
    !by $08
L1A3D
    !by $00
L1A3E
    !by $20
L1A3F
    !by $00
    !by $02,$00,$00,$00,$01,$FF,$07,$F8 
    !by $02,$00,$00,$00,$08,$00,$20,$00 
    !by $00,$01,$FF,$FF,$FF,$13,$80,$00 
    !by $01,$01,$FF,$FF,$FF,$00 

---------------------------------
L1A5E
    LDA $CB
    CMP #$40
    BNE L1A5E
    LDA $24
    AND #$10
    BNE L1A5E
    LDA #$00
    STA $C6
    RTS

; fill area $7F40 to 7F7F with $00
L1A6F
    LDA #$00
    LDY #$3F
L1A73
    STA $7F40,Y
    DEY
    BPL L1A73
    RTS

; save area $7F40 to 7F7F to $03c0
L1A7A
    LDX #$3F
L1A7C
    LDA $7F40,X
    STA $03C0,X
    DEX
    BPL L1A7C
    RTS

; restore area $7F40 to 7F7F from $03c0
L1A86
    LDX #$3F
L1A88
    LDA $03C0,X
    STA $7F40,X
    DEX
    BPL L1A88
    RTS
---------------------------------
L1A92
    !by $3B,$0E,$03,$05,$20,$12,$05,$03 
    !by $08,$14,$13,$60,$60,$20

---------------------------------
L1AA0
    TYA
    PHA
    LDY #$28
    JSR multiply_x_y                ; multiply X with Y
    STX $03
    TYA
    ORA #$04
    STA $04
    LDX #$00
L1AB0
    LDA #$00
    LDY #$10
L1AB4
    ROL $13
    ROL $14
    ROL
    CMP #$0A
    BCC L1ABF
    SBC #$0A
L1ABF
    DEY
    BNE L1AB4
    ROL $13
    ROL $14
    STA $0200,X
    INX
    CPX #$05
    BNE L1AB0
    DEX
L1ACF
    LDA $0200,X
    BNE L1AD7
    DEX
    BNE L1ACF
L1AD7
    PLA
    TAY
L1AD9
    LDA $0200,X
    ORA #$30
    STA ($03),Y
    INY
    DEX
    BPL L1AD9
    RTS
---------------------------------
; clculate screen position, and copy msg. to screen
; msg start in ($03)
; line No. in X
L1AE5
print_msg
    PHA                             ; save msg. length
    LDY #$28                        ; screen line length
    JSR multiply_x_y                ; multiply X with Y
    STX $09                         ; screen position low byte
    TYA
    ORA #$04
    STA $0A                         ; screen position high byte
    PLA                             ; msg. length
    BEQ +                           ; if zero, go delete the whole line
    PHA
    TAY
    DEY

; copy actual msg. to the screen
-   LDA ($03),Y
    STA ($09),Y
    DEY
    BPL -
    PLA
; fill actual line from Y-position to the end with empty spaces

+   TAY                             ; position in line
    LDA #$1F                        ; empty space
L1B03
    CPY #$28                        ; compare with line end position
    BCS L1B0C
    STA ($09),Y
    INY
    BNE L1B03
L1B0C
    RTS
---------------------------------
; delete line 1
L1B0D
    LDA #$00
    STA $5A
    LDX #$01
    JMP print_msg                   ;L1AE5


; print a text into the second line on screen
; the text part No. must be in accu
L1B16                       
    LDX #$FF
    STX $5A
    LDX #$01                        ; line No.
; print a text into a line on screen
; the line No. must be in X,
; the text part No. must be in accu
L1B1C
    TAY                             ; msg. No.
    TXA                             ; line No.
    PHA                             ; save line No.
    TYA                             ; msg. No
    BMI L1B2A
    LDX #<msg_table                 ; msg. table start
    LDY #>msg_table
    STX $03
    STY $04
L1B2A
    AND #$7F                        ; delete bit 7
    TAX                             ; set masg. No as counter

; find msg. address pointer
; the msg. address will be in $03/$04
msg_search
    LDY #$00                        ; pointer

; find $0D for msg. end
-   INY
    LDA ($03),Y                     ; load char from msg_table
    CMP #$0D
    BNE -

    DEX                             ; decrement counter
    BMI msg_found

; increment msg. pointer
    TYA
    SEC
    ADC $03                         ; increment pointer low byte with counter
    STA $03                         ; store as new low byte
    BCC msg_search                  ; bcc skip
    INC $04                         ; else increment high byte
    BCS msg_search                  ; (jmp)

msg_found
    PLA                             ; line No.
    TAX                             ; move to X
    TYA                             ; msg. length
    PHA
    JSR print_msg                   ; L1AE5
    PLA
    RTS
; --------------------------------
; it seems, that the area from L1B4E to L0B80 is not used
; so i have put some new code parts here
; --------------------------------
L1B4E
!if VERSION = 1.3 {
; --------------------------------
prepline1
    JSR L1B1C                       ; print first screen line

    LDX #$04
-   LDA lwtab,X
    STA $041F,X                     ; print "<LW: " to the screen
    DEX
    BPL -

    CLC
    LDA $BA
    BEQ second_dig                  ; if a zero is inside
    CMP #$0A                        ; check with 10
    BCC second_dig                  ; if less handle only second digit
    LDA #$31                        ; else load with '1'
    STA $0423                       ; and print as first digit to the screen

; handle if we had two digits
    LDA $BA                         ; get back drive No.
    CLC
    ADC #$26                        ; set to $30 to $39
    !by $2C                         ; skip next command

; jump in, if we had only one digit
second_dig
    ADC #$30                        ; add #$30 to adjust to #$38 or #$39
    STA $0424                       ; store as second digit to the screen
    LDA #$1D                        ; '>'
    STA $0425                       ; print last sign
    RTS                             ; finish

lwtab
    !tx $1c,"LW:0"
}

; --------------------------------
; it seems, that the area from L1B4E to L0B80 is not used
!if VERSION = 1.2 {
    !by $00,$00,$00,$00,$00,$00,$00,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00 
    !by $00,$00,$00,$00,$00,$00,$00,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00 
    !by $00,$00,$00,$00,$00,$00,$00,$00 
    !by $00,$00,$00,$00,$00,$00,$00,$00 
    !by $00,$00
}

L1B80
    JMP L1B9B
L1B83
    JMP L30F3                       ; fill third line with #$1e (empty spaces)
L1B86
    JMP L34C7
L1B89
    JMP L34E3
L1B8C
    JMP L245F                       ; read dir
L1B8F
    JMP L2545
L1B92
    JMP L2582                       ; set file parameter and open
L1B95
    JMP L25A7                       ; restore i/o and close
    JMP L1B16                       ; print a text into the second line on screen

L1B9B
    LDX #$FE
    TXS
    JSR L300B
L1BA1
    JSR L1BA7
    JMP L1BA1
    
---------------------------------
L1BA7
    JSR CBM_GETIN                   ; get character from input device
    BEQ L1BA7
    STA $6F
    BIT $5A
    BPL L1BB7
    PHA
    JSR L1B0D
    PLA
L1BB7
    CMP #$A0
    BCS L1BBE
    JMP L1C11
---------------------------------
L1BBE
    SBC #$A0
    ASL
    TAX
    LDA L1BCB+1,X
    PHA
    LDA L1BCB,X
    PHA

; ---------------------------------
; Text command RUN/STOP
; ---------------------------------
L1BCA
    RTS

; ---------------------------------
; Text address table
; ---------------------------------

L1BCB
!word L1DBF-1   ; CURSOR DOWN
!word L1D6F-1   ; CURSOR UP
!word L1DB1-1   ; CURSOR RIGHT
!word L1D59-1   ; CURSOR LEFT

!word L1DDD-1   ; CLR/HOME
!word L1DED-1   ; SHIFT-CLR/HOME
!word L1DF5-1   ; F1
!word L1E10-1   ; F2

!word L1E2B-1   ; F3
!word L1E50-1   ; F4
!word L1E60-1   ; F5
!word L1E6B-1   ; F6

!word L1E79-1   ; SHIFT RETURN
!word L1C41-1   ; RETURN
!word L1C41-1   ; CTRL RETURN
!word L1C60-1   ; INST/DEL

!word L1C5B-1   ; SHIFT-INST/DEL
!word L1C7B-1   ; F7
!word L2089-1   ; F8
!word L1BCA-1   ; RUN/STOP (points to RTS only)

!word L20AA-1   ; C= ARROW LEFT
!word L2357-1   ; C= L
!word L22EF-1   ; C= S
!word L283C-1   ; C= P

!word L27FB-1   ; C= Q
!word L0812-1   ; C= G
!word L2452-1   ; C= D
!word L20C0-1   ; C= C

!word L20A3-1   ; C= M
!word L27F4-1   ; C= ARROW UP
!word L25B5-1   ; C= F
!word L25EA-1   ; C= R

!word L27A6-1   ; C= F1 - F8
!word L27DB-1   ; C= CLR/HOME
!word L280E-1   ; C= X

L1C11
    CMP #$20
    BCC L1C37
    LDY $1D
    LDA ($07),Y
    CMP #$02
    BCC L1C3B
    CMP #$0D
    BEQ L1C3B
    LDA $6F
    STA ($07),Y
    LDX $07
    LDY $08
    STX $03
    STY $04
    LDX $1C
    LDA $61
    JSR print_msg                   ; L1AE5
    JMP L1DB1
---------------------------------
L1C37
    CMP #$03
    BCC L1C43
L1C3B
    JSR L1C90
    JMP L1DB1

; ---------------------------------
; Text command RETURN
; Text command CTRL RETURN
; ---------------------------------
L1C41
    LDA #$0D
L1C43
    JSR L1C8E
    BCS L1C5A
    LDA $6F
    CMP #$01
    BNE L1C53
    INC $56
    JSR L352E
L1C53
    LDA $1D
    STA $61
    JSR L1DB1
L1C5A
    RTS

; ---------------------------------
; Text command SHIFT-INST/DEL
; ---------------------------------
L1C5B
    LDA #$20
    JMP L1C8E

; ---------------------------------
; Text command INST/DEL
; ---------------------------------
L1C60
    LDY $1D
    LDA ($07),Y
    CMP #$0D
    BEQ L1C6C
    CMP #$02
    BCS L1C77
L1C6C
    JSR L1D59
    LDY $1D
    LDA ($07),Y
    CMP #$02
    BCC L1C7A
L1C77
    JSR L1CEE
L1C7A
    RTS

; ---------------------------------
; Text command F7
; ---------------------------------
L1C7B
    LDY $1D
    LDA ($07),Y
    CMP #$0D
    BEQ L1C8B
    LDA #$0D
    JSR L1C8E
    JMP L1F1C
---------------------------------
L1C8B
    JMP L1CEE
---------------------------------
L1C8E
    STA $6F
L1C90
    LDA $53
    TAX
    SEC
    SBC $07
    LDA $54
    TAY
    SBC $08
    STA $15
    INX
    BNE L1CA5
    INY
    CPY #$5C
    BCS L1CE7
L1CA5
    STX $53
    STY $54
    TAX
    INX
    LDA $07
    CLC
    ADC $1D
    STA $03
    STA $09
    LDA $08
    ADC $15
    STA $04
    STA $0A
    INC $09
    BNE L1CC2
    INC $0A
L1CC2
    JSR L1D36
    LDY $1D
    LDA $6F
    STA ($07),Y
    INC $61
    LDA $61
    CMP #$29
    BCS L1CE2
    LDX $07
    LDY $08
    STX $03
    STY $04
    LDX $1C
    JSR print_msg                   ; L1AE5
    CLC
    RTS
---------------------------------
L1CE2
    JSR L1F1C
    CLC
    RTS
---------------------------------
L1CE7
    LDA #$04                        ; msg. No.
    JSR L1B16                       ; print "Speicher",$7D,"berlauf"
    SEC
    RTS
---------------------------------
L1CEE
    LDA $53
    TAY
    SEC
    SBC $07
    LDA $54
    SBC $08
    TAX
    INX
    TYA
    BNE L1CFF
    DEC $54
L1CFF
    DEC $53
    LDA $07
    CLC
    ADC $1D
    STA $03
    STA $09
    LDA $08
    ADC #$00
    STA $04
    STA $0A
    INC $03
    BNE L1D18
    INC $04
L1D18
    JSR L1D48
    DEC $61
    LDA $1D
    CMP $61
    BCS L1D33
    LDX $07
    LDY $08
    STX $03
    STY $04
    LDX $1C
    LDA $61
    JSR print_msg                   ; L1AE5
    RTS
---------------------------------
L1D33
    JMP L1F1C
---------------------------------
L1D36
    LDY #$00
L1D38
    DEY
    LDA ($03),Y
    STA ($09),Y
    TYA
    BNE L1D38
    DEC $04
    DEC $0A
    DEX
    BNE L1D38
    RTS
---------------------------------
L1D48
    LDY #$00
L1D4A
    LDA ($03),Y
    STA ($09),Y
    INY
    BNE L1D4A
    INC $04
    INC $0A
    DEX
    BNE L1D4A
    RTS

; ---------------------------------
; Text command CURSOR LEFT
; ---------------------------------
L1D59
    LDA $1D
    BNE L1D64
    JSR L1EF9
    LDA $1D
    BEQ L1D69
L1D64
    DEC $1D
    JMP L350D
---------------------------------
L1D69
    LDA #$27
    STA $1D
    BNE L1D72

; ---------------------------------
; Text command CURSOR UP
; ---------------------------------
L1D6F
    JSR L1EF9
L1D72
    LDA $1C
    CMP #$03
    BEQ L1D92
    JSR L1FD6
    LDA $07
    SEC
    SBC $03
    STA $61
    JSR L1E7F
    DEC $1C
    LDX $03
    LDY $04
    STX $07
    STY $08
    JMP L350D
---------------------------------
L1D92
    JSR L1F98
    LDX $05
    LDY $06
    STX $07
    STY $08
    STX $03
    STY $04
    JSR L201C
    STA $61
    JSR L1E7F
    LDX #$03
    JSR L1FF5
    JMP L350D

; ---------------------------------
; Text command CURSOR RIGHT
; ---------------------------------
L1DB1
    INC $1D
    LDA $1D
    CMP $61
    BCC L1DBC
    JMP L1F1C
---------------------------------
L1DBC
    JMP L350D

; ---------------------------------
; Text command CURSOR DOWN
; ---------------------------------
L1DBF
    LDA $07
    CLC
    ADC $61
    STA $03
    LDA $08
    ADC #$00
    STA $04
    JSR L201C
    TAY
    JSR L1E81
    LDA $1D
    CLC
    ADC $61
    STA $1D
    JMP L1F1C

; ---------------------------------
; Text command CLR/HOME
; ---------------------------------
L1DDD
    LDA $1C
    CMP #$03
    BNE L1DEA
    LDA $1D
    BNE L1DEA
    JMP L3018
---------------------------------
L1DEA
    JMP L3020

; ---------------------------------
; Text command SHIFT-CLR/HOME
; ---------------------------------
L1DED
    JSR L1E89
    LDA #$12
    JMP L1ECB

; ---------------------------------
; Text command F1
; ---------------------------------
L1DF5
    LDA $55
    CMP $56
    BEQ L1E0F
    JSR L1E89
    LDX $07
    LDY $08
    INX
    BNE L1E06
    INY
L1E06
    STX $51
    STY $52
    INC $55
    JSR L3018
L1E0F
    RTS

; ---------------------------------
; Text command F2
; ---------------------------------
L1E10
    LDA $55
    CMP #$01
    BEQ L1E2A
    LDY $52
    LDX $51
    BNE L1E1D
    DEY
L1E1D
    DEX
    STX $05
    STY $06
    JSR L1EA5
    DEC $55
    JSR L3018
L1E2A
    RTS

; ---------------------------------
; Text command F3
; ---------------------------------
L1E2B
    LDX $05
    LDY $06
    STX $03
    STY $04
    LDA #$12
    STA $21
L1E37
    JSR L201C
    BCC L1E4D
    CLC
    ADC $03
    STA $03
    STA $05
    BCC L1E49
    INC $04
    INC $06
L1E49
    DEC $21
    BNE L1E37
L1E4D
    JMP L3020

; ---------------------------------
; Text command F4
; ---------------------------------
L1E50
    LDA #$12
    STA $21
L1E54
    JSR L1F98
    BEQ L1E5D
    DEC $21
    BNE L1E54
L1E5D
    JMP L3020

; ---------------------------------
; Text command F5
; ---------------------------------
L1E60
    JSR L1EF9
    LDY $61
    DEY
    STY $1D
    JMP L350D

; ---------------------------------
; Text command F6
; ---------------------------------
L1E6B
    LDA $1D
    BEQ L1E60
L1E6F
    JSR L1EF9
    LDA #$00
    STA $1D
    JMP L350D

; ---------------------------------
; Text command SHIFT RETURN
; ---------------------------------
L1E79
    JSR L1E6F
    JMP L1DBF
---------------------------------
L1E7F
    LDY $61
L1E81
    DEY
    CPY $1D
    BCS L1E88
    STY $1D
L1E88
    RTS
---------------------------------
L1E89
    LDY #$00
L1E8B
    LDA ($07),Y
    CMP #$02
    BCC L1E98
    INY
    BNE L1E8B
    INC $08
    BNE L1E8B
L1E98
    PHA
    TYA
    CLC
    ADC $07
    STA $07
    BCC L1EA3
    INC $08
L1EA3
    PLA
    RTS
---------------------------------
L1EA5
    LDX $05
    LDY $06
    STX $03
    DEY
    STY $04
    LDY #$00
L1EB0
    DEY
    LDA ($03),Y
    CMP #$02
    BCC L1EBE
    TYA
    BNE L1EB0
    DEC $04
    BNE L1EB0
L1EBE
    TYA
    SEC
    ADC $03
    STA $51
    LDA $04
    ADC #$00
    STA $52
    RTS
---------------------------------
L1ECB
    LDX $07
    LDY $08
    STX $05
    STY $06
    STA $21
L1ED5
    JSR L1F98
    BEQ L1EDE
    DEC $21
    BNE L1ED5
L1EDE
    LDX #$07
    JSR L2047
    STX $1C
    LDX $05
    LDY $06
    STX $03
    STY $04
    LDX #$03
    JSR L1FF5
    LDA #$00
    STA $1D
    JMP L1F1C
---------------------------------
L1EF9
    LDA $1C
    CMP #$03
    BEQ L1F0C
    JSR L1FD6
    JSR L201C
    CLC
    ADC $03
    CMP $07
    BNE L1F1C
L1F0C
    LDX $07
    LDY $08
    STX $03
    STY $04
    JSR L201C
    CMP $61
    BNE L1F1C
    RTS
---------------------------------
L1F1C
    LDA $07
    CLC
    ADC $1D
    STA $07
    BCC L1F27
    INC $08
L1F27
    JSR L1FD6
    STX $1C
    TXA
    PHA
    LDA $03
    PHA
    LDA $04
    PHA
L1F34
    LDA $07
    SEC
    SBC $03
    STA $1D
    JSR L201C
    STA $61
    BCC L1F57
    LDA $1D
    CMP $61
    BCC L1F57
    INC $1C
    LDA $03
    CLC
    ADC $61
    STA $03
    BCC L1F34
    INC $04
    BCS L1F34
L1F57
    LDX $03
    LDY $04
    STX $07
    STY $08
    JSR L1E7F
L1F62
    LDA $1C
    CMP #$18
    BCC L1F8A
    PLA
    PLA
    PLA
    LDA #$03
    PHA
    LDX $05
    LDY $06
    STX $03
    STY $04
    JSR L201C
    CLC
    ADC $05
    STA $05
    PHA
    LDA $06
    ADC #$00
    STA $06
    PHA
    DEC $1C
    BNE L1F62
L1F8A
    PLA
    STA $04
    PLA
    STA $03
    PLA
    TAX
    JSR L1FF5
    JMP L350D
---------------------------------
L1F98
    LDA $05
    SEC
    SBC #$28
    STA $05
    BCS L1FA3
    DEC $06
L1FA3
    LDY #$27
    LDA #$FF
    STA $72
L1FA9
    LDA ($05),Y
    CMP #$02
    BCC L1FC8
    BEQ L1FC9
    CPY #$27
    BEQ L1FC3
    CMP #$0D
    BEQ L1FC8
    CMP #$2D
    BEQ L1FC1
    CMP #$20
    BNE L1FC3
L1FC1
    STY $72
L1FC3
    DEY
    BPL L1FA9
    LDY $72
L1FC8
    INY
L1FC9
    TYA
    CLC
    ADC $05
    STA $05
    BCC L1FD3
    INC $06
L1FD3
    CPY #$28
    RTS
---------------------------------
L1FD6
    LDA $05
    STA $03
    LDA $06
    STA $04
    LDX #$04
L1FE0
    CPX $1C
    BCS L1FF3
    JSR L201C
    CLC
    ADC $03
    STA $03
    BCC L1FF0
    INC $04
L1FF0
    INX
    BNE L1FE0
L1FF3
    DEX
    RTS
---------------------------------
L1FF5
    TXA
    PHA
    JSR L201C
    BCC L2013
    PHA
    JSR print_msg                   ; L1AE5
    PLA
    CLC
    ADC $03
    STA $03
    BCC L200A
    INC $04
L200A
    PLA
    TAX
    INX
    CPX #$19
    BCC L1FF5
    CLC
    RTS
---------------------------------
L2013
    JSR print_msg                   ; L1AE5
    PLA
    TAX
    INX
    JMP L354E
---------------------------------
L201C
    LDY #$00
    LDA #$28
    STA $72
L2022
    LDA ($03),Y
    INY
    CMP #$02
    BCC L2030
    BNE L2032
    CPY #$01
    BEQ L2032
    DEY
L2030
    TYA
    RTS
---------------------------------
L2032
    CMP #$0D
    BEQ L2030
    CMP #$20
    BEQ L203E
    CMP #$2D
    BNE L2040
L203E
    STY $72
L2040
    CPY #$28
    BCC L2022
    LDA $72
    RTS
---------------------------------
L2047
    LDA $05
    STA $03
    LDA $06
    STA $04
    LDA #$03
    STA $21
L2053
    LDA $00,X
    SEC
    SBC $03
    STA $15
    LDA $01,X
    SBC $04
    BCC L2080
    BEQ L2066
    LDA #$FF
    STA $15
L2066
    JSR L201C
    CMP $15
    BEQ L206F
    BCS L2084
L206F
    CLC
    ADC $03
    STA $03
    BCC L2078
    INC $04
L2078
    INC $21
    LDA $21
    CMP #$19
    BCC L2053
L2080
    LDA #$00
    STA $15
L2084
    LDX $21
    LDA $15
    RTS

; ---------------------------------
; Text command F8
; ---------------------------------
L2089
    JSR L21CC
    BCS L20A2
    LDA $56
    SEC
    SBC $57
    STA $56
    JSR L2101
    JSR L213A
    JSR L1F1C
    JSR L352E
    CLC
L20A2
    RTS

; ---------------------------------
; Text command C= M
; ---------------------------------
L20A3
    JSR L2089
    BCS L20A2
    BCC L20C8

; ---------------------------------
; Text command C= ARROW LEFT
; ---------------------------------
L20AA
    BIT $57
    BPL L20B3
    LDA #$16                        ; msg. No.
    JMP L1B16                       ; print "Sorry, nichts da"
---------------------------------
L20B3
    LDA $07
    CLC
    ADC $1D
    TAX
    LDA $08
    ADC #$00
    TAY
    BCC L20CD

; ---------------------------------
; Text command C= C
; ---------------------------------
L20C0
    JSR L21CC
    BCS L2100
    JSR L2101
L20C8
    JSR L2197
    BCS L2100
L20CD
    LDA $53
    SEC
    ADC $77
    LDA $54
    ADC $78
    CMP #$5C
    BCS L20FB
    STX $03
    STY $04
    TXA
    PHA
    TYA
    PHA
    JSR L216A
    PLA
    STA $0A
    PLA
    STA $09
    JSR L2117
    JSR L1F1C
    LDA $57
    CLC
    ADC $56
    STA $56
    JMP L352E
---------------------------------
L20FB
    LDA #$04                        ; msg. No.
    JSR L1B16                       ; print "Speicher",$7D,"berlauf"
L2100
    RTS
---------------------------------
L2101
    LDX $27
    LDY $28
    STX $03
    STY $04
    LDX #$00                        ; $6000
    LDY #$60
    STX $09
    STY $0A
    LDX $78
    INX
    JMP L1D48
---------------------------------
L2117
    LDY #$00
    STY $03
    LDA #$60                        ; $6000
    STA $04
    LDX $77
    LDA $78
    STA $15
L2125
    LDA ($03),Y
    STA ($09),Y
    INY
    BNE L2130
    INC $04
    INC $0A
L2130
    DEX
    CPX #$FF
    BNE L2125
    DEC $15
    BPL L2125
    RTS
---------------------------------
L213A
    LDX $29
    LDY $2A
    INX
    BNE L2142
    INY
L2142
    STX $03
    STY $04
    LDX $27
    LDY $28
    STX $09
    STY $0A
    LDA $53
    SEC
    SBC $29
    LDA $54
    SBC $2A
    TAX
    INX
    JSR L1D48
    LDA $53
    CLC
    SBC $77
    STA $53
    LDA $54
    SBC $78
    STA $54
    RTS
---------------------------------
L216A
    LDA $53
    CMP $03
    LDA $54
    SBC $04
    TAX
    INX
    CLC
    ADC $04
    STA $04
    LDA $03
    SEC
    ADC $77
    STA $09
    LDA $04
    ADC $78
    STA $0A
    JSR L1D36
    LDA $53
    SEC
    ADC $77
    STA $53
    LDA $54
    ADC $78
    STA $54
    RTS
---------------------------------
L2197
    LDA #$09                        ; msg. No.
    JSR L1B16                       ; print "Ziel markieren, dann RETURN"
L219C
    JSR CBM_GETIN                   ; get character from input device
    CMP #$A0
    BCC L219C
    CMP #$B3
    BEQ L21C7
    CMP #$AD
    BEQ L21B3
    BCS L219C
    JSR L1BB7
    JMP L219C
---------------------------------
L21B3
    LDA $07
    CLC
    ADC $1D
    PHA
    LDA $08
    ADC #$00
    PHA
    JSR L1B0D
    PLA
    TAY
    PLA
    TAX
    CLC
    RTS
---------------------------------
L21C7
    JSR L1B0D
    SEC
L21CB
    RTS
---------------------------------
L21CC
    LDY $1D
    LDA ($07),Y
    SEC
    BEQ L21CB
    LDA #$08                        ; msg. No.
    JSR L1B16                       ; print "Ende markieren, dann RETURN"
    JSR L1EF9
    LDA $05
    PHA
    LDA $06
    PHA
    LDA $1C
    PHA
    LDA $55
    PHA
    LDA $07
    CLC
    ADC $1D
    STA $27
    STA $29
    LDA $08
    ADC #$00
    STA $28
    STA $2A
L21F8
    JSR L2297
L21FB
    JSR CBM_GETIN                    ; get character from input device
    CMP #$A0
    BCC L21FB
    CMP #$B3
    BEQ L222C
    CMP #$AD
    CLC
    BEQ L222C
    CMP #$AD
    BCS L21FB
    JSR L1BB7
    LDA $07
    CLC
    ADC $1D
    STA $29
    ROL $15
    CMP $27
    ROR $15
    LDA $08
    ADC #$00
    STA $2A
    ROL $15
    SBC $28
    BCS L21F8
    SEC
L222C
    ROL $15
    LDY #$00
    LDA ($29),Y
    CMP #$01
    BEQ L2242
    BCS L2244
    LDA $29
    BNE L223E
    DEC $2A
L223E
    DEC $29
    DEC $55
L2242
    INC $55
L2244
    PLA
    TAY
    SEC
    SBC $55
    EOR #$FF
    TAX
    INX
    STY $55
    PLA
    STA $1C
    PLA
    STA $06
    STA $04
    PLA
    STA $05
    STA $03
    LDA $27
    STA $07
    LDA $28
    STA $08
    LDA #$00
    STA $1D
    ROR $15
    PHP
    TXA
    PHA
    BCS L227E
    STA $57
    LDA $29
    SEC
    SBC $27
    STA $77
    LDA $2A
    SBC $28
    STA $78
L227E
    LDX #$03
    JSR L1FF5
    JSR L30DF
    JSR L1B0D
    JSR L1F1C
    PLA
    BEQ L2295
    JSR L1EA5
    JSR L352E
L2295
    PLP
    RTS
---------------------------------
L2297
    LDX #$29
    JSR L22DA
    INX
    BNE L22A0
    INY
L22A0
    STX $09
    STY $0A
    LDX #$27
    JSR L22DA
    STX $15
    STY $16
    LDA #$D8
    STA $04
    LDA #$00
    STA $03
    LDY #$78
L22B7
    LDX $7A
    CPY $15
    LDA $04
    SBC $16
    BCC L22CB
    CPY $09
    LDA $04
    SBC $0A
    BCS L22CB
    LDX $7B
L22CB
    TXA
    STA ($03),Y
    INY
    BNE L22B7
    INC $04
    LDA $04
    CMP #$DC
    BCC L22B7
    RTS
---------------------------------
L22DA
    JSR L2047
    PHA
    LDY #$28
    JSR multiply_x_y                ; multiply X with Y
    STX $15
    PLA
    CLC
    ADC $15
    TAX
    TYA
    ADC #$D8
    TAY
    RTS

; ---------------------------------
; Text command C= S 
; ---------------------------------
L22EF
    LDX #<textstart+1
    LDY #>textstart+1
    STX $27
    STY $28
    LDX $53

!if VERSION = 1.2 {
    LDY $54
    STX $29
    STY $2A  
}
!if VERSION = 1.3 {
    JSR ask_tsave
    BCS L2354
    NOP 
}

    LDA #$0E                        ; msg. No. "<A>lles oder <B>ereich?"
    LDX #$41                        ; "A"
    LDY #$42                        ; "B"
    JSR L34E3
    BCS L2354
    BEQ L2314
    JSR L350D
    JSR L21CC
    BCS L2354
L2314  
    LDA #$0F                        ; msg. No. "Name:"
    JSR L34C7
    BCS L2354
    LDY #$01
    JSR L2582                       ; set file parameter and open
    BCS L234C
    LDA #$54
    JSR CBM_CHROUT                  ; Output Vector
    LDY $27
    LDA #$00
    STA $27
L232D
    LDA ($27),Y
    JSR CBM_CHROUT                  ; Output Vector
    LDA $90
    BNE L234C
    CPY $29
    BNE L2340
    LDA $28
    CMP $2A
    BEQ L2347
L2340
    INY
    BNE L232D
    INC $28
    BNE L232D
L2347
    LDA #$00
    JSR CBM_CHROUT                  ; Output Vector
L234C
    JSR L25A7                       ; restore i/o and close
    LDA #$00
    JSR L2545
L2354
    JMP L350D

; ---------------------------------
; Text command C= L
; ---------------------------------
L2357

!if VERSION = 1.2 {
    JSR L245F                       ; read dir
}
!if VERSION = 1.3 {
    JSR ask_tload
}

    BNE L2362
    JSR L2545
    JMP L243F
---------------------------------
L2362
    LDA #$00
    LDX $53
    CPX #$A1
    BNE L2370
    LDX $54
    CPX #$3C
    BEQ L237B
L2370
    LDA #$12                        ; msg. No. "Mischen (j/n)?"
    LDX #$4E                        ; "N"
    LDY #$4A                        ; "J"
    JSR L34E3
    BCS L23DF
L237B
    STA $19
    BNE L2385
    LDX #<textstart+1
    LDY #>textstart+1
    BNE L2389
L2385
    LDX $53
    LDY $54
L2389
    STX $29
    STY $2A
    LDX #$00
    LDY #$60                        ; $6000
    STX $03
    STY $04
    LDY #$00
    STY $21
    JSR L2582                       ; set file parameter and open
    JSR CBM_CHRIN                   ; Input Vector
    CMP #$54
    BNE L23D0
    LDA #$80
    STA $57
L23A7
    JSR CBM_CHRIN                   ; Input Vector
    CMP #$01
    BCC L23E4
    BNE L23B2
    INC $21
L23B2
    LDY #$00
    STA ($03),Y
    INC $03
    BNE L23BC
    INC $04
L23BC
    LDX $29
    LDY $2A
    INX
    BNE L23C8
    INY
    CPY #$5C
    BCS L23E2
L23C8
    STX $29
    STY $2A
    LDA $90
    BEQ L23A7
L23D0
    JSR L25A7                       ; restore i/o and close
    LDA #$00
    JSR L2545
    BCS L23DF
    LDA #$03                        ; msg. No.
    JSR L1B16                       ; print "Aechtz!"
L23DF
    JMP L243F
---------------------------------
L23E2
    LDA #$04                        ; msg. No. "Speicher",$7D,"berlauf"
L23E4
    PHA
    JSR L25A7                       ; restore i/o and close
    JSR L1B0D
    PLA
    BEQ L23F1
    JSR L1B16                       ; print a text into the second line on screen
L23F1
    LDA $19
    BNE L240A
    JSR L30A8
    STX $05
    STY $06
    STX $07
    STY $08
    LDA #$00
    STA $1D
    LDA #$03
    STA $1C
    BNE L2415
L240A
    LDA $07
    CLC
    ADC $1D
    TAX
    LDA $08
    ADC #$00
    TAY
L2415
    LDA $21
    CLC
    ADC $56
    STA $56
    LDA $29
    CLC
    SBC $53
    STA $77
    LDA $2A
    SBC $54
    STA $78
    BCC L243F
    STX $03
    STY $04
    TXA
    PHA
    TYA
    PHA
    JSR L216A
    PLA
    STA $0A
    PLA
    STA $09
    JSR L2117
L243F
    LDX $05
    LDY $06
    STX $03
    STY $04
    LDX #$03
    JSR L1FF5
    JSR L1F1C
    JMP L352E

; ---------------------------------
; Text command C= D
; ---------------------------------
L2452
    LDA #$0B                        ; msg. No. 'Befehl:'
    JSR L34C7
    BCS L245C
    JSR L2545
L245C
    JMP L350D
---------------------------------
; read dir
L245F
    LDA #$0A                        ; msg. No.
    JSR L1B16                       ; print "SPACE=weiter, CRSR/RETURN=Laden"
    LDX #<L24F4                     ; "$0"
    LDY #>L24F4
    LDA #$02
    JSR CBM_SETNAM                  ; Set file name
    LDY #$00
    JSR L2582                       ; set file parameter and open
    BCS L24E0
    LDA #$04
    STA $21
L2478
    JSR CBM_CHRIN                   ; Input Vector
    DEC $21
    BNE L2478
    JSR CBM_CLRCHN                  ; Restore I/O Vector
L2482
    JSR L24F6
    BCS L24E0
    STA $15
    LDA #$03
    STA $22
L248D
    LDY $22
    LDA #$0C
    JSR L3511
L2494
    JSR CBM_GETIN                   ; get character from input device
    LDX $22
    CMP #$A0
    BNE L24A5
    CPX $21
    BCS L2494
    INC $22
    BCC L248D
L24A5
    CMP #$A1
    BNE L24B1
    CPX #$04
    BCC L2494
    DEC $22
    BCS L248D
L24B1
    CMP #$AD
    BNE L24D4
    LDY #$28
    JSR multiply_x_y                ; multiply X with Y
    TXA
    CLC
    ADC #$0C
    STA $03
    TYA
    ADC #$04
    STA $04
    LDY #$00
    LDA #$22
L24C9
    CMP ($03),Y
    BEQ L24E2
    INY
    CPY #$14
    BCC L24C9
    BCS L24E0
L24D4
    CMP #$B3
    BEQ L24E0
    CMP #$20
    BNE L2494
    LDA $15
    BNE L2482
L24E0
    LDY #$00
L24E2
    TYA
    PHA
    JSR L25A7                       ; restore i/o and close
    PLA
    BEQ L24F3
    PHA
    LDX $03
    LDY $04
    JSR CBM_SETNAM                  ; Set file name
    PLA
L24F3
    RTS
---------------------------------
L24F4
    !pet "$0"
L24F6
    LDA #$00
    STA $D015
    LDX #$03
    STX $21
    JSR L354E
    LDX #$08
    JSR CBM_CHKIN                   ; Set input file
L2507
    JSR CBM_CHRIN                   ; Input Vector
    STA $13
    JSR CBM_CHRIN                   ; Input Vector
    STA $14
    LDX $21
    LDY #$07
    JSR L1AA0
    LDA #$00
    LDX $21
    JSR L3431
    BCS L2538
    JSR CBM_CHRIN                   ; Input Vector
    STA $15
    JSR CBM_CHRIN                   ; Input Vector
    ORA $15
    BEQ L2537
    LDA $21
    CMP #$18
    BCS L2537
    INC $21
    BCC L2507
L2537
    CLC
L2538
    PHA
    PHP
    JSR CBM_CLRCHN                  ; Restore I/O Vector
    LDA #$02
    STA $D015
    PLP
    PLA
    RTS
---------------------------------
L2545
    LDX #$30                        ; $0430 , read text from screen
    LDY #$04
    JSR CBM_SETNAM                  ; Set file name
    LDA #$0F
    TAY

!if VERSION = 1.2 {
    LDX #$08
}
!if VERSION = 1.3 {
    LDX $BA
}    

    JSR CBM_SETLFS                  ; set file parameters
    JSR CBM_OPEN                    ; OPEN Vector
    LDX #$0F
    JSR CBM_CHKIN                   ; Set input file
    BCS L2577
    JSR L1B0D
    LDA #$FF
    STA $5A
    LDA #$0D
    LDY #$00
    JSR L342F
    LDA $0428
    ORA $0429 
    CMP #$30
    BNE L2577
    CLC
L2577
    PHP
    JSR CBM_CLRCHN                  ; Restore I/O Vector
    LDA #$0F
    JSR CBM_CLOSE                   ; CLOSE Vector
    PLP
    RTS
---------------------------------
; set file parameter and open
L2582
    STY $26
    LDA #$00
    STA $D015

!if VERSION = 1.2 {
    LDA #$08
    TAX
}
!if VERSION = 1.3 {
    JSR store_BA    
}

    JSR CBM_SETLFS                  ; set file parameters
    JSR CBM_OPEN                    ; OPEN Vector
    BCS L25A5
    LDX #$08
    LDA $26
    BNE L25A0
    JSR CBM_CHKIN                   ; Set input file
    BCS L25A5
L259F
    RTS
---------------------------------
L25A0
    JSR CBM_CHKOUT                  ; Set Output
    BCC L259F
L25A5
    SEC
    RTS
---------------------------------
; restore i/o and close
L25A7
    JSR CBM_CLRCHN                  ; Restore I/O Vector
    LDA #$08
    JSR CBM_CLOSE                   ; CLOSE Vector
    LDA #$02
    STA $D015
    RTS

; ---------------------------------
; Text command C= F
; ---------------------------------
L25B5
    LDY #$00
    JSR L2643
    BCS L25E4
    LDA #$1B                        ; msg. No. "Gro",$7E,"/klein beachten (j/n)?"
    LDX #$4A                        ; "J"
    LDY #$4E                        ; "N"
    JSR L34E3
    BCS L25E4
    LSR
    ROR $19
    LDA #$00
L25CC
    JSR L26AA
    BCS L25E4
    LDA #$1C                        ; msg. No.
    JSR L1B16                       ; print "RETURN=weiter"
L25D6
    JSR CBM_GETIN                   ; get character from input device
    BEQ L25D6
    CMP #$AD
    BNE L25E4
    LDA $033E
    BCS L25CC
L25E4
    JSR L350D
    JMP L1B0D

; ---------------------------------
; Text command C= R
; ---------------------------------
L25EA
    LDY #$00
    JSR L2643
    BCS L25E4
    LDA #$1B                        ; msg. No. "Gro",$7E,"/klein beachten (j/n)?"
    LDX #$4A                        ; "J"
    LDY #$4E                        ; "N"
    JSR L34E3
    BCS L25E4
    LSR
    ROR
    STA $19
    LDY #$21
    JSR L2643
    BCS L25E4
    LDA #$00
L2609
    JSR L26AA
    BCS L25E4
    LDA #$1D                        ; msg.No.
    JSR L1B16                       ; print "RETURN=Ersetzen, SPACE=",$5D,"berspringen"
L2613
    JSR CBM_GETIN                   ; get character from input device
    CMP #$B3
    BEQ L25E4
    BIT $19
    BVS L2636
    TAX
    BEQ L2613
    LDA $033E
    CPX #$20
    BEQ L2609
    CPX #$AD
    BEQ L2636
    CPX #$AC
    BNE L25E4
    LDA $19
    ORA #$40
    STA $19
L2636
    JSR L2732
    LDA $035F
    BCC L2609
    LDA #$04                        ; msg. No.
    JMP L1B16                       ; print "Speicher",$7D,"berlauf"
---------------------------------
L2643
    STY $6C
    JSR L269F
    LDY $6C
    LDA $033E,Y
    BEQ L267B
    TAX
    DEX
    CLC
    ADC $6C
    TAY
L2655
; restore part of graphics screen
    LDA $033E,Y
    STA $0430,X
    DEY
    DEX
    BPL L2655
    LDA #$08
    LDY #$01
    JSR L3511
L2666
    JSR CBM_GETIN                   ; get character from input device
    BEQ L2666
    CMP #$AD
    BEQ L269D
    SEI
    LDX $C6
    STA $0277,X
    INC $C6
    CLI
    JSR L269F
L267B
    JSR L342B
    BCS L269E
    SEC
    TAX
    ORA $6C
    BEQ L269E
    LDY $6C
    TXA
    STA $033E,Y
    BEQ L269D
    CLC
    ADC $6C
    TAY
    DEX
L2693
; save part of graphics screen
    LDA $0430,X
    STA $033E,Y
    DEY
    DEX
    BPL L2693
L269D
    CLC
L269E
    RTS
---------------------------------
L269F
    LDA #$19
    LDY $6C
    BEQ L26A7
    LDA #$1A                        ; msg. No.
L26A7
    JMP L1B16                       ; print "Neu:"
---------------------------------
L26AA
    SEI
    CLC
    ADC $1D
    ADC $07
    STA $03
    LDA $08
    ADC #$00
    STA $04
    LDA #$00
    STA $21
L26BC
    LDA $03
    CLC
    ADC $033E
    ROL $15
    CLC
    SBC $53
    LDA $04
    ROR $15
    ADC #$00
    ROL $15
    SBC $54
    BCS L271B
    LDY #$00
L26D5
    LDA ($03),Y
    CMP #$02
    BCC L271D
    BIT $19
    BPL L26E2
    JSR L3402
L26E2
    STA $15
    LDA $033F,Y
    CMP #$09
    BEQ L26F6
    BIT $19
    BPL L26F2
    JSR L3402
L26F2
    CMP $15
    BNE L2729
L26F6
    INY
    CPY $033E
    BCC L26D5
    LDA $21
    PHA
    LDX $03
    LDY $04
    STX $07
    STY $08
    LDA #$0A
    JSR L1ECB
    PLA
    BEQ L271A
    CLC
    ADC $55
    STA $55
    JSR L352E
    JSR L1EA5
L271A
    CLC
L271B
    CLI
    RTS
---------------------------------
L271D
    INC $21
    TYA
    CLC
    ADC $03
    STA $03
    BCC L2729
    INC $04
L2729
    INC $03
    BNE L272F
    INC $04
L272F
    JMP L26BC
---------------------------------
L2732
    LDA $77
    PHA
    LDA $78
    PHA
    LDA $07
    CLC
    ADC $1D
    TAX
    LDA #$00
    STA $78
    ADC $08
    TAY
    LDA $035F
    SEC
    SBC $033E
    BEQ L2789
    BCC L276D
    STA $77
    DEC $77
    CLC
    ADC $53
    LDA $54
    ADC #$00
    CMP #$5C
    BCS L279F
    STX $03
    STY $04
    TXA
    PHA
    TYA
    PHA
    JSR L216A
    JMP L2785
---------------------------------
L276D
    EOR #$FF
    STA $77
    STX $27
    TXA
    PHA
    CLC
    ADC $77
    STA $29
    STY $28
    TYA
    PHA
    ADC #$00
    STA $2A
    JSR L213A
L2785
    PLA
    TAY
    PLA
    TAX
L2789
    STX $03
    STY $04
    LDY $035F
    BEQ L279B
    DEY
L2793
    LDA $0360,Y
    STA ($03),Y
    DEY
    BPL L2793
L279B
    JSR L1F1C
    CLC
L279F
    PLA
    STA $78
    PLA
    STA $77
    RTS

; ---------------------------------
; Text command C= F1 - F8
; ---------------------------------
L27A6
    LDA #$0D                        ; msg. No.
    JSR L1B16                       ; print "F1=Text, F3=Schirm, F5=Rahmen, F7=Mark."
L27AB
    JSR CBM_GETIN                   ; get character from input device
    CMP #$B3
    BEQ L27D8
    CMP #$A8
    BNE L27B9
    INC $D021
L27B9
    CMP #$AA
    BNE L27C0
    INC $D020
L27C0
    CMP #$A6
    BNE L27CC
    INC $7A
    JSR L30DF
    JMP L27AB
---------------------------------
L27CC
    CMP #$B1
    BNE L27AB
    INC $7B
    JSR L30D4
    JMP L27AB
---------------------------------
L27D8
    JMP L1B0D

; ---------------------------------
; Text command C= CLR/HOME
; ---------------------------------
L27DB
    LDA #$0C                        ; msg. No.
    JSR L1B16                       ; print "Freie Zeichen:"
    LDA #$00
    CLC
    SBC $53
    STA $13
    LDA #$5C
    SBC $54
    STA $14
    LDX #$01
    LDY #$0F
    JMP L1AA0

; ---------------------------------
; Text command C= ARROW UP
; ---------------------------------
L27F4
    LDA #$FF
    EOR $59
    JMP L33EE                       ; switch on CAPS

; ---------------------------------
; Text command C= Q
; ---------------------------------
L27FB
    LDA #$11                        ; msg. No. "Wirklich beenden (j)?"
    LDX #$4A                        ; "J"
    LDY #$80                        ; RETURN ?
    JSR L34E3
    BCS L2808
    BEQ L280B
L2808
    JMP L350D
---------------------------------
L280B
    JMP CBM_START                   ; Start (Hardware reset $FCE2)

; ---------------------------------
; Text command C= X
; ---------------------------------
L280E
    LDA #$18                        ; msg. No. "Erweiterungsdisk einlegen"

!if VERSION = 1.2 {
    LDY #$80                        ; RETURN ?
    JSR L34E3
} 
!if VERSION = 1.3 {
    NOP
    NOP
    JSR askdevice+2
}

    BCS L2837
    LDX #<L283A                     ; "XF"
    LDY #>L283A
    LDA #$02
    JSR CBM_SETNAM                  ; Set file name
    LDY #$01

!if VERSION = 1.2 {
    LDA #$08
}
!if VERSION = 1.3 {
    LDA $BA
}

    TAX
    JSR CBM_SETLFS                  ; set file parameters
    LDA #$00
    JSR CBM_LOAD                    ; call the load function
    LDA #$00
    JSR L2545
    BCS L2837

!if VERSION = 1.2 {
    JSR $6000
}
!if VERSION = 1.3 {
    JSR L6000
}

L2837
    JMP L350D
---------------------------------
L283A
!tx "XF"

; ---------------------------------
; Text command C= P
; ---------------------------------
L283C
    LDA #$05                        ; msg. No. "Seitenh",$7B,"lfte (1/2)?"
    LDX #$31                        ; "1"
    LDY #$32                        ; "2"
    JSR L34E3
    BCS L28B6
    STA $6E
    LDA #$17                        ; msg. No. "Grafik l",$7C,"schen (j/n)?"
    LDX #$4E                        ; "N"
    LDY #$4A                        ; "J"
    JSR L34E3
    BCS L28B6
    PHA
    LDA #$14                        ; msg. No. "Zeichensatzdiskette einlegen"

!if VERSION = 1.2 {
    LDY #$80                        ; RETURN ?
    JSR L34E3
} 
!if VERSION = 1.3 {
    JSR askdevice+2
    NOP
    NOP
}  

    PLA
    BCS L28B6
    BEQ L2864
    JSR L0815
L2864
    LDA #$00
    STA $D015
    LDA #$80
    STA $57
    JSR L28C4
    LDA $51
    STA $05
    LDA $52
    STA $06
L2878
    JSR L28EB
    LDY #$00
    LDA ($05),Y
    CMP #$02
    BCC L28BE
    BEQ L2898
    LDA $6000
    BNE L2891
    LDA #$01
    JSR L2F74
    BCS L28B0
L2891
    JSR L2B02
    BCS L28B0
    BCC L28A2
L2898
    JSR L2976
    BCS L28B0
    JSR L28F8
    BCS L28B0
L28A2
    JSR L2909
    BCS L28B0
    JSR CBM_GETIN                   ; get character from input device
    CMP #$B3
    BNE L2878
    LDA #$03                        ; msg. No. "Aechtz!
L28B0
    JSR L1B16                       ; print message
    JSR L25A7                       ; restore i/o and close
L28B6
    LDA #$02
    STA $D015
    JMP L3020
---------------------------------
L28BE
    JSR L25A7                       ; restore i/o and close
    JMP L0812
---------------------------------
L28C4
    LDX #$0C
L28C6
    LDA L28DE,X
    STA $5D,X
    DEX
    BPL L28C6
    LDA #$00
    STA $6000
    LDA #$00
    LDX #$1F
L28D7
    STA $02C0,X
    DEX
    BPL L28D7
    RTS
---------------------------------
L28DE
    !by $14,$00
    !by $14,$00,$58,$02,$01,$02,$02,$00 
    !by $00,$00,$00 

L28EB
    LDA $05
    STA $03
    LDA $06
    STA $04
    LDX #$03
    JMP L1FF5
---------------------------------
L28F8
    LDA $61
    CLC
    ADC $5D
    TAX
    LDA $62
    ADC $5E
    CPX #$81
    SBC #$02
    LDA #$02
    RTS
---------------------------------
L2909
    LDX $66
    BEQ L2966
    DEX
    TXA
    ASL
    ASL
    TAY
    TAX
L2913
    LDA $5F
    CMP $02E0,X
    LDA $60
    SBC $02E1,X
    BCS L2927
    DEX
    DEX
    DEX
    DEX
    BPL L2913
    BMI L2966
L2927
    LDA $05
    PHA
    LDA $06
    PHA
    LDA $02E2,X
    STA $05
    LDA $02E3,X
    STA $06
    LDA $02E0,Y
    STA $02E0,X
    LDA $02E1,Y
    STA $02E1,X
    LDA $02E2,Y
    STA $02E2,X
    LDA $02E3,Y
    STA $02E3,X
    DEC $66
    JSR L2976
    BCS L2971
    JSR L28F8
    BCS L2971
    JSR L2909
    BCS L2971
    PLA
    STA $06
    PLA
    STA $05
L2966
    LDA $5F
    CMP #$20
    LDA $60
    SBC #$03
    LDA #$02
    RTS
---------------------------------
L2971
    TAX
    PLA
    PLA
    TXA
    RTS
---------------------------------
L2976
    LDA #$00
    STA $6C

; ---------------------------------
; Format commands :, SPACE, $02
; ---------------------------------
L297A
    JSR L2A86
    JSR L3402
    LDX #$0F
L2982
    CMP L29A6,X
    BEQ L298E
    DEX
    BPL L2982
    LDA #$00
    SEC
    RTS
---------------------------------
L298E
    TXA
    CMP #$0B
    BCS L2998
    PHA
    JSR L2A9E
    PLA
L2998
    TAY
    ASL
    TAX
    LDA L29B6+1,X
    PHA
    LDA L29B6,X
    PHA
    LDA $13
    RTS

; ---------------------------------
; Format command chars table
L29A6
    !tx "XYLSHVUZGITC"
    !by $0D
    !tx ": "
    !by $02

; Format commnds table
L29B6
!word L29D6-1   ; 'X'
!word L29D6-1   ; 'Y'
!word L29D6-1   ; 'L'
!word L29F1-1   ; 'S'
!word L29E3-1   ; 'H'
!word L29DF-1   ; 'V'
!word L29DF-1   ; 'U'
!word L29E9-1   ; 'Z'
!word L2A3A-1   ; 'G'
!word L2A55-1   ; 'I'
!word L2A07-1   ; 'T'
!word L2A74-1   ; 'C'
!word L2A7D-1   ; $0d
!word L297A-1   ; ':'
!word L297A-1   ; ' '
!word L297A-1   ; $02


; ---------------------------------
; Format commands X,Y,L
; ---------------------------------
L29D6
    STA $5D,X
    LDA $14
    STA $5E,X
    JMP L297A

; ---------------------------------
; Format commands V,U
; ---------------------------------
L29DF
    CMP #$21
    BCS L29F3

; ---------------------------------
; Format command H
; ---------------------------------
L29E3
    STA $005F,Y
    JMP L297A

; ---------------------------------
; Format command Z
; ---------------------------------
L29E9
    JSR L2F74
    BCS L2A38
    JMP L297A

; ---------------------------------
; Format command S
; ---------------------------------
L29F1
    CMP #$04
L29F3
    BCS L2A36
    AND #$03
    ASL
    ASL
    ASL
    STA $13
    LDA $6E
    AND #$E7
    ORA $13
    STA $6E
L2A04
    JMP L297A

; ---------------------------------
; Format command T
; ---------------------------------
L2A07
    LDA #$01
    STA $6A
L2A0B
    LDA $6A
    ASL
    TAX
    LDA $13
    STA $02C0,X
    LDA $14
    STA $02C1,X
    INC $6A
    LDA $6A
    CMP #$10
    BCS L2A04
    LDY $6C
    LDA ($05),Y
    CMP #$2C
    BNE L2A04
    JSR L2A86
    JSR L2A9E
    JMP L2A0B
---------------------------------
L2A32
    LDA #$00
    SEC
    RTS
---------------------------------
L2A36
    LDA #$02
L2A38
    SEC
    RTS

; ---------------------------------
; Format command G
; ---------------------------------
L2A3A
    CMP #$04
    BCS L2A32
    LDX #$00
    STX $15
    LSR
    ROR $15
    LSR $15
    LSR
    ROL $15
    LDA $67
    AND #$7E
    ORA $15
    STA $67
    JMP L297A

; ---------------------------------
; Format command I
; ---------------------------------
L2A55
    LDA $66
    CMP #$08
    BCS L2A36
    INC $66
    ASL
    ASL
    TAX
    LDA $13
    STA $02E0,X
    LDA $14
    STA $02E1,X
    JSR L2A93
    STA $02E2,X
    TYA
    STA $02E3,X

; ---------------------------------
; Format command C
; ---------------------------------
L2A74
    JSR L2A86
    CMP #$0D
    BCC L2A32
    BNE L2A74

; ---------------------------------
; Format command $0d
; ---------------------------------
L2A7D
    JSR L2A93
    STA $05
    STY $06
    CLC
    RTS
---------------------------------
L2A86
    LDY $6C
    LDA ($05),Y
    STA $6F
    INC $6C
    BNE L2A92
    INC $06
L2A92
    RTS
---------------------------------
L2A93
    LDA $6C
    CLC
    ADC $05
    LDY $06
    BCC L2A9D
    INY
L2A9D
    RTS
---------------------------------
L2A9E
    LDX #$00
    STX $13
    STX $14
    STX $19
L2AA6
    JSR L2A86
    CPX #$00
    BNE L2AB9
    CMP #$3D
    BEQ L2AA6
    CMP #$2D
    BNE L2AB9
    ROR $19
    BMI L2AA6
L2AB9
    SEC
    SBC #$30
    BCC L2AE7
    CMP #$0A
    BCS L2AE7
    PHA
    LDA $14
    PHA
    LDA $13
    ASL
    ROL $14
    ASL
    ROL $14
    ADC $13
    STA $13
    PLA
    ADC $14
    STA $14
    ASL $13
    ROL $14
    PLA
    ADC $13
    STA $13
    BCC L2AE4
    INC $14
L2AE4
    INX
    BNE L2AA6
L2AE7
    BIT $19
    BPL L2AF8
    LDA #$00
    SEC
    SBC $13
    STA $13
    LDA #$00
    SBC $14
    STA $14
L2AF8
    LDA $6C
    BNE L2AFE
    DEC $06
L2AFE
    DEC $6C
    TXA
    RTS
---------------------------------
L2B02
    LDA #$00
    LDX #$03
L2B06
    STA $6A,X
    DEX
    BPL L2B06
    JSR L2D60
    LDA $6E
    AND #$DF
    STA $6E
    LDA $67
    PHA
    LDA $69
    PHA
    LDA $68
    PHA
    JSR L2BC2
    PLA
    STA $68
    PLA
    STA $69
    PLA
    STA $67
    LDA $5F
    SEC
    SBC $65
    TAX
    LDA $60
    SBC #$00
    JSR L2EC8
    BCC L2B4D
    LDA $67
    LSR
    LDA $6002
    BCC L2B41
    ASL
L2B41
    ADC $65
    ADC $5F
    TAX
    LDA #$00
    ADC $60
    JSR L2EC8
L2B4D
    ROR $74
    LDA $61
    SEC
    SBC $70
    STA $77
    LDA $62
    SBC $71
    STA $78
    JSR L2D60
    LDA $6E
    AND #$38
    BEQ L2B8F
    CMP #$18
    BEQ L2B71
    AND #$30
    BEQ L2B80
    LSR $78
    ROR $77
L2B71
    LDA $70
    CLC
    ADC $77
    STA $70
    LDA $71
    ADC $78
    STA $71
    BCC L2B8F
L2B80
    LDY $6C
    DEY
    LDA ($05),Y
    CMP #$0D
    BEQ L2B8F
    JSR L2DA3
    JMP L2B95
---------------------------------
L2B8F
    LDA #$00
    STA $75
    STA $76
L2B95
    LDA $6C
    STA $6D
    LDA #$00
    STA $6C
    STA $6A
    STA $6B
    JSR L2C54
    BCS L2BC1
    LDA $67
    LSR
    LDA $6002
    BCC L2BAF
    ASL
L2BAF
    ADC $64
    ADC $5F
    STA $5F
    BCC L2BB9
    INC $60
L2BB9
    JSR L2A93
    STA $05
    STY $06
    CLC
L2BC1
    RTS
---------------------------------
L2BC2
    JSR L2A86
    JSR L2D21
    CMP #$03
    BCS L2BCF
    DEC $6C
    RTS
---------------------------------
L2BCF
    JSR L2CB3
    BCC L2BC2
    LDX $68
    CPX #$E8
    BNE L2BEA
    LDA #$2D
    JSR L2D6F
    BCS L2C1A
    STX $72
    STY $73
    LDX $6C
    DEX
    STX $6D
L2BEA
    LDA $6F
    CMP #$2D
    BNE L2C00
    JSR L2D97
    BCS L2C1A
    STX $72
    STY $73
    LDA $6C
    STA $6D
    JMP L2BC2
---------------------------------
L2C00
    CMP #$20
    BNE L2C3D
    INC $6B
    LDX $70
    LDY $71
    STX $72
    STY $73
    LDA $6C
    STA $6D
    JSR L2D97
    BCS L2C1A
    JMP L2BC2
---------------------------------
L2C1A
    LDA $6D
    BEQ L2C34
    STA $6C
    LDX $72
    LDY $73
    STX $70
    STY $71
    TAY
    DEY
    LDA ($05),Y
    CMP #$20
    BNE L2C32
    DEC $6B
L2C32
    CLC
    RTS
---------------------------------
L2C34
    LDA #$01                        ; msg. No.
    JSR L1B16                       ; print "Syntaxfehler in Formatzeile",
    DEC $6C
    CLC
    RTS
---------------------------------
L2C3D
    CMP #$0D
    BNE L2C43
    CLC
    RTS
---------------------------------
L2C43
    CMP #$20
    BCC L2C51
    CMP $6003
    BCS L2C51
    JSR L2D97
    BCS L2C1A
L2C51
    JMP L2BC2
---------------------------------
L2C54
    JSR L2A86
    JSR L2D21
    CMP #$0D
    BNE L2C64
    LDA #$00
    STA $69
    CLC
    RTS
---------------------------------
L2C64
    JSR L2CB3
    BCC L2C95
    BIT $74
    BMI L2C95
    CMP #$20
    BNE L2C86
    JSR L2D97
    INC $6B
    LDA $76
    CMP $6B
    LDA $70
    ADC $75
    STA $70
    BCC L2C95
    INC $71
    BCS L2C95
L2C86
    BCC L2C95
    CMP $6003
    BCS L2C95
    JSR L2DC2
    BCS L2CB2
    JSR L2D97
L2C95
    LDY $6C
    CPY $6D
    BCC L2C54
    BIT $74
    BMI L2CB1
    LDA ($05),Y
    JSR L2D21
    STY $68
    BCS L2CB1
    LDA #$2D
    STA $6F
    JSR L2DC2
    BCS L2CB2
L2CB1
    CLC
L2CB2
    RTS
---------------------------------
L2CB3
    CMP #$20
    BCS L2CC1
    LDX #$08
L2CB9
    CMP L2CCF,X
    BEQ L2CC3
    DEX
    BPL L2CB9
L2CC1
    SEC
    RTS
---------------------------------
L2CC3
    TXA
    ASL
    TAY
    LDA L2CD8+1,Y
    PHA
    LDA L2CD8,Y
    PHA
    RTS
---------------------------------
L2CCF
    !by $03,$04,$05,$0B,$0C,$06,$07,$08,$0A 

L2CD8
!word L2CEA-1
!word L2CEA-1
!word L2CEA-1
!word L2CEA-1
!word L2CEA-1
!word L2CF3-1
!word L2CFB-1
!word L2D01-1
!word L2D0A-1

L2CEA
    LDA L2F6C,X
    EOR $67
    STA $67
    CLC
    RTS
---------------------------------
L2CF3
    LDA $6E
    ORA #$20
    STA $6E
    CLC
    RTS
---------------------------------
L2CFB
    INC $6A
    LDA $6A
    BNE L2D05

L2D01
    INC $69
    LDA $69
L2D05
    JSR L2D41
    CLC
    RTS
---------------------------------
L2D0A
    JSR L2A9E
    LDA $70
    SBC $13
    TAX
    LDA $71
    SBC $14
    BCS L2D1B
    LDA #$00
    TAX
L2D1B
    STX $70
    STA $71
    CLC
    RTS
---------------------------------
L2D21
    LDY $68
    CMP #$41
    ROL $68
    CMP #$5E
    ROL $68
    CMP #$61
    ROL $68
    CMP #$7F
    ROL $68
    LDX $68
    CPX #$E8
    BNE L2D3F
    CLC
    ADC #$20
    STA $6F
    RTS
---------------------------------
L2D3F
    SEC
    RTS
---------------------------------
L2D41
    CMP #$10
    BCS L2D5F
    ASL
    TAY
    LDX $02C0,Y
    LDA $02C1,Y
    TAY
    CPX $70
    SBC $71
    BCC L2D5F
    TYA
    CPX $61
    SBC $62
    BCS L2D5F
    STX $70
    STY $71
L2D5F
    RTS
---------------------------------
L2D60
    LDA $69
    ASL
    TAX
    LDA $02C0,X
    STA $70
    LDA $02C1,X
    STA $71
    RTS
---------------------------------
L2D6F
    TAX
    LDA $5FE4,X
    CLC
    ADC $63
    CLC
    BPL L2D7B
    LDA #$00
L2D7B
    BIT $67
    BPL L2D80
    ASL
L2D80
    BIT $67
    BVC L2D86
    ADC #$01
L2D86
    PHA
    ADC $70
    TAX
    LDA $71
    ADC #$00
    TAY
    TXA
    CMP $61
    TYA
    SBC $62
    PLA
    RTS
---------------------------------
L2D97
    LDA $6F
    JSR L2D6F
    BCS L2DA2
    STX $70
    STY $71
L2DA2
    RTS
---------------------------------
L2DA3
    LDY #$00
    LDX $6B
    BEQ L2DBD
    LDX $77
L2DAB
    CPX $6B
    LDA $78
    SBC #$00
    BCC L2DBD
    STA $78
    TXA
    SBC $6B
    TAX
    INY
    JMP L2DAB
---------------------------------
L2DBD
    STY $75
    STX $76
L2DC1
    RTS
---------------------------------
L2DC2
    BIT $6E
    BPL L2DCB
    JSR L2FE5
    BCS L2DC1
L2DCB
    LDX $6001
    LDY $6002
    JSR multiply_x_y                ; multiply X with Y
    STX $79
    LDA $6F
    SEC
    SBC #$20
    SBC $6078
    TAY
    JSR multiply_x_y                ; multiply X with Y
    TXA
    CLC
    ADC #$78
    STA $5B
    TYA
    ADC #$60
    STA $5C
    LDX $5F
    LDY $60
    LDA $67
    AND #$10
    BEQ L2E01
    SEC
    TXA
    SBC $65
    TAX
    BCS L2E01
    DEY
    BMI L2E07
L2E01
    LDA $67
    AND #$08
    BEQ L2E0F
L2E07
    CLC
    TXA
    ADC $65
    TAX
    BCC L2E0F
    INY
L2E0F
    STX $0D
    STY $0E
    LDA $5D
    CLC
    ADC $70
    STA $0B
    LDA $5E
    ADC $71
    STA $0C
    LDY #$00
    STY $19
L2E24
    LDX #$00
    STX $15
L2E28
    LDA ($5B),Y
    STA $0200,X
    ORA $15
    STA $15
    INY
    INX
    CPX $6001
    BNE L2E28
    LDA $15
    BEQ L2E80
    JSR L2EC4
    BCS L2E80
    TYA
    PHA
    JSR L2ED9
    LDX $6F
    LDA $5FE4,X
    STA $1A
    JSR L2F60
    LDY #$00
L2E52
    LDX $6001
    DEX
L2E56
    ROL $0200,X
    DEX
    BPL L2E56
    PHP
    JSR L2F31
    JSR L2F3A
    PLP
    BIT $67
    BPL L2E70
    PHP
    JSR L2F31
    JSR L2F3A
    PLP
L2E70
    BIT $67
    BVC L2E77
    JSR L2F31
L2E77
    DEC $1A
    BPL L2E52
    JSR L2F66
    PLA
    TAY
L2E80
    LDA $67
    EOR $19
    AND #$01
    STA $19
    BEQ L2E90
    TYA
    SEC
    SBC $6001
    TAY
L2E90
    CPY $79
    BEQ L2E9C
    INC $0D
    BNE L2E24
    INC $0E
    BNE L2E24
L2E9C
    LDA $67
    AND #$20
    BEQ L2EC2
    JSR L2EC4
    BCS L2EC2
    JSR L2ED9
    LDA $6F
    JSR L2D6F
    TAX
    JSR L2F60
    LDY #$00
L2EB5
    SEC
    JSR L2F31
    JSR L2F3A
    DEX
    BNE L2EB5
    JSR L2F66
L2EC2
    CLC
    RTS
---------------------------------
L2EC4
    LDX $0D
    LDA $0E
L2EC8
    CPX #$90
    PHA
    SBC #$01
    ROL
    EOR $6E
    LSR
    PLA
    BCS L2ED8
    CPX #$20
    SBC #$03
L2ED8
    RTS
---------------------------------
L2ED9
    LDA $6E
    LSR
    LDA $0D
    PHA
    LDA $0E
    BCC L2EEC
    TAX
    PLA
    SEC
    SBC #$90
    PHA
    TXA
    SBC #$01
L2EEC
    STA $04
    TAX
    PLA
    PHA
    AND #$07
    STA $15
    PLA
    AND #$F8
    STA $03
    ASL
    ROL $04
    ASL
    ROL $04
    ADC $03
    PHA
    TXA
    ADC $04
    STA $04
    PLA
    LDX #$04
L2F0B
    ASL
    ROL $04
    DEX
    BNE L2F0B
    STA $03
    LDA $0B
    AND #$F8
    CLC
    ADC $15
    ADC $03
    STA $03
    LDA $0C
    ADC $04
    ORA #$80
    STA $04
    LDA $0B
    AND #$07
    TAX
    LDA L2F6C,X
    STA $12
    RTS
---------------------------------
L2F31
    BCC L2F39
    LDA $12
    ORA ($03),Y
    STA ($03),Y
L2F39
    RTS
---------------------------------
L2F3A
    LSR $12
    BCC L2F44
    ROR $12
    TYA
    ADC #$08
    TAY
L2F44
    RTS
---------------------------------
L2F45
; multiply X with Y
; result in X = low byte, and Y = high byte
multiply_x_y
    STX $15                         ; line No. (multiplier)
    STY $16                         ; value to multiply
    LDA #$00
    LDY #$08
-   ASL
    ROL $16
    BCC +
    CLC
    ADC $15
    BCC +
    INC $16
+   DEY
    BNE -
    TAX
    LDY $16
    RTS
---------------------------------
L2F60
    SEI
    LDA #$34
    STA $01
    RTS
---------------------------------
L2F66
    LDA #$37
    STA $01
    CLI
    RTS
---------------------------------
L2F6C
!by $80,$40,$20,$10,$08,$04,$02,$01

L2F74
    STA $18
    JSR L25A7                       ; restore i/o and close
    LDA #$02
    STA $22
L2F7D
    LDA #$13                        ; msg. No.
    JSR L1B16                       ; print "ZS"
    TAY
    LDA $18
    STA $13
    LDA #$00
    STA $14
    LDX #$01
    JSR L1AA0
    TYA
    LDX #$28                        ; $0428 , read from screen
    LDY #$04
    JSR CBM_SETNAM                  ; Set file name
    LDY #$00
    STY $21
    JSR L2582                       ; set file parameter and open
    JSR CBM_CHRIN                   ; Input Vector
    CMP #$5A
    BNE L2FCA
L2FA6
    JSR CBM_CHRIN                   ; Input Vector
    LDY $21
    INC $21
    STA $6000,Y
    LDA $90
    BNE L2FCA
    CPY #$77
    BCC L2FA6
    LDA $18
    CMP $6000
    BNE L2FCA
    LDA $6E
    ORA #$80
    STA $6E
    JSR CBM_CLRCHN                  ; Restore I/O Vector
    CLC
    RTS
---------------------------------
L2FCA
    JSR L25A7                       ; restore i/o and close
    LDA #$00
    JSR L2545
    BCC L2FE1
    DEC $22
    BEQ L2FE1
L2FD8
    JSR CBM_GETIN                   ; get character from input device
    BEQ L2FD8
    CMP #$B3
    BNE L2F7D
L2FE1
    LDA #$03
    SEC
    RTS
---------------------------------
L2FE5
    LDA $90
    BNE L2FE1
    LDA $6E
    AND #$7F
    STA $6E
    LDA #$00
    STA $39
    LDX #$08
    JSR CBM_CHKIN                   ; Set input file
    LDA #$02
    JSR L081B
    JSR L25A7                       ; restore i/o and close
    LDA #$00
    STA $D015
    JSR L2545
    LDA #$03
    RTS
---------------------------------
L300B
    JSR L3042                       ; init IRQ,NMI
    JSR L30C3
    JSR L30DF
    LDA #$80
    STA $57
L3018
    LDX $51
    LDY $52
    STX $05
    STY $06
L3020
    LDX $05
    LDY $06
    STX $07
    STY $08
    STX $03
    STY $04
    JSR L201C
    STA $61
    LDA #$00
    STA $1D
    LDX #$03
    STX $1C
    JSR L1FF5
    JSR L352E
    JMP L350D

; ---------------------------------
; init IRQ,NMI
; used at start and in Graphic mode for await text input
; ---------------------------------
L3042
    LDA #$1E
    STA $D018
    LDA #$9B
    STA $D011
    LDA $DD00
    ORA #$03
    STA $DD00
    SEI
    LDX #<L310C
    LDY #>L310C
    STX $0314
    STY $0315
    LDA #$00
    STA $58
    JSR L33EE                       ; switch off CAPS
    LDA #$1C
    STA $DC04
    STA $DC05
    CLI
    LDX #<L326E
    LDY #>L326E
    STX $FFFA                       ; NMI vector
    STY $FFFB
    STX $0318
    STY $0319
    LDA #$00
    STA $D01C
    STA $D01D
    STA $D017
    LDX #$3E
L308C
    STA $0380,X
    DEX
    BPL L308C
    LDA #$FF
    STA $03AB
    STA $03AE
    LDA #$02
    STA $D01B
    STA $D015
    LDA #$0E
    STA $07F9
    RTS
---------------------------------
L30A8
    LDX #<textstart+1
    LDY #>textstart+1
    STX $51
    STY $52
    STX $53
    STY $54
    LDA #$00
    STA textstart+1
    STA textstart
    LDA #$01
    STA $55
    STA $56
    RTS
---------------------------------
L30C3
    LDX #$00                        ; line No. to print to
    LDA #$06                        ; msg. No. "<PRINTFOX>"

!if VERSION = 1.2 {
    JSR L1B1C
}
!if VERSION = 1.3 {
    JSR prepline1
}

    JSR L1B0D
    LDX #$02                        ; line No. to print to
    LDA #$07                        ; msg. No. "<SEITE 1 von 1>"
    JSR L1B1C
L30D4
    LDA $7B
    LDY #$77
L30D8
    STA $D800,Y
    DEY
    BPL L30D8
    RTS
---------------------------------
L30DF
    LDA $7A
    LDY #$DC
L30E3
    STA $D877,Y
    STA $D953,Y
    STA $DA2F,Y
    STA $DB0B,Y
    DEY
    BNE L30E3
    RTS
---------------------------------
L30F3
    JSR L3042                       ; init IRQ,NMI
    JSR L30C3
; fill third line with #$1e, used in graphic mode
    LDY #$27
    LDA #$1E
-   STA $0450,Y
    DEY
    BPL -
    LDX #$03
    JSR L354E
    JSR L30DF
    RTS

; ---------------------------------
; IRQ
; ---------------------------------
L310C
    INC $A2
    LDA $A2
    AND #$3F
    BNE L311E
    LDA $D028
    AND #$01
    EOR #$01
    STA $D028
L311E
    JSR L3146
    LDA $24
    AND #$10
    ORA $7D
    ORA $7E
    BEQ L313B
    LDX $7D
    LDY $7E
    JSR L3240
    LDA $7C
    ORA #$80
    STA $7C
    JMP CBM_KPREND                  ; CLEAR INTERUPT FLAGS, RESTORE REGISTERS
---------------------------------
L313B
    LDA $A2
    LSR
    BCC L3143
    JSR L3275
L3143
    JMP CBM_KPREND                  ; CLEAR INTERUPT FLAGS, RESTORE REGISTERS
---------------------------------
L3146
    LDA #$FF
    STA $DC00
    LDA $7C
    AND #$18
    BNE L316E
    LDX $D419
    CPX #$FF
    BEQ L31A6
    LDX #$00
L315A
    NOP
    NOP
    INX
    BNE L315A
    LDA #$08
    LDX $D41A
    CPX #$FF
    BNE L316A
    LDA #$10
L316A
    ORA $7C
    STA $7C
L316E
    AND #$08
    BEQ L31B0
    LDX #$01
L3174
    LDA $D419,X
    TAY
    SEC
    SBC $7F,X
    AND #$7F
    CMP #$40
    BCS L3186
    LSR
    BEQ L3192
    BNE L318D
L3186
    EOR #$7F
    BEQ L3192
    LSR
    EOR #$FF
L318D
    PHA
    TYA
    STA $7F,X
    PLA
L3192
    STA $7D,X
    DEX
    BPL L3174
    LDA #$00
    SEC
    SBC $7E
    STA $7E
    LDA $DC01
    EOR #$FF
    LSR
    BPL L31E9
L31A6
    LDA #$00
    STA $7E
    STA $7D
    STA $24
    BEQ L31F1
L31B0
    LDA #$00
    STA $DC02
    LDA #$10
    STA $DC03
    LDX #$00
    LDY #$08
L31BE
    LDA #$00
    JSR L3231
    ASL
    ASL
    ASL
    ASL
    STA $7D,X
    LDA #$10
    JSR L3231
    AND #$0F
    ORA $7D,X
    CLC
    ADC #$01
    STA $7D,X
    INX
    CPX #$02
    BNE L31BE
    LDA #$00
    STA $DC03
    LDA $D419
    CMP #$FF
    BEQ L31E9
    CLC
L31E9
    LDA #$00
    BCC L31EF
    LDA #$10
L31EF
    STA $24
L31F1
    LDA $DC00
    EOR #$FF
    LDX #$FF
    STX $DC02
    ORA $24
    STA $24
    AND #$0F
    BEQ L3228
    LDX $82
    BNE L3225
    LSR
    BCC L320C
    DEC $7E
L320C
    LSR
    BCC L3211
    INC $7E
L3211
    LSR
    BCC L3216
    DEC $7D
L3216
    LSR
    BCC L321B
    INC $7D
L321B
    LDX $81
    BEQ L3230
    DEX
    STX $81
    STX $82
    RTS
---------------------------------
L3225
    DEC $82
    RTS
---------------------------------
L3228
    LDA #$0A
    STA $81
    LDA #$00
    STA $82
L3230
    RTS
---------------------------------
L3231
    STA $DC01
L3234
    NOP
    NOP
    NOP
    DEY
    BNE L3234
    LDY #$05
    LDA $DC01
    RTS
---------------------------------
L3240
    TYA
    PHA
    LDY #$00
    TXA
    BPL L3249
    LDY #$FF
L3249
    CLC
    ADC $2C
    TAX
    TYA
    ADC $2D
    BPL L3255
    LDA #$00
    TAX
L3255
    STX $2C
    STA $2D
    PLA
    CLC
    BMI L3265
    ADC $2E
    BCC L326B
    LDA #$FF
    BNE L326B
L3265
    ADC $2E
    BCS L326B
    LDA #$00
L326B
    STA $2E
    RTS

; ---------------------------------
; NMI
; ---------------------------------
L326E
    PHA
    LDA #$00
    STA $7C
    PLA
    RTI

; ---------------------------------
; IRQ part
; ---------------------------------
L3275
    LDA $C6
    PHA
    LDA $028D
    PHA
    JSR $EA87
    PLA
    TAX
    LDA $028D
    AND #$06
    BEQ L3293
    TXA
    EOR $028D
    AND #$06
    BEQ L3293
    JSR L33D6
L3293
    PLA
    CMP $C6
    BEQ L32C7
    TAX
    LDA $028D
    ORA $58
    CMP #$04
    BCC L32A4
    LDA #$04
L32A4
    ASL
    TAY
    LDA L32C8,Y
    STA $F5
    LDA L32C8+1,Y
    STA $F6
    LDY $CB
    LDA ($F5),Y
    BIT $59
    BPL L32BB
    JSR L3402
L32BB
    STA $0277,X
    LDA $58
    BEQ L32C7
    LDA #$00
    JSR L33D6                       ; empty second line from c=,ctrl and caps
L32C7
    RTS
---------------------------------
L32C8
    !word L32D2
    !word L3313
    !word L3354
    !word L3354
    !word L3395
L32D2
    !by $AF,$AD,$A2,$B1,$A6,$A8,$AA,$A0 
    !by $33,$77,$61,$34,$7A,$73,$65,$00
    !by $35,$72,$64,$36,$63,$66,$74,$78 
    !by $37,$79,$67,$38,$62,$68,$75,$76 
    !by $39,$69,$6A,$30,$6D,$6B,$6F,$6E 
    !by $2B,$70,$6C,$2D,$2E,$7C,$7D,$2C 
    !by $7E,$2A,$7B,$A4,$00,$3D,$5E,$2F 
    !by $31,$5F,$00,$32,$20,$00,$71,$B3 
    !by $00
L3313
    !by $B0,$AC,$A3,$B2,$A7,$A9,$AB,$A1
    !by $23,$57,$41,$24,$5A,$53,$45,$00 
    !by $25,$52,$44,$26,$43,$46,$54,$58 
    !by $27,$59,$47,$28,$42,$48,$55,$56 
    !by $29,$49,$4A,$30,$4D,$4B,$4F,$4E 
    !by $2B,$50,$4C,$80,$3A,$5C,$5D,$3B 
    !by $91,$40,$5B,$A5,$00,$3C,$8E,$3F 
    !by $21,$8D,$00,$22,$7F,$00,$51,$B3 
    !by $00
L3354
    !by $00,$00,$00,$C0,$C0,$C0,$C0,$00 
    !by $00,$00,$82,$00,$00,$B6,$83,$00 
    !by $00,$BF,$BA,$00,$BB,$BE,$00,$C2 
    !by $00,$00,$B9,$8B,$00,$00,$86,$00 
    !by $8C,$84,$00,$00,$BC,$00,$85,$88 
    !by $00,$B7,$B5,$00,$00,$8F,$00,$87 
    !by $00,$60,$90,$C1,$00,$3E,$BD,$89 
    !by $8A,$B4,$00,$81,$C1,$00,$B8,$B3 
    !by $00
L3395
    !by $00,$AE,$00,$00,$00,$00,$00,$00 
    !by $00,$00,$00,$00,$00,$0C,$04,$00 
    !by $00,$00,$00,$00,$06,$02,$07,$00 
    !by $00,$00,$00,$00,$03,$00,$05,$00 
    !by $00,$08,$09,$00,$00,$00,$00,$00 
    !by $00,$01,$00,$00,$00,$00,$00,$00 
    !by $00,$00,$00,$00,$00,$00,$0B,$00 
    !by $00,$0A,$00,$00,$00,$00,$00,$B3 
    !by $00

; print CTRL or C= or an empty string
; 0 => empty, to delete C= or CTRL in front of CAPS
; 2 => print C=
; 4 => print CTRL
L33D6
    STA $58
    CMP #$06    ; 0 = empty, 2 = C=
    BCC L33DE
    LDA #$04    ; for CTRL
L33DE
    ASL
    ASL
    TAX
    LDY #$07
L33E3
    LDA L3413,X
    STA $0450,Y
    INX
    DEY
    BPL L33E3
    RTS
---------------------------------
; handle 'CAPS'
; #$00 > switch off, #$FF > switch on
L33EE
    STA $59
    AND #$06
    EOR #$06
    TAX
    LDY #$05
L33F7
    LDA L340D,X
    STA $0459,Y
    INX
    DEY
    BPL L33F7
    RTS
---------------------------------
L3402
    CMP #$7E
    BCS L340C
    CMP #$61
    BCC L340C
    SBC #$20
L340C
    RTS
---------------------------------
L340D
    !pet $1D,"spac",$1C                     ; "<caps>" 
L3413
    !by $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E     ; empty string

    !pet $1E,$1D,"=c",$1C,$1E,$1E,$1E       ; " <C=>   "

    !pet $1D,"lrtc",$1C,$1E,$1E             ; "<ctrl>  " 


L342B
    LDA #$AD
    LDY #$08
L342F
    LDX #$01
L3431
    STA $1F
    TYA
    PHA
    STX $21
    LDY #$28
    JSR multiply_x_y                ; multiply X with Y
    STX $03
    TYA
    ORA #$04
    STA $04
    PLA
    STA $16
    STA $15
    LDY $21
    JSR L3511
    LDA #$00
    STA $90
L3451
    JSR CBM_GETIN                   ; get character from input device
    SEC
    LDX $90
    BNE L34C6
    LDY $15
    CMP $1F
    BEQ L34C1
    LDX $99
    BNE L34AF
    CMP #$02
    BCC L3451
    CMP #$AE
    BNE L346D
    LDA #$0D
L346D
    CMP #$AF
    BNE L347C
    CPY $16
    BEQ L3451
    DEY
    DEC $15
    LDA #$1F
    BNE L34B5
L347C
    CMP #$B3
    BEQ L34C6
    CMP #$BD
    BNE L348A
    JSR L27F4
    JMP L3451
---------------------------------
L348A
    CMP #$B4
    BNE L34AB
    LDA $08
    CMP #$5C
    BCS L3451
    LDX $1D
L3496
    TXA
    TAY
    LDA ($07),Y
    CMP #$02
    BCC L34B7
    LDY $15
    CPY #$28
    BCS L34B7
    STA ($03),Y
    INX
    INC $15
    BNE L3496
L34AB
    CMP #$A0
    BCS L3451
L34AF
    CPY #$28
    BCS L3451
    INC $15
L34B5
    STA ($03),Y
L34B7
    LDA $15
    LDY $21
    JSR L3511
    JMP L3451
---------------------------------
L34C1
    SEC
    TYA
    SBC $16
    CLC
L34C6
    RTS
---------------------------------
L34C7
    JSR L1B16                       ; print a text into the second line on screen
    LDA #$FF
    JSR L33EE                       ; switch on CAPS, and print on screen
    JSR L342B
    PHA
    PHP
L34D4
    LDX #$30                        ; $0430 , read from screen ?
    LDY #$04
    JSR CBM_SETNAM                  ; Set file name
    LDA #$00
    JSR L33EE                       ; switch off CAPS
    PLP
    PLA
    RTS
---------------------------------
L34E3
    STX $13
    STY $14
    JSR L1B16                       ; print a text into the second line on screen
    LDY #$01
    JSR L3511
L34EF
    JSR CBM_GETIN                   ; get character from input device
    BEQ L34EF
    CMP #$B3                        ; stop???
    BEQ L350C
    JSR L3402
    LDY #$00
    CMP $13
    BEQ L350A
    INY
    BIT $14
    BMI L350A
    CMP $14
    BNE L34EF
L350A
    CLC
    TYA
L350C
    RTS
---------------------------------
L350D
    LDA $1D
    LDY $1C
L3511
    ASL
    ASL
    ASL
    PHP
    ADC #$10
    STA $D002
    LDA #$00
    ROL
    PLP
    ADC #$00
    ASL
    STA $D010
    TYA
    ASL
    ASL
    ASL
    ADC #$2B
    STA $D003
    RTS
---------------------------------
L352E
    LDA $55
    LDY #$1C
    JSR L3539
    LDA $56
    LDY #$23
L3539
    STA $13
    CMP #$0A
    BCS L3545
    LDA #$20
    STA $0450,Y
    INY
L3545
    LDA #$00
    STA $14
    LDX #$02
    JMP L1AA0
---------------------------------
L354E
    CPX #$19
    BCS L355E
    TXA
    PHA
    LDA #$00
    JSR print_msg                   ; L1AE5
    PLA
    TAX
    INX
    BNE L354E
L355E
    RTS
---------------------------------
; L355F
msg_table
;00
    !tx "Syntaxfehler in Formatzeile",$0D
;01
    !tx "Schnipp",$0D
;02
    !tx "Bereichsfehler",$0D
;03
    !tx $5B,"chtz!",$0d
;04
    !tx "Speicher",$7D,"berlauf",$0D
;05
    !tx "Seitenh",$7B,"lfte (1/2)?",$0D
;06
; Screen row 1 (< PRINTFOX >)
    !by $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
    !by $1E,$1E,$1E,$1C,$1B,$1B,$0F,$10
    !by $11,$12,$13,$14,$15,$16,$17,$18
    !by $19,$1A,$1B,$1B,$1D,$1E,$1E,$1E
    !by $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
    !by $0D
;07
; Screen row 3 (<SEITE 1 von 1>)
    !by $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
    !by $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
    !by $1E,$1E,$1E,$1E,$1E,$1C,$53,$45
    !by $49,$54,$45,$3A,$20,$20,$20,$56
    !by $4F,$4E,$3A,$20,$20,$1D,$1E,$1E
    !by $0D

; 08, $3610
    !tx "Ende markieren, dann RETURN",$0D
; 09, $362C
    !tx "Ziel markieren, dann RETURN",$0D
; 0a, $3648  
    !tx "SPACE=weiter, CRSR/RETURN=Laden",$0D 
; 0b, $3668
    !tx "Befehl:",$0D
; 0c, $3670
    !tx "Freie Zeichen:",$0D
; 0d, $367F
    !tx "F1=Text, F3=Schirm, F5=Rahmen, F7=Mark.",$0D 
; 0e, $36A7
    !tx "<A>lles oder <B>ereich?",$0D
; 0f, $36BF
    !tx "Name:",$0D
; 10, $36C5
    !tx "<G>esamtbild oder <B>ildschirm?",$0D
; 11, $36E5
    !tx "Wirklich beenden (j)?",$0D
; 12, $36FB
    !tx "Mischen (j/n)?",$0D
; 13, $370A
    !tx "ZS",$0D
; 14, $370D
!if VERSION = 1.2 {
    !tx "Zeichensatzdiskette einlegen",$0D
}
!if VERSION = 1.3 {
    !tx "ZS Disk:",$0D
}
; 15, $372A
    !tx "Programmdiskette einlegen",$0D
; 16, $3744
    !tx "Sorry, nichts da",$0D
; 17, $3755
    !tx "Grafik l",$7C,"schen (j/n)?",$0D
; 18, $376B
!if VERSION = 1.2 {
    !tx "Erweiterungsdisk einlegen",$0D
    }
!if VERSION = 1.3 {
    !tx "EW Disk:",$0D
}
; 19, $3785
    !tx "Suchen:",$0D
; 1a, $378D
    !tx "Neu:",$0D
; 1b, $3792
    !tx "Gro",$7E,"/klein beachten (j/n)?",$0D
; 1c, $37AD
    !tx "RETURN=weiter",$0D
; 1d, $37BB
    !tx "RETURN=Ersetzen, SPACE=",$5D,"berspringen",$0D

!if VERSION = 1.3 {
; 1e
    !tx "LW Nr.:",$0D    
}

!if VERSION = 1.2 {
; it seems, that the area from L37DF to L37FF is not used
; -------------------------------
!by $00,$00

L37E1
    ORA $B4
    RTS
L37E4
    CMP #$3A

    BCC L37EA
    ADC #$08
L37EA
    AND #$0F
    RTS
L37ED
    JSR $BC7F
    CMP #$20
    BEQ L37ED
    DEC $D3
    RTS
L37F7
    JSR $FFCF
    DEC $D3
    CMP #$0D
    RTS

    !by $20 
}
; so i have put some new code parts here
; --------------------------------
!if VERSION = 1.3 {
    ; ---------------------------------
chk_dev     ; 26
; at this point, the content of the accu is positive
    STA CBM_STATUS
	TXA
    JSR CBM_LISTN                   ; LISTEN
    LDA #$ff                        ; Secondary address - $0f OR'ed with $f0 to open
    JSR CBM_SECND                   ; opens the channel with sa of 15
  	JSR CBM_UNLSN                   ; UNLISTEN
	LDA CBM_STATUS                  ; what happened?

    BPL next
    PLA                             ; for saved device number

    PLA
    PLA
exit
    PLP
    PLA
next
 	RTS

; ---------------------------------
printlw     ; 20
    LDY #$00
    LDA $0423
    CMP #$30
    BEQ +
    STA $0430,Y
    INY
+   LDA $0424
    STA $0430,Y
    RTS

; ---------------------------------
ask_print       ; 10
    JSR L0AA3
    LDA #$00
    STA $39
    JMP askdevice

store_BA
    LDA #$08
    LDX $BA
    RTS
}

*=$3800

; the char set must start at $3800

; control and header char set   
    !by $00,$00,$38,$7C,$7C,$7C,$38,$00
    !by $00,$00,$38,$7C,$7C,$7C,$38,$00
    !by $FF,$F1,$E7,$C1,$E7,$E7,$E7,$00
    !by $FF,$9F,$9F,$83,$99,$99,$83,$00
    !by $FF,$FF,$C3,$99,$81,$9F,$C3,$00
    !by $FF,$FF,$99,$99,$99,$99,$C1,$00
    !by $FF,$FF,$C3,$9F,$9F,$9F,$C3,$00
    !by $FF,$E7,$81,$E7,$E7,$E7,$F1,$00
    !by $FF,$E7,$FF,$C7,$E7,$E7,$C3,$00
    !by $C3,$99,$F9,$F3,$E7,$FF,$E7,$00
    !by $FF,$DF,$9F,$01,$01,$9F,$DF,$00
    !by $E7,$C3,$81,$E7,$E7,$E7,$E7,$00
    !by $E7,$E7,$E7,$E7,$81,$C3,$E7,$00
    !by $10,$3F,$7F,$FF,$7F,$3F,$10,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00
    !by $FF,$C0,$CF,$CF,$C0,$CF,$CF,$FF
    !by $FF,$1E,$CE,$CE,$1E,$FE,$FE,$FF
    !by $FF,$00,$7E,$7E,$00,$71,$7C,$FF
    !by $FF,$F3,$73,$73,$F3,$F3,$73,$FF
    !by $FF,$9F,$87,$91,$9C,$9F,$9F,$FF
    !by $FF,$CE,$CF,$CF,$4F,$0F,$CF,$FF
    !by $FF,$00,$E7,$E7,$E7,$E7,$E7,$FF
    !by $FF,$70,$F3,$F3,$F0,$F3,$F3,$FF
    !by $FF,$07,$FF,$FF,$1F,$FF,$FF,$FF
    !by $FF,$80,$3E,$3E,$3E,$3E,$80,$FF
    !by $FF,$F1,$7C,$7E,$7E,$7C,$F1,$FF
    !by $FF,$E3,$CF,$1F,$1F,$CF,$E3,$FF
    !by $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !by $03,$0F,$3F,$FF,$FF,$3F,$0F,$03
    !by $C0,$F0,$FC,$FF,$FF,$FC,$F0,$C0
    !by $00,$00,$00,$FF,$FF,$00,$00,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00
    
; numbers
; $3900
    !by $00,$00,$00,$00,$00,$00,$08,$00
    !by $18,$18,$18,$18,$00,$00,$18,$00
    !by $66,$66,$66,$00,$00,$00,$00,$00
    !by $66,$66,$FF,$66,$FF,$66,$66,$00
    !by $18,$3E,$60,$3C,$06,$7C,$18,$00
    !by $62,$66,$0C,$18,$30,$66,$46,$00
    !by $3C,$66,$3C,$38,$67,$66,$3F,$00
    !by $06,$0C,$18,$00,$00,$00,$00,$00
    !by $0C,$18,$30,$30,$30,$18,$0C,$00
    !by $30,$18,$0C,$0C,$0C,$18,$30,$00
    !by $00,$66,$3C,$FF,$3C,$66,$00,$00
    !by $00,$18,$18,$7E,$18,$18,$00,$00
    !by $00,$00,$00,$00,$00,$18,$18,$30
    !by $00,$00,$00,$7E,$00,$00,$00,$00
    !by $00,$00,$00,$00,$00,$18,$18,$00
    !by $00,$03,$06,$0C,$18,$30,$60,$00
    !by $3C,$66,$6E,$76,$66,$66,$3C,$00
    !by $18,$38,$18,$18,$18,$18,$7E,$00
    !by $3C,$66,$06,$0C,$30,$60,$7E,$00
    !by $3C,$66,$06,$1C,$06,$66,$3C,$00
    !by $06,$0E,$1E,$66,$7F,$06,$06,$00
    !by $7E,$60,$7C,$06,$06,$66,$3C,$00
    !by $1C,$30,$60,$7C,$66,$66,$3C,$00
    !by $7E,$66,$06,$0C,$18,$18,$18,$00
    !by $3C,$66,$66,$3C,$66,$66,$3C,$00
    !by $3C,$66,$66,$3E,$06,$0C,$38,$00
    !by $00,$00,$18,$00,$00,$18,$00,$00
    !by $00,$00,$18,$00,$00,$18,$18,$30
    !by $0E,$18,$30,$60,$30,$18,$0E,$00
    !by $00,$00,$7E,$00,$7E,$00,$00,$00
    !by $70,$18,$0C,$06,$0C,$18,$70,$00
    !by $3C,$66,$06,$0C,$18,$00,$18,$00
    
; German char set
; $3A00
    !by $3C,$60,$3C,$66,$3C,$06,$3C,$00
    !by $18,$3C,$66,$66,$7E,$66,$66,$00
    !by $7C,$66,$66,$7C,$66,$66,$7C,$00
    !by $3C,$66,$60,$60,$60,$66,$3C,$00
    !by $78,$6C,$66,$66,$66,$6C,$78,$00
    !by $7E,$60,$60,$78,$60,$60,$7E,$00
    !by $7E,$60,$60,$78,$60,$60,$60,$00
    !by $3C,$66,$60,$6E,$66,$66,$3C,$00
    !by $66,$66,$66,$7E,$66,$66,$66,$00
    !by $3C,$18,$18,$18,$18,$18,$3C,$00
    !by $1E,$0C,$0C,$0C,$0C,$6C,$38,$00
    !by $66,$6C,$78,$70,$78,$6C,$66,$00
    !by $60,$60,$60,$60,$60,$60,$7E,$00
    !by $63,$77,$7F,$6B,$63,$63,$63,$00
    !by $66,$76,$7E,$7E,$6E,$66,$66,$00
    !by $3C,$66,$66,$66,$66,$66,$3C,$00
    !by $7C,$66,$66,$7C,$60,$60,$60,$00
    !by $3C,$66,$66,$66,$66,$6A,$3C,$06
    !by $7C,$66,$66,$7C,$78,$6C,$66,$00
    !by $3C,$66,$60,$3C,$06,$66,$3C,$00
    !by $7E,$18,$18,$18,$18,$18,$18,$00
    !by $66,$66,$66,$66,$66,$66,$3C,$00
    !by $63,$63,$36,$36,$1C,$1C,$08,$00
    !by $63,$63,$63,$6B,$7F,$77,$63,$00
    !by $66,$66,$3C,$18,$3C,$66,$66,$00
    !by $66,$66,$66,$3C,$18,$18,$18,$00
    !by $7E,$06,$0C,$18,$30,$60,$7E,$00
    !by $66,$18,$3C,$66,$7E,$66,$66,$00
    !by $66,$3C,$66,$66,$66,$66,$3C,$00
    !by $66,$00,$66,$66,$66,$66,$3C,$00
    !by $18,$3C,$7E,$18,$18,$18,$18,$00
    !by $00,$20,$60,$FE,$FE,$60,$20,$00
    !by $3C,$66,$6E,$6E,$60,$62,$3C,$00
    !by $00,$00,$3C,$06,$3E,$66,$3E,$00
    !by $00,$60,$60,$7C,$66,$66,$7C,$00
    !by $00,$00,$3C,$60,$60,$60,$3C,$00
    !by $00,$06,$06,$3E,$66,$66,$3E,$00
    !by $00,$00,$3C,$66,$7E,$60,$3C,$00
    !by $00,$0E,$18,$3E,$18,$18,$18,$00
    !by $00,$00,$3E,$66,$66,$3E,$06,$7C
    !by $00,$60,$60,$7C,$66,$66,$66,$00
    !by $00,$18,$00,$38,$18,$18,$3C,$00
    !by $00,$06,$00,$06,$06,$06,$06,$3C
    !by $00,$60,$60,$6C,$78,$6C,$66,$00
    !by $00,$38,$18,$18,$18,$18,$3C,$00
    !by $00,$00,$66,$7F,$7F,$6B,$63,$00
    !by $00,$00,$7C,$66,$66,$66,$66,$00
    !by $00,$00,$3C,$66,$66,$66,$3C,$00
    !by $00,$00,$7C,$66,$66,$7C,$60,$60
    !by $00,$00,$3E,$66,$66,$3E,$06,$06
    !by $00,$00,$7C,$66,$60,$60,$60,$00
    !by $00,$00,$3E,$60,$3C,$06,$7C,$00
    !by $00,$18,$7E,$18,$18,$18,$0E,$00
    !by $00,$00,$66,$66,$66,$66,$3E,$00
    !by $00,$00,$66,$66,$66,$3C,$18,$00
    !by $00,$00,$63,$6B,$7F,$3E,$36,$00
    !by $00,$00,$66,$3C,$18,$3C,$66,$00
    !by $00,$00,$66,$66,$66,$3E,$0C,$78
    !by $00,$00,$7E,$0C,$18,$30,$7E,$00
    !by $66,$00,$3C,$06,$3E,$66,$3E,$00
    !by $66,$00,$3C,$66,$66,$66,$3C,$00
    !by $66,$00,$00,$66,$66,$66,$3E,$00
    !by $3C,$66,$66,$6C,$6E,$66,$6C,$60
    !by $00,$00,$00,$00,$00,$00,$7F,$00
    
; international char set
; $3C00
    !by $00,$00,$00,$7E,$00,$00,$7E,$00
    !by $00,$00,$00,$00,$00,$66,$66,$66
    !by $18,$0C,$3C,$06,$3E,$66,$3E,$00
    !by $18,$0C,$3C,$66,$7E,$60,$3C,$00
    !by $30,$18,$00,$38,$18,$18,$3C,$00
    !by $18,$0C,$3C,$66,$66,$66,$3C,$00
    !by $18,$0C,$66,$66,$66,$66,$3E,$00
    !by $00,$00,$3C,$60,$60,$3C,$18,$30
    !by $3B,$6E,$00,$7C,$66,$66,$66,$00
    !by $18,$00,$18,$30,$60,$66,$3C,$00
    !by $18,$00,$00,$18,$18,$18,$18,$00
    !by $D8,$6C,$36,$1B,$36,$6C,$D8,$00
    !by $1B,$36,$6C,$D8,$6C,$36,$1B,$00
    !by $00,$04,$06,$7F,$7F,$06,$04,$00
    !by $18,$18,$18,$18,$7E,$3C,$18,$00
    !by $3C,$30,$30,$30,$30,$30,$3C,$00
    !by $3C,$0C,$0C,$0C,$0C,$0C,$3C,$00
    !by $0C,$12,$30,$7C,$30,$62,$FC,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00
    !by $00,$00,$00,$00,$00,$00,$00,$00

; -------------------------------
; v1.3
; some new code part is placed here
; it will also reduce the available text memory
; -------------------------------
!if VERSION = 1.3 {
ask_tsave
    LDY $54
    STX $29
    STY $2A
    JMP askdevice

ask_tload
    JSR askdevice
    BCS +
    JMP L245F
+   PLA
    PLA
    JMP L237B-2

ask_gsave    ; 24 + 64
    JSR L1B89
    BCS back
    PHP
    PHA
    JSR askdevice
    PLA
    PLP
    RTS

ask_gload
    JSR askdevice
    BCC +
    JMP L0C36
+   JMP L1B8C

askdevice   ; 64
    LDA #$1e
    JSR L1B16                       ; print msg. ("LW Nr.:")
    LDY #$00
    JSR printlw
    JSR L342B                       ; get input, and print on screen
    PHA
    PHP
; evaluate input from screen
    LDA $0430
    CMP #$31
    BNE +                           ; not 1, then go and check for 8 or 9
    LDA $0431                       ; else get 2. char from screen
    CMP #$3A                        ; limit to 19
    BCS +++                         ; higher, then return witout evaluation
    CMP #$30                        ; compare with 10 as smallest 2 digit number
    BCC +++                         ; less then return without evaluation
; here the content is now 30 - 39 > LW 10 - 19
    SBC #$26                        ; reduce to set to $0a - $13  
    BNE ++                          ; (jmp)

; handle the first digit, test for 8 or 9
+   CMP #$3A                        ; check if higher then 9
    BCS +++                         ; higher, then return witout evaluation
    CMP #$38                        ; compare with 8
    BCC +++                         ; less then return without evaluation
    SBC #$30                        ; adjust to $08 or $09
; here the content is now $08 or $09

; jump in from 2 digit number
++  PHA                             ; save device No.
    TAX
    JSR chk_dev
; if the device exists, get back the device number
    PLA                             ; restore device No.
    STA $BA                         ; set as new device number
    
; print the device number to the screen
    JSR prepline1+3

; finish and go back
;    LDX #$1e                        ; load msg number for "OK"
    JMP exit                        ; print 'OK' and go back

; restore the stack, and go back without evaluation
+++ PLP
    PLA
back
    RTS

; ---------------------------------
L6000       ; 10
    LDA $BA
    PHA
    JSR $6000
    PLA
    STA $BA
    RTS
}
; -------------------------------
; end of new code part v1.3
; -------------------------------

textstart
    !by $00,$00

; -------------------------------
; Here is the start of the text memory
; The following code part is called only one time at start-up,
; everything after here will be overwritten by text input.
; -------------------------------

Init_PF
    LDA #$00
    STA $D021
    LDA #$06
    STA $D020
    LDA #$03
    STA $7A
    LDA #$01
    STA $7B
    LDA #$0F
    STA $35
    JSR L0818                       ; JMP L1A6F  (fill area $7F40 to 7F7F with $00)
    LDX #$0D
--  LDA L3D2F,X
    STA $2B,X
    DEX
    BPL --
    LDA #$00
    STA $7C
    LDX #<L3D3D                     ; "foxcol"
    LDY #>L3D3D
    LDA #$06
    JSR CBM_SETNAM                  ; Set file name
    LDY #$00
    JSR L2582                       ; set file parameter and open
    JSR CBM_CHRIN                   ; Input Vector
    LDX $90                         ; check status
    BNE L3D03                       ; branch if the file was not found
    STA $7A
    JSR CBM_CHRIN                   ; Input Vector
    STA $D021
    JSR CBM_CHRIN                   ; Input Vector
    STA $D020
    JSR CBM_CHRIN                   ; Input Vector
    STA $7B
    JSR CBM_CHRIN                   ; Input Vector
    ASL
    ASL
    ASL
    ASL
    STA $15
    JSR CBM_CHRIN                   ; Input Vector
    AND #$0F
    ORA $15
    STA $35
L3D03
    JSR L25A7                       ; restore i/o and close
    LDA #$00
    JSR L2545
    JSR L30A8
    LDA #$00
    STA $033E
    STA $035F
    LDX #$FE
    TXS
    JSR L300B
    LDX #<L3D43
    LDY #>L3D43
    STX $03
    STY $04
    LDX #$05
    JSR L1FF5
    JSR L0815
    JMP L1BA1
---------------------------------
L3D2F
    !by $00,$AE,$00,$8C,$00,$00,$00,$00
    !by $00,$00,$0F,$AE,$00,$8C

L3D3D
    !tx "FOXCOL"

L3D43
    !by $0D
    !by $0D
    !tx $0D,"                PRINTFOX                "
    !tx $0D,"        Der schlaue Druckerfuchs        "
!if VERSION = 1.2 {
    !tx $0D,"                  V1.2                  "
    !by $0D
    !tx $0D,"            von  Hans Haberl            "
}    
!if VERSION = 1.3 {
    !tx $0D,"            von  Hans Haberl            "
    !by $0D
    !tx $0D,"            V1.3 (b1) by C.S.           "
}

    !by $0D
    !tx $0D,"        (C) 1987 by  SCANNTRONIK        "

    !by $00,$00



