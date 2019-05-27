1
mov eax, 0
cycle1:
cmp eax, 0
je 1_act
jmp 1_after
1_act:
action
jmp cycle1
1_after:

2
mov eax, 0
1_do:
action
cmp eax, 0
je 1_do

3
section .data
start equ 2
fin equ 10
size equ 4

section .bss
arr resd 20

section .text
global CMAIN
CMAIN:
mov ebx, [size]
mov ecx, [start]
cycle:
cmp ebx, ecx
jg cycle_end
add eax, [arr + ebx * size]
cycle_end: 
