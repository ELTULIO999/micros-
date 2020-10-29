; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
    #INCLUDE "p16f887.inc"
; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;-----------------------------------------------------------------------------
 
 GPR_VAR  UDATA 
 CONT_A       RES 1
 CONTADOR_1S  RES 1
 CONTADOR     RES 1 
 TEMP1        RES 1
 TEMP2        RES 1
 CONTDE_4     RES 1
  ; VARIABLES TEPORALES 
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
 

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************TODO ADD INTERRUPTS HERE IF USED
ISR_VEC CODE 0X004
 
 PUSH:
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
 ISR:
 POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
RETFIE
;---------------------------SUB_RUTINAD_INTERUPSION__________
 
SEV_SEG:
    
    ANDLW B'00001111';0-F
    ADDWF PCL, F
    RETLW B'01110111';0
    RETLW B'01000001';1
    RETLW B'00111011';2
    RETLW B'01101011';3
    RETLW B'01001101';4
    RETLW B'01101110';5
    RETLW B'01111110';6
    RETLW B'01000011';7
    RETLW B'01111111';8
    RETLW B'00011111';9
    ;RETLW B'01011111';A
    ;RETLW B'01111100';b
    ;RETLW B'00110110';C
    ;RETLW B'01111001';d
    ;RETLW B'00111110';E
    ;RETLW B'00011110';F
 
MAIN_PROG CODE       0X100              ;
CALL   CONFIG_IO
CALL   CONFIG_TIMER0
CALL   CONFIG_FLAG
 

 GOTO LOOP  
;*************************************loop forever******************************
;*******************************************************************************
 LOOP:
    
 
 
    GOTO START                         

    
    
;*******************************************************************************    
;**********************************OPERACIONES**********************************
 CONFIG_TIMER0
 BANKSEL TRISA
 BCF OPTION_REG , T0CS
 BCF OPTION_REG , PSA
 BSF OPTION_REG , PS2
 BSF OPTION_REG , PS1
 BCF OPTION_REG , PS0
 BANKSEL PORTA
 MOVLW .60
 MOVWF TMR0
 BCF INTCON, T0IF
 RETURN
CONFIG_FLAG
 BSF  INTCON, GIE
 BSF  INTCON, T0IE
 BCF  INTCON, T0IF 
 RETURN 
 
  DISPLAY_D1
 BCF   PORTD, RD0
 SWAPF  CONT_A, W
 MOVWF TEMP1
 MOVLW 0X0F
 ANDWF TEMP1, W
 CALL SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD1
 RETURN
 
 DISPLAY_D2
 BCF   PORTD, RD1
 MOVLW 0X0F
 ANDWF CONT_A,W
 CALL  SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD0
 RETURN    
    
    
    
 
CONFIG_IO
    BANKSEL TRISA
    
    MOVLW   B'0000000'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
  
    BANKSEL TRISB
    MOVLW   B'0000000'
    MOVWF   TRISB
    BANKSEL PORTB
    CLRF    PORTB
    
    BANKSEL TRISC
    MOVLW   B'00000000'
    MOVWF   TRISC
    BANKSEL PORTC
    CLRF    PORTC
    
    BANKSEL TRISD
    MOVLW   B'00000000'
    MOVWF   TRISD
    BANKSEL PORTD
    CLRF    PORTD
    
    RETURN
END