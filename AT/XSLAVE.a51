;***************************************************************************************************
;*** XSLAVE.a51											****
;***************************************************************************************************
; Implementation file for module XSLAVE (slave node via xbus).



NAME	XSLAVE


$INCLUDE	(MAIN.inc)
IF	USE_XSLAVE = 1


$INCLUDE	(SYSTEM.inc)
$INCLUDE	(MEMORY.inc)
$INCLUDE	(XBUS.inc)


XSLAVE_C	SEGMENT	CODE

;XSLAVE_D	SEGMENT	DATA

IF	XSLAVE_B_ADDR = 0
XSLAVE_B	SEGMENT	BIT
ENDIF	;XSLAVE_B_ADDR = 0


		EXTRN	CODE	(XSLAVE_TABLE_ToAll)
		EXTRN	CODE	(XSLAVE_TABLE_ToMy)
		

		PUBLIC	XSLAVE_Init
		PUBLIC	XSLAVE_Run

		PUBLIC	XSLAVE_Response


RSEG	XSLAVE_C

XSLAVE_Init:
		MOV	XBUS_NodeID, #XSLAVE_DefaultNodeID
		JMP	XSLAVE_Run_Rx_End

XSLAVE_Run:
		MOV	C, XBUS_RxInProgress
		ORL	C, XBUS_TxInProgress
		JNC	XSLAVE_Run_Complete
		RET
XSLAVE_Run_Complete:
		JB	XBUS_Error, XSLAVE_Run_Rx_End
		JNB	XSLAVE_Response, XSLAVE_Run_Request
XSLAVE_Run_Rx_End:
		CLR	XSLAVE_Response
		JMP	XBUS_StartRxMessage
XSLAVE_Run_Tx_End:
		SETB	XSLAVE_Response
		JMP	XBUS_StartTxMessage
XSLAVE_Run_Request:
		MOV	A, XBUS_Header_DataSize
		ANL	A, #XBUS_FLG_Read OR XBUS_FLG_Write
		XRL	A, #XBUS_FLG_Read OR XBUS_FLG_Write
		JZ	XSLAVE_Run_Rx_End
		MOV	A, XBUS_Header_NodeID
		JZ	XSLAVE_Run_Request_ToAll

		XRL	A, #0xff
		JZ	XSLAVE_Run_Request_ToMy
		XRL	A, #0xff

		XRL	A, XBUS_NodeID
		JZ	XSLAVE_Run_Request_ToMy
		JMP	XSLAVE_Run_Rx_End
XSLAVE_Run_Request_ToAll:
		MOV	DPTR, #XSLAVE_TABLE_ToAll
		JMP	XSLAVE_Run_Find
XSLAVE_Run_Request_ToMy:
		MOV	DPTR, #XSLAVE_TABLE_ToMy
XSLAVE_Run_Find:
		MOVC	A, @A + DPTR
		MOV	R2, A
		INC	DPTR
		JMP	XSLAVE_Run_Find_Loop
XSLAVE_Run_Find_Loop5:
		INC	DPTR
XSLAVE_Run_Find_Loop4:
		INC	DPTR
XSLAVE_Run_Find_Loop3:
		INC	DPTR
XSLAVE_Run_Find_Loop2:
		INC	DPTR
XSLAVE_Run_Find_Loop1:
		INC	DPTR
XSLAVE_Run_Find_Loop0:
		DEC	R2
XSLAVE_Run_Find_Loop:
		MOV	A, R2
		JZ	XSLAVE_Run_Rx_End
		CLR	A
		MOVC	A, @A + DPTR
		CJNE	A, XBUS_Header_MessageID + 0, XSLAVE_Run_Find_Loop5
		INC	DPTR
		CLR	A
		MOVC	A, @A + DPTR
		CJNE	A, XBUS_Header_MessageID + 1, XSLAVE_Run_Find_Loop4
		INC	DPTR
		CLR	A
		MOVC	A, @A + DPTR
		MOV	B, A
		ANL	A, XBUS_Header_DataSize
		MOV	C, ACC.XBUS_BIT_Read
		MOV	F0, C
		MOV	C, ACC.XBUS_BIT_Write
		MOV	F1, C
		MOV	A, XBUS_Header_DataSize
		ORL	A, B
		MOV	C, ACC.XBUS_BIT_Read
		ORL	C, ACC.XBUS_BIT_Write
		CPL	C
		ORL	C, F0
		ORL	C, F1
		JNC	XSLAVE_Run_Find_Loop3

