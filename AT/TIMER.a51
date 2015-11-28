;***************************************************************************************************
;*** TIMER.a51											****
;***************************************************************************************************
; Implementation file for module TIMER (system timer).



NAME	TIMER


$INCLUDE	(MAIN.inc)
IF	USE_TIMER = 1


TIMER_C		SEGMENT	CODE

IF	TIMER_D_ADDR = 0
TIMER_D		SEGMENT	DATA
ENDIF	;TIMER_D_ADDR = 0


IF	TIMER_CallBack = 1
		EXTRN	CODE	(TIMER_OnTimer)		; typ. 100us on standard core, 10us on SC core
ENDIF	;TIMER_CallBack = 1
IF	TIMER_CallBack0 = 1
		EXTRN	CODE	(TIMER_OnTimer0)	; typ. 1ms
ENDIF	;TIMER_CallBack0 = 1
IF	TIMER_CallBack1 = 1
		EXTRN	CODE	(TIMER_OnTimer1)	; typ. 10ms
ENDIF	;TIMER_CallBack1 = 1


		PUBLIC	TIMER_Init

		PUBLIC	TIMER_Value


IF	TIMER_Timer = 0
CSEG	AT	0x000b
		LJMP	INT_Timer0
ENDIF	;TIMER_Timer = 0
IF	TIMER_Timer = 1
CSEG	AT	0x001b
		LJMP	INT_Timer1
ENDIF	;TIMER_Timer = 1


RSEG	TIMER_C

TIMER_Init:
IF	TIMER_Timer = 0
IF	TIMER_PWM = 1
		ANL	TCONB, #10111000b	; TCONB = ?0???000
		ORL	TCONB, #01000000b	; TCONB = ?1???000
		ANL	TMOD, #11110000b	; TMOD = ????0000
		ORL	TMOD, #00000001b	; TMOD = ????0001
		MOV	RL0, #TIMER_RL0
		MOV	RH0, #0x00
		MOV	TH0, #0x00
		MOV	TL0, #0x00
ELSE	; TIMER_PWM = 1
		ANL	TMOD, #11110000b	; TMOD = ????0000
		ORL	TMOD, #00000010b	; TMOD = ????0010 (8bit auto reload timer)
		MOV	TH0, #(256 - TIMER_CNT)
		MOV	TL0, #0x00		; First interrupt delayed by TIMER_CNT cycles to TR0 high
ENDIF	; TIMER_PWM = 1
ENDIF	; TIMER_Timer = 0
		MOV	A, #TIMER_CNT0
		MOV	TIMER_Counter0, A
		MOV	A, #TIMER_CNT1
		MOV	TIMER_Counter1, A
		CLR	A
		MOV	TIMER_Value + 1, A
		MOV	TIMER_Value + 0, A
IF	TIMER_Timer = 0
		SETB	TR0			; Run timer0
		SETB	PT0
;		CLR	PT0
		SETB	ET0
ENDIF	;TIMER_Timer = 0
IF	TIMER_Timer = 1
		SETB	TR1			; Run timer1
		SETB	PT1
;		CLR	PT1
		SETB	ET1
ENDIF	;TIMER_Timer = 1
		RET

IF	TIMER_Timer = 0
INT_Timer0:
ENDIF	;TIMER_Timer = 0
IF	TIMER_Timer = 1
INT_Timer1:
ENDIF	;TIMER_Timer = 1
		PUSH	PSW
		PUSH	ACC
		PUSH	B
		MOV	PSW, #0x08		; RS = 1
IF	TIMER_CallBack = 1
		CALL	TIMER_OnTimer
ENDIF	;TIMER_CallBack = 1
		DJNZ	TIMER_Counter0, INT_Timer0_End
		MOV	TIMER_Counter0, #TIMER_CNT0
IF	TIMER_CallBack0 = 1
		CALL	TIMER_OnTimer0
ENDIF	;TIMER_CallBack0 = 1
		INC	TIMER_Value + 1
		MOV	A, TIMER_Value + 1
		JNZ	$+4
		INC	TIMER_Value + 0
		DJNZ	TIMER_Counter1, INT_Timer0_End
		MOV	TIMER_Counter1, #TIMER_CNT1
IF	TIMER_CallBack1 = 1
		CALL	TIMER_OnTimer1
ENDIF	;TIMER_CallBack1 = 1
INT_Timer0_End:
		POP	B
		POP	ACC
		POP	PSW
		RETI


IF	TIMER_D_ADDR = 0
RSEG	TIMER_D
ELSE	;TIMER_D_ADDR = 0
DSEG	AT	TIMER_D_ADDR
TIMER_D:
ENDIF	;TIMER_D_ADDR = 0

TIMER_Counter0:
		DS	1
TIMER_Counter1:
		DS	1
TIMER_Value:
		DS	2


ENDIF	;USE_TIMER = 1


END
