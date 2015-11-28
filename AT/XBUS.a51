;***************************************************************************************************
;*** XBUS.a51											****
;***************************************************************************************************
; Implementation file for module XBUS (extended multinode master slave byte protocol via serial UART)



NAME	XBUS


$INCLUDE	(MAIN.inc)
IF	USE_XBUS = 1


$INCLUDE	(SERIAL.inc)


XBUS_PHASE_None			EQU	0
XBUS_PHASE_Start		EQU	1
XBUS_PHASE_Header		EQU	2
XBUS_PHASE_Data			EQU	3
XBUS_PHASE_Ack			EQU	4
XBUS_PHASE_Complete		EQU	5

XBUS_MSK_DataSize		EQU	0x07
XBUS_BIT_Data			EQU	3
XBUS_FLG_Data			EQU	0x08
XBUS_BIT_Read			EQU	6
XBUS_FLG_Read			EQU	0x40
XBUS_BIT_Write			EQU	7
XBUS_FLG_Write			EQU	0x80


XBUS_C	SEGMENT	CODE

IF	XBUS_D_ADDR = 0
XBUS_D	SEGMENT	DATA
ENDIF	;XBUS_D_ADDR = 0

IF	XBUS_B_ADDR = 0
XBUS_B	SEGMENT	BIT
ENDIF	;XBUS_B_ADDR = 0


IF	XBUS_CallBack = 1
		EXTRN	CODE	(XBUS_OnRxComplete)
		EXTRN	CODE	(XBUS_OnTxComplete)
ENDIF	;XBUS_CallBack = 1
		

		PUBLIC	XBUS_Init
		PUBLIC	XBUS_OnTimer
		PUBLIC	XBUS_StartRxMessage
		PUBLIC	XBUS_StartTxMessage
		PUBLIC	SERIAL_OnRxComplete
		PUBLIC	SERIAL_OnTxComplete

		PUBLIC	XBUS_Phase
		PUBLIC	XBUS_NodeID
		PUBLIC	XBUS_Header
		PUBLIC	XBUS_Header_NodeID
		PUBLIC	XBUS_Header_MessageID
		PUBLIC	XBUS_Header_DataSize
		PUBLIC	XBUS_Data

		PUBLIC	XBUS_RxInProgress
		PUBLIC	XBUS_TxInProgress
		PUBLIC	XBUS_AcknowledgeAll
		PUBLIC	XBUS_Error

		PUBLIC	XBUS_MSK_DataSize
		PUBLIC	XBUS_BIT_Data
		PUBLIC	XBUS_FLG_Data
		PUBLIC	XBUS_BIT_Read
		PUBLIC	XBUS_FLG_Read
		PUBLIC	XBUS_BIT_Write
		PUBLIC	XBUS_FLG_Write


RSEG	XBUS_C

XBUS_Init:
		CLR	XBUS_RxInProgress
		CLR	XBUS_TxInProgress
		CLR	XBUS_Error
		CLR	XBUS_AcknowledgeAll
		CLR	XBUS_Direction
IF	XBUS_DirectionOut = 1
		CLR	XBUS_DIR
ENDIF	;XBUS_DirectionOut = 1
		MOV	XBUS_Phase, #0x00
		MOV	XBUS_NodeID, #0x00
		RET


XBUS_OnTimer:
IF	XBUS_TxInterleave > 0
		MOV	A, XBUS_Interleave
		JZ	XBUS_OnTimer_End
		DJNZ	XBUS_Interleave, XBUS_OnTimer_End
		SETB	XBUS_Direction
XBUS_OnTimer_Tx:
		SETB	SERIAL_TxInProgress
		SETB	TI
XBUS_OnTimer_End:
ENDIF	;XBUS_TxInterleave > 0
		RET

XBUS_RxBytes:
		MOV	SERIAL_CheckSum, #0
		SETB	SERIAL_CheckSumPresent
		CLR	SERIAL_Error
IF	SERIAL_LoopBack = 1
		CLR	SERIAL_Echo
ENDIF	;SERIAL_LoopBack = 1
		SETB	SERIAL_RxInProgress
		CLR	SERIAL_TxInProgress
		CLR	XBUS_Direction
IF	XBUS_DirectionOut = 1
		CLR	XBUS_DIR
ENDIF	;XBUS_DirectionOut = 1
		RET

XBUS_TxBytes:
		MOV	SERIAL_CheckSum, #0
		SETB	SERIAL_CheckSumPresent
		CLR	SERIAL_Error
IF	SERIAL_LoopBack = 1
		CLR	SERIAL_Echo
		SETB	SERIAL_RxInProgress
ELSE	;SERIAL_LoopBack = 1
		CLR	SERIAL_RxInProgress
ENDIF	;SERIAL_LoopBack = 1
IF	XBUS_TxInterleave > 0
		JB	XBUS_Direction, XBUS_OnTimer_Tx
