;*******************************************************************************
;                                                                              *
;    Filename: julio lopez                                                     *
;    Date:     9/8/2020                                                        *
;    File Version:                                                             *
;    Author:                                                                   *
;    Company:                                                                  *
;    Description:                                                              *
;                            HORAS  CON ITERMITENTES                                                   *
;*******************************************************************************
; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
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
 CONTF         RES 1 ;IN USE 
 CONTSEG       RES 1 ;IN USE 
 CONTSEGALARMA RES 1 ;IN USE 
 CONTALARMA    RES 1 ;IN USE 
 ALARMA_SU     RES 1 ;IN USE 
 ALARMA_SD     RES 1 ;IN USE 
 ALARMA_MU     RES 1 ;IN USE
 ALARMA_MD     RES 1 ;IN USE
 TEMPALARMA    RES 1 ;IN USE      
 ESPE          RES 1 ;IN USE
 ESPE2         RES 1 ;IN USE
 ESPE3         RES 1 ;IN USE
 ESPE4         RES 1 ;IN USE
 CONTDIA       RES 1 ;IN USE
 CONT2         RES 1 ;IN USE 
 CONTADOR1     RES 1 ;IN USE
 CONTADOR2     RES 1 ;IN USE 
 NIBBLEH       RES 1  ;MIN
 NIBBLEL       RES 1  ;10 MIN
 NIBBLE_HL     RES 1  ;HORAS
 NIBBLE_HH     RES 1  ;20 HORAS 
 NIBBLE_DL     RES 1  ;9 DIAS  
 NIBBLE_DH     RES 1  ;28 DIAS MAX 
 NIBBLE_ML     RES 1  ;9 MESES    MAX 12
 NIBBLE_MH     RES 1  ;10MESES    MAX 12
 CONT_NEW      RES 1 ;NO USE
 CONT_OLD      RES 1 ;NO USE 
 ESTADO        RES 1 ;IN USE  
 FLAGSMES      RES 1 ;IN USE 
 FLAGSHORAS    RES 1 ;IN USE 
 FLAGSMODH     RES 1 ;IN USE 
 FLAGSALARMA   RES 1 ;IN USE 
 FLAGCOUNTDOWN RES 1 ;IN USE 
 ;++++++++++++++++++++++++++++++++++++++++++++++++
CONTHORAS       RES 1 ;IN USE
CONTHORAS_H     RES 1 ;IN USE
TEMPHORAS       RES 1 
TEMPHORAS_H     RES 1 
CONTMES_L       RES 1 ;IN USE
CONTMES_H       RES 1 ;IN USE
TEMPMES_L       RES 1 
TEMPMES_H       RES 1 
 TEMP1          RES 1 ;NOT USE NOT CLEAN
 TEMP2          RES 1 ;NOT USE NOT CLEAN
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
    MOVLW .6
    MOVWF TMR0
    BCF INTCON, T0IF
    BTFSC FLAGSHORAS,0
     CALL DISPLAY_GE
    BTFSC FLAGSMES,0
     CALL DISPLAY_GEMES
    BTFSC FLAGSALARMA,0
     CALL DISPLAY_GEALRMA
    RETURN 
FUE_TIMR1
    MOVLW .207  ;PRESCALER HIGH 
    MOVWF TMR1H
    MOVLW .38  ;PRESCALER LOW
    MOVWF TMR1L
    BCF  PIR1, TMR1IF
    INCF CONTADOR1
    CALL TIMER1S
    RETURN 
