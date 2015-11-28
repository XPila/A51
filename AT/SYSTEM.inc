;***************************************************************************************************
;*** SYSTEM.inc											****
;***************************************************************************************************
; Include file for module SYSTEM (base module - startup etc.).



IF	USE_SYSTEM = 1


		EXTRN	CODE	(SYSTEM_Reset)
		EXTRN	CODE	(SYSTEM_WarmReset)
		EXTRN	CODE	(SYSTEM_ColdReset)

		EXTRN	DATA	(SYSTEM_ControlValue)
		EXTRN	BIT	(SYSTEM_ResetFlag)
		EXTRN	BIT	(SYSTEM_ColdResetFlag)


ENDIF	;USE_SYSTEM = 1
