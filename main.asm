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



            
 ; Insert here your data definition.
OneSec EQU 23 ; 1 second delay (at 23Hz)
TwoSec EQU 46 ; 2 second delay (at 23Hz)
LCD_DAT EQU PORTB ; LCD data port, bits - PB7,...,PB0
LCD_CNTR EQU PTJ ; LCD control port, bits - PJ7(E),PJ6(RS)
LCD_E EQU $80 ; LCD E-signal pin
LCD_RS EQU $40 ; LCD RS-signal pin

;variable/data section
  ORG $3850 ; Where our TOF counter register lives
TOF_COUNTER RMB 1 ; The timer, incremented at 23Hz
AT_DEMO RMB 1 ; The alarm time for this demo


; code section
            ORG   $4000           ; Where the code starts

Entry:
_Startup:
 LDS #$4000 ; initialize the stack pointer
 JSR initLCD ; initialize the LCD
 JSR clrLCD ; clear LCD & home cursor
 JSR ENABLE_TOF ; Jump to TOF initialization
 CLI ; Enable global interrupt
 LDAA #'A' ; Display A (for 1 sec)
 JSR putcLCD ; --"--
 LDAA TOF_COUNTER ; Initialize the alarm time
 ADDA #OneSec ; by adding on the 1 sec delay
 STAA AT_DEMO ; and save it in the alarm
CHK_DELAY_1 LDAA TOF_COUNTER ; If the current time
 CMPA AT_DEMO ; equals the alarm time
 BEQ A1 ; then display B
 BRA CHK_DELAY_1 ; and check the alarm again
A1 LDAA #'B' ; Display B (for 2 sec)
 JSR putcLCD ; --"--
 LDAA AT_DEMO ; Initialize the alarm time
 ADDA #TwoSec ; by adding on the 2 sec delay
 STAA AT_DEMO ; and save it in the alarm
CHK_DELAY_2 LDAA TOF_COUNTER ; If the current time
 CMPA AT_DEMO ; equals the alarm time
 BEQ A2 ; then display C
 BRA CHK_DELAY_2 ; and check the alarm again
A2 LDAA #'C' ; Display C (forever)
 JSR putcLCD ; --"--
 SWI
;subroutine section
; same as in lab3
initLCD BSET DDRB,%11111111 ; FIGURING OUT WHICH PINS ARE BEING USED FOR OUTPUT IN PS4 TO PS7
        BSET DDRJ,%11000000 ; FIGURING OUT WHICH PINS ARE BEING USED FOR OUTPUT IN PS4 AND PS7 
        LDY #2000 ; WAIT FOR LCD TO GET READY
        JSR del_50us   ; 
        LDAA #$28 ;SETTING 4 BIT DATA AND THE 2 LINE DISPLAY
        JSR cmd2LCD ;
        LDAA #$0C ; DISPLAY SHOULD BE ON AND THE CURSOR AND THE BLINKING SHOULD BE OFF
        JSR cmd2LCD
        LDAA #$06 ;THE CURSOR SHOULD BE MOVED RIGHT AFTER TYPING A CHARACTER
        JSR cmd2LCD;
        RTS
        
          
clrLCD LDAA #$01 ;THE CURSOR IS CLEARED AND WILL RETURN TO THE DEFAULT POSITION
       JSR cmd2LCD ;
       LDY #40    ;SHOULD WAIT UNTILL THE CLEAR CURSOR COMMAND IS EXECUTED
       JSR del_50us ;
       RTS
       
       
       
del_50us: PSHX ;
eloop:    LDX #30;
iloop:    PSHA  ;2
          PULA  ;3
          PSHA  ;2, 50us
          PULA  ;3
          PSHA  ;2
          PULA  ;3
          PSHA  ;2
          PULA  ;3
          PSHA  ;2
          PULA  ;3
          PSHA  ;2
          PULA  ;3
          
          
          NOP;1
          NOP;1
          DBNE X,iloop ;3
          DBNE Y,eloop ;3
          PULX ;3
          RTS;
                      
cmd2LCD BCLR LCD_CNTR,LCD_RS ;
        JSR dataMov ;
        RTS

putcLCD BSET LCD_CNTR,LCD_RS
        JSR dataMov
        RTS; --"--
dataMov BSET LCD_CNTR,LCD_E ; PULLING the LCD'S E-sigal high
        STAA LCD_DAT ; SENDING THE UPPER 4 BIT's OF THE DATA TO LCD
        BCLR LCD_CNTR,LCD_E ; pull the LCD E-signal low to complete the write oper.
        LSLA ; MATCHING THE LOWER 4 BITS WITH THE LCD DATA PINS
        LSLA ; 
        LSLA ; 
        LSLA ; 
        BSET LCD_CNTR,LCD_E ; PULLING the LCD'S E-sigal high
        STAA LCD_DAT ; send the lower 4 bits of data to LCD
        BCLR LCD_CNTR,LCD_E ; pull the LCD E-signal low to complete the write oper.
        LDY #1 ; adding this delay will complete the internal
        JSR del_50us ; operation for most instructions
        RTS; --"--
ENABLE_TOF LDAA #%10000000        ; same as in Appendix B of this lab

 STAA TSCR1 ; Enable TCNT
 STAA TFLG2 ; Clear TOF
 LDAA #%10000100 ; Enable TOI and select prescale factor equal to 16
 STAA TSCR2
 RTS
TOF_ISR INC TOF_COUNTER
 LDAA #%10000000 ; Clear
 STAA TFLG2 ; TOF
 RTI
; --"--
**** Interrupt Vectors ***** ; --"--
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            
            ORG  $FFDE
            DC.W TOF_ISR 
