%include "io.inc"

struc pair
    dc:     resd 1
    p:    resd 1
endstruc

section .data
struc_size equ 8

temp_byte4 dd 0
temp_byte1 db 0

str1 db 'Enter a number count: ', 0
str2 db 'Enter the number of the words you want to be printed and their indices: ', 0
str4 db 'Result: ', 0

section .bss
arr resb struc_size * 20
arr_len resd 1
cmp_res resd 1

ind1 resd 1
ind2 resd 1

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    
    ; Prints the task
    PRINT_STRING str1
    NEWLINE
    
    ; read input data
    GET_DEC 4, arr_len
    call read_arr
    
    
	
    xor eax, eax
    ret

; takes elements using indecis ind1, ind2
compare:
    pushad
    mov ebx, [ind1]
    mov edx, [ind2]
    mov eax, [arr + ebx * struc_size + dc]
    mov ecx, [arr + ebx * struc_size + p]
    sub ecx, [arr + edx * struc_size + p]
    cmp ecx, 0
    jb compare_neg
    ; push ebx, 'cause it's gonna be used as divisor
    push ebx
    mov ebx, 10
compare_mul:
    imul ebx
    loop compare_mul
    jmp compare_end
compare_neg:
    cmp ecx, 0
    jge compare_end
    idiv ebx
    inc ecx
    jmp compare_neg    
compare_end:
    pop ebx
    sub eax, [arr + edx * struc_size + dc]
    cmp eax, 0
    jge compare_greater
    mov dword [cmp_res], 1
    jmp compare_ret
compare_greater:
    mov dword [cmp_res], 0
compare_ret:
    popad
    ret

; Implements buble sort
sort_arr:
    ret

read_arr:
    pushad
    mov ecx, 0
read_arr_start:
    cmp ecx, [arr_len]
    jge read_arr_end
    GET_DEC 4, eax
    mov [arr + ecx * struc_size + dc], eax
    GET_DEC 4, eax
    mov [arr + ecx * struc_size + p], eax
    inc ecx
    jmp read_arr_start
read_arr_end:
    popad
    ret
