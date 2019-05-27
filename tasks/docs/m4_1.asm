mov cx, 100
cycle_1:
...
; push cx
mov ax, 50
xchg ax, cx
cycle_2:
...
; push cx
mov bx, 25
xchg bx, cx
cycle_3:
...
loop cycle_3
...
xchg bx, cx
loop cycle_2
...
xchg ax, cx
loop cycle_1
...