FUE_TIMR2
    CLRF TMR2
    BCF PIR1, TMR2IF 
    INCF CONTADOR2
    CALL TIMER1_2S
    BTFSC FLAGCOUNTDOWN,0
    CALL lj
    RETURN 
 ;/////////////////////////////////////////////////////////////////////////////
 lj
 BTFSS PORTB      ,RB5
 CALL TIMERALRMA 
 BTFSC PORTB      ,RB5
 CALL TIMER_ALARMA_TILL_OFF
 RETURN 
 ;/////////////////////////////////////////////////////////////////////////////
 ; tablas de displays 
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
    ;tabla de carga de horas 
    HORAS:
    MOVF CONTHORAS, W
    ADDWF PCL, F
    GOTO UNDERZERO
    RETLW 0X0
    RETLW 0X1
    RETLW 0X2
    RETLW 0X3
    RETLW 0X4
    RETLW 0X5
    RETLW 0X6
    RETLW 0X7
    RETLW 0X8
    RETLW 0X9
    RETLW 0X10
    RETLW 0X11
    RETLW 0X12
    RETLW 0X13
    RETLW 0X14
    RETLW 0X15
    RETLW 0X16
    RETLW 0X17
    RETLW 0X19
    RETLW 0X20
    RETLW 0X21
    RETLW 0X22
    RETLW 0X23
    GOTO HORARESET
    HORAS_L
    MOVF CONTHORAS_H, W
    ADDWF PCL, F
    GOTO UNDERZERO2
    RETLW 0X0
    RETLW 0X1
    RETLW 0X2
    RETLW 0X3
    RETLW 0X4
    RETLW 0X5
    RETLW 0X6
    RETLW 0X7
    RETLW 0X8
    RETLW 0X9
    RETLW 0X10
    RETLW 0X11
    RETLW 0X12
    RETLW 0X13
    RETLW 0X14
    RETLW 0X15
    RETLW 0X16
    RETLW 0X17
    RETLW 0X19
    RETLW 0X20
    RETLW 0X21
    RETLW 0X22
    RETLW 0X23
    RETLW 0X24
    RETLW 0X25
    RETLW 0X26
    RETLW 0X27
    RETLW 0X28
    RETLW 0X29
    RETLW 0X30
    RETLW 0X31
    RETLW 0X32
    RETLW 0X33
    RETLW 0X34
    RETLW 0X35
    RETLW 0X36
    RETLW 0X37
    RETLW 0X38
    RETLW 0X39
    RETLW 0X40
    RETLW 0X41
    RETLW 0X42
    RETLW 0X43
    RETLW 0X44
    RETLW 0X45
    RETLW 0X46
    RETLW 0X47
    RETLW 0X48
    RETLW 0X49
    RETLW 0X50
    RETLW 0X51
    RETLW 0X52
    RETLW 0X53
    RETLW 0X54
    RETLW 0X55
    RETLW 0X56
    RETLW 0X57
    RETLW 0X58
    RETLW 0X59
    GOTO HORARESET2
   ;tabla de estados 
  ESTADOS:
    MOVF ESTADO, W
    ADDWF PCL
    GOTO LOOPHORA
    GOTO LOOPMES
    GOTO LOOP_MOD_HORA
    GOTO LOOP_MOD_MES
    GOTO LOOP_MODALARMA 
    GOTO LOOP_ALARMA 
    GOTO RESETLOOP 
    ;tabla de funcion de meses 
    MES:
    MOVF CONTDIA, W
    ADDWF PCL
    GOTO ENE ;0
    GOTO FEB ;1
    GOTO MAR ;2
    GOTO ABR ;3
    GOTO MAY ;4
    GOTO JUN ;5
    GOTO JUL ;6
    GOTO AGO ;7
    GOTO SEP ;8
    GOTO OCT ;9
    GOTO NOV ;10
    GOTO DIC ;11
    ;tabla de mes para cargar un valor a los meses
    MES_L:
    MOVF CONTMES_L, W
    ADDWF PCL, F
    RETLW .1 ;0
    RETLW .2 ;1
    RETLW .3 ;2
    RETLW .4 ;3
    RETLW .5 ;4
    RETLW .6 ;5
    RETLW .7 ;6
    RETLW .8 ;6
    RETLW .9 ;8
    RETLW .0 ;8
    GOTO MESRESET
    MES_H:
    MOVF CONTMES_H, W
    ADDWF PCL, F
    RETLW .0
    RETLW .1
    GOTO MESRESET_H
   
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
 ;setUP de todo el programa 
