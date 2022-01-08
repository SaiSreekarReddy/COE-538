;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

; code
 org $4000
;starting the program
Entry:
_Startup:
;assignment 7.1

          LDAA #$FF    ; ACCA = $FF
          STAA DDRH    ; config. port H for support
          STAA PERT    ; Enab. pull-up res. of port T

 Loop:    LDAA PTT     ; Read port T
          STAA PTH     ; Display Swi on LED1 connected to port H
          BRA  Loop    ; Loop
      
      
                   
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
