;***************************************************************************************************
;*** CLOCK.a51											****
;***************************************************************************************************
; Implementation file for module CLOCK (system clock).



NAME	CLOCK


$INCLUDE	(Main.inc)
IF	USE_CLOCK = 1


CLOCK_C		SEGMENT	CODE

IF	CLOCK_D_ADDR = 0
CLOCK_D	SEGMENT	DATA
ENDIF	;CLOCK_D_ADDR = 0

IF	CLOCK_B_ADDR = 0
CLOCK_B	SEGMENT	BIT
ENDIF	;CLOCK_B_ADDR = 0


IF	USE_CALENDAR = 1
		EXTRN	CODE	(CALENDAR_On24h)
ENDIF	;USE_CALENDAR = 1

		EXTRN	BIT	(SYSTEM_ColdResetFlag)


		PUBLIC	CLOCK_Init
		PUBLIC	CLOCK_Reset
		PUBLIC	CLOCK_On10ms

		PUBLIC	CLOCK_Time
		PUBLIC	CLOCK_Hour
		PUBLIC	CLOCK_Minute
		PUBLIC	CLOCK_Second
		PUBLIC	CLOCK_HSecond

		PUBLIC	CLOCK_TimeSet


RSEG	CLOCK_C

CLOCK_Init:
		JNB	SYSTEM_ColdResetFlag, CLOCK_Init_End
CLOCK_Reset:
		CLR	A
		MOV	CLOCK_HSecond, A
		MOV	CLOCK_Second, A
		MOV	CLOCK_Minute, A
		MOV	CLOCK_Hour, A
		CLR	CLOCK_TimeSet
CLOCK_Init_End:
		RET

CLOCK_On10ms:
;		JNB	CLOCK_TimeSet, CLOCK_On10ms_End
		INC	CLOCK_HSecond
		MOV	A, CLOCK_HSecond
		CJNE	A, #100, CLOCK_On10ms_End
		MOV	CLOCK_HSecond, #0
		INC	CLOCK_Second
		MOV	A, CLOCK_Second
		CJNE	A, #60, CLOCK_On10ms_End
		MOV	CLOCK_Second, #0
		INC	CLOCK_Minute
		MOV	A, CLOCK_Minute
		CJNE	A, #60, CLOCK_On10ms_End
		MOV	CLOCK_Minute, #0
		INC	CLOCK_Hour
		MOV	A, CLOCK_Hour
		CJNE	A, #24, CLOCK_On10ms_End
		MOV	CLOCK_Hour, #0
IF	USE_CALENDAR = 1
		JMP	CALENDAR_On24h
ENDIF	;USE_CALENDAR = 1
CLOCK_On10ms_End:
		RET


IF	CLOCK_D_ADDR = 0
RSEG	CLOCK_D
ELSE	;CLOCK_D_ADDR = 0
DSEG	AT	CLOCK_D_ADDR
CLOCK_D:
ENDIF	;CLOCK_D_ADDR = 0


CLOCK_Time:
CLOCK_Hour:
		DS	1
CLOCK_Minute:
		DS	1
CLOCK_Second:
		DS	1
CLOCK_HSecond:
		DS	1


IF	CLOCK_B_ADDR = 0
RSEG	CLOCK_B
ELSE	;CLOCK_B_ADDR = 0
BSEG	AT	CLOCK_B_ADDR
CLOCK_B:
ENDIF	;CLOCK_B_ADDR = 0

CLOCK_TimeSet:
		DBIT	1


ENDIF	;USE_CLOCK = 1


END
