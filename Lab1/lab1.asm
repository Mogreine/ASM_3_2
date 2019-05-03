.MODEL SMALL
.STACK 200h
.386

.DATA
	NUMBER	DB	33 DUP('$')
	X	DD	0
	Y	DD	0
	Z	DD	0
	RES DB	'$$'
	Z1_STR DB 33 DUP('$')
	Z2_STR DB 33 DUP('$')
	Z_FORMULA DB "Z_FORMULA: f ? X - Y / 8 : X + Y / 8$"
	F_EQ DB "f equation: x1x3x4 | x1!x2 | !x3!x4 | x2x4 | !x1x2!x4$"
	Z_CHANGE DB "Z changes: z4 &= z3, z11 |= z13, z8 = !z9$"
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

MAIN	PROC	FAR
	PUSHAD
	PUSH SI
	; Cleaning all the variable in case the function has been already called.
	MOV EAX, 0
	MOV EBX, 0
	MOV ECX, 0
	MOV SI, 0	
	
	LEA DX, NUMBER
	MOV CX, 32
	CALL FILL_STR
	LEA DX, Z1_STR
	MOV CX, 32
	CALL FILL_STR
	LEA DX, Z2_STR
	MOV CX, 32
	CALL FILL_STR
	MOV X, 0
	MOV Y, 0
	MOV Z, 0
	
	LEA DX, Z_FORMULA
	CALL PRINTLN
	LEA DX, F_EQ
	CALL PRINTLN
	LEA DX, Z_CHANGE
	CALL PRINTLN
	
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
	LEA DX, NUMBER
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
	
	POP SI
	POPAD
	RET
MAIN ENDP

PUBLIC MAIN
END