MAIN_PROG CODE       0X100   
START
BCF OPTION_REG , 7
CALL    CONFIG_IO
CALL    CONFIG_TIMER0
CALL    CONFIG_TIMER1
CALL    CONFIG_TIMER2
CALL    CONFIG_FLAG
BANKSEL PORTA 
CLRF    CONTADOR1
CLRF    CONTADOR2
CLRF    NIBBLEL
CLRF    NIBBLEH
CLRF    NIBBLE_HL
CLRF    NIBBLE_HH
CLRF    NIBBLE_DL
INCF    NIBBLE_DL
CLRF    NIBBLE_DH
CLRF    NIBBLE_ML
CLRF    NIBBLE_MH
CLRF    ALARMA_SU 
INCF    ALARMA_SU 
CLRF    ALARMA_SD 
CLRF    ALARMA_MU 
CLRF    ALARMA_MD 
CLRF    CONTHORAS
CLRF    CONTHORAS_H
INCF    CONTHORAS
INCF    CONTHORAS_H
CLRF    TEMPHORAS
CLRF    TEMPHORAS_H
CLRF    CONTMES_L
CLRF    CONTMES_H
CLRF    TEMPMES_L
CLRF    TEMPMES_H
CLRF    CONTDIA
CLRF    ESPE
CLRF    ESPE2
CLRF    ESPE3
CLRF    ESPE4
CLRF    TEMPALARMA
CLRF    CONTSEG 
CLRF    CONTSEGALARMA
CLRF    CONTALARMA 
CLRF    ESTADO 
CLRF    FLAGSHORAS 
CLRF    FLAGSMES
CLRF    FLAGSALARMA 
CLRF    FLAGSMODH
CLRF    FLAGSMODH
CLRF    FLAGCOUNTDOWN
MOVLW   .250
MOVWF   ESPE3
GOTO    LOOPHORA  
 ;******************************************************************************
 ;//////////////////////////////////////////////////////////////////////////////
 ;******************************************************************************
 ;                              loop forever
 ;******************************************************************************
 ;//////////////////////////////////////////////////////////////////////////////
 ;******************************************************************************
 LOOPHORA:
 BSF PORTB,RB0
 BCF PORTB,RB1
 BCF PORTB,RB2
 BCF PORTB,RB3
 BSF FLAGSHORAS      ,0 ;DISPLAY DE HORAS EN ON 
 BCF FLAGSMES        ,0 ;DISPLAY DE MES   EN OFF
 BCF FLAGSALARMA     ,0 ;DISPLAY DE ALR   EN OFF
 CALL SUMA_ESTADO       ;ESTADO CHANGE 
 CALL INCREMENTUNOS
 CALL PISHLEDS
 GOTO ESTADOS 
 GOTO LOOPHORA 
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
 LOOPMES:
 BCF PORTB,RB0
 BSF PORTB,RB1
 BCF PORTB,RB2
 BCF PORTB,RB3
 BCF FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF 
 BSF FLAGSMES       ,0 ;DISPLAY DE MES   EN ON 
 BCF FLAGSALARMA    ,0 ;DISPLAY DE ALR   EN OFF 
 CALL SUMA_ESTADO      ;ESTADO CHANGE 
 CALL INCREMENTUNOS
 GOTO ESTADOS  
 GOTO LOOPMES  
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
 LOOP_MOD_HORA:
 CALL SUMA_ESTADO      ;ESTADO CHANGE 
 BSF PORTB,RB0
 BCF PORTB,RB1
 BSF PORTB,RB2
 BCF PORTB,RB3
 BSF FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF
 BCF FLAGSMES       ,0 ;DISPLAY DE MES   EN OFF 
 BCF FLAGSALARMA    ,0 ;DISPLAY DE ALR   EN OFF 
 CALL SUMA2
 CALL SUMA2_
 CALL MEN2
 CALL MEN2_
 CALL INCREMENTUNOS
 CALL PISHLEDS
 GOTO ESTADOS 
 GOTO LOOP_MOD_HORA  
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
 LOOP_MOD_MES:  
 BCF PORTB,RB0
 BSF PORTB,RB1
 BCF PORTB,RB2
 BSF PORTB,RB3
 BCF FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF
 BSF FLAGSMES       ,0 ;DISPLAY DE MES   EN ON 
 BCF FLAGSALARMA    ,0 ;DISPLAY DE ALR   EN OFF 
 CALL SUMA_ESTADO   ;ESTADO CHANGE 
 CALL SUMA
 CALL SUMA_
 CALL MEN
 CALL MEN_
 CALL INCREMENTUNOS
 GOTO ESTADOS 
 GOTO LOOP_MOD_MES
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
  LOOP_MODALARMA:
 BCF PORTB,RB0
 BSF PORTB,RB1
 BSF PORTB,RB2
 BSF PORTB,RB3
 BCF FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF
 BCF FLAGSMES       ,0 ;DISPLAY DE MES   EN OFF 
 BSF FLAGSALARMA    ,0 ;DISPLAY DE ALM   EN ON
 CALL SUMAA
 CALL SUMAA_
 CALL MENA
 CALL MENA_
 CALL ALARMADADA
 CALL SUMA_ESTADO
 CALL INCREMENTUNOS
 GOTO ESTADOS 
 GOTO LOOP_MODALARMA
 ;******************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;******************************************************************************
 LOOP_ALARMA:
 BSF PORTB,RB0
 BSF PORTB,RB1
 BSF PORTB,RB2
 BSF PORTB,RB3
 BCF FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF
 BCF FLAGSMES       ,0 ;DISPLAY DE MES   EN OFF 
 BSF FLAGSALARMA    ,0 ;DISPLAY DE ALM   EN ON 
 BSF FLAGCOUNTDOWN   ,0 ;DISPLAY DE ALM   EN OFF
 CALL SUMA_ESTADO
 CALL INCREMENTUNOS
 BTFSC TEMPALARMA,0
 INCF ESTADO
 CALL  CHANGEALARMA
 BTFSS PORTB ,RB5
 CALL  ALARMADUDU
 CALL  ALARMACERO
 GOTO  ESTADOS 
 GOTO  LOOP_ALARMA
 ;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*****************************************************************************
 RESETLOOP:
 BCF   FLAGSHORAS     ,0 ;DISPLAY DE HORAS EN OFF
 BCF   FLAGSMES       ,0 ;DISPLAY DE MES   EN OFF 
 BCF   FLAGSALARMA    ,0 ;DISPLAY DE ALM   EN OFF
 BCF   FLAGCOUNTDOWN   ,0 ;DISPLAY DE ALM   EN OFF
 INCF  ALARMA_SU
 CLRF  TEMPALARMA
 BCF   PORTB, RB5
 CLRF  ESTADO  
 GOTO  ESTADOS 
 GOTO  RESETLOOP
