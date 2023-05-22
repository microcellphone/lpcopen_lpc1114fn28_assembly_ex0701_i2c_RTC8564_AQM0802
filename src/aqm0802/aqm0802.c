#include <string.h>
#include "st7032.h"
#include "aqm0802.h"
#include "my_delay.h"
#include "i2c.h"

extern void ST7032_i2c_cmd(uint8_t cmd);
extern void ST7032_i2c_data(uint8_t data);
extern uint32_t I2C_Config_Request( uint32_t I2cMode, uint32_t I2cAddress );
extern uint32_t I2CInit( uint32_t I2cMode );

int AQM0802_cleardisplay(void)
{
	ST7032_i2c_cmd(ST7032_CLEARDISPLAY);
	Delay(1);
	return 1;
}

int AQM0802_setcursor( int col, int row )
{
	int row_offs[] = { 0x00, 0x40, 0x14, 0x54 };

	ST7032_i2c_cmd(ST7032_SETDDRAMADDR | (col + row_offs[row]));
	Delay(1);
	return 1;
}

int AQM0802_putc( char c )
{
	ST7032_i2c_data((uint32_t)c);
	Delay(1);

	return 1;
}

uint8_t cnt;

int AQM0802_puts( char *str )
{
	for(cnt = 0; cnt<strlen(str); cnt++){
		ST7032_i2c_data((uint32_t)str[cnt]);
		Delay(1);
	}

	return 1;
}

int AQM0802_init( int contrast )
{
	ST7032_i2c_cmd( ST7032_FUNCTIONSET | ST7032_FUNC_8BITMODE | ST7032_FUNC_2LINE );
	ST7032_i2c_cmd( ST7032_FUNCTIONSET | ST7032_FUNC_8BITMODE | ST7032_FUNC_2LINE | ST7032_FUNC_INSTABLE );
	ST7032_i2c_cmd( ST7032_IS_OSC | ST7032_OSC_FREQ );
	ST7032_i2c_cmd( ST7032_IS_CONTSET1 | contrast_lower(contrast) );
	ST7032_i2c_cmd( ST7032_IS_CONTSET2 | contrast_upper(contrast) );
	ST7032_i2c_cmd( ST7032_IS_FOLLOWER | ST7032_IS_FOLLOWER_ON | ST7032_AMP_RATIO );
	ST7032_i2c_cmd( ST7032_DISPLAYCONTROL | ST7032_DISP_ON );
	ST7032_i2c_cmd( ST7032_ENTRYMODESET | ST7032_ENTRYLEFT );

	AQM0802_cleardisplay();
	return 1;
}

#define CONTRAST	56

void AQM0802_Config_Request(void)
{
	if (I2C_Config_Request((uint32_t) I2CMASTER, AQM0802_ADDR) == FALSE ) {
		  while (1); // Error Trap
	}

  if (AQM0802_init(CONTRAST) < 0 ) {
    while (1); // Error Trap
  }
}
