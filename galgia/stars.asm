star_amount equ 30
star_speed equ 1

star_x times star_amount dw 0
star_y times star_amount dw 0
star_fast times star_amount dw 0

stars_init:
	xor bx,bx
.loop:
	call randomize
	call random
	push bx
	xor dx,dx
	mov bx,320
	div bx
	mov ax,dx
	pop bx
	mov word [star_x+bx],ax
	
	call random
	push bx
	xor dx,dx
	mov bx,200
	div bx
	mov ax,dx
	pop bx
	mov word [star_y+bx],ax
	
	call randomize
	call random
	and ax,1
	mov byte [star_fast+bx],al
	
	add bx,2
	cmp bx,star_amount*2
	jne .loop
	ret
	
stars_draw:
	xor bx,bx
.loop:
	mov cx,[star_x+bx]
	mov dx,[star_y+bx]
	call bgl_get_x_y_offset
	mov al,20
	add al,[star_fast+bx]
	add al,[star_fast+bx]
	add al,[star_fast+bx]
	add al,[star_fast+bx]
	add al,[star_fast+bx]
	add al,[star_fast+bx]
	mov byte [es:di],al

	add bx,2
	cmp bx,star_amount*2
	jne .loop
	ret
	
stars_handler:
	xor bx,bx
.loop:
	add word [star_y+bx],star_speed
	cmp byte [star_fast+bx],0
	je .fast_skip
	add word [star_y+bx],star_speed
.fast_skip:
	add bx,2
	cmp bx,star_amount*2
	jne .loop
	ret