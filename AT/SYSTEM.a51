;***************************************************************************************************
;*** SYSTEM.a51											****
;***************************************************************************************************
; Implementation file for module SYSTEM (base module - startup etc.).



NAME	SYSTEM


$INCLUDE	(MAIN.inc)
IF	 USE_SYSTEM = 1


SYSTEM_C	SEGMENT	CODE

IF	SYSTEM_D_ADDR = 0
SYSTEM_D	SEGMENT	DATA
ENDIF	;SYSTEM_D_ADDR = 0

IF	SYSTEM_B_ADDR = 0
SYSTEM_B	SEGMENT	BIT
ENDIF	;SYSTEM_B_ADDR = 0


		EXTRN	CODE	(MAIN_Run)

		PUBLIC	SYSTEM_Reset
		PUBLIC	SYSTEM_WarmReset
		PUBLIC	SYSTEM_ColdReset

		PUBLIC	SYSTEM_ControlValue
		PUBLIC	SYSTEM_ResetFlag
		PUBLIC	SYSTEM_ColdResetFlag

CSEG	AT	0x0000
		LJMP	INT_Reset

;CSEG	AT	0x0003
;		LJMP	INT_External0

;CSEG	AT	0x000b
;		LJMP	INT_Timer0

;CSEG	AT	0x0013
;		LJMP	INT_External1

;CSEG	AT	0x001b
;		LJMP	INT_Timer1

;CSEG	AT	0x0023
;		LJMP	INT_Serial

;CSEG	AT	0x0033
;		LJMP	INT_Analog


RSEG	SYSTEM_C

SYSTEM_Reset:

SYSTEM_WarmReset:
		CLR	EA
		JMP	INT_Reset
SYSTEM_ColdReset:
		CLR	EA
		MOV	SYSTEM_ControlValue, #0x00


INT_Reset:
		SETB	SYSTEM_ResetFlag
		CLR	SYSTEM_ColdResetFlag
		MOV	A, #0xa5
		XRL	A, SYSTEM_ControlValue
		JZ	INT_Reset_Warm
INT_Reset_Cold:
		SETB	SYSTEM_ColdResetFlag
		MOV	R0, #0x7f
		CLR	A
		MOV	@R0, A
		DJNZ	R0, $-1
		MOV	SYSTEM_ControlValue, #0xa5
INT_Reset_Warm:
		MOV	SP, #SYSTEM_StackTop

		JMP	MAIN_Run


;INT_External0:
;		RETI

;INT_Timer0:
;		RETI

;INT_External1:
;		RETI

;INT_Timer1:
;		RETI

;INT_Serial:
;		RETI


IF	SYSTEM_D_ADDR = 0
RSEG	SYSTEM_D
ELSE	;SYSTEM_D_ADDR = 0
DSEG	AT	SYSTEM_D_ADDR
SYSTEM_D:
ENDIF	;SYSTEM_D_ADDR = 0

SYSTEM_ControlValue:
		DS	1


IF	SYSTEM_B_ADDR = 0
RSEG	SYSTEM_B
ELSE	;SYSTEM_B_ADDR = 0
BSEG	AT	SYSTEM_B_ADDR
SYSTEM_B:
ENDIF	;SYSTEM_B_ADDR = 0

SYSTEM_ResetFlag:
		DBIT	1
SYSTEM_ColdResetFlag:
		DBIT	1


ENDIF	;USE_SYSTEM = 1


END
