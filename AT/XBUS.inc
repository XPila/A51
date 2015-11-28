;***************************************************************************************************
;*** XBUS.inc											****
;***************************************************************************************************
; Include file for module XBUS (extended multinode master slave byte protocol via serial UART)



IF	USE_XBUS = 1


		EXTRN	CODE	(XBUS_Init)
		EXTRN	CODE	(XBUS_OnTimer)
		EXTRN	CODE	(XBUS_StartRxMessage)
		EXTRN	CODE	(XBUS_StartTxMessage)

		EXTRN	DATA	(XBUS_NodeID)
		EXTRN	DATA	(XBUS_Header)
		EXTRN	DATA	(XBUS_Header_NodeID)
		EXTRN	DATA	(XBUS_Header_MessageID)
		EXTRN	DATA	(XBUS_Header_DataSize)
		EXTRN	DATA	(XBUS_Data)
		EXTRN	DATA	(XBUS_Phase)

		EXTRN	BIT	(XBUS_RxInProgress)
		EXTRN	BIT	(XBUS_TxInProgress)
		EXTRN	BIT	(XBUS_AcknowledgeAll)
		EXTRN	BIT	(XBUS_Error)

XBUS_MSK_DataSize		EQU	0x07
XBUS_BIT_Data			EQU	3
XBUS_FLG_Data			EQU	0x08
XBUS_BIT_Read			EQU	6
XBUS_FLG_Read			EQU	0x40
XBUS_BIT_Write			EQU	7
XBUS_FLG_Write			EQU	0x80
/*		EXTRN	NUMBER	(XBUS_MSK_DataSize)
		EXTRN	BYTE	(XBUS_BIT_Data)
		EXTRN	NUMBER	(XBUS_FLG_Data)
		EXTRN	NUMBER	(XBUS_BIT_Read)
		EXTRN	NUMBER	(XBUS_FLG_Read)
		EXTRN	NUMBER	(XBUS_BIT_Write)
		EXTRN	NUMBER	(XBUS_FLG_Write)*/


ENDIF	;USE_XBUS = 1
