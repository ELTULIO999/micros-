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
 TEMP         RES 1 ;IN USE 
 TEMP1         RES 1 ;IN USE 
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
	 
;******************************************************************************
;******************************************************************************
	 RES_VECT  CODE    0x0000            ; processor reset vector
 GOTO    START                   ; go to beginning of program
;**************TODO ADD INTERRUPTS HERE IF USED******************************** 
MAIN_PROG CODE       0X100   
START
BCF OPTION_REG , 7
CALL    CONFIG_IO
CALL    CONFIG_OSC
CALL    CONFIG_ADC
CALL    CONFIG_MASTER
BSF PORTB, RB2
 
BANKSEL PORTA 
CLRF    CONT
CLRF    TEMP
CLRF    TEMP1
CLRF    W_TEMP       
CLRF    STATUS_TEMP  
GOTO    LOOP
LOOP:
    CALL DELAY
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO$-1
    MOVF ADRESH, W
    MOVWF TEMP
    CALL SEND  
GOTO LOOP
CONFIG_MASTER
        BCF TXSTA, SYNC
        BSF TXSTA, BRGH
	BANKSEL BAUDCTL
	BSF BAUDCTL, BRG16
	BANKSEL SPBRG
	MOVLW .51
	MOVWF SPBRG
	CLRF SPBRGH
	BANKSEL RCSTA
	BSF RCSTA, SPEN
	BCF RCSTA, CREN
	BANKSEL TXSTA
	BCF TXSTA, TX9
	BSF TXSTA, TXEN
	BANKSEL PORTD
	CLRF PORTD
 RETURN 
SEND:
    BTFSS PIR1,TXIF
    GOTO SEND
    MOVFW TEMP
    MOVWF TXREG
    RETURN 
    
CONFIG_OSC:
    BANKSEL OSCCON
    MOVLW B'01100001'
    MOVWF OSCCON
    RETURN

CONFIG_ADC:
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
DELAY
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
NOP
NOP
NOP
NOP
NOP
RETURN
END