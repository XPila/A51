;***************************************************************************************************
;*** MAIN.inc											****
;***************************************************************************************************
; Main include file (XProgISP [AT89LP2052@20MHz/XBus@115200Bd]).


$INCLUDE	(..\AT\89LPx052.inc)

DEBUG				EQU	0

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F1				EQU	PSW.1		; PSW.1

USE_SYSTEM			EQU	1		; Use module SYSTEM.		(44 bytes)
USE_MEMORY			EQU	1		; Use module MEMORY.		(27 bytes)
USE_TIMER			EQU	1		; Use module TIMER.		(83 bytes)
USE_CLOCK			EQU	1		; Use module CLOCK.		(56 bytes)
USE_CALENDAR			EQU	1		; Use module CALENDAR.		(87 bytes)
USE_SERIAL			EQU	1		; Use module SERIAL.		(218 bytes)
USE_XBUS			EQU	1		; Use module XBUS.		(281 bytes)
USE_XSLAVE			EQU	1		; Use module XSLAVE.		(214 bytes)
USE_I2C				EQU	1		; Use module I2C.		(xxx bytes)
USE_AT24C256			EQU	1		; Use module AT24C256.		(xxx bytes)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module SYSTEM configuration.
SYSTEM_D_ADDR			EQU	0x30		; Data segment SYSTEM_D address (IRam - 1byte)
SYSTEM_B_ADDR			EQU	0x00		; Bit segment SYSTEM_B address (Bit - 2)
SYSTEM_StackTop			EQU	0xbf		; Stack top @0xc0 (stack size = 48bytes).


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module MEMORY configuration.
MEMORY_X			EQU	0		; External memory present/absent.
MEMORY_MULTI			EQU	0		; Multiple memory type unified access (LD/ST).
MEMORY_CallBack			EQU	0		; Callback for MemLD/MemST (M0..3).

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module TIMER configuration.
TIMER_D_ADDR			EQU	0x31		; Data segment TIMER_D address (IRam - 4bytes)
TIMER_Timer			EQU	0		; Use Timer0.
TIMER_PWM			EQU	0		; Use timer in PWM mode.
TIMER_CNT			EQU	200		; Timer periode = 10us = 200 ticks.
TIMER_CNT0			EQU	100		; Timer divisor - periode = 1ms/10us = 100.
TIMER_CNT1			EQU	10		; Timer periode = 10ms/1ms = 10.
TIMER_CallBack			EQU	1		; Timer callback (100us).
TIMER_CallBack0			EQU	1		; Timer callback (1ms).
TIMER_CallBack1			EQU	1		; Timer callback (10ms).


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module CLOCK configuration.
CLOCK_D_ADDR			EQU	0x35		; Data segment CLOCK_D address (IRam - 4bytes)
CLOCK_B_ADDR			EQU	0x02		; Bit segment CLOCK_B address (Bit - 1)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module CALENDAR configuration.
CALENDAR_D_ADDR			EQU	0x39		; Data segment CALENDAR_D address (IRam - 4bytes)
CALENDAR_B_ADDR			EQU	0x03		; Bit segment CALENDAR_B address (Bit - 1)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module SERIAL configuration.
SERIAL_D_ADDR			EQU	0x3d		; Data segment SERIAL_D address (IRam - 8bytes)
SERIAL_B_ADDR			EQU	0x04		; Bit segment SERIAL_B address (Bit - 5)
SERIAL_Timer			EQU	1		; Use timer1 to generate baudrate.
SERIAL_Timer_External		EQU	0		; Use external clock on T1.
SERIAL_PWM			EQU	0		; Use timer1 to generate baudrate.
SERIAL_SMOD			EQU	1		; SMOD bit value (baudrate *= 2).
SERIAL_TH1			EQU	0xF5		; TH1 = 0xf5 - Baudrate = 115200.
SERIAL_LoopBack			EQU	1		; Tx to Rx loopback.
SERIAL_FullDuplex		EQU	0		; Full duplex - separate rx/tx buffer.
SERIAL_CallBack			EQU	1		; Perform call-back notification.
SERIAL_CheckSumError		EQU	1		; Supports checksum error checking.
SERIAL_TimeOutError		EQU	1		; Supports timeout error checking.
SERIAL_SPI			EQU	1       	; Use SPI.
SERIAL_SPI_SPCR			EQU	11010000b	; SPI control register (f/4, MSB first, master).
SERIAL_SPI_SPSR			EQU	00000000b	; SPI status register (standard mode).
SERIAL_SPI_CallBack		EQU	0		; SPI event callback.
SERIAL_SPI_R			EQU	1		; SPI buffered data reception enabled.
SERIAL_SPI_T			EQU	1		; SPI buffered data transmit enabled.
SERIAL_SPI_RCallBack		EQU	1		; SPI buffered data reception complete event callback.
SERIAL_SPI_TCallBack		EQU	1		; SPI buffered data transmit complete event callback.


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module XBUS configuration.
XBUS_D_ADDR			EQU	0x45		; Data segment XBUS_D address (IRam - 7bytes)
XBUS_B_ADDR			EQU	0x09		; Bit segment XBUS_B address (Bit - 5)
XBUS_D_ADDR_Data		EQU	0x80		; Data buffer XBUS_Data address (IRam - 8bytes)
XBUS_StartChar			EQU	0x5A		; XBus protocol starting character
XBUS_AckChar			EQU	0xA5		; XBus protocol acknowledge character
XBUS_TimeOut_TxStart		EQU	200		; Timeout
XBUS_TimeOut_TxHeader		EQU	200		; Timeout
XBUS_TimeOut_TxData		EQU	200		; Timeout
XBUS_TimeOut_TxAck		EQU	200		; Timeout
XBUS_TimeOut_RxStart		EQU	200		; Timeout
XBUS_TimeOut_RxHeader		EQU	200		; Timeout
XBUS_TimeOut_RxData		EQU	200		; Timeout
XBUS_TimeOut_RxAck		EQU	200		; Timeout
XBUS_TxInterleave		EQU	0		; Direction change interleave 
XBUS_CallBack			EQU	0		; Perform call-back notification
XBUS_DirectionOut		EQU	0		; Setup XBUS_DIR pin (rx/tx)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module XSLAVE configuration.
XSLAVE_D_ADDR			EQU	0x54		; Data segment XSLAVE_D address (IRam - 0bytes)
XSLAVE_B_ADDR			EQU	0x0e		; Bit segment XSLAVE_B address (Bit - 1)
XSLAVE_DefaultNodeID		EQU	0xff
XSLAVE_ModuleNameString		MACRO
				DB	"PrgS_mN1"
				ENDM


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module I2C configuration.
I2C_PortModeReg0		EQU	P1M0
I2C_PortModeReg1		EQU	P1M1
I2C_PortModeMskClock		EQU	(00000001b)
I2C_PortModeMskData		EQU	(00000010b)
I2C_CLOCK			BIT	P1.0		; P1.0
I2C_DATA			BIT	P1.1		; P1.1


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module AT24C256 configuration.
AT24C256_ADDRESS		EQU	(0x50 + 0x80)	; I2C chipp addres for AT24C256 (16bit address)
AT24C256_DELAY			EQU	10		; I2C wait delay for AT24C256


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Module MAIN configuration.
MAIN_D_ADDR			EQU	0x54		; Data segment MAIN_D address (IRam - 1byte)
MAIN_B_ADDR			EQU	0x0f		; Bit segment MAIN_B address (Bit - 1)
MAIN_VersionMajor		EQU	0		; Version number major 
MAIN_VersionMinor		EQU	9		; Version number minor
MAIN_VersionBuild		EQU	99		; Build number
MAIN_SupportL			EQU	0x0769		; Support word low
MAIN_SupportH			EQU	0x0000		; Support word high


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; IRam Memory map
; Addr	Len	Description
; 0x00	8	Register bank 0
; 0x08	8	Register bank 1
; 0x10	8	Register bank 2
; 0x18	8	Register bank 3
; 0x20	16	Bit addressable 
; 0x30	1	SYSTEM_ControlValue
; 0x35	4	CLOCK_D_ADDR
; 0x39	4	CALENDAR_D_ADDR
; 0x3d	8	SERIAL_D_ADDR
; 0x45	7	XBUS_D_ADDR
; 0x54	0	XSLAVE_D_ADDR
; 0x54	1	MAIN_D_ADDR
; 0x55	1	XPROG_D_ADDR
; 0x80	8	XBUS_D_ADDR_Data
; 0x88	88	IRamH
; 0xc0	32	Stack
; BitRam Memory map
; 0x00	0x20.0	SYSTEM_ResetFlag
; 0x01	0x20.1	SYSTEM_ColdResetFlag
