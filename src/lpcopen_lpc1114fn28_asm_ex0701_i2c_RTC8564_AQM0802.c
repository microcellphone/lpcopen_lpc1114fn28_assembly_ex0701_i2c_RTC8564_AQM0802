/*
===============================================================================
 Name        : lpcopen_lpc1114fn28_asm_ex0701_i2c_RTC8564_AQM0802.c
 Author      : $(author)
 Version     :
 Copyright   : $(copyright)
 Description : main definition
===============================================================================
*/

#if defined (__USE_LPCOPEN)
#if defined(NO_BOARD_LIB)
#include "chip.h"
#else
#include "board.h"
#endif
#endif

#include <cr_section_macros.h>

// TODO: insert other include files here
#include "rtc8564.h"
#include "aqm0802.h"
#include "xprintf.h"
#include "i2c.h"
#include "my_delay.h"

// TODO: insert other definitions and declarations here
extern void USART_putc(char data);
extern void USART_Config_Request(uint32_t baudrate);


int main(void) {

#if defined (__USE_LPCOPEN)
    // Read clock settings and update SystemCoreClock variable
    SystemCoreClockUpdate();
#if !defined(NO_BOARD_LIB)
    // Set up and initialize all required blocks and
    // functions related to the board hardware
    Board_Init();
    // Set the LED to the state of "On"
    Board_LED_Set(0, true);
#endif
#endif

    // TODO: insert code here
	RTC_INFO_T RTC_Data;

	SysTick_Config(SystemCoreClock/1000 - 1); /* Generate interrupt each 1 s   */
//	USART_Config_Request(115200);
//	xdev_out(USART_putc);
//	xprintf ("lpcopen_lpc1114fn28_asm_ex07_i2c_RTC8564\n");
	AQM0802_Config_Request();
	xdev_out(AQM0802_putc);

	RTC8564_Config_Request();
	RTC_Config_Request(1, 17, 10, 19, WED, 21, 42, 30);

    // Force the counter to be placed into memory
    volatile static int i = 0 ;
    // Enter an infinite loop, just incrementing a counter
    while(1) {
     	 Delay(1000);
     	 RTC_Get_Data(&RTC_Data);
     	 AQM0802_setcursor( 0, 0 );
//     	 xprintf("20%02d/%02d/%02d(%s)\n", RTC_Data.year, RTC_Data.mon, RTC_Data.day, Get_Week_String(RTC_Data.week));
     	 xprintf("%02d/%02d/%02d", RTC_Data.year, RTC_Data.mon, RTC_Data.day);
     	 AQM0802_setcursor( 0, 1 );
     	 xprintf("%02d:%02d:%02d", RTC_Data.hour, RTC_Data.min, RTC_Data.sec);
		i++ ;
    	// "Dummy" NOP to allow source level single
    	// stepping of tight while() loop
    	__asm volatile ("nop");
    }
    return 0 ;
}
/*
void baudrate_config_request(uint32_t baudrate)
{
	uint32_t DL;
    DL = (SystemCoreClock * LPC_SYSCTL->SYSAHBCLKDIV)
       / (16 * baudrate * LPC_SYSCTL->USARTCLKDIV);
    LPC_USART->LCR |= (1<<7);
    LPC_USART->DLM = DL / 256;
    LPC_USART->DLL = DL % 256;
}
*/
