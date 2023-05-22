#ifndef __RTC8564_H__
#define __RTC8564_H__

#include "chip.h"



#define TZD (+9) // Japan
#define RTC_DEV_ADDR 0xa2

#define RTC_CONTROL1 0x00
#define RTC_CONTROL2 0x01
#define RTC_SECONDS  0x02
#define RTC_MINUTES  0x03
#define RTC_HOURS    0x04
#define RTC_DAYS     0x05
#define RTC_WEEKDAYS 0x06
#define RTC_C_MONTHS 0x07
#define RTC_YEARS    0x08
#define RTC_MINUTE_ALARM  0x09
#define RTC_HOUR_ALARM    0x0a
#define RTC_DAY_ALARM     0x0b
#define RTC_WEEKDAY_ALARM 0x0c
#define RTC_CLKOUT_FREQ   0x0d
#define RTC_TIMER_CONTROL 0x0e
#define RTC_TIMER         0x0f

typedef struct
{
    uint8_t  year; // RTC year
    uint8_t  mon;  // RTC month
    uint8_t  day;  // RTC day
    uint8_t  week; // RTC week
    uint8_t  hour; // RTC hour
    uint8_t  min;  // RTC minute
    uint8_t  sec;  // RTC second
} RTC_INFO_T;

enum WEEK {SUN = 0, MON, TUE, WED, THU, FRI, SAT};

void RTC_Config_Request(uint32_t do_adj, uint8_t year, uint8_t month,  uint8_t day,
              uint8_t week,    uint8_t hour, uint8_t minute, uint8_t second);
void RTC_Get_Data(RTC_INFO_T *psRTC);
uint8_t *Get_Week_String(uint32_t week);
void RTC8564_Write_Reg(uint32_t addr, uint32_t data);
uint32_t RTC8564_Read_Reg(uint32_t addr);
void RTC8564_Config_Request(void);

#endif // __GPSRTC_H__
