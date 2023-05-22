/*
Here are some common GCC directives for ARM Cortex-M0 assembly:

.align: Specifies the byte alignment of the following instruction or data item.
.ascii: Specifies a string of characters to be included in the output file.
.asciz: Specifies a zero-terminated string of characters to be included in the output file.
.byte: Specifies one or more bytes of data to be included in the output file.
.data: Marks the start of a data section.
.global: Marks a symbol as visible outside of the current file.
.section: Specifies the section of memory where the following instructions or data items should be placed.
.space: Reserves a block of memory with a specified size.
.thumb: Instructs the assembler to generate Thumb code.
.thumb_func: Marks a function as using the Thumb instruction set.
.word: Specifies one or more words of data to be included in the output file.

Note that this is not an exhaustive list, and different versions of GCC may support additional or different directives.
*/
#include "i2c_11xx_asm.h"
#include "iocon_11xx_asm.h"
#include "gpio_11xx_2_asm.h"
#include "i2c.h"


//; Define constants for I2C states
#define I2C_STATUS_START                (0x08)
#define I2C_STATUS_REPEATED_START       (0x10)
#define I2C_STATUS_SLAW_ACK             (0x18)
#define I2C_STATUS_SLAW_NACK            (0x20)
#define I2C_STATUS_DATA_TX_ACK          (0x28)
#define I2C_STATUS_DATA_TX_NACK         (0x30)
#define I2C_STATUS_ARBITRATION_LOST     (0x38)
#define I2C_STATUS_SLAR_ACK             (0x40)
#define I2C_STATUS_SLAR_NACK            (0x48)
#define I2C_STATUS_DATA_RX_ACK          (0x50)
#define I2C_STATUS_DATA_RX_NACK         (0x58)
#define I2C_STATUS_SLAVE_GENERAL_CALL   (0x70)
#define I2C_STATUS_SLAVE_SLAW_ACK       (0x60)
#define I2C_STATUS_SLAVE_SLAW_NACK      (0x68)
#define I2C_STATUS_SLAVE_DATA_RX_ACK    (0x80)
#define I2C_STATUS_SLAVE_DATA_RX_NACK   (0x88)
#define I2C_STATUS_SLAVE_STOP           (0xA0)
#define I2C_STATUS_SLAVE_REPEATED_START (0xA8)
#define I2C_STATUS_SLAVE_SLAR_ACK       (0xB0)
#define I2C_STATUS_SLAVE_SLAR_NACK      (0xB8)
#define I2C_STATUS_SLAVE_DATA_TX_ACK    (0xC0)
#define I2C_STATUS_SLAVE_DATA_TX_NACK   (0xC8)
#define I2C_STATUS_SLAVE_LAST_DATA_TX   (0xC8)
#define I2C_STATUS_BUS_ERROR            (0x00)

.extern  I2CMasterState
.extern  I2CSlaveState
.extern  I2CMode
.extern  I2CMasterBuffer
.extern  I2CSlaveBuffer
.extern  I2CCount
.extern  I2CReadLength
.extern  I2CWriteLength
.extern  RdIndex
.extern  WrIndex

    .syntax unified

	.cpu cortex-m0
	.text
	.global	I2C_IRQHandler
	.thumb_func
	.type	I2C_IRQHandler, %function
