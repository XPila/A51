;***************************************************************************************************
;*** CALENDAR.a51										****
;***************************************************************************************************
; Implementation file for module CALENDAR (system calendar).


NAME	CALENDAR


$INCLUDE	(Main.inc)
IF	USE_CALENDAR = 1


CALENDAR_C	SEGMENT	CODE

IF	CALENDAR_D_ADDR = 0
CALENDAR_D	SEGMENT	DATA
ENDIF	;CALENDAR_D_ADDR = 0

IF	CALENDAR_B_ADDR = 0
CALENDAR_B	SEGMENT	BIT
ENDIF	;CALENDAR_B_ADDR = 0


		EXTRN	BIT	(SYSTEM_ColdResetFlag)


		PUBLIC	CALENDAR_Init
		PUBLIC	CALENDAR_Reset
		PUBLIC	CALENDAR_On24h

		PUBLIC	CALENDAR_Date
		PUBLIC	CALENDAR_Year
		PUBLIC	CALENDAR_Month
		PUBLIC	CALENDAR_Day

		PUBLIC	CALENDAR_DateSet


RSEG	CALENDAR_C

CALENDAR_Init:
		JNB	SYSTEM_ColdResetFlag, CALENDAR_Init_End
CALENDAR_Reset:
		MOV	CALENDAR_Day, #1
		MOV	CALENDAR_Month, #1
		MOV	CALENDAR_Year + 0, #HIGH(0000)
		MOV	CALENDAR_Year + 1, #LOW(0000)
		CLR	CALENDAR_DateSet
CALENDAR_Init_End:
		RET

CALENDAR_On24h:
		PUSH	DPL
		PUSH	DPH
;		JNB	CALENDAR_DateSet, CALENDAR_On24h_End
		INC	CALENDAR_Day
		MOV	A, CALENDAR_Month
		MOV	B, #0
		CJNE	A, #2, CALENDAR_On24h_NoLeapYear
		MOV	A, CALENDAR_Year + 1
		ANL	A, #3
		JNZ	CALENDAR_On24h_NoLeapYear
		MOV	B, #1
CALENDAR_On24h_NoLeapYear:
		MOV	A, CALENDAR_Month
		DEC	A
		MOV	DPTR, #CALENDAR_Months
		MOVC	A, @A + DPTR
		ADD	A, B
		INC	A
		CJNE	A, CALENDAR_Day, CALENDAR_On24h_End
		MOV	CALENDAR_Day, #1
		INC	CALENDAR_Month
		MOV	A, CALENDAR_Month
		CJNE	A, #13, CALENDAR_On24h_End
		MOV	CALENDAR_Month, #1
		INC	CALENDAR_Year + 1
		MOV	A, CALENDAR_Year + 1
		JNZ	CALENDAR_On24h_End
		INC	CALENDAR_Year + 0
CALENDAR_On24h_End:
		POP	DPH
		POP	DPL
		RET

CALENDAR_Months:
		DB	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


IF	CALENDAR_D_ADDR = 0
RSEG	CALENDAR_D
ELSE	;CALENDAR_D_ADDR = 0
DSEG	AT	CALENDAR_D_ADDR
CALENDAR_D:
ENDIF	;CALENDAR_D_ADDR = 0

CALENDAR_Date:
CALENDAR_Year:
		DS	2
CALENDAR_Month:
		DS	1
CALENDAR_Day:
		DS	1


IF	CALENDAR_B_ADDR = 0
RSEG	CALENDAR_B
ELSE	;CALENDAR_B_ADDR = 0
BSEG	AT	CALENDAR_B_ADDR
CALENDAR_B:
ENDIF	;CALENDAR_B_ADDR = 0

CALENDAR_DateSet:
		DBIT	1


ENDIF	;USE_CALENDAR = 1


END
