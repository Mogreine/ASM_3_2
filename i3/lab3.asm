%include "io.inc"

struc pair
    dc:     resd 1
    p:    resd 1
    sign: resd 1
endstruc

section .data
struc_size equ 8

temp_byte4 dd 0
temp_byte1 db 0

str1 db 'Enter a number count: ', 0
str2 db 'Enter the indices: ', 0
str3 db 'Result: ', 0

section .bss
arr resb struc_size * 20
arr_len resd 1
cmp_res resd 1
signs_sum resd 1

tmp_val resd 2

ind1 resd 1
ind2 resd 1

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    mov eax, 745
    mov ebx, 10
    idiv ebx
    
    ; Prints the task
    PRINT_STRING str1
    NEWLINE
    
    ; read input data
    GET_DEC 4, arr_len
    mov ecx, [arr_len]
    call read_arr
    call sort_arr
    
    ; reads the indices
    GET_DEC 4, ebx
    GET_DEC 4, ecx
    
print_res:
    cmp ebx, ecx
    jg print_res_end
    PRINT_DEC 4, [arr + ebx * struc_size + dc]
    PRINT_CHAR 'P'
    PRINT_DEC 4, [arr + ebx * struc_size + p]
    NEWLINE
    inc ebx
    jmp print_res    
print_res_end:    
	
    xor eax, eax
    ret

; takes elements using indecis ind1, ind2
compare:
    mov ebp, esp; for correct debugging
    pushad
    mov ebx, [ind1]
    mov edx, [ind2]
    mov eax, [arr + ebx * struc_size + dc]
    mov ecx, [arr + ebx * struc_size + p]
    sub ecx, [arr + edx * struc_size + p]
    ; push ebx, 'cause it's gonna be used as divisor
    push ebx
    mov ebx, 10
    cmp ecx, 0
    jl compare_neg
compare_mul:
    cmp ecx, 0
    jle compare_mul_end
    push edx
    imul ebx
    pop edx
    dec ecx
    jmp compare_mul
compare_mul_end:
    pop ebx
    cmp eax, [arr + edx * struc_size + dc]
    jl compare_less
    jmp compare_greater
compare_neg:
    mov eax, [arr + edx * struc_size + dc]
compare_neg_cycle:
    cmp ecx, 0
    jge compare_neg_end
    push edx
    imul ebx
    pop edx
    inc ecx
    jmp compare_neg_cycle
compare_neg_end:
    pop ebx
    mov ecx, [arr + ebx * struc_size + dc]
    cmp ecx, eax
    jl compare_less
    jmp compare_greater
compare_less:
    mov dword [cmp_res], 1
    jmp compare_ret
compare_greater:
    mov dword [cmp_res], 0
compare_ret:
    popad
    ret

; Takes the values from ind1 and ind2
swap:
    mov ebp, esp; for correct debugging
    pushad
    mov ebx, [ind1]
    mov edx, [ind2]
    
    ; moving data from arr[ind2] to tmp_val
    mov eax, [arr + edx * struc_size + dc]
    mov [tmp_val + dc], eax
    mov eax, [arr + edx * struc_size + p]
    mov [tmp_val + p], eax
    
    ; moving data from arr[ind1] to arr[ind2]
    mov eax, [arr + ebx * struc_size + dc]
    mov [arr + edx * struc_size + dc], eax
    mov eax, [arr + ebx * struc_size + p]
    mov [arr + edx * struc_size + p], eax
    
    ; moving data from tmp_val to arr[ind1]
    mov eax, [tmp_val + dc]
    mov [arr + ebx * struc_size + dc], eax
    mov eax, [tmp_val + p]
    mov [arr + ebx * struc_size + p], eax
    
    popad
    ret

; Implements buble sort
sort_arr:
    mov ebp, esp; for correct debugging
    pushad
    mov ecx, [arr_len]
    dec ecx
buble1:
    push ecx
    mov ecx, [arr_len]
    dec ecx
buble2:
    mov eax, [arr_len]
    dec eax
    sub eax, ecx
    mov [ind1], eax
    mov [ind2], eax
    inc dword [ind2]
    call compare
    cmp dword [cmp_res], 1
    ; do not swap if not less
    je no_change
    call swap
no_change: 
    loop buble2
    pop ecx
    loop buble1
buble1_end:
    popad
    ret

; reads input data
read_arr:
    mov ebp, esp; for correct debugging
    pushad
    mov ecx, 0
read_arr_start:
    cmp ecx, [arr_len]
    jge read_arr_end
    GET_DEC 4, eax
    mov [arr + ecx * struc_size + dc], eax
    GET_CHAR ax
    GET_DEC 4, eax
    mov [arr + ecx * struc_size + p], eax
    inc ecx
    jmp read_arr_start
read_arr_end:
    popad
    ret
