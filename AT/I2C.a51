;***************************************************************************************************
;*** I2C.a51											****
;***************************************************************************************************
; Implementation file for module I2C (SW emulated I2C bus [low-level]).



NAME	I2C


$INCLUDE	(Main.inc)
IF	USE_I2C = 1


I2C_C	SEGMENT	CODE

I2C_D	SEGMENT	DATA


		PUBLIC	I2C_Init
		PUBLIC	I2C_Start
		PUBLIC	I2C_Stop
		PUBLIC	I2C_ACK
		PUBLIC	I2C_WaitACK
		PUBLIC	I2C_Read
		PUBLIC	I2C_Write
		PUBLIC	I2C_Wait
		PUBLIC	I2C_ReadBytes
		PUBLIC	I2C_WriteBytes


RSEG	I2C_C

;********************************************************************************
;** I2C_Init: Bus initialization.
;I:
;O:
;U:
I2C_Init:
		ANL	I2C_PortModeReg0, #NOT (I2C_PortModeMskData OR I2C_PortModeMskClock)
		ORL	I2C_PortModeReg1, #(I2C_PortModeMskData OR I2C_PortModeMskClock)
		SETB	I2C_CLOCK
		SETB	I2C_DATA
		RET

;********************************************************************************
;** I2C_Start: Start sequence.
;I:
;O:
;U:
I2C_Start:
		CLR	I2C_DATA
		ACALL	I2C_Wait
		CLR	I2C_CLOCK
		ACALL	I2C_Wait
		RET

;********************************************************************************
;** I2C_Stop: Stop sequence.
;I:
;O:
;U:
I2C_Stop:
		SETB	I2C_CLOCK
		ACALL	I2C_Wait
		SETB	I2C_DATA
		ACALL	I2C_Wait
		RET

;********************************************************************************
;** I2C_ACK: ACK sequence.
;I:
;O:
;U:
I2C_ACK:
		CLR	I2C_DATA
		ACALL	I2C_Wait
		SETB	I2C_CLOCK
		ACALL	I2C_Wait
		CLR	I2C_CLOCK
		ACALL	I2C_Wait
		RET

;********************************************************************************
;** I2C_WaitACK: Waiting for ACK.
;I:
;O:
;U:
I2C_WaitACK:
		ANL	I2C_PortModeReg1, #NOT I2C_PortModeMskData
		SETB	I2C_DATA
		ACALL	I2C_Wait
		SETB	I2C_CLOCK
IF 	DEBUG = 1
		ACALL	I2C_Wait
ELSE	;DEBUG = 1
		JB	I2C_DATA, $
ENDIF	;DEBUG = 1
		ORL	I2C_PortModeReg1, #I2C_PortModeMskData
		ACALL	I2C_Wait
		CLR	I2C_CLOCK
		ACALL	I2C_Wait
		CLR	I2C_DATA
		ACALL	I2C_Wait
		RET

;********************************************************************************
;** I2C_Read: Receive data (single byte).
;I:
;O: A - received data.
;U: A, R3
I2C_Read:
		ANL	I2C_PortModeReg1, #NOT I2C_PortModeMskData
		SETB	I2C_DATA
		ACALL	I2C_Wait
		MOV	R3, #0x08
I2C_Read_loop:
		SETB	I2C_CLOCK
		ACALL	I2C_Wait
		MOV	C, I2C_DATA
		RLC	A
		CLR	I2C_CLOCK
		ACALL	I2C_Wait
		DJNZ	R3, I2C_Read_loop
		ORL	I2C_PortModeReg1, #I2C_PortModeMskData
		RET

;********************************************************************************
;** I2C_Write: Send data (single byte).
;I: A - Data to send.
;O:
;U: A, R3
I2C_Write:
		MOV	R3, #0x08
I2C_Write_loop:
		RLC	A
		MOV	I2C_DATA, C
		ACALL	I2C_Wait
		SETB	I2C_CLOCK
		ACALL	I2C_Wait
		CLR	I2C_CLOCK
		DJNZ	R3, I2C_Write_loop
		RET

;********************************************************************************
;** I2C_Wait: Wait single bus cycle.
;I:
;O:
;U: R7
I2C_Wait:
		MOV	R7, I2C_Delay
		DJNZ	R7, $
		RET

;********************************************************************************
;** I2C_ReadBytes: Read multiple bytes.
;I: A - wait delay; B.7 - 16/8bit address; B - DEVICE_ADDRESS; DPTR - adress; R1 - destination buffer (idata); R2 - byte count
;O:
;U: A, B, R1, R2, DPTR (R3, R7)
I2C_ReadBytes:
		MOV	I2C_Delay, A
		CLR	EA
		ACALL	I2C_Start
		MOV	A, B
		CLR	C
		RLC	A
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
		JNB	B.7, I2C_ReadBytes_8bit
		MOV	A, DPH
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
I2C_ReadBytes_8bit:
		MOV	A, DPL
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
		ACALL	I2C_Stop
		ACALL	I2C_Start
		MOV	A, B
		SETB	C
		RLC	A
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
I2C_ReadBytes_loop:
		ACALL	I2C_Read
		MOV	@R1, A
		INC	R1
		DEC	R2
		MOV	A, R2
		JZ	I2C_ReadBytes_end
		ACALL	I2C_ACK
		SJMP	I2C_ReadBytes_loop
I2C_ReadBytes_end:
		ACALL	I2C_Stop
		SETB	EA
		RET

;********************************************************************************
;** I2C_WriteBytes: Write multiple bytes.
;I: A - Wait delay; B.7 - 16/8bit address; B - DEVICE_ADDRESS; DPTR - adress; R0 - destination buffer (idata); R2 - byte count
;O:
;U: A, B, R0, R2, DPTR (R3, R7)
I2C_WriteBytes:
		MOV	I2C_Delay, A
		CLR	EA
		ACALL	I2C_Start
		MOV	A, B
		CLR	C
		RLC	A
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
		JNB	B.7, I2C_WriteBytes_8bit
		MOV	A, DPH
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
I2C_WriteBytes_8bit:
		MOV	A, DPL
		ACALL	I2C_Write
		ACALL	I2C_WaitACK
I2C_WriteBytes_loop:
		MOV	A, @R0
		ACALL	I2C_Write
		INC	R0
		DEC	R2
		MOV	A, R2
		ACALL	I2C_WaitACK
		JZ	I2C_WriteBytes_end
		SJMP	I2C_WriteBytes_loop
I2C_WriteBytes_end:
		ACALL	I2C_Stop
		SETB	EA
		RET


RSEG	I2C_D

I2C_Delay:
		DS	1


ENDIF	;USE_I2C = 1


END
