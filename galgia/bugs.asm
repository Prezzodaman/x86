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
	cmp cx,300<<bug_precision ; checks for bug type 1
	jl .end
	jmp .bugs_x_skip
.bugs_x_2:
	cmp cx,200<<bug_precision
	jl .end
	jmp .bugs_x_skip
.bugs_x_3:
	cmp cx,130<<bug_precision
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
	sar ax,bug_precision
	mov word [bgl_x_pos],ax
	mov ax,[bug_y+bx]
	sar ax,bug_precision
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
	; move bugs side to side
	cmp byte [bug_flying+bx],0 ; check that bug isn't flying
	jne .side_end ; don't do any side-related stuff
	cmp byte [bug_x_add],0 ; moving right?
	je .side_left ; if not, move left
	add word [bug_x+bx],bug_side_speed ; move right
	jmp .side_end
.side_left:
	sub word [bug_x+bx],bug_side_speed ; move left
.side_end:
.loop_end: ; the sidewalk... docta. step aside
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	
	inc byte [bug_x_timer]
	cmp byte [bug_x_timer],50
	jne .end
	mov byte [bug_x_timer],0
	not byte [bug_x_add]
.end:
	ret

bug_1_amount equ 12*2 ; yes i can work out 12*2, but it's here to let me know that there'll be 2 rows of bug 1 :)
bug_2_amount equ 8
bug_3_amount equ 4
bug_amount equ bug_1_amount+bug_2_amount+bug_3_amount ; much, much easier to handle as one set of variables instead of bug 1 x, bug 2 x, bug 3 x, etc...
bug_width equ 19
bug_height equ 16
bug_x_start equ 16<<bug_precision
bug_y_start equ 10<<bug_precision
bug_x_spacing equ (6+bug_width)<<bug_precision
bug_y_spacing equ (3+bug_height)<<bug_precision
bug_precision equ 4 ; always the safe bet
bug_side_speed equ 2

bug_x_add db 0 ; adding or subtracting
bug_x_timer db 0
bug_x times bug_amount dw 0
bug_y times bug_amount dw 0
bug_active times bug_amount dw 0
bug_x_vel times bug_amount dw 0
bug_y_vel times bug_amount dw 0
bug_angle times bug_amount dw 0
bug_flying times bug_amount dw 0
bug_shot times bug_amount dw 0
bug_type:
	times bug_1_amount dw 0
	times bug_2_amount dw 1
	times bug_3_amount dw 2

bug_1_gfx: incbin "alien_1.gfx"
bug_2_gfx: incbin "alien_2.gfx"
bug_3_gfx: incbin "alien_3.gfx"