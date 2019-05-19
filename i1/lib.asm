.MODEL SMALL
.CODE
.386
LOCALS
.DATA
	INT_32_RES	DD	0
.CODE
;----------------------
; Arguments: DX - pointer to the string, CX - number of symbols to fill.
FILL_STR	PROC	FAR
	;POP SYMB
	PUSHAD
	PUSH SI
	MOV SI, DX
@FILL_STR_CYCLE:
	CMP CX, 0
	JE @FILL_STR_END
	MOV BYTE PTR[SI], '$'
	INC SI
	DEC CX
	JMP @FILL_STR_CYCLE
@FILL_STR_END:
	;MOV TES, SI 
	POP SI
	POPAD
	RET
FILL_STR ENDP

;-------------------------------
; Transform every symbols into lower if it's a letter
TO_LOWER	PROC	FAR
	PUSHAD
	PUSH SI
	MOV SI, DX
@TO_LOWER_START:
	CMP BYTE PTR [SI], '$'
	JE @TO_LOWER_EXIT
	CMP BYTE PTR [SI], 0
	JE @TO_LOWER_EXIT
	CMP BYTE PTR [SI], 'A'
	JL @TO_LOWER_NOT_BIG
	CMP BYTE PTR [SI], 'Z'
	JG @TO_LOWER_NOT_BIG
	; 32 - is the difference between 'A' and 'a', so adding transform upper case letter to lower case.
	ADD BYTE PTR [SI], 32
@TO_LOWER_NOT_BIG:
	INC SI
	JMP @TO_LOWER_START
@TO_LOWER_EXIT:
	POP SI
	POPAD
	RET
TO_LOWER ENDP

;---------------------------------
; A hex number must be in DX
; Transform a hex number to int32
; EDX - the result
.DATA
	VALIDATION_ERROR DB "The entered hex number is incorrect!$"
.CODE
HEX_TO_INT32	PROC	FAR
	MOV INT_32_RES, 0
	PUSHAD
	PUSH SI
	CALL TO_LOWER
	MOV SI, DX
	
	; Validation - checks that the string contains only digits and [a-f].
@HEX_TO_INT32_VALIDATION:
	CMP BYTE PTR [SI], '$'
	JE @HEX_TO_INT32_VALIDATION_SUCCESS
	CMP BYTE PTR [SI], 0
	JE @HEX_TO_INT32_VALIDATION_SUCCESS
	CMP BYTE PTR [SI], 'f'
	JG @HEX_TO_INT32_VALIDATION_FAIL
	CMP BYTE PTR [SI], 'a'
	JGE @HEX_TO_INT32_NEXT
	CMP BYTE PTR [SI], '9'
	JG @HEX_TO_INT32_VALIDATION_FAIL
	CMP BYTE PTR [SI], '0'
	JL @HEX_TO_INT32_VALIDATION_FAIL
@HEX_TO_INT32_NEXT:
	INC SI
	JMP @HEX_TO_INT32_VALIDATION
@HEX_TO_INT32_VALIDATION_FAIL:
	MOV DX, OFFSET VALIDATION_ERROR
	CALL PRINT
	JMP @HEX_TO_INT32_EXIT
	; End of the validation
	
@HEX_TO_INT32_VALIDATION_SUCCESS:
	CALL STR_LEN
	DEC CX
	MOV SI, DX
@HEX_TO_INT32_START:
	MOV EBX, 0
	CMP BYTE PTR [SI], '$'
	JE @HEX_TO_INT32_EXIT
	CMP BYTE PTR [SI], 0
	JE @HEX_TO_INT32_EXIT
	
	MOV BL, BYTE PTR [SI] 
	CMP BX, 'a'
	JL @HEX_TO_INT32_IS_DIGIT
	SUB BX, 87
	JMP @HEX_TO_INT32_ADDING
@HEX_TO_INT32_IS_DIGIT:
	SUB BX, '0'
