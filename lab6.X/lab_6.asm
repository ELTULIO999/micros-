;*******************************************************************************
;                                                                              *
;    Filename: julio lopez                                                     *
;    Date:     9/29/2020                                                        *
;    File Version:                                                             *
;    Author:                                                                   *
;    Company:                                                                  *
;    Description:                                                              *
;                            HORAS  CON ITERMITENTES                                                   *
;*******************************************************************************
;
;    TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
    #INCLUDE "p16f887.inc"
; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;-----------------------------------------------------------------------------
 ;-----------------------------------------------------------------------------
 
 GPR_VAR  UDATA 
 CONT         RES 1 ;IN USE 
 CONT1         RES 1 ;IN USE 
 CONT2         RES 1 ;IN USE 
 TEMP         RES 1 ;IN USE 
 TEMP1         RES 1 ;IN USE 
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
	 
;******************************************************************************
;******************************************************************************
	 RES_VECT  CODE    0x0000            ; processor reset vector
 GOTO    START                   ; go to beginning of program
;**************TODO ADD INTERRUPTS HERE IF USED********************************
ISR_VEC CODE 0X004
 PUSH:
    BCF   INTCON, GIE
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
 ISR:
    BTFSC PIR1, TMR2IF
    CALL FUE_TIMR2
    BTFSC PIR1, TMR1IF
    CALL FUE_TIMR1  
    BTFSS INTCON, T0IF 
    GOTO POP    
    CALL FUE_TIMR0
 POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    BSF   INTCON, GIE 
RETFIE
;//////////////////////////////SUBRUTINAS DE TIMERS/////////////////////////////
FUE_TIMR0
    BTFSS INTCON, T0IF 
    GOTO POP
    MOVLW .6
    MOVWF TMR0
    BCF INTCON, T0IF
    CALL DISPLAY_D2
    CALL DISPLAY_D1
    
    
    RETURN 
FUE_TIMR1
    MOVLW .207  ;PRESCALER HIGH 
    MOVWF TMR1H
    MOVLW .38  ;PRESCALER LOW
    MOVWF TMR1L
    BCF  PIR1, TMR1IF
    
    RETURN 
FUE_TIMR2
    CLRF TMR2
    BCF PIR1, TMR2IF
    INCF CONT1
    RETURN 
 ;/////////////////////////////////////////////////////////////////////////////	 
	 
SEV_SEG:
    ADDWF PCL, F
    RETLW B'01110111';0
    RETLW B'00010100';1
    RETLW B'10110011';2
    RETLW B'10110110';3
    RETLW B'11010100';4
    RETLW B'11100110';5
    RETLW B'11100111';6
    RETLW B'00110100';7
    RETLW B'11110111';8
    RETLW B'11110100';9                                                                                                                              
    RETLW B'11110101';A
    RETLW B'11000111';b
    RETLW B'01100011';C
    RETLW B'10010111';d
    RETLW B'11100011';E
    RETLW B'11100001';F
    MAIN_PROG CODE       0X100   
START
BCF OPTION_REG , 7
CALL    CONFIG_IO
CALL    CONFIG_TIMER0
CALL    CONFIG_TIMER1
CALL    CONFIG_TIMER2
CALL    CONFIG_FLAG
CALL    CONFUG_OSC
CALL    CONFUG_ADC
 
BANKSEL PORTA 
CLRF    CONT
CLRF    CONT1
CLRF    CONT2
CLRF    TEMP
CLRF    TEMP1
 CLRF W_TEMP       
 CLRF STATUS_TEMP  
GOTO    LOOP
LOOP:
    CALL DELAY
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO$-1
    MOVF ADRESH, W
    MOVWF CONT
    MOVWF PORTB
    CLRF CONT1
    
GOTO LOOP
 
CONFUG_OSC:
    BANKSEL OSCCON
    MOVLW B'01100001'
    MOVWF OSCCON
    RETURN
CONFUG_ADC:
CONFIG_ADC
    BANKSEL PORTA
    BCF ADCON0, ADCS1
    BSF ADCON0, ADCS0		; FOSC/8 RELOJ TAD
    BCF ADCON0, CHS3		; CANAL 0 PARA LA CONVERSION
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BCF ADCON0, CHS0	
    BANKSEL TRISA
    BCF ADCON1, ADFM		; JUSTIFICACIÓN A LA IZQUIERDA
    BCF ADCON1, VCFG1		; VSS COMO REFERENCIA VREF-
    BCF ADCON1, VCFG0		; VDD COMO REFERENCIA VREF+
    BANKSEL PORTA
    BSF ADCON0, ADON		; ENCIENDO EL MÓDULO ADC
    RETURN

    
    
DISPLAY_D1
 BCF   PORTD, RD0
 SWAPF  CONT, W
 MOVWF TEMP
 MOVLW 0X0F
 ANDWF TEMP, W
 CALL SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD1
 RETURN 
 DISPLAY_D2
 BCF   PORTD, RD1
 MOVLW 0X0F
 ANDWF CONT,W
 CALL  SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD0
 RETURN 
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 CONFIG_FLAG
 BSF  INTCON, GIE
 BSF  INTCON, T0IE
 BCF  INTCON, T0IF 
 BANKSEL TRISA 
 BSF     PIE1, TMR1IE
 BSF     PIE1, TMR2IE 
 BANKSEL PORTA
 BSF     INTCON, GIE
 BSF     INTCON, PEIE
 BCF     PIR1, TMR1IF
 BCF     PIR1, TMR2IF 
 RETURN 
  CONFIG_TIMER0
 BANKSEL TRISA
 BCF OPTION_REG , T0CS
 BCF OPTION_REG , PSA
 BCF OPTION_REG , PS2
 BSF OPTION_REG , PS1
 BCF OPTION_REG , PS0
 BANKSEL PORTA
 MOVLW   .6
 MOVWF   TMR0
 BCF INTCON, T0IF
 RETURN
CONFIG_TIMER1
 BANKSEL   PORTA
 BCF T1CON, TMR1GE
 BSF T1CON, T1CKPS1 ;PRESCALER 
 BSF T1CON, T1CKPS0 ;PRESCALER 
 BCF T1CON, T1OSCEN ;TIMER INTERNO  
 BCF T1CON, TMR1CS 
 BSF T1CON, TMR1ON 
 MOVLW .207  ;PRESCALER HIGH 
 MOVWF TMR1H
 MOVLW .38  ;PRESCALER LOW
 MOVWF TMR1L
 BCF PIR1, TMR1IF
RETURN 
CONFIG_TIMER2
 BANKSEL PORTA
 MOVLW   B'00100101'
 MOVWF   T2CON
 BANKSEL TRISA
 MOVLW   .1
 MOVWF   PR2
 BANKSEL PORTA
 CLRF    TMR2
 BCF     PIR1, TMR2IF
RETURN 
 ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 CONFIG_IO
    BANKSEL TRISA
    MOVLW   B'00000001'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
    BSF ANSEL, ANS0
    BANKSEL TRISB
    MOVLW   B'00000000'
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
     
     ;DELAY
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
    RETURN 
     
DELAY_SMALL
    MOVLW .20
    MOVFW CONT1
    DECFSZ CONT1, F
               GOTO $-1 ;IR A PC - 1, REGRESAR A DECFSZ
 RETURN
DELAYM
    MOVLW .20
    MOVWF CONT2
CONFIG1:    
    CALL DELAY_SMALL
    DECFSZ CONT2, F
    GOTO CONFIG1
    RETURN
DELAY
MOVF CONT1,W
SUBLW .1
BTFSC STATUS,Z
RETURN 
GOTO $-4
END