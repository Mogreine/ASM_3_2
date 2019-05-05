%include "io.inc"

section .data
    msg db "Sum is ", 0

section .text
global CMAIN
CMAIN:
    PRINT_STRING msg
    mov eax, 23
    mov ebx, 7
    call sum
    PRINT_DEC 4, eax
    
    mov eax, 0
    ret

sum:
    add eax, ebx
    ret