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
#include "sysctl_11xx_asm.h"

#include "i2c.h"
//#include "st7032.h"

#define PCLK_CLOCK 48000000UL

    .syntax unified

    .text
	.thumb
	.thumb_func
    .type	NVIC_EnableIRQ, %function
NVIC_EnableIRQ:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r2, r0
	adds	r3, r7, #7
	strb	r2, [r3]
	adds	r3, r7, #7
	ldrb	r3, [r3]
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	movs	r2, #1
	lsls	r2, r2, r3
	ldr	r3, .L2
	str	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #8
	pop	{r7, pc}
.L3:
	.align	2
.L2:
	.word	-536813312
	.size	NVIC_EnableIRQ, .-NVIC_EnableIRQ




	.global	I2CMasterState
	.section	.bss.I2CMasterState,"aw",%nobits
	.align	2
	.type	I2CMasterState, %object
	.size	I2CMasterState, 4
I2CMasterState:
	.space	4

	.global	I2CSlaveState
	.section	.bss.I2CSlaveState,"aw",%nobits
	.align	2
	.type	I2CSlaveState, %object
	.size	I2CSlaveState, 4
I2CSlaveState:
	.space	4

	.global	I2CMode
	.section	.bss.I2CMode,"aw",%nobits
	.align	2
	.type	I2CMode, %object
	.size	I2CMode, 4
I2CMode:
	.space	4

	.global	I2CMasterBuffer
	.section	.bss.I2CMasterBuffer,"aw",%nobits
	.align	2
	.type	I2CMasterBuffer, %object
	.size	I2CMasterBuffer, 6
I2CMasterBuffer:
	.space	6

	.global	I2CSlaveBuffer
	.section	.bss.I2CSlaveBuffer,"aw",%nobits
	.align	2
	.type	I2CSlaveBuffer, %object
	.size	I2CSlaveBuffer, 6
I2CSlaveBuffer:
	.space	6

	.global	I2CCount
	.section	.bss.I2CCount,"aw",%nobits
	.align	2
	.type	I2CCount, %object
	.size	I2CCount, 4
I2CCount:
	.space	4

	.global	I2CReadLength
	.section	.bss.I2CReadLength,"aw",%nobits
	.align	2
	.type	I2CReadLength, %object
	.size	I2CReadLength, 4
I2CReadLength:
	.space	4

	.global	I2CWriteLength
	.section	.bss.I2CWriteLength,"aw",%nobits
	.align	2
	.type	I2CWriteLength, %object
	.size	I2CWriteLength, 4
I2CWriteLength:
	.space	4

	.global	RdIndex
	.section	.bss.RdIndex,"aw",%nobits
	.align	2
	.type	RdIndex, %object
	.size	RdIndex, 4
RdIndex:
	.space	4

	.global	WrIndex
	.section	.bss.WrIndex,"aw",%nobits
	.align	2
	.type	WrIndex, %object
	.size	WrIndex, 4
WrIndex:
	.space	4



	.section	.text.I2C_Config_Request,"ax",%progbits
	.align	1
	.global	I2C_Config_Request
	.syntax unified
	.code	16
	.thumb_func
	.fpu softvfp
	.type	I2C_Config_Request, %function
