#ifndef __AQM0802_H__
#define __AQM0802_H__

#include "chip.h"

#define AQM0802_ADDR			0x7c
#define ST7032_OSC_FREQ		0x04
#define ST7032_AMP_RATIO		0x02

void AQM0802_Config_Request(void);
int AQM0802_cleardisplay(void);
int AQM0802_setcursor(int , int);
int AQM0802_putc( char c );
int AQM0802_puts( char * );
int AQM0802_init( int );
int AQM0802_deinit(void);

#endif // __GPSRTC_H__

//=========================================================
// End of Program
//=========================================================
