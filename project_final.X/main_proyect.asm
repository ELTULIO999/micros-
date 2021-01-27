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
; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

    
  GPR	UDATA
  ADC_V2	RES 1	
  ADC_V		RES 1	
  DELAY		RES 1		
  X		RES 1		

    RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of program
; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

SETUP
    CALL CONFIG_IO
    CALL CONFIG_PWM	
    CALL CONFIG_ADC
    MOVLW .10
    MOVWF DELAY
    GOTO LOOP
LOOP    
    CALL SERV1
    CALL DELAY10US    
    CALL SERV2
    GOTO LOOP

;*********************************CONFIG GENERALES*****************************
CONFIG_IO
    BCF STATUS, 5
    BCF STATUS, 6
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF PORTE
    BANKSEL TRISA        ;INDICO LAS ENTRADAS Y SALIDAS PARA LOS PUERTOS A USAR
    CLRF    TRISA
    COMF    TRISA
    CLRF   TRISB
    CLRF   TRISC
    CLRF   TRISD
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL    
    RETURN
    
CONFIG_ADC
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    RETURN
SERV1
    BANKSEL PORTA
    CALL    DELAY10US
    BANKSEL ADCON0
    MOVLW   B'01000001'
    MOVWF   ADCON0    
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, 0
    MOVWF   ADC_V    
    BANKSEL CCPR1L
    MOVF    ADC_V, 0
    MOVWF   CCPR1L
RETURN
    
    
SERV2
    BANKSEL PORTA
    CALL    DELAY10US
    BANKSEL ADCON0
    MOVLW   B'01000101'
    MOVWF   ADCON0
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, 0
    MOVWF   ADC_V2
    BANKSEL CCPR2L
    MOVF    ADC_V2, 0
    CALL MAPEO
    MOVWF   CCPR2L    
RETURN     
    
 MAPEO:
    MOVWF X
    RRF X
    ANDLW B'01111111'
    ADDLW .32
    RETURN 
    
DELAY10US
    DECFSZ  DELAY,  1
    GOTO    $-1
    MOVLW   .10
    MOVWF   DELAY
    RETURN

    
 
CONFIG_PWM
    BANKSEL T2CON
    MOVLW   B'00000111'    ;POSTSCALER EN 1:1, TIMER 2 EN ON, 1X PRESCALER 1:16
    MOVWF   T2CON
    BANKSEL PR2
    MOVLW   .156
    MOVWF   PR2
    BANKSEL TRISC
    MOVLW   B'00000000'
    MOVWF   TRISC
    ;CONFIGURACIÓN DE CCP1CON
    BANKSEL CCP1CON	    ;PWM MODE
    BSF	    CCP1CON,   3
    BSF	    CCP1CON,   2
    BCF	    CCP1CON,   1
    BCF	    CCP1CON,   0
    ;CONFIGURACIÓN DE CCP2CON
    BANKSEL CCP2CON	    ;PWM MODE
    BSF	    CCP2CON,   3
    BSF	    CCP2CON,   2
RETURN
    END