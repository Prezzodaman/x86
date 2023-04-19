stars_size equ 17
stars:
dw 32,1
dw 24,126
dw 226,349
dw 185,337
dw 100,154
dw 186,122
dw 262,31
dw 187,260
dw 2,38
dw 144,185
dw 63,259
dw 235,209
dw 238,1
dw 315,79
dw 279,273
dw 94,37
dw 288,371

star_y_offset dw 0

stars_draw:
	xor bx,bx
	mov cx,stars_size
.loop:
	push cx
	mov cx,[stars+bx]
	add bx,2
	mov dx,[stars+bx]
	sub dx,[star_y_offset]
	add bx,2
	call bgl_get_x_y_offset
	mov byte [es:di],26
	pop cx
	dec cx
	cmp cx,0
	jne .loop
	ret