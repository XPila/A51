;***************************************************************************************************
;*** AT24C256.inc										****
;***************************************************************************************************
; Include file for module AT24C256 (comunication with EEPROM AT24C256 via I2C).



IF	USE_AT24C256 = 1


		EXTRN	CODE	(AT24C256_Init)
		EXTRN	CODE	(AT24C256_ReadBytes)
		EXTRN	CODE	(AT24C256_WriteBytes)


ENDIF	;USE_AT24C256 = 1
