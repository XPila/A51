;***************************************************************************************************
;*** SERIAL.a51											****
;***************************************************************************************************
; Implementation file for module SERIAL (UART and SPI).



NAME	SERIAL


$INCLUDE	(MAIN.inc)
IF	USE_SERIAL = 1


IF	SERIAL_Timer = 1

IF	SERIAL_Timer_External = 1
ELSE	;SERIAL_Timer_External = 1
ENDIF	;SERIAL_Timer_External = 1

IF	SERIAL_SMOD = 1
SERIAL_Multiply			EQU	16
ELSE	;SERIAL_SMOD = 1
SERIAL_Multiply			EQU	32
ENDIF	;SERIAL_SMOD = 1

ENDIF	;SERIAL_Timer = 1


SERIAL_RxInProgress		EQU	REN
SERIAL_TxInProgress		EQU	TEN


SERIAL_C	SEGMENT	CODE

IF	SERIAL_D_ADDR = 0
SERIAL_D	SEGMENT	DATA
ENDIF	;SERIAL_D_ADDR = 0

IF	SERIAL_B_ADDR = 0
SERIAL_B	SEGMENT	BIT
ENDIF	;SERIAL_B_ADDR = 0


IF	SERIAL_CallBack = 1
		EXTRN	CODE	(SERIAL_OnRxComplete)
		EXTRN	CODE	(SERIAL_OnTxComplete)
ENDIF	;SERIAL_CallBack = 1

IF	SERIAL_SPI = 1
IF	SERIAL_SPI_CallBack = 1
		EXTRN	CODE	(SERIAL_OnSPI)
ENDIF	;SERIAL_SPI_CallBack = 1
IF	(SERIAL_SPI_R = 1)
		EXTRN	CODE	(SERIAL_OnSPIRxComplete)
ENDIF	;(SERIAL_SPI_R = 1)
IF	(SERIAL_SPI_T = 1)
		EXTRN	CODE	(SERIAL_OnSPITxComplete)
ENDIF	;(SERIAL_SPI_T = 1)
ENDIF	;SERIAL_SPI = 1


		PUBLIC	SERIAL_Init

IF	SERIAL_TimeOutError = 1
		PUBLIC	SERIAL_OnTimer
ENDIF	;SERIAL_TimeOutError = 1

		PUBLIC	SERIAL_Counter
		PUBLIC	SERIAL_Pointer

IF	SERIAL_CheckSumError = 1
		PUBLIC	SERIAL_CheckSum
ENDIF	;SERIAL_CheckSumError = 1

IF	SERIAL_TimeOutError = 1
		PUBLIC	SERIAL_TimeOut
ENDIF	;SERIAL_TimeOutError = 1

IF	SERIAL_FullDuplex = 1
		PUBLIC	SERIAL_CounterR
		PUBLIC	SERIAL_PointerR
ENDIF	;SERIAL_FullDuplex = 1

IF	(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)
		PUBLIC	SERIAL_CheckSumR
ENDIF	;(SERIAL_CheckSumError = 1) AND (SERIAL_CheckSumError = 1)

		PUBLIC	SERIAL_RxInProgress
		PUBLIC	SERIAL_TxInProgress

IF	SERIAL_CheckSumError = 1
		PUBLIC	SERIAL_CheckSumPresent
ENDIF	;SERIAL_CheckSumError = 1

