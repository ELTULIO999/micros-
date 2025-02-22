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
 CONT1        RES 1
 CONTADOR1    RES 1
 CONTADOR2    RES 1 
    
 TEMP1        RES 1 ;PARA EL SAWPF DE LOS DYPLAY 
 TEMP2        RES 1
 CONTDE_4     RES 1
     
NIBBLEH RES 1
NIBBLEL RES 1
     
 ; VARIABLES TEPORALES 
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
 

RES_VECT  CODE    0x0000            ; processor reset vector
 GOTO    START                   ; go to beginning of program

;*******************************************************************************TODO ADD INTERRUPTS HERE IF USED
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
    MOVLW .217
    MOVWF TMR0
    BCF INTCON, T0IF
     CALL DISPLAY_GE
    RETURN 
FUE_TIMR1
    MOVLW 085H  ;PRESCALER HIGH 
    MOVWF TMR1H
    MOVLW 0EEH  ;PRESCALER LOW
    MOVWF TMR1L
    BCF  PIR1, TMR1IF
    INCF CONTADOR1
    RETURN 
FUE_TIMR2
    CLRF TMR2
    BCF PIR1, TMR2IF 
    INCF CONTADOR2
    RETURN 
SEV_SEG:
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
    RETLW B'01011111';A
    RETLW B'01111100';b
    RETLW B'00110110';C
    RETLW B'01111001';d
    RETLW B'00111110';E
    RETLW B'00011110';F
 
MAIN_PROG CODE       0X100   
START
CALL    CONFIG_IO
CALL    CONFIG_TIMER0
CALL    CONFIG_TIMER1
CALL    CONFIG_TIMER2
CALL    CONFIG_FLAG
BANKSEL PORTA 
CLRF    CONTADOR1
CLRF    CONTADOR2
CLRF    CONT1
CLRF    NIBBLEL
CLRF    NIBBLEH

 GOTO LOOP  
;*************************************loop forever******************************
;*******************************************************************************
 LOOP:
    
 CALL TIMER1S
 CALL TIMER1_2S
 CALL INCREMENTUNOS
 CALL PISHLEDS
GOTO LOOP                        
;*******************************************************************************    
;**********************************OPERACIONES**********************************
 
 
 PISHLEDS
BSF   PORTA, RA4
BCF   PORTA, RA5
CLRF  CONT1

BCF   PORTA, RA4
BSF   PORTA, RA5
RETURN
 
TIMER1_2S
MOVF CONTADOR2,W
SUBLW .10
BTFSC STATUS,Z
CALL VAP2
RETURN 
 VAP2
INCF CONT1
CLRF CONTADOR2
RETURN 
 
 
 
INCREMENTUNOS 
MOVF NIBBLEL,W
SUBLW .10
BTFSC STATUS,Z
CALL  INCREMENT10S
RETURN 
 INCREMENT10S
 INCF NIBBLEH
 CLRF NIBBLEL
 MOVF NIBBLEH,W
 SUBLW .6
 BTFSC STATUS,Z
 CALL CEROS
 RETURN 
 CEROS
 CLRF NIBBLEL
 CLRF NIBBLEH
 RETURN 
 TIMER1S
MOVF CONTADOR1,0
SUBLW .10
BTFSC STATUS,Z
CALL VAP1
RETURN 
 VAP1
INCF NIBBLEL
CLRF CONTADOR1
RETURN 
 
    
CONFIG_FLAG
 ;TIMER0
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
 BSF OPTION_REG , PS0
 BANKSEL PORTA
 MOVLW   .128
 MOVWF   TMR0
 BCF INTCON, T0IF
 RETURN
 
CONFIG_TIMER1
 BANKSEL   PORTA
 BCF T1CON, TMR1GE
 BCF T1CON, T1CKPS1 ;PRESCALER 
 BSF T1CON, T1CKPS0 ;PRESCALER 
 BCF T1CON, T1OSCEN ;TIMER INTERNO  
 BCF T1CON, TMR1CS 
 BSF T1CON, TMR1ON 
 MOVLW 085H  ;PRESCALER HIGH 
 MOVWF TMR1H
 MOVLW 0EEH  ;PRESCALER LOW
 MOVWF TMR1L
 BCF PIR1, TMR1IF
RETURN 
 
CONFIG_TIMER2
 BANKSEL PORTA
 MOVLW   B'01100111'
 MOVWF   T2CON
 BANKSEL TRISA
 MOVLW   .241
 MOVWF   PR2
 BANKSEL PORTA
 CLRF    TMR2
 BCF     PIR1, TMR2IF
RETURN 
 
 
 ;****************************DISPLAY 7 SEGMENTOS ******************************
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
 DISPLAY_GE
 
  CALL DISPLAY_D1
  CALL DISPLAY_D2
  RETURN 
 
 
 DISPLAY_D1  ;
 BCF  PORTD, RD0
 MOVFW NIBBLEH
 CALL SEV_SEG
 MOVWF PORTC
 BSF   PORTD, RD1
 RETURN
 DISPLAY_D2
 BCF   PORTD, RD1
 MOVFW NIBBLEL
 CALL  SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD0
 RETURN   
 
 
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
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
 RETURN
END