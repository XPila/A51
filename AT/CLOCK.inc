;***************************************************************************************************
;*** CLOCK.inc											****
;***************************************************************************************************
; Include file for module CLOCK (system clock).



IF	USE_CLOCK = 1


		EXTRN	CODE	(CLOCK_Init)
		EXTRN	CODE	(CLOCK_Reset)
		EXTRN	CODE	(CLOCK_On10ms)

		EXTRN	DATA	(CLOCK_Time)
		EXTRN	DATA	(CLOCK_Hour)
		EXTRN	DATA	(CLOCK_Minute)
		EXTRN	DATA	(CLOCK_Second)
		EXTRN	DATA	(CLOCK_HSecond)

		EXTRN	BIT	(CLOCK_TimeSet)


ENDIF	;USE_CLOCK = 1
