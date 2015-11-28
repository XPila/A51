;***************************************************************************************************
;*** MEMORY.inc											****
;***************************************************************************************************
; Include file for module MEMORY (memory copying etc.).
;Code Size:	27 bytes
;IData Size:	0 bytes
;Bit Size:	0 bits
;Switches:
;	MEMORY_X		External memory present (+14bytes[=1])


IF	USE_MEMORY = 1


		EXTRN	CODE	(MEMORY_MemCpy_I2I)
		EXTRN	CODE	(MEMORY_MemCpy_C2I)
		EXTRN	CODE	(MEMORY_MemCmp_I2I)

IF	MEMORY_X = 1
		EXTRN	CODE	(MEMORY_MemCpy_X2I)
		EXTRN	CODE	(MEMORY_MemCpy_I2X)
ENDIF	;MEMORY_X = 1


IF	MEMORY_MULTI = 1
MEMORY_MEM_I	EQU	0x00
MEMORY_MEM_C	EQU	0x01
MEMORY_MEM_X	EQU	0x02
MEMORY_MEM_M0	EQU	0x04
MEMORY_MEM_M1	EQU	0x05
MEMORY_MEM_M2	EQU	0x06
MEMORY_MEM_M3	EQU	0x07
		EXTRN	CODE	(MEMORY_MemLd)
		EXTRN	CODE	(MEMORY_MemSt)
ENDIF	;MEMORY_MULTI = 1



ENDIF	;USE_MEMORY = 1
