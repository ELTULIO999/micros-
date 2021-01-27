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
 
 N1          RES 1
 N2          RES 1
 NUM         RES 1
 NUM2        RES 1  	  
 QUO         RES 1 
 QUO1        RES 1 
 XQUO        RES 1 
 XQUO1       RES 1 
 YQUO        RES 1 
 YQUO1       RES 1 
        
 W_TEMP         RES 1 ;time var 
 STATUS_TEMP    RES 1 ;timer var 

     

	 
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
    RETURN 
;/////////////////////////////////////////////////////////////////////////////	 
;-------------------------------------------------------------------
MAIN_PROG CODE       0X200   
START
CALL    CONFIG_OSC
BCF	OPTION_REG , 7
CALL    CONFIG_IO
CALL    CONFIG_TIMER0
CALL    CONFIG_TIMER1
CALL    CONFIG_TIMER2
CALL    CONFIG_FLAG
CALL    CONFIG_ADC 
BANKSEL PORTA 
 CLRF    XQUO
 CLRF    XQUO1
 CLRF    YQUO
 CLRF    YQUO1
 CLRF    NUM
 CLRF    NUM2
 CLRF    QUO1
GOTO    LOOP
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
LOOP:
    CALL CONVERT1
    CALL CHANGE1
    CALL CONVERT2
    CALL CHANGE2
    BSF PORTD,RD2
  
GOTO LOOP
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 CHANGE1
    MOVF    N1, W
    CALL    NUM_TO_PWM
    MOVF    QUO, W
    ADDLW  .32
    MOVWF   CCPR1L
 RETURN 
 CHANGE2
    MOVF    N2, W
    CALL    NUM_TO_PWM
    MOVF    QUO, W
    ADDLW   .32
    MOVWF   CCPR2L
 RETURN 
 
 NUM_TO_PWM:
    MOVWF   NUM
    CLRF    QUO
    MOVLW   .2  
    INCF    QUO
    SUBWF   NUM
    BTFSC   STATUS,C
    GOTO    $-4
    DECF    QUO
    RETURN 
    
CONVERT1:
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO $-1
    MOVF ADRESH, W
    MOVWF N1
    BSF ADCON0, CHS0
    CALL DELAY
    RETURN 
    
CONVERT2:	
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO$-1
    MOVF ADRESH, W
    MOVWF N2
    BCF ADCON0, CHS0
    CALL DELAY
RETURN   

CONFIG_PWM:
    MOT1:
    BANKSEL CCP1CON 
    BCF CCP1CON, 7
    BCF CCP1CON, 6
    BCF CCP1CON, 5
    BCF CCP1CON, 4
    BSF CCP1CON, 3
    BSF CCP1CON, 2
    BCF CCP1CON, 1
    BCF CCP1CON, 0
    MOT2:
    BANKSEL CCP2CON 
    BCF CCP2CON, 5
    BCF CCP2CON, 4
    BSF CCP2CON, 3
    BSF CCP2CON, 2
    BSF CCP2CON, 1
    BSF CCP2CON, 0    
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

 CONFIG_FLAG:
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
 
 CONFIG_TIMER0:
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
 
CONFIG_TIMER1:
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
 
CONFIG_TIMER2:
 BANKSEL PORTA
 MOVLW  B'01111111' ;B'00000101'
 MOVWF   T2CON
 
 BANKSEL TRISA
 MOVLW   .187
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
    MOVLW   B'00000011'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
    BSF ANSEL, ANS0
    BSF ANSEL, ANS1
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
RETURN
END