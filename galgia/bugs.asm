; there'll be plenty of these phwwoaaaa let me tell ya

bugs_init: ; m8
	xor bx,bx
	mov cx,0 ; x offset
	mov dx,0 ; y offset
.loop:
	mov byte [bug_active+bx],1
	mov byte [bug_shot+bx],0
	
	cmp byte [bug_type+bx],1
	je .bugs_start_2
	cmp byte [bug_type+bx],2
	je .bugs_start_3
	mov word [bug_x+bx],bug_x_start
	jmp .bugs_start_skip
.bugs_start_2:
	mov word [bug_x+bx],bug_x_start+(bug_x_spacing*2)
	jmp .bugs_start_skip
.bugs_start_3:
	mov word [bug_x+bx],bug_x_start+(bug_x_spacing*4)
.bugs_start_skip:
	add word [bug_x+bx],cx
	add cx,bug_x_spacing
	mov word [bug_y+bx],bug_y_start
	add word [bug_y+bx],dx
	
	cmp byte [bug_type+bx],1 ; perform bound checks for bug type 2
	je .bugs_x_2
	cmp byte [bug_type+bx],2 ; bug type 3...
	je .bugs_x_3
	cmp cx,300 ; checks for bug type 1
	jl .end
	jmp .bugs_x_skip
.bugs_x_2:
	cmp cx,200
	jl .end
	jmp .bugs_x_skip
.bugs_x_3:
	cmp cx,130
	jl .end
	jmp .bugs_x_skip
.bugs_x_skip:
	xor cx,cx
	add dx,bug_y_spacing
.end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	ret

bugs_draw:
	xor bx,bx
.loop:
	cmp byte [bug_active+bx],0 ; is the current bug active/visible?
	je .end ; if not, skip this bug
	mov ax,[bug_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[bug_y+bx]
	mov word [bgl_y_pos],ax
	
	cmp byte [bug_type+bx],1
	je .bug_2
	cmp byte [bug_type+bx],2
	je .bug_3
	mov word [bgl_buffer_offset],bug_1_gfx
	jmp .type_skip
.bug_2:
	mov word [bgl_buffer_offset],bug_2_gfx
	jmp .type_skip
.bug_3:
	mov word [bgl_buffer_offset],bug_3_gfx
.type_skip:
	call bgl_draw_gfx
.end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	ret

bugs_handler:
	xor bx,bx
.loop:
	ret

bug_1_amount equ 12*2 ; yes i can work out 12*2, but it's here to let me know that there'll be 2 rows of bug 1 :)
bug_2_amount equ 8
bug_3_amount equ 4
bug_amount equ bug_1_amount+bug_2_amount+bug_3_amount ; much, much easier to handle as one set of variables instead of bug 1 x, bug 2 x, bug 3 x, etc...
bug_width equ 19
bug_height equ 16
bug_x_start equ 14
bug_y_start equ 10
bug_x_spacing equ 6+bug_width
bug_y_spacing equ 3+bug_height

bug_x times bug_amount dw 0
bug_y times bug_amount dw 0
bug_active times bug_amount dw 0
bug_x_vel times bug_amount dw 0
bug_y_vel times bug_amount dw 0
bug_angle times bug_amount dw 0
bug_shot times bug_amount dw 0
bug_type:
	times bug_1_amount dw 0
	times bug_2_amount dw 1
	times bug_3_amount dw 2

bug_1_gfx: incbin "alien_1.gfx"
bug_2_gfx: incbin "alien_2.gfx"
bug_3_gfx: incbin "alien_3.gfx"