%include "io.inc"

struc pair
    num:     resd 1
    _word:    resb 20
endstruc

section .data
struc_size equ 24

temp_byte4 dd 0
temp_byte1 db 0

str1 db 'Enter a string: ', 0
str2 db 'Enter the number of the words you want to be printed and their indices: ', 0
str4 db 'Result: ', 0

section .bss
strucs_arr resb struc_size * 20

input_str resb 50

words_to_print resd 1
words_counter resd 1

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    
    ; Prints the task
    PRINT_STRING str1
    NEWLINE
    ; split the string
    call read_input
	
    ; print the struc arr
    mov ebx, strucs_arr
    mov ecx, words_counter
    call print_arr
    
    ; 
    PRINT_STRING str2
    NEWLINE
    GET_DEC 4, words_to_print
    
    call print_result
	
    xor eax, eax
    ret
    
print_result:
    pushad
    PRINT_STRING str4
    NEWLINE
    mov ecx, 0
print_result_start:
    cmp dword [words_to_print], 0
    je print_result_end
    GET_DEC 4, eax
    imul eax, struc_size
    PRINT_DEC 4, ecx
    PRINT_CHAR ' '
    PRINT_STRING [strucs_arr + eax + _word]
    NEWLINE
    inc ecx
    dec dword [words_to_print]
    jmp print_result_start    
print_result_end:
    popad
    ret

read_input:
    pushad
    ; read string
    GET_STRING input_str, 50
    ; counter
    mov dword [words_counter], 0
    ; string ind in bytes
    mov ebx, 0
    ; string ind
    mov ecx, 0
splitting_start:
    mov eax, dword [words_counter]
    mov dword [strucs_arr + ebx + num], eax
    ; word ind
    mov edx, 0
new_word_start:
    cmp byte [input_str + ecx], ' '
    je new_word_end
    cmp byte [input_str + ecx], 0
    je new_word_end
    mov al, [input_str + ecx]
    mov byte [strucs_arr + ebx + _word + edx], al
    inc ecx
    inc edx
    jmp new_word_start
new_word_end:
    mov byte [strucs_arr + ebx + _word + edx], 0
    add ebx, struc_size
    inc dword [words_counter]
    cmp byte [input_str + ecx], 0
    je splitting_end
    inc ecx
    jmp splitting_start	
splitting_end:
    popad
    ret

; takes the pointer to te struct arr to print from ebx
; takes the number of elements to print from ecx
print_arr:
    pushad
    mov ebx, 0
    mov ecx, 0
print_arr_start:
    cmp ecx, [words_counter]
    jge print_arr_end
    PRINT_DEC 4, [strucs_arr + ebx + num]
    PRINT_CHAR ' '
    PRINT_STRING [strucs_arr + ebx + _word]
    NEWLINE
    add ebx, struc_size
    inc ecx
    jmp print_arr_start	
print_arr_end:
    popad
    ret