IF	XBUS_DirectionOut = 1
		SETB	XBUS_DIR
ENDIF	;XBUS_DirectionOut = 1
		MOV	XBUS_Interleave, #XBUS_TxInterleave
ELSE	;XBUS_TxInterleave > 0
		SETB	SERIAL_TxInProgress
		SETB	TI
ENDIF	;XBUS_TxInterleave > 0
		RET

XBUS_RxChar:
		MOV	SERIAL_Counter, #1
		MOV	SERIAL_Pointer, #SERIAL_CheckSum
		CLR	SERIAL_CheckSumPresent
		CLR	SERIAL_Error
IF	SERIAL_LoopBack = 1
		CLR	SERIAL_Echo
ENDIF	;SERIAL_LoopBack = 1
		SETB	SERIAL_RxInProgress
		CLR	SERIAL_TxInProgress
		CLR	XBUS_Direction
IF	XBUS_DirectionOut = 1
		CLR	XBUS_DIR
ENDIF	;XBUS_DirectionOut = 1
		RET

XBUS_TxChar:
		MOV	SERIAL_Counter, #1
		MOV	SERIAL_Pointer, #SERIAL_CheckSum
		CLR	SERIAL_CheckSumPresent
		CLR	SERIAL_Error
IF	SERIAL_LoopBack = 1
		CLR	SERIAL_Echo
		SETB	SERIAL_RxInProgress
ELSE	;SERIAL_LoopBack = 1
		CLR	SERIAL_RxInProgress
ENDIF	;SERIAL_LoopBack = 1
IF	XBUS_TxInterleave > 0
		JB	XBUS_Direction, XBUS_OnTimer_Tx
IF	XBUS_DirectionOut = 1
		SETB	XBUS_DIR
ENDIF	;XBUS_DirectionOut = 1
		MOV	XBUS_Interleave, #XBUS_TxInterleave
ELSE	;XBUS_TxInterleave > 0
		SETB	SERIAL_TxInProgress
		SETB	TI
ENDIF	;XBUS_TxInterleave > 0
		RET


XBUS_StartRxMessage:
		SETB	XBUS_RxInProgress
		MOV	XBUS_Phase, #XBUS_PHASE_None
		CLR	XBUS_Error
		CLR	SERIAL_Error
SERIAL_OnRxComplete:
		JB	SERIAL_Error, SERIAL_OnRxTxComplete_Error
		INC	XBUS_Phase
		MOV	A, XBUS_Phase
SERIAL_OnRxComplete_Phase_Start:
		CJNE	A, #XBUS_PHASE_Start, SERIAL_OnRxComplete_Phase_Header
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_RxStart
		AJMP	XBUS_RxChar
SERIAL_OnRxComplete_Phase_Header:
		CJNE	A, #XBUS_PHASE_Header, SERIAL_OnRxComplete_Phase_Data
		MOV	A, SERIAL_CheckSum
		CJNE	A, #XBUS_StartChar, SERIAL_OnRxTxComplete_Error
		MOV	SERIAL_Counter, #4
		MOV	SERIAL_Pointer, #XBUS_Header
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_RxHeader
		SJMP	XBUS_RxBytes
SERIAL_OnRxComplete_Phase_Data:
		CJNE	A, #XBUS_PHASE_Data, SERIAL_OnRxComplete_Phase_Ack
		MOV	A, XBUS_Header_DataSize					
		JB	ACC.XBUS_BIT_Read, SERIAL_OnRxComplete_Phase_Data_NoData
		JB	ACC.XBUS_BIT_Data, SERIAL_OnRxComplete_Phase_Data_RxData
SERIAL_OnRxComplete_Phase_Data_NoData:
		INC	XBUS_Phase
		MOV	A, XBUS_Phase
		JMP	SERIAL_OnRxComplete_Phase_Ack
SERIAL_OnRxComplete_Phase_Data_RxData:
		ANL	A, #XBUS_MSK_DataSize
		INC	A
		MOV	SERIAL_Counter, A
		MOV	SERIAL_Pointer, #XBUS_Data
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_RxData
		JMP	XBUS_RxBytes
SERIAL_OnRxComplete_Phase_Ack:
		CJNE	A, #XBUS_PHASE_Ack, SERIAL_OnRxComplete_Phase_Complete
		JB	XBUS_AcknowledgeAll, SERIAL_OnRxComplete_Phase_Ack_TxAck
		MOV	A, XBUS_Header_NodeID
		XRL	A, XBUS_NodeID
		JNZ	SERIAL_OnRxTxComplete_Complete
SERIAL_OnRxComplete_Phase_Ack_TxAck:
		MOV	SERIAL_CheckSum, #XBUS_AckChar
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_TxAck
		JMP	XBUS_TxChar
SERIAL_OnRxComplete_Phase_Complete:
		CJNE	A, #XBUS_PHASE_Complete, SERIAL_OnRxTxComplete_End
		MOV	A, SERIAL_CheckSum
		XRL	A, #XBUS_AckChar
		JZ	SERIAL_OnRxTxComplete_Complete

