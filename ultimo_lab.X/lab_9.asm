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
 DATA_EE_ADDR EQU 0X00
 
 GPR_VAR  UDATA 
 CONT         RES 1 ;IN USE 	 
;//////////////////////////////////////////////////////////////////////////////
	 ;VAR DE TIMER 
;//////////////////////////////////////////////////////////////////////////////
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
	 
;******************************************************************************
;******************************************************************************
	 RES_VECT  CODE    0x0000            ; processor reset vector
 GOTO    START                   ; go to beginning of program
;**************TODO ADD INTERRUPTS HERE IF USED********************************
ISR_VEC CODE 0X004

	 
	 
    MAIN_PROG CODE       0X100   
START
BCF OPTION_REG , 7
CALL    CONFIG_IO
CALL    CONFIG_FLAG
CALL    CONFUG_OSC
CALL    CONFUG_ADC
BANKSEL PORTA 
CLRF    CONT
CLRF    W_TEMP       
CLRF    STATUS_TEMP   
 
CALL    R2_MEM
 
GOTO    LOOP
LOOP:
    BSF   ADCON0,GO
    BTFSC ADCON0,GO
    GOTO$-1
    MOVF ADRESH, W
    MOVWF PORTB
    MOVWF CONT
    CALL SAVE_THAT_SHIT
GOTO LOOP
    
SAVE_THAT_SHIT
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA3
  RETURN 
  BTFSC  PORTA , RA3
  GOTO $-1
  MOVFW CONT 
  MOVWF PORTD
  CALL W2_MEM
RETURN 
  
W_MEM:
   BANKSEL EEADR 
   MOVLW DATA_EE_ADDR 
   MOVWF EEADR          ;Data Memory Address to write
   
   MOVLW CONT ;
   
   MOVWF EEDAT          ;Data Memory Value to write
   BANKSEL EECON1 ;
   BCF EECON1, EEPGD     ;Point to DATA memory
   BSF EECON1, WREN      ;Enable writes
   BCF INTCON, GIE       ;Disable INTs.
   BTFSC INTCON, GIE     ;SEE AN576
   GOTO $-2
   MOVLW 0x55 ;
   MOVWF EECON2 ;Write 55h
   MOVLW 0XAA  ;
   MOVWF EECON2 ;Write AAh
   BSF EECON1, WR ;Set WR bit to begin write
   BSF INTCON, GIE ;Enable INTs.
   SLEEP ;Wait for interrupt to signal write complete
   BCF EECON1, WREN ;Disable writes
   BCF STATUS, RP0 ;Bank 0
   BCF STATUS, RP1
RETURN
   
W2_MEM:
    BANKSEL EEADR
    MOVLW .0
    MOVWF EEADR
    BANKSEL PORTA
    MOVFW CONT
    BANKSEL EEDAT
    MOVWF   EEDAT
    BANKSEL EECON1
    BCF EECON1,EEPGD
    BSF EECON1,WREN
    BCF INTCON, GIE
    MOVLW 0x55 
    MOVWF EECON2 ;Write 55h
    MOVLW 0XAA  
    MOVWF EECON2 
    BSF EECON1, WR
    BSF INTCON, GIE 
    
    BCF EECON1, WREN 
    BANKSEL PORTA   
RETURN 
  
R_MEM:
    BANKSEL EEADR ;
    MOVLW   DATA_EE_ADDR ;
    MOVWF   EEADR        ;Data Memory
                         ;Address to read
    BANKSEL EECON1 ;
    BCF     EECON1, EEPGD ;Point to DATA memory
    BSF     EECON1, RD    ;EE Read
    BANKSEL EEDAT ;
    MOVF    EEDAT, W ;W = EEDAT
    MOVWF PORTD	
    BCF     STATUS, RP1 ;Bank 0	   
RETURN 
  
 R2_MEM:
    BCF INTCON, GIE 
    MOVLW .0
    BANKSEL EEADR
    MOVWF   EEADR
    BANKSEL EECON1
    BCF     EECON1, EEPGD
    BSF     EECON1, RD
    BANKSEL EEDATA
    MOVFW   EEDATA
    BANKSEL PORTA
    MOVWF   PORTD
    BSF     INTCON, GIE 
RETURN 
  
 
 
CONFUG_OSC:
    BANKSEL OSCCON
    MOVLW B'01100001'
    MOVWF OSCCON
    RETURN
CONFUG_ADC:
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
    MOVLW   B'00001001'
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
END