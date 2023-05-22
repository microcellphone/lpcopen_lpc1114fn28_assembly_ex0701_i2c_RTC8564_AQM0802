/*****************************************************************************
 *   i2c.c:  I2C C file for NXP LPC11xx Family Microprocessors
 *
 *   Copyright(C) 2008, NXP Semiconductor
 *   All rights reserved.
 *
 *   History
 *   2009.12.07  ver 1.00    Preliminary version, first Release
 *
*****************************************************************************/
#include "chip.h"
#include "i2c.h"

extern uint32_t I2CStart( void );
extern uint32_t I2CStop( void );

extern uint32_t I2CMasterState;
extern uint32_t RdIndex;
extern uint32_t WrIndex;

/*****************************************************************************
** Function name:		I2CEngine
**
** Descriptions:		The routine to complete a I2C transaction
**				from start to stop. All the intermitten
**				steps are handled in the interrupt handler.
**				Before this routine is called, the read
**				length, write length, I2C master buffer,
**				and I2C command fields need to be filled.
**				see i2cmst.c for more details. 
**
** parameters:			None
** Returned value:		true or false, return false only if the
**				start condition can never be generated and
**				timed out. 
** 
*****************************************************************************/
uint32_t I2CEngine( void ) 
{
  I2CMasterState = I2C_IDLE;
  RdIndex = 0;
  WrIndex = 0;
  if ( I2CStart() != TRUE ) {
  	I2CStop();
  	return ( FALSE );
  }

  while ( 1 )  {
  	if ( I2CMasterState == DATA_NACK ) {
  		I2CStop();
  		break;
  	}
  }    
  return ( TRUE );      
}
