;***************************************************************************************************
;*** SERIAL.inc											****
;***************************************************************************************************
; Include file for module SERIAL (UART and SPI).



IF	USE_SERIAL = 1


		EXTRN	CODE	(SERIAL_Init)			; must be called at startup

IF	SERIAL_TimeOutError = 1
		EXTRN	CODE	(SERIAL_OnTimer)
ENDIF	;SERIAL_TimeOutError = 1

		EXTRN	DATA	(SERIAL_Counter)
		EXTRN	DATA	(SERIAL_Pointer)

IF	SERIAL_CheckSumError = 1
		EXTRN	DATA	(SERIAL_CheckSum)
ENDIF	;SERIAL_CheckSumError = 1

IF	SERIAL_TimeOutError = 1
		EXTRN	DATA	(SERIAL_TimeOut)
ENDIF	;SERIAL_TimeOutError = 1

IF	SERIAL_FullDuplex = 1
		EXTRN	DATA	(SERIAL_CounterR)
		EXTRN	DATA	(SERIAL_PointerR)
ENDIF	;SERIAL_FullDuplex = 1

IF	(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)
		EXTRN	DATA	(SERIAL_CheckSumR)
ENDIF	;(SERIAL_CheckSumError = 1) AND (SERIAL_CheckSumError = 1)

		EXTRN	BIT	(SERIAL_RxInProgress)
		EXTRN	BIT	(SERIAL_TxInProgress)

IF	SERIAL_CheckSumError = 1
		EXTRN	BIT	(SERIAL_CheckSumPresent)
ENDIF	;SERIAL_CheckSumError = 1

IF	(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
		EXTRN	BIT	(SERIAL_Error)
ENDIF	;(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)

IF	SERIAL_LoopBack = 1
		EXTRN	BIT	(SERIAL_Echo)
ENDIF	;SERIAL_LoopBack = 1

IF	(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)
		EXTRN	BIT	(SERIAL_CheckSumPresentR)
ENDIF	;(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)

IF	SERIAL_SPI = 1
		EXTRN	BIT	(SERIAL_SPI_Enabled)
ENDIF	;SERIAL_SPI = 1

IF	(SERIAL_SPI = 1)
IF	(SERIAL_SPI_R = 1)
		EXTRN	CODE	(SERIAL_SPI_RxData)
		EXTRN	DATA	(SERIAL_SPI_RCounter)
		EXTRN	DATA	(SERIAL_SPI_RPointer)
ENDIF	;(SERIAL_SPI_R = 1)
ENDIF	;(SERIAL_SPI = 1)

IF	(SERIAL_SPI = 1)
IF	(SERIAL_SPI_T = 1)
		EXTRN	CODE	(SERIAL_SPI_TxData)
		EXTRN	DATA	(SERIAL_SPI_TCounter)
		EXTRN	DATA	(SERIAL_SPI_TPointer)
ENDIF	;(SERIAL_SPI_T = 1)
ENDIF	;(SERIAL_SPI = 1)

		EXTRN	CODE	(SERIAL_TimerInit)

ENDIF	;USE_SERIAL = 1
