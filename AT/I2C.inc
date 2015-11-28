;***************************************************************************************************
;*** I2C.inc											****
;***************************************************************************************************
; Include file for module I2C (SW emulated I2C bus [low-level]).



IF	USE_I2C = 1


		EXTRN	CODE	(I2C_Init)
		EXTRN	CODE	(I2C_Start)
		EXTRN	CODE	(I2C_Stop)
		EXTRN	CODE	(I2C_ACK)
		EXTRN	CODE	(I2C_WaitACK)
		EXTRN	CODE	(I2C_Read)
		EXTRN	CODE	(I2C_Write)
		EXTRN	CODE	(I2C_Wait)
		EXTRN	CODE	(I2C_ReadBytes)
		EXTRN	CODE	(I2C_WriteBytes)


ENDIF	;USE_I2C = 1