IF	(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
		PUBLIC	SERIAL_Error
ENDIF	;(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)

IF	SERIAL_LoopBack = 1
		PUBLIC	SERIAL_Echo
ENDIF	;SERIAL_LoopBack = 1

IF	(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)
		PUBLIC	SERIAL_CheckSumPresentR
ENDIF	;(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)

IF	SERIAL_SPI = 1
		PUBLIC	SERIAL_SPI_Enabled
ENDIF	;SERIAL_SPI = 1
IF	(SERIAL_SPI = 1)
IF	(SERIAL_SPI_R = 1)
		PUBLIC	SERIAL_SPI_RxData
		PUBLIC	SERIAL_SPI_RCounter
		PUBLIC	SERIAL_SPI_RPointer
ENDIF	;(SERIAL_SPI_R = 1)
ENDIF	;(SERIAL_SPI = 1)

IF	(SERIAL_SPI = 1)
IF	(SERIAL_SPI_T = 1)
		PUBLIC	SERIAL_SPI_TxData
		PUBLIC	SERIAL_SPI_TCounter
		PUBLIC	SERIAL_SPI_TPointer
ENDIF	;(SERIAL_SPI_T = 1)
ENDIF	;(SERIAL_SPI = 1)

		PUBLIC	SERIAL_TimerInit


CSEG	AT	0x0023
		LJMP	INT_Serial


RSEG	SERIAL_C

SERIAL_Init:
		MOV	SCON, #0x00
		SETB	SM1
IF	SERIAL_SMOD = 1
		ORL	PCON, #0x80
ELSE	;SERIAL_SMOD = 1
		ANL	PCON, #0x7f
ENDIF	;SERIAL_SMOD = 1

IF	SERIAL_SPI = 1
		CLR	SERIAL_SPI_Enabled
		MOV	SPCR, #0
		MOV	SPSR, #SERIAL_SPI_SPSR
ENDIF	;SERIAL_SPI = 1

;		SETB	PS
		CLR	PS
		SETB	ES
		RET


SERIAL_TimerInit:
IF	SERIAL_Timer = 1
		ANL	TMOD, #00001111b	; TMOD = 0000????
IF	SERIAL_PWM = 1
		ORL	TMOD, #00010000b	; TMOD = 0001????
		ANL	TCONB, #01000111b	; TCONB = 0?000???
		ORL	TCONB, #10000000b	; TCONB = 1?000???
		MOV	RL1, #SERIAL_RL1
		MOV	RH1, #0x00
		MOV	TH1, #0x00
		MOV	TL1, #0x00
ELSE	;SERIAL_PWM = 1
IF	SERIAL_Timer_External = 1
		ORL	TMOD, #01100000b	; TMOD = 0110????
ELSE	;SERIAL_Timer_External = 1
		ORL	TMOD, #00100000b	; TMOD = 0010????
ENDIF	;SERIAL_Timer_External = 1
		MOV	TH1, #SERIAL_TH1
		MOV	TL1, #0x00
ENDIF	;SERIAL_PWM = 1
		SETB	TR1
ENDIF	;SERIAL_Timer = 1
IF	SERIAL_Timer = 2
		SETB	RCLK
		SETB	TCLK
		MOV	TH2, #0xff
		MOV	TL2, #0xff
		MOV	RCAP2H, #HIGH(SERIAL_R2CAP)
		MOV	RCAP2L, #LOW(SERIAL_R2CAP)
		SETB	TR2
ENDIF	;SERIAL_Timer = 2
		RET


IF	SERIAL_TimeOutError = 1
SERIAL_OnTimer:
		MOV	A, SERIAL_TimeOut
		JZ	SERIAL_OnTimer_End
IF	SERIAL_LoopBack = 1
SERIAL_OnTimer_Tx:
		JNB	TEN, SERIAL_OnTimer_Rx
		DJNZ	SERIAL_TimeOut, SERIAL_OnTimer_End
		SETB	SERIAL_Error
		CLR	REN
		CLR	TEN
IF	SERIAL_CallBack = 1
		JMP	SERIAL_OnTxComplete
ENDIF	;SERIAL_CallBack = 1
ENDIF	;SERIAL_LoopBack = 1
SERIAL_OnTimer_Rx:
		JNB	REN, SERIAL_OnTimer_End
		DJNZ	SERIAL_TimeOut, SERIAL_OnTimer_End
		SETB	SERIAL_Error
		CLR	REN
IF	SERIAL_CallBack = 1
		JMP	SERIAL_OnRxComplete
ENDIF	;SERIAL_CallBack = 1
SERIAL_OnTimer_End:		
		RET
ENDIF	;SERIAL_TimeOutError = 1


IF	SERIAL_SPI = 1
IF	SERIAL_SPI_R = 1
SERIAL_SPI_RxData:
		MOV	A, SERIAL_SPI_RCounter
		JZ	SERIAL_SPI_RxData_End
		MOV	R1, SERIAL_SPI_RPointer
		INC	SERIAL_SPI_RPointer
		MOV	@R1, SPDR
		DJNZ	SERIAL_SPI_RCounter, SERIAL_SPI_RxData_End
		CALL	SERIAL_OnSPIRxComplete
SERIAL_SPI_RxData_End:
		RET
ENDIF	;SERIAL_SPI_R = 1
IF	SERIAL_SPI_T = 1
SERIAL_SPI_TxData:
		MOV	A, SERIAL_SPI_TCounter
		JZ	SERIAL_SPI_TxData_End
		MOV	R0, SERIAL_SPI_TPointer
		INC	SERIAL_SPI_TPointer
		MOV	SPDR, @R0
		DJNZ	SERIAL_SPI_TCounter, SERIAL_SPI_TxData_End
		CALL	SERIAL_OnSPITxComplete
SERIAL_SPI_TxData_End:
		RET
ENDIF	;SERIAL_SPI_T = 1
ENDIF	;SERIAL_SPI = 1


INT_Serial:
		PUSH	PSW
		PUSH	ACC
		PUSH	B
IF	SERIAL_SPI = 1
		JNB	SERIAL_SPI_Enabled, INT_Serial_UART
		MOV	A, SPSR
		JNB	ACC.7, INT_Serial_UART
		MOV	PSW, #0x10		; RS = 2//3
IF	SERIAL_SPI_R = 1
SERIAL_SPI_Rx:
		CALL	SERIAL_SPI_RxData
ENDIF	;SERIAL_SPI_R = 1
IF	SERIAL_SPI_T = 1
SERIAL_SPI_Tx:
		CALL	SERIAL_SPI_TxData
ENDIF	;SERIAL_SPI_T = 1
IF	SERIAL_SPI_CallBack = 1
		CALL	SERIAL_OnSPI
ENDIF	;SERIAL_SPI_CallBack = 1
		ANL	SPSR, #0x7f
		JMP	INT_Serial_End
ENDIF	;SERIAL_SPI = 1

INT_Serial_UART:
		MOV	PSW, #0x10		; RS = 2
INT_Serial_UART_Rx:
		JNB	RI, INT_Serial_UART_Tx
		CLR	RI
		JNB	REN, INT_Serial_UART_Tx
IF	SERIAL_FullDuplex = 1
		MOV	A, SERIAL_CounterR
ELSE	;SERIAL_FullDuplex = 1
		MOV	A, SERIAL_Counter
ENDIF	;SERIAL_FullDuplex = 1
IF	SERIAL_CheckSumError = 1
		JZ	INT_Serial_UART_Rx_CheckSum
ELSE	;SERIAL_CheckSumError = 1
		JZ	INT_Serial_UART_Rx_End
ENDIF	;SERIAL_CheckSumError = 1
IF	SERIAL_FullDuplex = 1
		DEC	SERIAL_CounterR
		MOV	R0, SERIAL_PointerR
		INC	SERIAL_PointerR
ELSE	;SERIAL_FullDuplex = 1
		DEC	SERIAL_Counter
		MOV	R0, SERIAL_Pointer
		INC	SERIAL_Pointer
ENDIF	;SERIAL_FullDuplex = 1
		MOV	A, SBUF
IF	SERIAL_LoopBack = 1
		JB	TEN, INT_Serial_UART_RxTx_Char
ENDIF	;SERIAL_LoopBack = 1
		MOV	@R0, A
IF	SERIAL_FullDuplex = 1
IF	SERIAL_CheckSumError = 1
		JNB	SERIAL_CheckSumPresentR, $+5
		XRL	SERIAL_CheckSumR, A
		JB	SERIAL_CheckSumPresentR, INT_Serial_End
ENDIF	;SERIAL_CheckSumError = 1
		MOV	A, SERIAL_CounterR
ELSE	;SERIAL_FullDuplex = 1
IF	SERIAL_CheckSumError = 1
		JNB	SERIAL_CheckSumPresent, $+5
		XRL	SERIAL_CheckSum, A
		JB	SERIAL_CheckSumPresent, INT_Serial_End
ENDIF	;SERIAL_CheckSumError = 1
		MOV	A, SERIAL_Counter
ENDIF	;SERIAL_FullDuplex = 1
		JZ	INT_Serial_UART_Rx_End
		JMP	INT_Serial_End
IF	SERIAL_LoopBack = 1
INT_Serial_UART_RxTx_Char:
		XRL	A, @R0
INT_Serial_UART_RxTx_End:
		JNZ	INT_Serial_UART_Tx_Error
		CLR	SERIAL_Echo
		SETB	TI
		JMP	INT_Serial_End
ENDIF	;SERIAL_LoopBack = 1
IF	SERIAL_CheckSumError = 1
INT_Serial_UART_Rx_CheckSum:
IF	SERIAL_FullDuplex = 1
		JNB	SERIAL_CheckSumPresentR, INT_Serial_UART_Rx_End
		CLR	SERIAL_CheckSumPresentR
		MOV	A, SBUF
		XRL	A, SERIAL_CheckSumR
ELSE	;SERIAL_FullDuplex = 1
		JNB	SERIAL_CheckSumPresent, INT_Serial_UART_Rx_End
		CLR	SERIAL_CheckSumPresent
		MOV	A, SBUF
		XRL	A, SERIAL_CheckSum
ENDIF	;SERIAL_FullDuplex = 1
ENDIF	;SERIAL_CheckSumError = 1
IF	SERIAL_LoopBack = 1
		JB	TEN, INT_Serial_UART_RxTx_End
ENDIF	;SERIAL_LoopBack = 1
		JZ	INT_Serial_UART_Rx_End
IF	(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
INT_Serial_UART_Rx_error:
		SETB	SERIAL_Error
ENDIF	;(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
INT_Serial_UART_Rx_End:
		CLR	REN
IF	SERIAL_CallBack = 1
		CALL	SERIAL_OnRxComplete
ENDIF	;SERIAL_CallBack = 1
		JMP	INT_Serial_End
INT_Serial_UART_Tx:
		JNB	TI, INT_Serial_End
		CLR	TI
		JNB	TEN, INT_Serial_End
IF	SERIAL_LoopBack = 1
		JB	SERIAL_Echo, INT_Serial_End
		SETB	SERIAL_Echo
ENDIF	;SERIAL_LoopBack = 1
		MOV	A, SERIAL_Counter
IF	SERIAL_CheckSumError = 1
		JZ	INT_Serial_UART_Tx_CheckSum
ELSE	;SERIAL_CheckSumError = 1
		JZ	INT_Serial_UART_Tx_End
ENDIF	;SERIAL_CheckSumError = 1
IF	SERIAL_LoopBack = 0
		DEC	SERIAL_Counter
ENDIF	;SERIAL_LoopBack = 0
		MOV	R1, SERIAL_Pointer
IF	SERIAL_LoopBack = 0
		INC	SERIAL_Pointer
ENDIF	;SERIAL_LoopBack = 0
		MOV	A, @R1
		MOV	SBUF, A
IF	SERIAL_CheckSumError = 1
		JNB	SERIAL_CheckSumPresent, $+5
		XRL	SERIAL_CheckSum, A
ENDIF	;SERIAL_CheckSumError = 1
		JMP	INT_Serial_End
IF	SERIAL_CheckSumError = 1
INT_Serial_UART_Tx_CheckSum:
		JNB	SERIAL_CheckSumPresent, INT_Serial_UART_Tx_End
IF	SERIAL_LoopBack = 0
		CLR	SERIAL_CheckSumPresent
ENDIF	;SERIAL_LoopBack = 0
		MOV	SBUF, SERIAL_CheckSum
ENDIF	;SERIAL_CheckSumError = 1
		JMP	INT_Serial_End
IF	SERIAL_LoopBack = 1
IF	(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
INT_Serial_UART_Tx_Error:
		SETB	SERIAL_Error
ENDIF	;(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
ENDIF	;SERIAL_LoopBack = 1
INT_Serial_UART_Tx_End:
IF	SERIAL_LoopBack = 1
		CLR	REN
ENDIF	;SERIAL_LoopBack = 1
		CLR	TEN
IF	SERIAL_CallBack = 1
		CALL	SERIAL_OnTxComplete
ENDIF	;SERIAL_CallBack = 1
INT_Serial_End:
		POP	B
		POP	ACC
		POP	PSW
		RETI


IF	SERIAL_D_ADDR = 0
RSEG	SERIAL_D
ELSE	;SERIAL_D_ADDR = 0
DSEG	AT	SERIAL_D_ADDR
SERIAL_D:
ENDIF	;SERIAL_D_ADDR = 0

SERIAL_Counter:
		DS	1
SERIAL_Pointer:
		DS	1

IF	SERIAL_CheckSumError = 1
SERIAL_CheckSum:
		DS	1
ENDIF	;SERIAL_CheckSumError = 1

IF	SERIAL_FullDuplex = 1
SERIAL_CounterR:
		DS	1
SERIAL_PointerR:
		DS	1

IF	SERIAL_CheckSumError = 1
SERIAL_CheckSumR:
		DS	1
ENDIF	;SERIAL_CheckSumError = 1

ENDIF	;SERIAL_FullDuplex = 1

IF	SERIAL_TimeOutError = 1
SERIAL_TimeOut:
		DS	1
ENDIF	;SERIAL_TimeOutError = 1


IF	SERIAL_SPI = 1

IF	SERIAL_SPI_R = 1
SERIAL_SPI_RCounter:
		DS	1
SERIAL_SPI_RPointer:
		DS	1
ENDIF	;SERIAL_SPI_R = 1

IF	SERIAL_SPI_T = 1
SERIAL_SPI_TCounter:
		DS	1
SERIAL_SPI_TPointer:
		DS	1
ENDIF	;SERIAL_SPI_T = 1

ENDIF	;SERIAL_SPI = 1



IF	SERIAL_B_ADDR = 0
RSEG	SERIAL_B
ELSE	;SERIAL_B_ADDR = 0
BSEG	AT	SERIAL_B_ADDR
SERIAL_B:
ENDIF	;SERIAL_B_ADDR = 0

TEN:
		DBIT	1

IF	SERIAL_CheckSumError = 1
SERIAL_CheckSumPresent:
		DBIT	1
ENDIF	;SERIAL_CheckSumError = 1

IF	(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)
SERIAL_Error:
		DBIT	1
ENDIF	;(SERIAL_LoopBack = 1) OR (SERIAL_CheckSumError = 1) OR (SERIAL_TimeOutError = 1)

IF	(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)
SERIAL_CheckSumPresentR:
		DBIT	1
ENDIF	;(SERIAL_FullDuplex = 1) AND (SERIAL_CheckSumError = 1)

IF	SERIAL_LoopBack = 1
SERIAL_Echo:
		DBIT	1
ENDIF	;SERIAL_LoopBack = 1

IF	SERIAL_SPI = 1
SERIAL_SPI_Enabled:
		DBIT	1
ENDIF	;SERIAL_SPI = 1


ENDIF	;USE_SERIAL = 1


END
