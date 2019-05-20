%include "io.inc"

struc fixed
    num:    resd 1
    exp:    resd 1
endstruc

section .data
struc_size equ 8

temp_byte4 dd 0
temp_byte1 db 0

str1 db 'The task is to calculate (A[i] - A[j]) * (A[j] - 1)', 0
str2 db 'Calculations are to be in m * exp(-e) notation', 0
str3 db 'Result:', 0

section .bss

strucs_arr resb struc_size * 15

nums_number resd 1
ind1 resd 1
ind2 resd 1

res1 resd 2
res2 resd 2

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    
    ; Prints the task
    PRINT_STRING str1
    NEWLINE
    PRINT_STRING str2
    NEWLINE
    
    GET_DEC 4, nums_number
    mov ebx, 0
reading_cycle:
    cmp ebx, [nums_number]
    jnl reading_cycle_end
    GET_DEC 4, eax
    mov [strucs_arr + ebx * struc_size + num], eax
    GET_CHAR ax
    GET_DEC 4, eax
    mov [strucs_arr + ebx * struc_size + exp], eax
    inc ebx
    jmp reading_cycle
reading_cycle_end:
    
    GET_DEC 4, ind1
    GET_DEC 4, ind2
    
    call sub_fixed
    
    ;PRINT_DEC 4, [res1 + num]
    ;PRINT_CHAR 'E'
    ;PRINT_DEC 4, [res1 + exp]
    ;NEWLINE
    
    call mul_fixed
    
    ; Prints the result
    PRINT_STRING str3
    NEWLINE
        
    PRINT_DEC 4, [res1 + num]
    PRINT_CHAR 'E'
    PRINT_DEC 4, [res1 + exp]
    NEWLINE
    
    xor eax, eax
    ret

sub_fixed:
    mov ebp, esp
    
    pushad
    ; putting indices into registers to have access
    mov ebx, [ind1]
    mov edx, [ind2]
    
    ; putting m1 into res1.num
    mov eax, [strucs_arr + ebx * struc_size + num]
    mov [res1 + num], eax
    
    ; putting e2 - e1 into ecx
    mov ecx, 0
    mov eax, [strucs_arr + ebx * struc_size + exp]
    sub ecx, eax
    mov eax, [strucs_arr + edx * struc_size + exp]
    add ecx, eax
    
    ; calculates res1.num = m1^(e2 - e1)
    mov eax, [res1 + num]
    call shift
    mov [res1 + num], eax
    
    ; calculate res1.num -= m2
    mov eax, [strucs_arr + struc_size * edx + num]
    sub [res1 + num], eax
    
    ; calculates res1.exp = e2
    mov eax, [strucs_arr + struc_size * edx + exp]
    mov [res1 + exp], eax
    popad
    ret
    
mul_fixed:
    mov ebp, esp
    pushad
    mov edx, [ind2]
    
    ; puts m2 into res2.num
    mov eax, [strucs_arr + struc_size * edx + num]
    mov [res2 + num], eax    
    
    ; transforms 1 to fixed: 1 << e2 and subs it from res2.num. Also puts e2 into res2.exp
    mov eax, [strucs_arr + struc_size * edx + exp]
    mov [res2 + exp], eax
    mov cl, al
    mov eax, 1
    shl eax, cl
    sub [res2 + num], eax
    
    ; exp calculating
    mov eax, [res1 + exp]
    add eax, [res2 + exp]
    mov [res1 + exp], eax
    
    ; num calculating
    mov eax, [res1 + num]
    imul eax, [res2 + num]
    mov [res1 + num], eax  
    
    popad
    ret

; Takes the values to shift form eax, the shift length from ecx
; returns the shifted value to eax
shift:
    mov ebp, esp
    push DWORD [temp_byte4]
    mov [temp_byte4], eax
    pushad
    cmp ecx, 0
    jl shift_neg
    shl DWORD [temp_byte4], cl
    jmp shift_end
shift_neg:
    mov eax, ecx
    call abs_val
    mov cl, al
    shr DWORD [temp_byte4], cl
shift_end:
    popad
    mov eax, [temp_byte4]
    pop DWORD [temp_byte4]
    ret

; Takes the value form eax
abs_val:
    mov ebp, esp
    push DWORD [temp_byte4]
    pushad
    mov [temp_byte4], eax
    sar eax, 31
    xor [temp_byte4], eax
    sub [temp_byte4], eax
    popad
    mov eax, [temp_byte4]
    pop DWORD [temp_byte4]
    ret

print_array:
    mov ebx, 0
print_cycle:
    cmp ebx, [nums_number]
    jnl print_cycle_end
    PRINT_DEC 4, [strucs_arr + ebx * struc_size + num]
    PRINT_CHAR ' '
    PRINT_DEC 4, [strucs_arr + ebx * struc_size + exp]
    NEWLINE
    inc ebx
    jmp print_cycle
print_cycle_end:
ret
    
