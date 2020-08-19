         INCLUDE       <P16F873.INC>
            
      
      
      
         LIST P=16F873, R = HEX
      

REG1      EQU         20H
R12       EQU         21H
VALOR1       EQU       22H
VALOR2       EQU       23H
      
         ORG         0X00
         GOTO      INICIO
         ORG         0X05


INICIO      MOVLW       .0
         TRIS       PORTB ;CONFIGURAR EL PERTO B TODO COMO SALIDA.
         MOVLW       .0
         TRIS       PORTC ;CONFIGURA EL PUERTO C COMO SALIDA.
         MOVLW       .7 ;CARGA W CON 7.
         MOVWF       VALOR2 ;LLEVA 7 A VALOR 2.
         MOVLW       .5 ;CARGA W CON 5.
         MOVWF       VALOR1 ;LLEVA 5 A VALOR 1.
         
LOOP1          MOVLW       .0;paramos los displays
         MOVWF       PORTC ;HABILITA EL TRANSISTOR DE

         MOVF       VALOR1,W ;LLEVA VALOR 1 A W.
      
         CALL       TABLA ;LLAMA A TABLA PARA ENCONTRAR EL VALOR         7 SEGMENTOS DEL NUMERO 5.
         MOVWF      PORTB ;LLEVA EL VALOR 7 SEG AL PUERTO B.
         MOVLW       .1;00000001<- rc0 =0, Rc1=1; habilitamos display 1 negado.

         MOVWF       PORTC  ;HABILITA EL TRANSISTORCORRESPONDIENTE A VALOR1 (RC0)
      
         CALL       RETARDO
         MOVLW       .0;paramos los displays  para que no titile
         MOVWF       PORTC ;HABILITA EL TRANSISTOR DE

         MOVF       VALOR2,W ;LLEVA VALOR 2 A W.

         CALL       TABLA ;CONVIERTE VALOR 2 A CODIGO 7SEGMENTOS.
         MOVWF      PORTB  ;SACA AL PUERTO B EL VALOR 2.
         MOVLW       .2;00000010<-rc0=1,rc1=0; habilitamos display 2 negado;
         MOVWF       PORTC ;HABILITA EL TRANSISTOR DE VALOR2 (RC1).
         CALL       RETARDO
      
         GOTO      LOOP1
RETARDO    MOVLW       .255 ;RETARDO DE 1 mS APROX.
         MOVWF       R12
REP       DECFSZ       R12,F
         GOTO       REP

         MOVLW       .255
         MOVWF       REG1
RET1       DECFSZ       REG1,F
         GOTO       RET1
         RETURN
; ahora si tenias la TABLA incrustada en el retardo;
TABLA
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
    RETLW B'01011111';A
    RETLW B'01111100';b
    RETLW B'00110110';C
    RETLW B'01111001';d
    RETLW B'00111110';E
    RETLW B'00011110';F
         END ;FIN DEL PROGRAMA


