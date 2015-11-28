;***************************************************************************************************
;*** AT24C256.a51										****
;***************************************************************************************************
; Implementation file for module AT24C256 (comunication with EEPROM AT24C256 via I2C).



NAME	AT24C256

$INCLUDE	(Main.inc)
IF	USE_AT24C256 = 1


$INCLUDE	(I2C.inc)


AT24C256_C	SEGMENT	CODE


		PUBLIC	AT24C256_Init
		PUBLIC	AT24C256_ReadBytes
		PUBLIC	AT24C256_WriteBytes


RSEG	AT24C256_C


AT24C256_Init:
		RET

AT24C256_ReadBytes:
		MOV	A, #AT24C256_DELAY
		MOV	B, #AT24C256_ADDRESS
		JMP	I2C_ReadBytes

AT24C256_WriteBytes:
		MOV	A, #AT24C256_DELAY
		MOV	B, #AT24C256_ADDRESS
		JMP	I2C_WriteBytes


ENDIF	;USE_AT24C256 = 1


END
