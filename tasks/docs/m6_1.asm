model small
stack 256
.data
	N=5
	mas db 5 dup (3 dup(0))
.code
main:
mov ax,@data
mov ds,ax
xor ax,ax
mov si,0
mov cx,N

go:
mov dl,mas[si]
inc dl
mov mas[si],dl
add si,3
loop go

mov cx, N
lea si, mas
stack_cycle:
mov al, [si]
inc si
push ax
loop stack_cycle
mov cx, N
show:
	pop bx
	mov dl, mas[bl]
	add dl, 30h
	mov ah, 02h
	int 21h
loop show

exit:
	mov ax,4c00h
	int 21h
end main