@HEX_TO_INT32_ADDING:
	PUSH CX
	MOV AL, CL
	MOV CL, 4
	MUL CL
	MOV CL, AL
	; Transforming 16^n to 2^4n and shifting a bit on 4n
	SHL EBX, CL
	POP CX
	DEC CX
	ADD INT_32_RES, EBX
	INC SI
	JMP @HEX_TO_INT32_START
@HEX_TO_INT32_EXIT:
	POP SI
	POPAD
	MOV EDX, INT_32_RES
	RET
HEX_TO_INT32 ENDP


;-----------------------------
; DX - should contain the pointer to the buffer to read in
; CX - should contain the size of the buffer
; In the end CX will contain the number of read characters

READ_STR	PROC	FAR
	PUSH AX
	PUSH BX
	PUSH SI
	
	MOV SI, DX
	MOV BX, 0
@READ_STR_READING_LOOP:
	MOV AH, 1
	INT 21H
	
	CMP AL, 13
	JE @READ_STR_READING_END
	MOV [SI][BX], AL
	INC BX
	JMP @READ_STR_READING_LOOP
@READ_STR_READING_END:
	MOV [SI][BX], '$'
	MOV CX, BX
	MOV DX, SI
	
	POP SI
	POP BX
	POP AX
	RET
READ_STR ENDP

;-----------------------------
; Takes a string from DX. Counts char until 0 or '$'
; Puts the length to CX.

STR_LEN	PROC	FAR
	PUSH SI
	MOV SI, DX
	MOV CX, 0
@STR_LEN_START:
	CMP BYTE PTR [SI], 0
	JE @STR_LEN_END
	CMP BYTE PTR [SI], '$'
	JE @STR_LEN_END
	INC SI
	INC CX
	JMP @STR_LEN_START
@STR_LEN_END:
	POP SI
	RET
STR_LEN	ENDP

;------------------------------------------
; Converts string to int,
; the pointer to the string to convert are to be in DX
; Puts the result in EDX
BIN_TO_INT  PROC    FAR
	PUSHAD
    PUSH SI
	MOV SI, DX
    CALL STR_LEN
    ;Power of 2
    DEC CL
    ;The actual result
    MOV INT_32_RES, 0
@BEG:
    ;The number for exponentiation
    MOV EAX, 0
    ;Bit
    MOV AL, BYTE PTR [SI]
    CMP AL, 0
    JE @TO_INT_R
    CMP AL, '$'
    JE @TO_INT_R
	SUB EAX, '0'
    SHL EAX, CL
    ADD INT_32_RES, EAX
    INC SI
    DEC CL
    JMP @BEG
@TO_INT_R:
	POP SI
	POPAD
	MOV EDX, INT_32_RES
    RET
BIN_TO_INT ENDP

;------------------------------------------------------------
; Reverse the string whose pointer is in DX

.DATA
	J DW 0
	STR_PTR DW 0
.CODE
REVERSE_STR		PROC	FAR
	PUSHAD
	PUSH SI
	MOV SI, DX
	CALL STR_LEN
	MOV J, CX
	DEC J
	SHR CX, 1
	MOV BX, 0
	MOV EAX, 0
@REVERSE_STR_CYCLE:
	MOV AL, BYTE PTR [SI + BX]
	PUSH BX
	MOV BX, J
	XOR AL, BYTE PTR [SI + BX]
	XOR BYTE PTR [SI + BX], AL
	XOR AL, BYTE PTR [SI + BX]
	POP BX
	MOV BYTE PTR [SI + BX], AL
	INC BX
	DEC J
	CMP BX, CX
	JL @REVERSE_STR_CYCLE
	MOV STR_PTR, SI
	
	POP SI
	POPAD
	MOV DX, STR_PTR
	RET
REVERSE_STR ENDP

; ---------------------------------------------------------
; Gets the number to covert from ECX, and the buffer's pointer from DX.
; Puts the pointer to the result into DX.

