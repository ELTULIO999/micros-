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
 CONT           RES 1 ;IN USE 
 CONT1          RES 1 ;IN USE 
 CONT2          RES 1 ;IN USE 
 TEMP           RES 1 ;IN USE 
 TEMP1          RES 1 ;IN USE 
 CLIF           RES 1 ;IN USE 
 W_TEMP         RES 1
 STATUS_TEMP    RES 1
 CONV_FLAGAS    RES 1
     
 N1X             RES 1
 N1Y             RES 1
	     
 XX              RES 1
 YY              RES 1
 RAM              RES 1
	     
 QUOX            RES 1
 QUO1X           RES 1
 QUOY            RES 1
 QUO1Y           RES 1
 QUO             RES 1
 QUO1            RES 1
	    
 QUOS            RES 1
 QUOS1            RES 1
 QUOS2            RES 1
 QUOS3            RES 1
	    
	    
 NUM	         RES 1
 NUM2	         RES 1
	   
 SEM             RES 1
	 
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
    BTFSC PIR1, RCIF
    CALL SAVEGG
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
    MOVF CLIF,W
    ANDLW   B'00000011'
    ADDWF   PCL, F
    GOTO DISPLAY_D1
    GOTO DISPLAY_D2
    GOTO DISPLAY_D12
    GOTO DISPLAY_D22
    RETURN 

    DISPLAY_D1
    BCF   PORTD,RD6
    BCF   PORTD,RD7
    BCF   PORTC,RC4
    BCF   PORTC,RC5
    MOVFW QUOS
    CALL SEV_SEG
    MOVWF PORTB 
    BSF   PORTD,RD7
    INCF    CLIF, F
    RETURN 

    DISPLAY_D2
    BCF   PORTD,RD6
    BCF   PORTD,RD7
    BCF   PORTC,RC4
    BCF   PORTC,RC5
    MOVFW QUOS1
    CALL  SEV_SEG
    MOVWF PORTB 
    BSF   PORTD,RD6
    INCF    CLIF, F
    RETURN 

    DISPLAY_D12
    BCF   PORTD,RD6
    BCF   PORTD,RD7
    BCF   PORTC,RC4
    BCF   PORTC,RC5
    MOVFW QUOS2
    CALL SEV_SEG
    MOVWF PORTB 
    BSF   PORTC,RC4
    INCF    CLIF, F
    RETURN 
    
    DISPLAY_D22
    BCF   PORTD,RD6
    BCF   PORTD,RD7
    BCF   PORTC,RC4
    BCF   PORTC,RC5
    MOVFW QUOS3
    CALL  SEV_SEG
    MOVWF PORTB 
    BSF   PORTC,RC5
    CLRF    CLIF
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
    ;BTFSC   PIR1, TXIF
    ;CALL    SEND
    RETURN 
SAVEGG:    
    MOVF RAM ,W
    ANDLW   B'00000011'
    ADDWF   PCL, F
    GOTO X01
    GOTO X10
    GOTO Y01
    GOTO Y10
    RETURN 
    

X01
    MOVLW 0X30
    SUBWF RCREG ,W
    MOVWF QUOS
    INCF RAM
    RETURN
    
X10
    MOVLW 0X30
    SUBWF RCREG ,W
    MOVWF QUOS1
    INCF RAM
    RETURN
Y01  
    
    MOVLW 0X30
    SUBWF RCREG ,W
    MOVWF QUOS2
    INCF RAM
    RETURN
Y10  
   
    MOVLW 0X30
    SUBWF RCREG ,W
    MOVWF QUOS3
    CLRF RAM
    RETURN
RETURN 
 ;/////////////////////////////////////////////////////////////////////////////	 
	 
SEV_SEG:
    ADDWF PCL,F
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
CALL    CONFIG_MASTER

 
BANKSEL PORTA 
CLRF    CONT
CLRF    CONT1
CLRF    CONT2
CLRF    TEMP
CLRF    TEMP1
CLRF    W_TEMP       
CLRF    STATUS_TEMP  
CLRF    CLIF
CLRF    N1X
CLRF    N1Y
CLRF    QUOX
CLRF    QUO1X
CLRF    QUOY
CLRF    QUO1Y
CLRF    QUOS
CLRF    QUOS1
CLRF    QUOS2
CLRF    QUOS3
CLRF    SEM
CLRF    XX
CLRF    YY
CLRF    CONV_FLAGAS 
CLRF    RAM
GOTO    LOOP
 
