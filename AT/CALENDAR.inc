;***************************************************************************************************
;*** CALENDAR.inc										****
;***************************************************************************************************
; Include file for module CALENDAR (system calendar).



IF	USE_CALENDAR = 1


		EXTRN	CODE	(CALENDAR_Init)
		EXTRN	CODE	(CALENDAR_Reset)
		EXTRN	CODE	(CALENDAR_On24h)

		EXTRN	DATA	(CALENDAR_Date)
		EXTRN	DATA	(CALENDAR_Year)
		EXTRN	DATA	(CALENDAR_Month)
		EXTRN	DATA	(CALENDAR_Day)

		EXTRN	BIT	(CALENDAR_DateSet)


ENDIF	;USE_CALENDAR = 1