;******************************************************************************
;////////////////////////////////REGULAOR ///////////////////////////////////
;*****************************************************************************
 ; los reguladores de tiempo respectivos para cada contador y estos se llamanan en el 
 ; isr para que funcionen siempre 
TIMER1S
MOVF CONTADOR1,0
SUBLW .2
BTFSC STATUS,Z
GOTO $+2
RETURN 
INCF CONTSEG
CLRF CONTADOR1
MOVF CONTSEG,0
SUBLW .60
BTFSC STATUS,Z
GOTO $+2
RETURN 
INCF CONTHORAS_H
CLRF CONTSEG 
RETURN  
TIMER_ALARMA_TILL_OFF
INCF CONTSEGALARMA 
MOVF CONTSEGALARMA,0
SUBLW .250
BTFSC STATUS,Z
GOTO $+2
RETURN 
BSF TEMPALARMA,0
RETURN
TIMERALRMA 

CLRF CONTALARMA
DECF ALARMA_SU
RETURN 
 ;******************************************************************************
 ;////////////////////////////////ALRMA/////////////////////////////////////////
 ;******************************************************************************
  PRE_CARGA_RESET
  MOVLW .9
  MOVWF ALARMA_SU
  DECF  ALARMA_SD
  CLRF CONTALARMA
  RETURN
  PRE_CARGA1
  MOVLW .9
  MOVWF ALARMA_SU
  DECF ALARMA_SD
  RETURN
  PRE_CARGA2
  MOVLW .5
  MOVWF ALARMA_SD
  DECF ALARMA_MU
  RETURN
  PRE_CARGA3
  MOVLW .9
  MOVWF ALARMA_MU
  DECF ALARMA_MD
  RETURN
  PRE_CARGA4
  MOVLW .0
  MOVWF ALARMA_MD
  RETURN
