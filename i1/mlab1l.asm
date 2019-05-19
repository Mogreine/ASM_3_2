;*********************************************************
; ?????? ??? ?????? ???? ???????? ???? N 1  *
; ?? ???. 10.09.02: ?????? ?.?.                           *
;*********************************************************

.MODEL SMALL
.CODE
.386
 INCLUDE mlab1.inc
 LOCALS
;=====================================================
; ???????? ???? ?? ?? ????, ??????? SI, 
; ? ??????? ????? ????? ??????? ? <CX,DX> mcs.
; ???????? ???? ?????? ????? 0 ??? 0FFh.
; ???? ???? ??????????? ???? 0,
;   ?? ?????????? ???? ? ???? ????? ????
; 
;=====================================================
PUTSS   PROC    NEAR
@@L:    MOV AL, [SI]
        CMP AL, 0FFH
        JE  @@R
        CMP AL, 0
        JZ  @@E
        CALL    PUTC
        INC SI
    CALL    DILAY
        JMP SHORT @@L
        ; ???? ?? ??????? ????
@@E:    MOV AL, CHCR
        CALL    PUTC
        MOV AL, CHLF
        CALL    PUTC
@@R:    RET
PUTSS   ENDP

;==============================================
; ???????? ???? AL ?? ?????
;==============================================
PUTC    PROC    NEAR
        PUSH    DX
        MOV DL,   AL
        MOV AH,   FUPUTC
        INT DOSFU
        POP DX
        RET
PUTC    ENDP

;==============================================
; ???????? ????? ????? ? AL ? ??????
;==============================================
GETCH   PROC    NEAR
        MOV AH,   FUGETCH
        INT DOSFU
        RET
GETCH   ENDP

;=================================================
; ???????? ????? ???? ? ????, ?????? DX
;   ? ????? ????????: 
;    { char size; // ???? ???? 
;      char len;  // ??? ???????
;      char str[size]; // ????? ???? }
;=================================================
GETS    PROC    NEAR
    PUSH    SI
    MOV SI, DX
        MOV AH, FUGETS
        INT DOSFU
    ; ?????? ???? 0 ? ????? ????
    XOR AH, AH
    MOV AL, [SI+1]
    ADD SI, AX
    MOV BYTE PTR [SI+2], 0
    POP SI
        RET
GETS    ENDP

;==============================================
; ???????? ?????? ?? ?????? ? ????,
; ??????? SI. ???????? ????: 0 ? 0FFh
; ??????? ????????? ? AX
;==============================================
SLEN    PROC    NEAR
    XOR     AX,   AX
LSLEN:  CMP     BYTE PTR [SI], 0
    JE  RSLEN
        CMP     BYTE PTR [SI], 0FFh
    JE  RSLEN
    INC AX
    INC SI
    JMP SHORT   LSLEN
RSLEN:  RET
SLEN    ENDP

;====================================================
; ???????? ?????????? <EDX,EAX> ? ??????????? 
; ???????, ??????? ?? ????? DI
;==============================================
    .DATA
UBINARY DQ  0  ; ?????? ?????? 64-?????
UPACK   DT  0  ; ?????????? 18 ???????? ??? 
    .CODE
UTOA10  PROC    NEAR
    PUSH    CX
    PUSH    DI
    MOV DWORD PTR [UBINARY],   EAX
    MOV DWORD PTR [UBINARY+4], EDX
    FINIT           ; ?????????? ??????
    FILD    UBINARY     ; ????????? ? ???? ???????
    FBSTP   UPACK       ; ???????? ?????????? ????????
    MOV CX, LENPACK ; ?????? 9 ??? ???
    PUSH    DS      ; ????? 
    POP ES      ;   ???
    CLD             ;     ?? stosw
    LEA SI, UPACK   ;     ? ???? 
    ADD SI, LENPACK ;     ???? upack        
    ; ???? ?????????? ??? ?????? ? ASCII-???? ???
@@L:    XOR AX, AX
    DEC SI
    MOV AL, [SI]
    SHL AX, 4
    SHR AL, 4   
    ADD AX, 3030h
    XCHG    AL, AH
    STOSW       
    LOOP    @@L
    ; ?????? ???? ????
    XOR AL,     AL
    STOSB
    ; ????? ???????? ??? ???????? ??
    CLD
    MOV AX, LENNUM-4    
@@L1:   MOV CX, AX
    POP DI     ; ???? ?? ???? ????
    PUSH    DI  
    MOV SI, DI
    INC SI
    REP MOVSB
    MOV BYTE PTR [DI], CHCOMMA ; ?????? ??????? ??? ???
    SUB AX, 4  ;     3 ???? + ??????? ??????
    JS  @@E        ; ??????, ?? ?????? ?? ????? 3-? ???
    JMP SHORT   @@L1
@@E:    POP SI
    PUSH    SI
    XOR CX, CX
    ; ????? ???? ??
    ;   ??? ?????????
@@L2:   CMP BYTE PTR [SI], '0'
    JE  @@N
    CMP BYTE PTR [SI], CHCOMMA      
    JNE @@N1
@@N:    INC CX
    INC SI
    JMP SHORT   @@L2
@@N1:   ;   ? ???? ?????
    POP DI
    SUB CX, LENNUM+1
    NEG CX
    REP MOVSB
    POP CX
        RET
UTOA10  ENDP

;==============================================
; ???????? ?????? ???????? ????? 
; ?? <CX,DX> ?????? 
;==============================================
DILAY   PROC    NEAR
    MOV AH, 86h
        INT 15h
        RET
DILAY   ENDP

        PUBLIC  PUTSS, PUTC, GETCH, GETS, DILAY, SLEN, UTOA10

        END