I2C_Config_Request:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, =LPC_SYSCTL_BASE
	ldr	r2, [r3, #SYSCTL_OFFSET_PRESETCTRL]
	ldr	r3, =LPC_SYSCTL_BASE
	movs	r1, #2
	orrs	r2, r1
	str	r2, [r3, #SYSCTL_OFFSET_PRESETCTRL]
	ldr	r2, =LPC_SYSCTL_BASE
	movs	r3, #SYSCTL_OFFSET_SYSAHBCLKCTRL
	ldr	r3, [r2, r3]
	ldr	r1, =LPC_SYSCTL_BASE
	movs	r2, #(1<<5)
	orrs	r3, r2
	movs	r2, #SYSCTL_OFFSET_SYSAHBCLKCTRL
	str	r3, [r1, r2]
	ldr	r3, =LPC_IOCON_BASE
	ldr	r2, [r3, #IOCON_OFFSET_PIO0_4]
	ldr	r3, =LPC_IOCON_BASE
	movs	r1, #63
	bics	r2, r1
	str	r2, [r3, #IOCON_OFFSET_PIO0_4]
	ldr	r3, =LPC_IOCON_BASE
	ldr	r2, [r3, #IOCON_OFFSET_PIO0_4]
	ldr	r3, =LPC_IOCON_BASE
	movs	r1, #1
	orrs	r2, r1
	str	r2, [r3, #IOCON_OFFSET_PIO0_4]
	ldr	r3, =LPC_IOCON_BASE
	ldr	r2, [r3, #IOCON_OFFSET_PIO0_5]
	ldr	r3, =LPC_IOCON_BASE
	movs	r1, #63
	bics	r2, r1
	str	r2, [r3, #IOCON_OFFSET_PIO0_5]
	ldr	r3, =LPC_IOCON_BASE
	ldr	r2, [r3, #IOCON_OFFSET_PIO0_5]
	ldr	r3, =LPC_IOCON_BASE
	movs	r1, #1
	orrs	r2, r1
	str	r2, [r3, #IOCON_OFFSET_PIO0_5]
	ldr	r3, =LPC_I2C_BASE
	movs	r2, #108
	str	r2, [r3, #I2C_OFFSET_CONCLR]
	ldr	r3, =LPC_I2C_BASE
	ldr	r2, =I2SCLL_SCLL
	str	r2, [r3, #I2C_OFFSET_SCLL]
	ldr	r3, =LPC_I2C_BASE
	ldr	r2, =I2SCLH_SCLH
	str	r2, [r3, #I2C_OFFSET_SCLH]
	ldr	r3, [r7, #4]
	cmp	r3, #I2CSLAVE
	bne	MODE_CHECK
	ldr	r3, =LPC_I2C_BASE
	ldr	r2, [r7]
	str	r2, [r3, #I2C_OFFSET_ADR0]
MODE_CHECK:
	movs	r0, #15
	bl	NVIC_EnableIRQ
	ldr	r3, =LPC_I2C_BASE
	movs	r2, #I2C_I2CONSET_I2EN
	str	r2, [r3, #I2C_OFFSET_CONSET]
	movs	r3, #1
	movs	r0, r3
	mov	sp, r7
	add	sp, sp, #8
	pop	{r7, pc}
	.size	I2C_Config_Request, .-I2C_Config_Request


    .text
    .global  I2CStart
	.thumb
	.thumb_func
    .type	I2CStart, %function
I2CStart:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r3, #0
	str	r3, [r7, #4]
	movs	r3, #0
	str	r3, [r7]
	ldr		r1, =LPC_I2C_BASE
	ldr		r2, =I2C_OFFSET_CONSET
	movs	r3, #I2C_I2CONSET_STA
	str	r3, [r1, r2]
FOREVER_LOOP:
	ldr	r3, =I2CMasterState
	ldr	r3, [r3]
	cmp	r3, #I2C_STARTED
	bne	TIMER_CMP
	movs	r3, #1
	str	r3, [r7]
	b	I2CStart_RETURN
TIMER_CMP:
	ldr	r3, [r7, #4]
	ldr	r2, =(MAX_TIMEOUT-1)
	cmp	r3, r2
	bls	TIMER_COUNT
	movs	r3, #0
	str	r3, [r7]
	b	I2CStart_RETURN
TIMER_COUNT:
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
	b	FOREVER_LOOP
I2CStart_RETURN:
	ldr	r3, [r7]
	movs	r0, r3
	mov	sp, r7
	add	sp, sp, #8
	pop	{r7, pc}
	.size	I2CStart, .-I2CStart


    .text
    .global  I2CStop
	.thumb
	.thumb_func
    .type	I2CStop, %function
I2CStop:
	push	{r7, lr}
	add	r7, sp, #0
	ldr		r1, =LPC_I2C_BASE
	ldr		r2, =I2C_OFFSET_CONSET
	movs	r3, #I2C_I2CONSET_STO
	str	r3, [r1, r2]
	ldr		r2, =I2C_OFFSET_CONCLR
	movs	r3, #I2C_I2CONCLR_SIC
	str	r3, [r1, r2]
	nop
WAIT_LOOP:
	ldr		r2, =I2C_OFFSET_CONSET
	ldr	r3, [r1, r2]
	movs	r2, #I2C_I2CONSET_STO
	ands	r3, r2
	bne	WAIT_LOOP
	movs	r3, #1
	movs	r0, r3
	mov	sp, r7
	pop	{r7, pc}
	.size	I2CStop, .-I2CStop


    .text
    .global  I2CInit
	.thumb
	.thumb_func
    .type	I2CInit, %function
I2CInit:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr		r3, =LPC_SYSCTL_BASE+SYSCTL_OFFSET_PRESETCTRL
	ldr		r2, [r3]
	movs	r1, #(1<<RESET_I2C0)
	orrs	r2, r1
	str	r2, [r3]

	ldr		r2, =LPC_SYSCTL_BASE+SYSCTL_OFFSET_SYSAHBCLKCTRL
	ldr		r3, [r2]
	ldr		r1, =LPC_SYSCTL_BASE+SYSCTL_OFFSET_SYSAHBCLKCTRL
	movs	r2, #(1<<5)
	orrs	r3, r2
	str	r3, [r1]
	ldr		r3, =LPC_IOCON_BASE+IOCON_OFFSET_PIO0_4
	ldr	r2, [r3]
	movs	r1, #0x3F
	bics	r2, r1
	str	r2, [r3]
	ldr		r3, =LPC_IOCON_BASE+IOCON_OFFSET_PIO0_4
	ldr		r2, [r3]
	movs	r1, #1
	orrs	r2, r1
	str	r2, [r3]
	ldr		r3, =LPC_IOCON_BASE+IOCON_OFFSET_PIO0_5
	ldr	r2, [r3]
	movs	r1, #0x3F
	bics	r2, r1
	str	r2, [r3]
	ldr		r3, =LPC_IOCON_BASE+IOCON_OFFSET_PIO0_5
	ldr	r2, [r3]
	movs	r1, #1
	orrs	r2, r1
	str	r2, [r3]
	ldr		r3, =LPC_I2C_BASE+I2C_OFFSET_CONCLR
	movs	r2, #(I2C_I2CONCLR_AAC | I2C_I2CONCLR_SIC | I2C_I2CONCLR_STAC | I2C_I2CONCLR_I2ENC)
	str	r2, [r3]
	ldr		r3, =LPC_I2C_BASE+I2C_OFFSET_SCLL
	ldr r2, =I2SCLL_SCLL
	str	r2, [r3]
	ldr		r3, =LPC_I2C_BASE+I2C_OFFSET_SCLH
	ldr r2, =I2SCLH_SCLH
	str	r2, [r3]
	ldr	r3, [r7, #4]
	cmp	r3, #I2CSLAVE
	bne	.L5
	ldr		r3, =LPC_I2C_BASE+I2C_OFFSET_ADR0
	movs	r2, #AQM0802_ADDR
	str	r2, [r3]
.L5:
	movs	r0, #15
	bl	NVIC_EnableIRQ
	ldr		r3, =LPC_I2C_BASE+I2C_OFFSET_CONSET
	movs	r2, #I2C_I2CONSET_I2EN
	str	r2, [r3]
	movs	r3, #1
	movs	r0, r3
	mov	sp, r7
	add	sp, sp, #8
	pop	{r7, pc}
	.size	I2CInit, .-I2CInit
