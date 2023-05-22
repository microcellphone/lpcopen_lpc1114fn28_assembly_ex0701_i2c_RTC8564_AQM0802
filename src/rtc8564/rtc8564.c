#include "chip.h"
#include <i2c.h>
#include "rtc8564.h"
#include "my_delay.h"


extern uint32_t I2CEngine( void );
extern uint32_t I2C_Config_Request( uint32_t I2cMode, uint32_t I2cAddress );

extern volatile uint32_t I2CCount;
extern volatile uint8_t  I2CMasterBuffer[BUFSIZE];
extern volatile uint8_t  I2CSlaveBuffer[BUFSIZE];
extern volatile uint32_t I2CMasterState;
extern volatile uint32_t I2CReadLength, I2CWriteLength;

uint8_t BCD_INT(uint8_t num)
{
  return ((num / 10) << 4) + (num % 10);
}

uint8_t INT_BCD(uint8_t bcd)
{
  return (((bcd >> 4) * 10) + (bcd & 0x0f));
}

void RTC_Config_Request(uint32_t do_adj, uint8_t year, uint8_t month,  uint8_t day,
              uint8_t week,    uint8_t hour, uint8_t minute, uint8_t second)
{
    if (do_adj) {
      	Delay(1000);

    	  //
        RTC8564_Write_Reg(RTC_CONTROL1, 0x20); // STOP
        RTC8564_Write_Reg(RTC_CONTROL2, 0x00);
        //
        RTC8564_Write_Reg(RTC_HOURS,   BCD_INT(hour));
        RTC8564_Write_Reg(RTC_MINUTES, BCD_INT(minute));
        RTC8564_Write_Reg(RTC_SECONDS, BCD_INT(second));
        //
        RTC8564_Write_Reg(RTC_YEARS,    BCD_INT(year));
        RTC8564_Write_Reg(RTC_C_MONTHS, BCD_INT(month));
        RTC8564_Write_Reg(RTC_DAYS,     BCD_INT(day));
        RTC8564_Write_Reg(RTC_WEEKDAYS, BCD_INT(week));
        //
        RTC8564_Write_Reg(RTC_MINUTE_ALARM,  0x00);
        RTC8564_Write_Reg(RTC_HOUR_ALARM,    0x00);
        RTC8564_Write_Reg(RTC_DAY_ALARM,     0x00);
        RTC8564_Write_Reg(RTC_WEEKDAY_ALARM, 0x00);
        //
        RTC8564_Write_Reg(RTC_CLKOUT_FREQ,  0x00);
        RTC8564_Write_Reg(RTC_TIMER_CONTROL,0x00);
        RTC8564_Write_Reg(RTC_TIMER,        0x00);
        //
        RTC8564_Write_Reg(RTC_CONTROL1, 0x00); // START
    }
}

void RTC_Get_Data(RTC_INFO_T *psRTC)
{
    psRTC->year = INT_BCD(RTC8564_Read_Reg(RTC_YEARS));
    psRTC->mon  = INT_BCD(RTC8564_Read_Reg(RTC_C_MONTHS) & 0x1f);
    psRTC->day  = INT_BCD(RTC8564_Read_Reg(RTC_DAYS) & 0x3f);
    psRTC->week = RTC8564_Read_Reg(RTC_WEEKDAYS) & 0x07;
    psRTC->hour = INT_BCD(RTC8564_Read_Reg(RTC_HOURS) & 0x3f);
    psRTC->min  = INT_BCD(RTC8564_Read_Reg(RTC_MINUTES) & 0x7f);
    psRTC->sec  = INT_BCD(RTC8564_Read_Reg(RTC_SECONDS) & 0x7f);
}

uint8_t *Get_Week_String(uint32_t week)
{
    static const char *WEEK[] = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};

    return (uint8_t*) WEEK[week];
}

void RTC8564_Write_Reg(uint32_t addr, uint32_t data)
{
    I2CWriteLength = 3;
    I2CReadLength = 0;
    I2CMasterBuffer[0] = RTC_DEV_ADDR;
    I2CMasterBuffer[1] = addr;
    I2CMasterBuffer[2] = data;
    I2CEngine();
}

uint32_t RTC8564_Read_Reg(uint32_t addr)
{
    I2CWriteLength = 2;
    I2CReadLength = 1;
    I2CMasterBuffer[0] = RTC_DEV_ADDR;
    I2CMasterBuffer[1] = addr;
    I2CMasterBuffer[2] = RTC_DEV_ADDR | RD_BIT ;
    I2CEngine();
    //
    return I2CSlaveBuffer[0];
}

void RTC8564_Config_Request(void)
{
  if (I2C_Config_Request((uint32_t) I2CMASTER, RTC_DEV_ADDR) == FALSE ) {
    while (1); // Error Trap
  }
}
