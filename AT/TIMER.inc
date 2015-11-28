;***************************************************************************************************
;*** TIMER.inc											****
;***************************************************************************************************
; Include file for module TIMER (system timer).



IF	USE_TIMER = 1


		EXTRN	CODE	(TIMER_Init)			; must be called at startup

		EXTRN	DATA	(TIMER_Value)


ENDIF	;USE_TIMER = 1