;------------------------------------------------------
LOOP:
   CALL CONVERTX
   CALL CHANGE_X
   CALL SENDX
   CALL CONVERTY
   CALL CHANGE_Y
   CALL SENDY
   
   GOTO LOOP


;----------------------------------------------------

   
NUM_TO_VOLTS:
    MOVWF   NUM
    CLRF    QUO
    CLRF    QUO1
    MOVLW .51  
    INCF QUO
    SUBWF NUM
    BTFSC STATUS,C
    GOTO $-4
    DECF QUO
    ADDWF NUM,W
    MOVWF NUM2     
    MOVLW .5
    INCF QUO1
    SUBWF NUM2
    BTFSC STATUS,C
    GOTO $-4
    DECF QUO1
    RETURN 
CHANGE_X:
    MOVF    N1X, W
    CALL    NUM_TO_VOLTS
    MOVF    QUO, W
    MOVWF   QUOX
    MOVF    QUO1, W
    MOVWF   QUO1X
    RETURN 
CHANGE_Y:
    MOVF    N1Y, W
    CALL    NUM_TO_VOLTS
    MOVF    QUO, W
    MOVWF   QUOY
    MOVF    QUO1, W
    MOVWF   QUO1Y
    RETURN  
CONVERTX:
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO $-1
    MOVF ADRESH, W
    MOVWF N1X
    BSF ADCON0, CHS0
    CALL DELAY
RETURN     
CONVERTY:	
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO$-1
    MOVF ADRESH, W
    MOVWF N1Y
    BCF ADCON0, CHS0
    CALL DELAY
RETURN     
SENDX:
   BTFSS PIR1,TXIF   ;PRIMERO VALOR
   GOTO  $-1
   CALL  DELAY_10MS
   MOVFW QUOX
   ADDLW 0X30
   MOVWF TXREG
   BTFSS PIR1,TXIF   ;SEGUNDO VALOR
   GOTO  $-1
   CALL  DELAY_10MS
   MOVFW QUO1X
   ADDLW 0X30
   MOVWF TXREG
   BTFSS PIR1,TXIF   ;coma
   GOTO  $-1
   CALL  DELAY_10MS
   MOVLW 0X2C 
   MOVWF TXREG
   RETURN 
SENDY:
   BANKSEL TXREG 
   BTFSS PIR1,TXIF   ;PRIMERO VALOR
   GOTO  $-1
   CALL  DELAY_10MS
   MOVFW QUOY
   ADDLW 0X30
   MOVWF TXREG
   BTFSS PIR1,TXIF   ;SEGUNDO VALOR
   GOTO  $-1
   CALL  DELAY_10MS
   MOVFW QUO1Y
   ADDLW 0X30
   MOVWF TXREG
   BTFSS PIR1,TXIF   ;NEXT LINE 
   GOTO  $-1
   CALL  DELAY_10MS
   MOVLW .10
   MOVWF TXREG
RETURN 
CONFIG_MASTER:
        BCF TXSTA, SYNC
        BSF TXSTA, BRGH
	BANKSEL BAUDCTL
	BCF BAUDCTL, BRG16
	BANKSEL SPBRG
	MOVLW .25
	MOVWF SPBRG
	CLRF SPBRGH
	BANKSEL RCSTA
	BSF RCSTA, SPEN
	BSF RCSTA, CREN ; en ON en on para 
	BCF RCSTA, RX9
	BANKSEL TXSTA
	BCF TXSTA, TX9
	BSF TXSTA, TXEN
	BANKSEL PORTD
	CLRF PORTD
	BSF PIE1,RCIE
 RETURN 
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------
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
 MOVLW  B'001000111' ;B'00000101'
 MOVWF   T2CON
 BANKSEL TRISA
 MOVLW   .250
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

  DELAY_10MS
  MOVLW  .20
  MOVWF  YY
  CALL   DELAY_500US
  DECFSZ YY, F
  GOTO  $-2
  RETURN 
  
 DELAY_500US
  MOVLW  .100
  MOVWF  XX
  DECFSZ XX
  GOTO $-1
  RETURN  

END