.CODE
TO_BINIRY_STRING   PROC    FAR
	PUSHAD
	PUSH SI
	MOV EAX, ECX
	MOV SI, DX
    MOV BX, 0
	MOV EDX, 0
@ST:
	MOV DL, 48
    CMP EAX, 2
    JL @R
	SHR EAX, 1
	JNC @NOPE
	INC DL
@NOPE:
	MOV BYTE PTR [SI + BX], DL
    INC BX
    JMP @ST
@R:
    ADD AL, 48
	MOV BYTE PTR [SI + BX], AL
	MOV STR_PTR, SI
	POP SI
	POPAD
	MOV DX, STR_PTR
	CALL REVERSE_STR
	RET
TO_BINIRY_STRING ENDP

;----------------------------------
; Takes a number form EDX and in the end return 0 or 1 into DX.
.DATA
    F_EQ    DB  "12!3,!23,!1!2,!2!3$"
    BIT     DW 0
	ONE_MORE DW 0
.CODE
CALCULATE_F     PROC    FAR
    PUSHAD
	PUSH SI
	LEA SI, F_EQ
	MOV EAX, 1
	MOV ECX, 0
	MOV EBX, 0
@CALCULATE_F_CONJ:
	CMP BYTE PTR [SI], 0
	JE @CALCULATE_F_CONJ_END
	CMP BYTE PTR [SI], '$'
	JE @CALCULATE_F_CONJ_END
	CMP BYTE PTR [SI], ','
	JE @CALCULATE_F_NEW
	CMP BYTE PTR [SI], '!'
	JNE @CALCULATE_F_POS
	MOV BX, 1
	INC SI
	JMP @CALCULATE_F_CONJ
@CALCULATE_F_POS:
	MOV BIT, 1
	PUSH EAX
	MOV EAX, 0
	MOV AL, BYTE PTR [SI]
	SUB AL, '0'
	BT EDX, EAX
	POP EAX
	JC @NEXT
	MOV BIT, 0
@NEXT:
	CMP BX, 0
	JE @CALCULATE_F_NON_NEG
	XOR BIT, 1
	MOV BX, 0
@CALCULATE_F_NON_NEG:
	AND AX, BIT
	INC SI
	JMP @CALCULATE_F_CONJ
@CALCULATE_F_NEW:
	PUSH AX
	MOV AX, 1
	INC CX
	INC SI
	JMP @CALCULATE_F_CONJ
@CALCULATE_F_CONJ_END:
	MOV BX, 0
@CALCULATE_F_DISJ:
	DEC CX
	POP AX
	OR BX, AX
	CMP CX, 0
	JG @CALCULATE_F_DISJ
	MOV STR_PTR, BX
	POP SI
	POPAD
	MOV DX, STR_PTR
    RET
CALCULATE_F ENDP

;---------------------------
; Take the pointer form DX and print the string.
PRINT	PROC	FAR
	PUSHAD
	MOV AH, 9
	INT 21H
	POPAD
	RET
PRINT ENDP

;----------------
; Print char in DL
PRINT_CHAR	PROC FAR
	PUSHAD
	MOV AH, 02H
	INT 21H
	POPAD
	RET
PRINT_CHAR ENDP

;-------------------
; Print str + '\n'
PRINTLN	PROC	FAR
	CALL PRINT
	PUSHAD
	; 10 - NEW LINE ASCII CODE
	MOV DL, 10
	CALL PRINT_CHAR
	; 13 - Carriage return
	MOV DL, 13
	CALL PRINT_CHAR
	POPAD
	RET
PRINTLN ENDP

PUBLIC READ_STR, STR_LEN, BIN_TO_INT, REVERSE_STR, TO_BINIRY_STRING, CALCULATE_F, FILL_STR, TO_LOWER, HEX_TO_INT32, PRINT, PRINTLN, PRINT_CHAR

END