I2C_IRQHandler:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0

	// Check interrupt source
	ldr r0, =LPC_I2C_BASE
	ldr r1, [r0, #I2C_OFFSET_STAT]

	cmp r1, #I2C_STATUS_START				// 0x08 : A Start condition is issued.
	bne NEXT_1
	b .start_transmitted
	b I2C_IRQHandler_RETURN
NEXT_1:
	cmp r1, #I2C_STATUS_REPEATED_START		// 0x10 : A repeated started is issued
	bne NEXT_2
	b .repeated_start_transmitted
NEXT_2:
	cmp r1, #I2C_STATUS_SLAW_ACK			// 0x18 : Regardless, it's a ACK
	bne NEXT_3
	b .sla_w_ack_received
NEXT_3:
	cmp r1, #I2C_STATUS_DATA_TX_ACK			// 0x28 : Data byte has been transmitted, regardless ACK or NACK
	beq SAME_0x28_0x30
NEXT_4:
	cmp r1, #I2C_STATUS_DATA_TX_NACK		// 0x30 : Data byte has been transmitted, regardless ACK or NACK
	bne NEXT_5
SAME_0x28_0x30:
	b .data_tx_nack_received
NEXT_5:
	cmp r1, #I2C_STATUS_SLAR_ACK			// 0x40 : Master Receive, SLA_R has been sent
	bne NEXT_6
	b .sla_r_ack_received
NEXT_6:
	cmp r1, #I2C_STATUS_DATA_RX_ACK			// 0x50 : Data byte has been received, regardless following ACK or NACK
	bne NEXT_7
	b .data_rx_ack_received
NEXT_7:
	cmp r1, #I2C_STATUS_DATA_RX_NACK		// 0x58 : SLA+R transmitted, ACK received
	bne NEXT_8
	b .data_rx_nack_received
NEXT_8:
	cmp r1, #I2C_STATUS_SLAW_NACK			// 0x20 : regardless, it's a NACK
	beq SAME_0x48
NEXT_9:
	cmp r1, #I2C_STATUS_SLAR_NACK			// 0x48
	bne NEXT_10
SAME_0x48:
	b .sla_r_nack_received
NEXT_10:
	cmp r1, #I2C_STATUS_ARBITRATION_LOST		// 0x38 : Arbitration lost, in this example, we don't deal with multiple master situation
	bne NEXT_11
	b .arbitration_lost_received
NEXT_11:
	b default_function
I2C_IRQHandler_RETURN:
	nop
	mov	sp, r7
	add	sp, sp, #8
	pop	{r7, pc}
	.size	I2C_IRQHandler, .-I2C_IRQHandler


	.text
	.global	.start_transmitted
	.thumb_func
	.type	.start_transmitted, %function
.start_transmitted:
JUMP_0x08:
//		WrIndex         = 0;
	ldr	r3, =WrIndex
	movs	r2, #0
	str	r2, [r3]
	ldr	r3, =WrIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =WrIndex
	str	r1, [r2]
//	LPC_I2C->DAT    = I2CMasterBuffer[WrIndex++];
	ldr	r2, =I2CMasterBuffer
	ldrb	r2, [r2, r3]
	ldr		r3, =LPC_I2C_BASE
	str	r2, [r3, #I2C_OFFSET_DAT]
//	LPC_I2C->CONCLR = (I2CONCLR_SIC | I2CONCLR_STAC);
	ldr		r3, =LPC_I2C_BASE
	movs r2, #I2C_I2CONCLR_SIC
	movs r4, #I2C_I2CONCLR_STAC
	orrs r2, r2, r4
	str	r2, [r3, #I2C_OFFSET_CONCLR]
//	I2CMasterState  = I2C_STARTED;
	ldr	r3, =I2CMasterState
	movs	r2, #I2C_STARTED
	str	r2, [r3]
	b	I2C_IRQHandler_RETURN
//	bx lr


	.text
	.global	.repeated_start_transmitted
	.thumb_func
	.type	.repeated_start_transmitted, %function
.repeated_start_transmitted:
JUMP_0x10: //.L10:
//	RdIndex = 0;
	ldr	r3, =RdIndex
	movs	r2, #0
	str	r2, [r3]
//	LPC_I2C->DAT    = I2CMasterBuffer[WrIndex++];
	ldr	r3, =WrIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =WrIndex
	str	r1, [r2]
	ldr	r2, =I2CMasterBuffer
	ldrb	r2, [r2, r3]
	ldr		r3, =LPC_I2C_BASE
	str	r2, [r3, #I2C_OFFSET_DAT]
//	LPC_I2C->CONCLR = (I2CONCLR_SIC | I2CONCLR_STAC);
	ldr		r3, =LPC_I2C_BASE
	movs r4, #I2C_I2CONCLR_SIC
	movs r5, #I2C_I2CONCLR_STAC
	orrs r5, r5, r4
	movs	r2, r5
	str	r2, [r3, #I2C_OFFSET_CONCLR]
//	I2CMasterState  = I2C_RESTARTED;
	ldr	r3, =I2CMasterState
	movs	r2, #I2C_RESTARTED
	str	r2, [r3]
	b	I2C_IRQHandler_RETURN
//	bx lr


	.text
	.global	.sla_w_ack_received
	.thumb_func
	.type	.sla_w_ack_received, %function
.sla_w_ack_received:
JUMP_0x18: //.L9:
//	if ( I2CMasterState == I2C_STARTED ) {
	ldr	r3, =I2CMasterState
	ldr	r3, [r3]
	cmp	r3, #I2C_STARTED
	bne	COMMON_CONCLR
//	  LPC_I2C->DAT   = I2CMasterBuffer[WrIndex++];
	ldr	r3, =WrIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =WrIndex
	str	r1, [r2]
	ldr	r2, =I2CMasterBuffer
	ldrb	r2, [r2, r3]
	ldr		r3, =LPC_I2C_BASE
	str	r2, [r3, #I2C_OFFSET_DAT]
//	  I2CMasterState = DATA_ACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_ACK
	str	r2, [r3]
//	LPC_I2C->CONCLR = I2CONCLR_SIC;
	b	COMMON_CONCLR
//	bx lr



	.text
	.global	COMMON_CONCLR
	.thumb_func
	.type	COMMON_CONCLR, %function
COMMON_CONCLR:
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	I2C_IRQHandler_RETURN
//	bx lr



	.text
	.global	.data_tx_ack_received
	.thumb_func
	.type	.data_tx_ack_received, %function
.data_tx_ack_received:
	b JUMP_0x28_0x30
	bx lr


	.text
	.global	.data_tx_nack_received
	.thumb_func
	.type	.data_tx_nack_received, %function
.data_tx_nack_received:
	b JUMP_0x28_0x30
	bx lr



	.text
	.global	JUMP_0x28_0x30
	.thumb_func
	.type	JUMP_0x28_0x30, %function
JUMP_0x28_0x30:
//	if ( WrIndex < I2CWriteLength )	{
	ldr	r3, =WrIndex
	ldr	r2, [r3]
	ldr	r3, =I2CWriteLength
	ldr	r3, [r3]
	cmp	r2, r3
	bcs	JUMP_0x28_0x30_CONTINUE
//	  LPC_I2C->DAT   = I2CMasterBuffer[WrIndex++]; // this should be the last one
	ldr	r3, =WrIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =WrIndex
	str	r1, [r2]
	ldr	r2, =I2CMasterBuffer
	ldrb	r2, [r2, r3]
	ldr		r3, =LPC_I2C_BASE
	str	r2, [r3, #I2C_OFFSET_DAT]
//	  I2CMasterState = DATA_ACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_ACK
	str	r2, [r3]
	b	JUMP_0x28_0x30_CONTINUE_2
JUMP_0x28_0x30_CONTINUE:
//	  if ( I2CReadLength != 0 ) {
	ldr	r3, =I2CReadLength
	ldr	r3, [r3]
	cmp	r3, #0
	beq	JUMP_0x28_0x30_CONTINUE_1
//	  	LPC_I2C->CONSET = I2CONSET_STA;	// Set Repeated-start flag
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_STA  //0x20
	str	r2, [r3, #I2C_OFFSET_CONSET]
//	  	I2CMasterState  = I2C_REPEATED_START;
	ldr	r3, =I2CMasterState
	movs	r2, #3
	str	r2, [r3]
	b	JUMP_0x28_0x30_CONTINUE_2
JUMP_0x28_0x30_CONTINUE_1:
//	  	I2CMasterState = DATA_NACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_NACK
	str	r2, [r3]
//	  	LPC_I2C->CONSET = I2CONSET_STO;      // Set Stop flag
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_STO
	str	r2, [r3, #I2C_OFFSET_CONSET]
JUMP_0x28_0x30_CONTINUE_2:
//	LPC_I2C->CONCLR = I2CONCLR_SIC;
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	I2C_IRQHandler_RETURN
//	bx lr



	.text
	.global	.sla_r_ack_received
	.thumb_func
	.type	.sla_r_ack_received, %function
.sla_r_ack_received:
JUMP_0x40:
//	if ( I2CReadLength == 1 )	{
	ldr	r3, =I2CReadLength
	ldr	r3, [r3]
	cmp	r3, #1
	bne	JUMP_0x40_CONTINUE_1
//	  LPC_I2C->CONCLR = I2CONCLR_AAC;	// assert NACK after data is received
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_AAC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	JUMP_0x40_CONTINUE_2
JUMP_0x40_CONTINUE_1:
//	  LPC_I2C->CONSET = I2CONSET_AA;	// assert ACK after data is received
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_AA
	str	r2, [r3, #I2C_OFFSET_CONSET]
JUMP_0x40_CONTINUE_2:
//	LPC_I2C->CONCLR = I2CONCLR_SIC;
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	I2C_IRQHandler_RETURN
//	bx lr



	.text
	.global	.data_rx_ack_received
	.thumb_func
	.type	.data_rx_ack_received, %function
.data_rx_ack_received:
JUMP_0x50: //.L4:
//	I2CSlaveBuffer[RdIndex++] = LPC_I2C->DAT;
	ldr		r3, =LPC_I2C_BASE
	ldr	r0, [r3, #I2C_OFFSET_DAT]
	ldr	r3, =RdIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =RdIndex
	str	r1, [r2]
	uxtb	r1, r0
	ldr	r2, =I2CSlaveBuffer
	strb	r1, [r2, r3]
//	if ( RdIndex < I2CReadLength ) {
	ldr	r3, =RdIndex
	ldr	r2, [r3]
	ldr	r3, =I2CReadLength
	ldr	r3, [r3]
	cmp	r2, r3
	bcs	JUMP_0x50_CONTINUE_1
//	  I2CMasterState = DATA_ACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_ACK
	str	r2, [r3]
//	  LPC_I2C->CONSET = I2CONSET_AA;	// assert ACK after data is received
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_AA
	str	r2, [r3, #I2C_OFFSET_CONSET]
	b	JUMP_0x50_CONTINUE_2
JUMP_0x50_CONTINUE_1:
//	  I2CMasterState = DATA_NACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_NACK
	str	r2, [r3]
//	  LPC_I2C->CONCLR = I2CONCLR_AAC;	// assert NACK on last byte
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_AAC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
JUMP_0x50_CONTINUE_2:
//	LPC_I2C->CONCLR = I2CONCLR_SIC;
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	I2C_IRQHandler_RETURN
//	bx lr



	.text
	.global	.data_rx_nack_received
	.thumb_func
	.type	.data_rx_nack_received, %function
.data_rx_nack_received:
JUMP_0x58:
//	I2CSlaveBuffer[RdIndex++] = LPC_I2C->DAT;
	ldr		r3, =LPC_I2C_BASE
	ldr	r0, [r3, #I2C_OFFSET_DAT]
	ldr	r3, =RdIndex
	ldr	r3, [r3]
	adds	r1, r3, #1
	ldr	r2, =RdIndex
	str	r1, [r2]
	uxtb	r1, r0
	ldr	r2, =I2CSlaveBuffer
	strb	r1, [r2, r3]
//	I2CMasterState = DATA_NACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_NACK
	str	r2, [r3]
//	LPC_I2C->CONSET = I2CONSET_STO;	// Set Stop flag
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_STO
	str	r2, [r3]
//	LPC_I2C->CONCLR = I2CONCLR_SIC;	// Clear SI flag
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	b	I2C_IRQHandler_RETURN
//	bx lr



	.text
	.global	.sla_w_nack_received
	.thumb_func
	.type	.sla_w_nack_received, %function
.sla_w_nack_received:
	b JUMP_0x48
	bx lr


	.text
	.global	.sla_r_nack_received
	.thumb_func
	.type	.sla_r_nack_received, %function
.sla_r_nack_received:
	b JUMP_0x48
	bx lr


	.text
	.global	JUMP_0x48
	.thumb_func
	.type	JUMP_0x48, %function
JUMP_0x48:  //.L5:
//	LPC_I2C->CONCLR = I2CONCLR_SIC;
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
//	I2CMasterState = DATA_NACK;
	ldr	r3, =I2CMasterState
	movs	r2, #DATA_NACK
	str	r2, [r3]
	b	I2C_IRQHandler_RETURN
//	bx lr




	.text
	.global	.arbitration_lost_received
	.thumb_func
	.type	.arbitration_lost_received, %function
.arbitration_lost_received:
	b	COMMON_COMPLETION
//	bx lr


	.text
	.global	default_function
	.thumb_func
	.type	default_function, %function
default_function:
	b	COMMON_COMPLETION
//	bx lr


	.text
	.global	COMMON_COMPLETION
	.thumb_func
	.type	COMMON_COMPLETION, %function
COMMON_COMPLETION: //.L3:
	ldr		r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONCLR_SIC
	str	r2, [r3, #I2C_OFFSET_CONCLR]
//	nop
	b I2C_IRQHandler_RETURN
//	bx lr

