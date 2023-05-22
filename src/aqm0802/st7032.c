#include "chip.h"
#include "i2c.h"
#include "st7032.h"

extern uint32_t I2CEngine( void );

extern volatile uint32_t I2CCount;
extern volatile uint8_t  I2CMasterBuffer[BUFSIZE];
extern volatile uint8_t  I2CSlaveBuffer[BUFSIZE];
extern volatile uint32_t I2CMasterState;
extern volatile uint32_t I2CReadLength, I2CWriteLength;

void ST7032_i2c_cmd(uint8_t cmd)
{
  I2CWriteLength     = 3;
  I2CReadLength      = 0;
  I2CMasterBuffer[0] = AQM0802_ADDR;
  I2CMasterBuffer[1] = ST7032_RS_CMD_WRITE;
  I2CMasterBuffer[2] = cmd;
  I2CEngine();
}

void ST7032_i2c_data(uint8_t data)
{
  I2CWriteLength     = 3;
  I2CReadLength      = 0;
  I2CMasterBuffer[0] = AQM0802_ADDR;
  I2CMasterBuffer[1] = ST7032_RS_DATA_WRITE;
  I2CMasterBuffer[2] = data;
  I2CEngine();
}