/*		XRL	A, B
		ANL	A, #XBUS_MSK_DataSize
		JNZ	XSLAVE_Run_Find_Loop3
		MOV	A, B
		ANL	A, #XBUS_MSK_DataSize*/

		CLR	A
		JNB	B.XBUS_BIT_Data, XSLAVE_Run_SetDataSize
		MOV	A, XBUS_Header_DataSize
		ANL	A, #XBUS_MSK_DataSize
		INC	A
XSLAVE_Run_SetDataSize:
		MOV	R2, A
		INC	DPTR
		CLR	A
		MOVC	A, @A + DPTR
		MOV	R0, A
		MOV	R1, A
		INC	DPTR
		CLR	A
		MOVC	A, @A + DPTR
		MOV	R0, A
		XCH	A, R1
		MOV	DPTR, #XSLAVE_Run_Rx_End
		JNB	F0, XSLAVE_Run_PushReturnAddress
		MOV	DPTR, #XSLAVE_Run_Tx_End
XSLAVE_Run_PushReturnAddress:
		PUSH	DPL
		PUSH	DPH
		MOV	DPL, R0
		MOV	DPH, A
XSLAVE_Run_Process_Read:
		JNB	F0, XSLAVE_Run_Process_Write
		MOV	R1, #XBUS_Data
		ANL	XBUS_HEADER_DataSize, #XBUS_MSK_DataSize
		JNB	B.XBUS_BIT_Data, XSLAVE_Run_Process
		ORL	XBUS_HEADER_DataSize, #XBUS_FLG_Data
		JMP	XSLAVE_Run_Process
XSLAVE_Run_Process_Write:
		JNB	F1, XSLAVE_Run_Process
		MOV	R0, #XBUS_Data
XSLAVE_Run_Process:
		MOV	A, B
		SWAP	A
		ANL	A, #0x03
XSLAVE_Run_Process_IData:
		CJNE	A,  #0x00, XSLAVE_Run_Process_XData
XSLAVE_Run_Process_IData_Read:
		JNB	F0, XSLAVE_Run_Process_IData_Write
		JMP	MEMORY_MemCpy_I2I
XSLAVE_Run_Process_IData_Write:
		JNB	F1, XSLAVE_Run_Process_End
		JMP	MEMORY_MemCpy_I2I
XSLAVE_Run_Process_XData:
		CJNE	A,  #0x01, XSLAVE_Run_Process_Code

IF	MEMORY_X = 1
XSLAVE_Run_Process_XData_Read:
		JNB	F0, XSLAVE_Run_Process_XData_Write
		JMP	MEMORY_MemCpy_X2I
XSLAVE_Run_Process_XData_Write:
		JNB	F1, XSLAVE_Run_Process_End
		JMP	MEMORY_MemCpy_I2X
ENDIF	;MEMORY_X = 1

XSLAVE_Run_Process_Code:
		CJNE	A,  #0x02, XSLAVE_Run_Process_Function
XSLAVE_Run_Process_Code_Read:
		JNB	F0, XSLAVE_Run_Process_End
;		CLR	A
;		MOV	R0, A
		JMP	MEMORY_MemCpy_C2I
XSLAVE_Run_Process_Function:
		CJNE	A,  #0x03, XSLAVE_Run_Process_End
		PUSH	DPL
		PUSH	DPH
XSLAVE_Run_Process_End:
		RET



;RSEG	XSLAVE_D


IF	XSLAVE_B_ADDR = 0
RSEG	XSLAVE_B
ELSE	;XSLAVE_B_ADDR = 0
BSEG	AT	XSLAVE_B_ADDR
XSLAVE_B:
ENDIF	;XSLAVE_B_ADDR = 0

XSLAVE_Response:
		DBIT	1


ENDIF	;USE_XSLAVE = 1


END