;******************************************************************************* 
;*******************************************************************************
 ALARMACERO:
    MOVF ALARMA_MD,W
    SUBLW .0           
    BTFSC STATUS,Z
    GOTO $+2
RETURN   
    MOVF ALARMA_MU,W
    SUBLW .0           
    BTFSC STATUS,Z
    GOTO $+2
RETURN
    MOVF ALARMA_SD,W
    SUBLW .0           
    BTFSC STATUS,Z
    GOTO $+2
RETURN
    MOVF ALARMA_SU,W
    SUBLW .0           
    BTFSC STATUS,Z
    BSF   PORTB   ,RB5
 RETURN 
;******************************************************************************* 
;******************************************************************************* 
;******************************************************************************* 
 ALARMADUDU:
    BTFSC ALARMA_SU,5
    GOTO PRE_CARGA_RESET
    BTFSC ALARMA_SD,5
    GOTO PRE_CARGA2
    BTFSC ALARMA_MU,5
    GOTO PRE_CARGA3
    BTFSC ALARMA_MD,5
    GOTO PRE_CARGA3  
    RETURN 
;*******************************************************************************  
;*******************************************************************************  
;*******************************************************************************  
ALARMADADA: 
    BTFSC ALARMA_SU,5
    GOTO PRE_CARGA_RESET
    MOVF ALARMA_SU,W
    SUBLW .10   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
    BTFSC ALARMA_SD,5
    GOTO PRE_CARGA2
     CLRF ALARMA_SU
     INCF ALARMA_SD
     MOVF ALARMA_SD,W
     SUBLW .6           
     BTFSC STATUS,Z
    GOTO $+2 
RETURN 
    BTFSC ALARMA_MU,5
    GOTO PRE_CARGA3
    CLRF ALARMA_SU
    CLRF ALARMA_SD
     INCF ALARMA_MU
     MOVF ALARMA_MU,W
     SUBLW .9           
     BTFSC STATUS,Z
    GOTO $+2 
RETURN
    CLRF ALARMA_SU
    CLRF ALARMA_SD
    CLRF ALARMA_MU
    INCF ALARMA_MD
    MOVF ALARMA_MD,W
    SUBLW .9           
    BTFSC STATUS,Z
    GOTO $+2 
RETURN
    CLRF ALARMA_SU
    CLRF ALARMA_SD
    CLRF ALARMA_MU
    CLRF ALARMA_MD
RETURN 
;*******************************************************************************    
;**********************************SUMA*****************************************
;******************************************************************************* 
 
