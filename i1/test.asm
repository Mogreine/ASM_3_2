.MODEL SMALL
.STACK 200h
.386

.DATA
	NUMBER	DB	32 DUP('$')
	X	DD	0
	Y	DD	0
	Z	DD	0
	RES DB	'$$'
	Z1_STR DB 32 DUP('$')
	Z2_STR DB 32 DUP('$')
	PRINT_X DB "Enter X: $"
	PRINT_Y DB "Enter Y: $"
	PRINT_Z1 DB "Z1: $"
	PRINT_Z2 DB "Z2: $"
	F_VAL	DB "f: $"
	
.CODE
EXTRN READ_STR: FAR
EXTRN STR_LEN: FAR
EXTRN REVERSE_STR: FAR
EXTRN TO_BINIRY_STRING: FAR
EXTRN BIN_TO_INT: FAR
EXTRN CALCULATE_F: FAR
EXTRN FILL_STR: FAR
EXTRN PRINT: FAR
EXTRN PRINTLN: FAR
EXTRN PRINT_CHAR: FAR

;--------------------------
; Take z from EDX and changes bits
CHANGE_Z	PROC	FAR
	BT EDX, 4
	JNC @CHANGE_Z_FIRST_END
	BT EDX, 3
	JC @CHANGE_Z_FIRST_END
	BTR EDX, 4
@CHANGE_Z_FIRST_END:
	BT EDX, 13
	JNC @CHANGE_Z_SECOND_END
	BTS EDX, 11
@CHANGE_Z_SECOND_END:
	BT EDX, 9
	JC @CHANGE_Z_THIRD_END
	BTS EDX, 8
	JMP @CHANGE_Z_END
@CHANGE_Z_THIRD_END:
	BTR EDX, 8
@CHANGE_Z_END:
	RET
CHANGE_Z ENDP

START:
	MOV AX, @DATA
	MOV DS, AX
	
	LEA DX, PRINT_X
	CALL PRINT
	LEA DX, NUMBER
	MOV CX, 32
	CALL READ_STR
	
	CALL BIN_TO_INT
	MOV X, EDX
	
	LEA DX, NUMBER
	MOV CX, 32
	CALL FILL_STR
	
	LEA DX, PRINT_Y
	CALL PRINT
	MOV CX, 32
	CALL READ_STR
	CALL BIN_TO_INT
	MOV Y, EDX
	
	; Calculating F
	MOV EDX, X
	CALL CALCULATE_F	
	ADD DX, '0'
	
	MOV SI, OFFSET RES
	MOV BYTE PTR [SI], DL
	
	LEA DX, F_VAL
	CALL PRINT
	
	; Printing the value of f
	LEA DX, RES
	CALL PRINTLN
	
	; Calculating the value of Z
	MOV CL, 3
	MOV EAX, X
	MOV Z, EAX
	SHR Y, CL
	LEA SI, RES
	CMP BYTE PTR [SI], '0'
	JE @ZERO
	MOV EAX, Y
	SUB Z, EAX
	JMP @END_Z_CALCULATING
@ZERO:
	MOV EAX, Y
	ADD Z, EAX
@END_Z_CALCULATING:
	LEA DX, PRINT_Z1
	CALL PRINT
	LEA DX, Z1_STR
	MOV ECX, Z
	CALL TO_BINIRY_STRING
	CALL PRINTLN
	
	; Changing Z
	MOV EDX, Z
	CALL CHANGE_Z
	MOV Z, EDX
	LEA DX, Z2_STR
	MOV ECX, Z
	CALL TO_BINIRY_STRING
	LEA DX, PRINT_Z2
	CALL PRINT
	LEA DX, Z2_STR
	CALL PRINTLN
	
	MOV AH, 4CH
	INT 21H
END START