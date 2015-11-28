;***************************************************************************************************
;*** MEMORY.a51											****
;***************************************************************************************************
; Implementation file for module MEMORY (memory copying etc.).



NAME	MEMORY


$INCLUDE	(MAIN.inc)
IF	 USE_MEMORY = 1


MEMORY_C	SEGMENT	CODE


IF	MEMORY_CallBack = 1
		EXTRN	CODE	(MEMORY_OnMemLD)
		EXTRN	CODE	(MEMORY_OnMemST)
ENDIF	;MEMORY_CallBack = 1


		PUBLIC	MEMORY_MemCpy_I2I
		PUBLIC	MEMORY_MemCpy_C2I
		PUBLIC	MEMORY_MemCmp_I2I

IF	 MEMORY_X = 1
		PUBLIC	MEMORY_MemCpy_X2I
		PUBLIC	MEMORY_MemCpy_I2X
ENDIF	 ;MEMORY_X = 1

IF	 MEMORY_MULTI = 1
		PUBLIC	MEMORY_MemLD
		PUBLIC	MEMORY_MemST
ENDIF	 ;MEMORY_MULTI = 1


RSEG	MEMORY_C

;********************************************************************************
;** MEMORY_MemCpy_I2I: Copy memory I -> I.
;I: R0 - src address; R1 - dst address; R2 - byte count
;O:
;U: A, R0, R1, R2
MEMORY_MemCpy_I2I:
		MOV	A, @R0
		INC	R0
		MOV	@R1, A
		INC	R1
		DJNZ	R2, MEMORY_MemCpy_I2I
		RET

;********************************************************************************
;** MEMORY_MemCpy_C2I: Copy memory C -> I.
;I: DPTR - src address; R1 - dst address; R2 - byte count
;O:
;U: A, DPTR, R1, R2
MEMORY_MemCpy_C2I:
		CLR	A
		MOVC	A, @A + DPTR
		INC	DPTR
		MOV	@R1, A
		INC	R1
		DJNZ	R2, MEMORY_MemCpy_C2I
		RET

;********************************************************************************
;** MEMORY_MemCmp_I2I: Compare memory I:I.
;I: R0 - src address0; R1 - src address1; R2 - byte count
;O:
;U: 
MEMORY_MemCmp_I2I:
		CLR	C
		MOV	A, @R0
		SUBB	A, @R1
		JC	MEMORY_MemCmp_I2I_End
		JNZ	MEMORY_MemCmp_I2I_End
		INC	R0
		INC	R1
		DJNZ	R2, MEMORY_MemCmp_I2I
MEMORY_MemCmp_I2I_End:
		RET

IF	 MEMORY_X = 1
;********************************************************************************
;** MEMORY_MemCpy_X2I: Copy memory X -> I.
;I: DPTR - src address; R1 - dst address; R2 - byte count
;O:
;U: A, DPTR, R1, R2
MEMORY_MemCpy_X2I:
		MOVX	A, @DPTR
		INC	DPTR
		MOV	@R1, A
		INC	R1
		DJNZ	R2, MEMORY_MemCpy_X2I
		RET

;********************************************************************************
;** MEMORY_MemCpy_I2X: Copy memory I -> X.
;I: R0 - src address; DPTR - dst address; R2 - byte count
;O:
;U: A, DPTR, R0, R2
MEMORY_MemCpy_I2X:
		MOV	A, @R0
		INC	R0
		MOVX	@DPTR, A
		INC	DPTR
		DJNZ	R2, MEMORY_MemCpy_I2X
		RET
ENDIF	 ;MEMORY_X = 1

IF	 MEMORY_MULTI = 1
;********************************************************************************
;** MEMORY_MemLD: Load data from memory (I, C, X, M0-3) -> I.
;I: A - memory type; DPTR - src address; R1 - dst address; R2 - byte count
;O:
;U: A, DPTR, R1, R2 (... depends on implementation of callbacks)
MEMORY_MemLD:
		MOV	R0, DPL
		JZ	MEMORY_MemCpy_I2I
		CJNE	A, #1, MEMORY_MemLD_NotCI
		JMP	MEMORY_MemCpy_C2I
MEMORY_MemLD_NotCI:
IF	MEMORY_X = 1
		CJNE	A, #2, MEMORY_MemLD_M
		JMP	MEMORY_MemCpy_X2I
ENDIF	;MEMORY_X = 1
MEMORY_MemLD_M:
IF	MEMORY_CallBack = 1
		JMP	MEMORY_OnMemLD
ELSE	;MEMORY_CallBack = 1
		RET
ENDIF	;MEMORY_CallBack = 1

;********************************************************************************
;** MEMORY_MemST: Store data to memory (I, C, X, M0-3) <- I.
;I: A - memory type; R0 - src address; DPTR - dst address; ; R2 - byte count
;O:
;U: A, DPTR, R0, R2 (... depends on implementation of callbacks)
MEMORY_MemST:
		MOV	R1, DPL
		JZ	MEMORY_MemCpy_I2I
IF	MEMORY_X = 1
		CJNE	A, #2, MEMORY_MemST_M
		JMP	MEMORY_MemCpy_I2X
ENDIF	;MEMORY_X = 1
MEMORY_MemST_M:
IF	MEMORY_CallBack = 1
		JMP	MEMORY_OnMemST
ELSE	;MEMORY_CallBack = 1
		RET
ENDIF	;MEMORY_CallBack = 1

ENDIF	 ;MEMORY_MULTI = 1


ENDIF	;USE_MEMORY = 1


END