; botones con sus respectivos antirebote 
 SUMA_ESTADO
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTB , RB6
  RETURN 
  BTFSC  PORTB , RB6
  GOTO   $-1
  INCF   ESTADO 
  RETURN   
 SUMA                  ;SUMA DE MESE EN MODO EDIT
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA0
  RETURN 
  BTFSC  PORTA , RA0
  GOTO   $-1
  INCF   NIBBLE_DL 
  RETURN
 SUMA_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA1
  RETURN 
  BTFSC  PORTA , RA1
  GOTO   $-1
  INCF   CONTDIA  
  RETURN   
  MEN                  ;RESTA DE MESE EN MODO EDIT
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA2
  RETURN 
  BTFSC  PORTA , RA2
  GOTO   $-1
  DECF   CONTDIA
  RETURN
  MEN_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA3
  RETURN 
  BTFSC  PORTA , RA3
  GOTO   $-1
  DECF   NIBBLE_DL  
  RETURN
 SUMA2              ;SUMA EN MINUTOS EN MODO EDIT 
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA0
  RETURN 
  BTFSC  PORTA , RA0
  GOTO   $-1
  INCF   CONTHORAS_H
  RETURN
 SUMA2_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA1
  RETURN 
  BTFSC  PORTA , RA1
  GOTO   $-1
  INCF   CONTHORAS
 MEN2               ;SUMA EN MINUTOS EN MODO EDIT 
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA2
  RETURN 
  BTFSC  PORTA , RA2
  GOTO   $-1
  DECF   CONTHORAS
  RETURN
  MEN2_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA3
  RETURN 
  BTFSC  PORTA , RA3
  GOTO   $-1
  DECF  CONTHORAS_H  
  RETURN 
 SUMAA              ;SUMA EN MINUTOS EN MODO EDIT 
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA0
  RETURN 
  BTFSC  PORTA , RA0
  GOTO   $-1
  INCF    ALARMA_SU 
  RETURN
  SUMAA_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA1
  RETURN 
  BTFSC  PORTA , RA1
  GOTO   $-1
  INCF    ALARMA_MU 
 MENA               ;SUMA EN MINUTOS EN MODO EDIT 
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA2
  RETURN 
  BTFSC  PORTA , RA2
  GOTO   $-1
  DECF   ALARMA_MU
  RETURN 
  MENA_
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA3
  RETURN 
  BTFSC  PORTA , RA3
  GOTO   $-1
  DECF   ALARMA_SU   
  RETURN 
  CHANGEALARMA
  BCF    STATUS, RP0
  BCF    STATUS, RP1
  BTFSS  PORTA , RA1
  RETURN 
  BTFSC  PORTA , RA1
  GOTO   $-1
  BSF   TEMPALARMA ,0
 ;******************************************************************************
 ;////////////////////////////////HORA//////////////////////////////////////////
 ;******************************************************************************
 ;
 ;esta parte hace el underflow dejando que todo tenga un valor cargado si la variable que 
 ;se decrementa pasa de 0 
 UNDERZERO 
 MOVLW .23
 MOVWF CONTHORAS
 RETURN
 UNDERZERO2 
 MOVLW .59
 MOVWF CONTHORAS_H
 RETURN
 ;los incrementos de la horas no cambian de valor solo los minutos por ennde se puede 
 ; dejar fijo los valores de las hora y que con el tiempo se sumen los minutos 
 ;el uso de una tabla fue la clave igual que los meses 
 ;
 INCREMENTUNOS 
 CALL MES
 CALL HORAS_L
 MOVWF TEMPHORAS_H
 SWAPF TEMPHORAS_H,W
 MOVWF ESPE4
 MOVLW 0X0F
 ANDWF ESPE4,W
 MOVWF NIBBLEH
 CALL HORAS_L
 ANDLW B'00001111';
 MOVWF NIBBLEL
 
 CALL HORAS
 MOVWF TEMPHORAS
 SWAPF TEMPHORAS,W
 MOVWF ESPE
 MOVLW 0X0F
 ANDWF ESPE,W
 MOVWF NIBBLE_HH
 CALL HORAS 
 ANDLW B'00001111';
 MOVWF NIBBLE_HL
 RETURN 
 
 HORARESET2
 CLRF CONTHORAS_H
 INCF CONTHORAS
 INCF CONTHORAS_H
 RETURN 
 
 HORARESET
 CLRF CONTHORAS
 CLRF NIBBLE_HL
 INCF NIBBLE_DL
 INCF CONTHORAS
 RETURN 

 ;******************************************************************************
 ;////////////////////////////////MES//////////////////////////////////////////
 ;******************************************************************************
  MESRESET
 CLRF CONTHORAS
 CLRF NIBBLE_ML
 INCF CONTMES_H
 RETURN 
 MESRESET_H
 CLRF CONTHORAS
 CLRF CONTMES_H
 CLRF NIBBLE_MH
 RETURN 
 ; se utilizo un codigo base para el mes de enero que se copia para todos los meses
 ; lo que cambia en cada mes es los dias es lo unico que varia durante el me por ende se puede 
 ;cargar un valor fijo a las ariables de cuentan el mes 
 ENE:    
 INCREMENTUNOS_MES
 MOVLW .0                 ;CAMBIO DE MES_L
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0                 ;CAMBIO DE MES_H
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HERE:
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRA
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HERE
 RETURN 
