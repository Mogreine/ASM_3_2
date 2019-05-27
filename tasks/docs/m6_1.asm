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
	mov si,0
	mov cx,N
mov cx, 15
shr cx, 1
lea si, mas
stack_cycle:
mov al, [si]
inc si
mov ah, [si]
inc si
push ax
loop stack_cycle
mov cx, 15
shr cx, 1
show:
	pop bx
	mov dl,mas[bl]
	add dl,30h
	mov ah,02h
	int 21h
	
	mov dl,mas[bh]
	add dl,30h
	int 21h
loop show
mov dl,mas[si]
add dl,30h
mov ah,02h
int 21h

exit:
	mov ax,4c00h
	int 21h
end main
