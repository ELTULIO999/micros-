//******************************************************************************
// Importación de Librerías
//******************************************************************************

#include <xc.h>

//******************************************************************************
// Palabra de configuración
//******************************************************************************
// CONFIG1
#pragma config FOSC = XT        // Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)
//******************************************************************************
// Variables
//******************************************************************************
int variable;

//******************************************************************************
// Prototipos de funciones
//******************************************************************************
void Setup(void);
void delay(char n);
//******************************************************************************
// Ciclo principal
//******************************************************************************
void main(void) { 
    Setup();
    //**************************************************************************
    // Loop principal
    //**************************************************************************
    while(1){
        delay(100);
        /*if(PORTBbits.RB0 == 1){
            PORTBbits.RB0 = 0;
        }else{
            PORTBbits.RB0 = 1;
        }*/
        PORTB++;
    
    
    }
}
//******************************************************************************
// Configuración
//******************************************************************************
void Setup(void){
    PORTB =  0;
    ANSEL =  0;
    ANSELH = 0;
    TRISC =  0;
    TRISD =  0;
    TRISE =  0;
    TRISAbits.TRISA0 = 1;
    PORTAbits.RA0 = 1;
    PORTAbits.RA1 = 1;
    PORTAbits.RA2 = 1;
}
//******************************************************************************
// Delay
//******************************************************************************
void delay(char n){
    for(int i = 0; i < n; i++){
        for(int j = 0; j < 255; j++ ){
            
        }
    }
    
}