DIASEXTRA
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCERO 
RETURN 
 MESCERO 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
 RETURN     
 FEB:
    INCREMENTUNOS_MESFEB
 MOVLW .1                     
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML                 
 MOVLW .0
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREFEB:
    MOVF NIBBLE_DH,W
    SUBLW .2   
    BTFSC STATUS,Z
    GOTO DIASEXTRAFEB
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .2           
     BTFSC STATUS,Z
     GOTO HEREFEB
 RETURN 
DIASEXTRAFEB
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO MESCEROFEB 
RETURN 
 MESCEROFEB 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
 RETURN 

 MAR:                    
    INCREMENTUNOS_MESMAR
 MOVLW .2                
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0                
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH 
HEREMAR:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAMAR    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREMAR         
 RETURN 
DIASEXTRAMAR                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROMAR         
RETURN 
 MESCEROMAR                 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
 RETURN 
 ABR:
        INCREMENTUNOS_MESABRI  
 MOVLW .3                      
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0               
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREABRI:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAABRI    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREABRI          
 RETURN 
DIASEXTRAABRI                 
    MOVF NIBBLE_DL,W
    SUBLW .1   
    BTFSC STATUS,Z  
    GOTO MESCEROABRI          
RETURN 
 MESCEROABRI                 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 MAY:
    INCREMENTUNOS_MESMAY  
 MOVLW .4                 
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0                
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREMAY:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAMAY    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREMAY            
 RETURN 
DIASEXTRAMAY                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROMAY          
RETURN 
 MESCEROMAY                 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 JUN:
    INCREMENTUNOS_MESJUN  
 MOVLW .5                          
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML                 
 MOVLW .0
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREJUN:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAJUN    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREJUN           
 RETURN 
DIASEXTRAJUN                 
    MOVF NIBBLE_DL,W
    SUBLW .1   
    BTFSC STATUS,Z  
    GOTO MESCEROJUN        
RETURN 
 MESCEROJUN                 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 JUL:
        INCREMENTUNOS_MESJUL  
 MOVLW .6                     
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREJUL:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAJUL;    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREJUL            
 RETURN 
DIASEXTRAJUL                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROJUL          
RETURN 
 MESCEROJUL                  
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 AGO:
       INCREMENTUNOS_MESAGO   
 MOVLW .7                      
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREAGO:                
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAAGO    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREAGO          
 RETURN 
DIASEXTRAAGO                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROAGO          
RETURN 
 MESCEROAGO                 
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 SEP:
            INCREMENTUNOS_MESSEP  
 MOVLW .8                      
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .0
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HERESEP:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRASEP;    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HERESEP            
 RETURN 
DIASEXTRASEP                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROSEP           
RETURN 
 MESCEROSEP                   
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 OCT:
           INCREMENTUNOS_MESOCT  
                 
 MOVLW .9                      
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
                 
 MOVLW .1
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREOCT:                
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRAOCT   
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREOCT           
 RETURN 
DIASEXTRAOCT                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCEROOCT         
RETURN 
 MESCEROOCT                
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 NOV:
       INCREMENTUNOS_MESNOV           
 MOVLW .0                    
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
 MOVLW .1
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HERENOV:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRANOV    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HERENOV           
 RETURN 
DIASEXTRANOV                 
    MOVF NIBBLE_DL,W
    SUBLW .1   
    BTFSC STATUS,Z  
    GOTO MESCERONOV          
RETURN 
 MESCERONOV                  
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF CONTDIA
 INCF NIBBLE_DL
    RETURN
 DIC:
           INCREMENTUNOS_MESDIC        
 MOVLW .1                      
 MOVWF CONTMES_L
CALL MES_L
 MOVWF TEMPMES_L
 ANDLW B'00001111';
 MOVWF NIBBLE_ML
                 
 MOVLW .1
 MOVWF CONTMES_H
CALL MES_H
 MOVWF TEMPMES_H
 ANDLW B'00001111';
 MOVWF NIBBLE_MH
HEREDIC:                 
    MOVF NIBBLE_DH,W
    SUBLW .3   
    BTFSC STATUS,Z
    GOTO DIASEXTRADIC    
    MOVF NIBBLE_DL,W
    SUBLW .9   
    BTFSC STATUS,Z  
    GOTO $+2
