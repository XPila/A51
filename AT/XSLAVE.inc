;***************************************************************************************************
;*** XSLAVE.inc											****
;***************************************************************************************************
; Include file for module XSLAVE (slave node via xbus).



IF	USE_XSLAVE = 1


						; W - Write
						; R - Read
						; TT - Type
						;----------
						; WRTT
XSLAVE_ENTRYTYPE_I		EQU	0x00	;(0000????)	IDATA
XSLAVE_ENTRYTYPE_IR		EQU	0x40	;(0100????)	IDATA	Read
XSLAVE_ENTRYTYPE_IW		EQU	0x80	;(1000????)	IDATA	Write
XSLAVE_ENTRYTYPE_IRW		EQU	0xc0	;(1100????)	IDATA	Read/Write

XSLAVE_ENTRYTYPE_X		EQU	0x10	;(0001????)	XDATA
XSLAVE_ENTRYTYPE_XR		EQU	0x50	;(0101????)	XDATA	Read
XSLAVE_ENTRYTYPE_XW		EQU	0x90	;(1001????)	XDATA	Write
XSLAVE_ENTRYTYPE_XRW		EQU	0xd0	;(1101????)	XDATA	Read/Write

XSLAVE_ENTRYTYPE_C		EQU	0x20	;(0010????)	CODE
XSLAVE_ENTRYTYPE_CR		EQU	0x60	;(0110????)	CODE	Read
XSLAVE_ENTRYTYPE_CW		EQU	0xa0	;(1010????)	CODE	Write
XSLAVE_ENTRYTYPE_CRW		EQU	0xe0	;(1110????)	CODE	Read/Write

XSLAVE_ENTRYTYPE_F		EQU	0x30	;(0011????)	FUNC
XSLAVE_ENTRYTYPE_FR		EQU	0x70	;(0111????)	FUNC	Read
XSLAVE_ENTRYTYPE_FW		EQU	0xb0	;(1011????)	FUNC	Write
XSLAVE_ENTRYTYPE_FRW		EQU	0xf0	;(1111????)	FUNC	Read/Write



XSLAVE_TABLE_BEGIN	MACRO	TableName
XSLAVE_TABLE_&TableName:
			DB	LOW((XSLAVE_TABLE_&TableName&_end - XSLAVE_TABLE_&TableName - 1) / 5)
			ENDM

XSLAVE_TABLE_END	MACRO	TableName
XSLAVE_TABLE_&TableName&_end:
			ENDM

XSLAVE_ENTRY		MACRO	MessageID, DataSize, Type, Address
			DB	HIGH(MessageID), LOW(MessageID), ((DataSize - 1) AND 0x07) OR ((DataSize > 0) * 0x08) OR (Type AND 0xf0), HIGH(Address), LOW(Address)
			ENDM

XSLAVE_ENTRY_IR		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_IR, Address
			ENDM
XSLAVE_ENTRY_IW		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_IW, Address
			ENDM
XSLAVE_ENTRY_IRW	MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_IRW, Address
			ENDM

XSLAVE_ENTRY_XR		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_XR, Address
			ENDM
XSLAVE_ENTRY_XW		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_XW, Address
			ENDM
XSLAVE_ENTRY_XRW	MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_XRW, Address
			ENDM

XSLAVE_ENTRY_CR		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_CR, Address
			ENDM

XSLAVE_ENTRY_F		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_F, Address
			ENDM
XSLAVE_ENTRY_FR		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_FR, Address
			ENDM
XSLAVE_ENTRY_FW		MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_FW, Address
			ENDM
XSLAVE_ENTRY_FRW	MACRO	MessageID, DataSize, Address
			XSLAVE_ENTRY	MessageID, DataSize, XSLAVE_ENTRYTYPE_FRW, Address
			ENDM


		EXTRN	CODE	(XSLAVE_Init)
		EXTRN	CODE	(XSLAVE_Run)

		EXTRN	BIT	(XSLAVE_Response)

/*
Physical Device

Logical Device Classes

Low Lewel Objects

	Digital Inputs
	Digital Outputs

	Analog Inputs
	Analog Outputs

	Counter Inputs
	Counter Outputs


High Level Objects

	SwitchOnOff
	PumpOnOff
	Position
	Angle
	LightIntensity

*/

ENDIF	;USE_XSLAVE = 1
