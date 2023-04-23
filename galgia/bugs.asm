; there'll be plenty of these phwwoaaaa let me tell ya

bugs_add_score:
	cmp byte [player_current],0
	jne .p2
	add dword [player_1_score],bug_score
	jmp .end
.p2:
	add dword [player_2_score],bug_score
.end:
	ret

bugs_init: ; m8
	xor bx,bx
	xor cx,cx ; x offset
	xor dx,dx ; y offset
.loop:
	mov byte [bug_active+bx],1
	mov byte [bug_shot+bx],0
	mov byte [bug_hits+bx],0
	mov byte [bug_flying+bx],0
	mov word [bug_angle+bx],0
	
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

bugs_bomb_handler:
	inc byte [bug_bomb_delay]
	cmp byte [bug_bomb_delay],20
	jne .bombs ; haven't reached delay yet, handle bombs as normal
	mov byte [bug_bomb_delay],0
	
	movzx bx,[bug_bomb_current]
	shl bx,1
	cmp byte [bug_bomb_active+bx],0 ; current bomb active?
	jne .active_skip ; if so, try next bomb
	mov byte [bug_bomb_active+bx],1 ; not active yet, make it
	mov ax,bx ; ax is bomb offset, for now
.get_bug:
	push ax ;
	call random ; ax will contain a random number
	xor dx,dx
	mov bx,bug_amount
	div bx ; dx will contain what we want...
	mov bx,dx
	shl bx,1 ; word length
	pop ax ;
	
	cmp word [bugs_shot],bug_amount
	je .bombs
	cmp byte [bug_active+bx],0 ; make sure this bug is active first!
	je .get_bug ; if not, try again
	cmp byte [bug_shot+bx],0 ; it's active, but has it been shot?
	jne .bombs ; if so, skip to bomb handler
	mov cx,[bug_x+bx]
	sar cx,bug_precision
	add cx,bug_width/2
	mov dx,[bug_y+bx]
	sar dx,bug_precision
	add dx,bug_height/2
	
	mov bx,ax
	mov word [bug_bomb_x+bx],cx
	mov word [bug_bomb_y+bx],dx
	jmp .bombs
	
.active_skip:
	inc byte [bug_bomb_current]
	cmp byte [bug_bomb_current],bug_bomb_amount
	jne .bombs
	mov byte [bug_bomb_current],0
	
.bombs:
	xor bx,bx ; let's get down to business
.bombs_loop:
	cmp byte [bug_bomb_active+bx],0
	je .end
	add word [bug_bomb_y+bx],bug_bomb_speed
	cmp word [bug_bomb_y+bx],200 ; reached bottom of screen?
	jl .end ; if not, skip
	mov byte [bug_bomb_active+bx],0 ; otherwise, reset
.end:
	add bx,2
	cmp bx,bug_bomb_amount*2
	jne .bombs_loop
	ret

bugs_bomb_draw:
	xor bx,bx
	mov word [bgl_buffer_offset],bug_bomb_gfx
.loop:
	cmp byte [bug_bomb_active+bx],0
	je .end
	mov ax,[bug_bomb_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[bug_bomb_y+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx
.end:
	add bx,2
	cmp bx,bug_bomb_amount*2
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
	cmp byte [bug_shot+bx],0 ; current bug shot?
	jne .shot ; if so, draw explosion
	
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
	mov al,[bug_hits+bx]
	shl al,3
	mov byte [bgl_tint],al
	call bgl_draw_gfx
	jmp .end
.shot:
	add word [bgl_x_pos],5
	add word [bgl_y_pos],4
	mov ax,[bug_explose_frame+bx]
	shr ax,bug_explose_speed
	cmp ax,1
	je .shot_2
	cmp ax,2
	je .shot_3
	cmp ax,3
	je .shot_4
	cmp ax,4
	je .shot_5
	mov word [bgl_buffer_offset],bug_explose_1_rle
	jmp .shot_skip
.shot_2:
	sub word [bgl_x_pos],4
	sub word [bgl_y_pos],4
	mov word [bgl_buffer_offset],bug_explose_2_rle
	jmp .shot_skip
.shot_3:
	sub word [bgl_x_pos],6
	sub word [bgl_y_pos],5
	mov word [bgl_buffer_offset],bug_explose_3_rle
	jmp .shot_skip
.shot_4:
	sub word [bgl_x_pos],11
	sub word [bgl_y_pos],8
	mov word [bgl_buffer_offset],bug_explose_4_rle
	jmp .shot_skip
.shot_5:
	sub word [bgl_x_pos],15
	sub word [bgl_y_pos],10
	mov word [bgl_buffer_offset],bug_explose_5_rle
.shot_skip:
	mov byte [bgl_tint],0
	call bgl_draw_gfx_rle_fast ; REALLY FAST.
.end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	
	mov byte [bgl_tint],0
	ret

bugs_handler:
	xor bx,bx
.loop:
	cmp byte [bug_active+bx],0 ; don't handle a bug if it isn't active
	je .loop_end
	; move bugs side to side
	cmp byte [bug_flying+bx],0 ; check that bug isn't flying
	jne .side_end ; don't do any side-related stuff
	cmp byte [bug_shot+bx],0 ; same for if it's shot...
	jne .side_end
	cmp byte [bug_x_add],0 ; moving right?
	je .side_left ; if not, move left
	add word [bug_x+bx],bug_side_speed ; move right
	jmp .side_end
.side_left:
	sub word [bug_x+bx],bug_side_speed ; move left
.side_end:
	cmp byte [bug_shot+bx],0 ; bug shot? (required because other checks branch here)
	je .shot_skip ; if not, skip
	inc byte [bug_explose_frame+bx]
.shot_skip:
	cmp byte [bug_explose_frame+bx],5<<bug_explose_speed ; last explosion frame?
	jne .active_skip ; if not, bug is still active
	mov byte [bug_active+bx],0 ; last frame, bug no longer active
.active_skip:
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
bug_score equ 100

bug_bomb_amount equ 3
bug_bomb_speed equ 3

bug_bomb_active times bug_bomb_amount dw 0
bug_bomb_x times bug_bomb_amount dw 0
bug_bomb_y times bug_bomb_amount dw 0
bug_bomb_delay db 0 ; overall, not per bug
bug_bomb_current db 0

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
bug_hits times bug_amount dw 0 ; for bugs that require multiple hits
bug_type:
	times bug_1_amount dw 0
	times bug_2_amount dw 1
	times bug_3_amount dw 2
bugs_shot dw 0 ; per level
	
bug_explose_speed equ 2

bug_explose_frame times bug_amount dw 0

bug_1_gfx: incbin "alien_1.gfx"
bug_2_gfx: incbin "alien_2.gfx"
bug_3_gfx: incbin "alien_3.gfx"
bug_bomb_gfx: incbin "alien_bomb.gfx"

bug_explose_1_rle: incbin "alien_explose_1.rle"
bug_explose_2_rle: incbin "alien_explose_2.rle"
bug_explose_3_rle: incbin "alien_explose_3.rle"
bug_explose_4_rle: incbin "alien_explose_4.rle"
bug_explose_5_rle: incbin "alien_explose_5.rle"