RETURN 
     CLRF NIBBLE_DL
     INCF NIBBLE_DH
     MOVF NIBBLE_DH,W
     SUBLW .3           
     BTFSC STATUS,Z
     GOTO HEREDIC           
 RETURN 
DIASEXTRADIC                 
    MOVF NIBBLE_DL,W
    SUBLW .2   
    BTFSC STATUS,Z  
    GOTO MESCERODIC         
RETURN 
 MESCERODIC                  
 CLRF NIBBLE_DL
 CLRF NIBBLE_DH
 INCF NIBBLE_DL
 CLRF CONTDIA
    RETURN 
 ;*****************************************************************************
 ;////////////////////////////////////LED ITERMITENTES/////////////////////////
 ;*****************************************************************************
 PISHLEDS
BCF   PORTD, RD0
BCF   PORTD, RD3
BTFSC  CONT2,0
GOTO SHOWON
SHOWOFF:
BCF   PORTD, RD0
BCF   PORTD, RD3
GOTO TOGGLE2
SHOWON:  
BSF   PORTD, RD0
BSF   PORTD, RD3
GOTO TOGGLE2
 TOGGLE2
    BTFSS  CONT2, 0
    GOTO    TOG_00
TOG_11:
    BSF	    CONT2, 0
    RETURN
TOG_00:
    BCF	    CONT2, 0
RETURN
    
TIMER1_2S
MOVF CONTADOR2,0
SUBLW .10
BTFSC STATUS,Z
GOTO VAP2
RETURN 
 VAP2
INCF CONT2
CLRF CONTADOR2
RETURN 
;*****************************************************************************
 ;/////////////////////////////////////////////////////////////////////////////
 ;*************************************************************************** 
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
BTFSS PORTD,RD4
GOTO $+7
BCF PORTD, RD4
BSF PORTD, RD5
MOVFW NIBBLEH
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD5
GOTO $+7
BCF PORTD, RD5
BSF PORTD, RD6
MOVFW NIBBLE_HL 
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD6
GOTO $+7
BCF PORTD, RD6
BSF PORTD, RD7
MOVFW NIBBLE_HH
CALL SEV_SEG
MOVWF PORTC
RETURN
BCF PORTD, RD7
BSF PORTD, RD4
MOVFW NIBBLEL
CALL SEV_SEG
MOVWF PORTC
RETURN
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
DISPLAY_GEMES
BTFSS PORTD,RD4
GOTO $+7
BCF PORTD, RD4
BSF PORTD, RD5
MOVFW NIBBLE_MH 
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD5
GOTO $+7
BCF PORTD, RD5
BSF PORTD, RD6
MOVFW NIBBLE_DL 
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD6
GOTO $+7
BCF PORTD, RD6
BSF PORTD, RD7
MOVFW  NIBBLE_DH
CALL SEV_SEG
MOVWF PORTC
RETURN
BCF PORTD, RD7
BSF PORTD, RD4
MOVFW NIBBLE_ML
CALL SEV_SEG
MOVWF PORTC
RETURN
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
DISPLAY_GEALRMA
BTFSS PORTD,RD4
GOTO $+7
BCF PORTD, RD4
BSF PORTD, RD5
MOVFW ALARMA_SD
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD5
GOTO $+7
BCF PORTD, RD5
BSF PORTD, RD6
MOVFW ALARMA_MU 
CALL SEV_SEG
MOVWF PORTC
RETURN
BTFSS PORTD, RD6
GOTO $+7
BCF PORTD, RD6
BSF PORTD, RD7
MOVFW ALARMA_MD
CALL SEV_SEG
MOVWF PORTC
RETURN
BCF PORTD, RD7
BSF PORTD, RD4
MOVFW ALARMA_SU
CALL SEV_SEG
MOVWF PORTC
RETURN
 ;******************************************************************************
 ;******************************************************************************
 ;******************************************************************************
CONFIG_IO
    BANKSEL TRISA
    MOVLW   B'0001111'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
    BANKSEL TRISB
    MOVLW   B'01000000'
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