SERIAL_OnRxTxComplete_Error:
		SETB	XBUS_Error
SERIAL_OnRxTxComplete_Complete:
SERIAL_OnRxTxComplete_TxComplete:
		JNB	XBUS_TxInProgress, SERIAL_OnRxTxComplete_RxComplete
		CLR	XBUS_TxInProgress
IF	XBUS_CallBack = 1
		CALL	XBUS_OnTxComplete
ENDIF	;XBUS_CallBack = 1
SERIAL_OnRxTxComplete_RxComplete:
		JNB	XBUS_RxInProgress, SERIAL_OnRxTxComplete_End
		CLR	XBUS_RxInProgress
IF	XBUS_CallBack = 1
		CALL	XBUS_OnRxComplete
ENDIF	;XBUS_CallBack = 1
SERIAL_OnRxTxComplete_End:
		RET

XBUS_StartTxMessage:
		SETB	XBUS_TxInProgress
		MOV	XBUS_Phase, #XBUS_PHASE_None
		CLR	XBUS_Error
		CLR	SERIAL_Error
SERIAL_OnTxComplete:
		JB	SERIAL_Error, SERIAL_OnRxTxComplete_Error
		INC	XBUS_Phase
		MOV	A, XBUS_Phase
SERIAL_OnTxComplete_Phase_Start:
		CJNE	A, #XBUS_PHASE_Start, SERIAL_OnTxComplete_Phase_Header
		MOV	SERIAL_CheckSum, #XBUS_StartChar
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_TxStart
		JMP	XBUS_TxChar
SERIAL_OnTxComplete_Phase_Header:
		CJNE	A, #XBUS_PHASE_Header, SERIAL_OnTxComplete_Phase_Data
		MOV	SERIAL_Counter, #4
		MOV	SERIAL_Pointer, #XBUS_Header
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_TxHeader
		JMP	XBUS_TxBytes
SERIAL_OnTxComplete_Phase_Data:
		CJNE	A, #XBUS_PHASE_Data, SERIAL_OnTxComplete_Phase_Ack
		MOV	A, XBUS_Header_DataSize					
		JB	ACC.XBUS_BIT_Read, SERIAL_OnTxComplete_Phase_Data_NoData
		JB	ACC.XBUS_BIT_Data, SERIAL_OnTxComplete_Phase_Data_TxData
SERIAL_OnTxComplete_Phase_Data_NoData:
		INC	XBUS_Phase
		MOV	A, XBUS_Phase
		JMP	SERIAL_OnRxComplete_Phase_Ack
SERIAL_OnTxComplete_Phase_Data_TxData:
		ANL	A, #XBUS_MSK_DataSize
		INC	A
		MOV	SERIAL_Counter, A
		MOV	SERIAL_Pointer, #XBUS_Data
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_TxData
		JMP	XBUS_TxBytes
SERIAL_OnTxComplete_Phase_Ack:
		CJNE	A, #XBUS_PHASE_Ack, SERIAL_OnTxComplete_Phase_Complete
		MOV	SERIAL_TimeOut, #XBUS_TimeOut_RxAck
		JMP	XBUS_RxChar
SERIAL_OnTxComplete_Phase_Complete:
		CJNE	A, #XBUS_PHASE_Complete, SERIAL_OnRxTxComplete_End
		JMP	SERIAL_OnRxTxComplete_Complete


IF	XBUS_D_ADDR = 0
RSEG	XBUS_D
ELSE	;XBUS_D_ADDR = 0
DSEG	AT	XBUS_D_ADDR
XBUS_D:
ENDIF	;XBUS_D_ADDR = 0

XBUS_Phase:
		DS	1
XBUS_NodeID:
		DS	1
XBUS_Header:
XBUS_Header_NodeID:
		DS	1
XBUS_Header_MessageID:
		DS	2
XBUS_Header_DataSize:
		DS	1
XBUS_Interleave:
		DS	1


IF	XBUS_D_ADDR_Data = 0
XBUS_Data:
		DS	8
ELSE	;XBUS_D_ADDR_Data = 0
XBUS_Data	EQU 	XBUS_D_ADDR_Data
ENDIF	;XBUS_D_ADDR_Data = 0


IF	XBUS_B_ADDR = 0
RSEG	XBUS_B
ELSE	;XBUS_B_ADDR = 0
BSEG	AT	XBUS_B_ADDR
XBUS_B:
ENDIF	;XBUS_B_ADDR = 0

XBUS_RxInProgress:
		DBIT	1
XBUS_TxInProgress:
		DBIT	1
XBUS_AcknowledgeAll:
		DBIT	1
XBUS_Error:
		DBIT	1
XBUS_Direction:
		DBIT	1


ENDIF	;USE_XBUS = 1


END
