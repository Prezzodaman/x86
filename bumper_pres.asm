bumper_pres_x_pos dw 0
bumper_pres_y_pos dw 0
bumper_pres_speed db 2
bumper_pres_facing_left db 0
bumper_pres_gfx: incbin "bumper_pres.gfx"
	
bumper_pres_draw:
	push word [bumper_pres_facing_left]
	push 0
	push bumper_pres_gfx
	push word [background_colour]
	push word [bumper_pres_x_pos]
	push word [bumper_pres_y_pos]
	call bgl_draw_gfx
	ret

bumper_pres_movement:
	; detect key presses
	
	xor dx,dx
	mov dl,[bumper_pres_speed]
	
	cmp byte [bgl_key_states+50h],0 ; down pressed?
	je .key_check_up ; if not, skip
	mov ax,200-32
	cmp word [bumper_pres_y_pos],ax ; have we reached the bottom?
	jae .key_check_up ; if so, skip
	add word [bumper_pres_y_pos],dx ; otherwise, move
.key_check_up:
	cmp byte [bgl_key_states+48h],0 ; up pressed?
	je .key_check_left ; if not, skip
	cmp word [bumper_pres_y_pos],0 ; have we reached the top?
	jbe .key_check_left ; if so, skip
	sub word [bumper_pres_y_pos],dx ; otherwise, move
.key_check_left:
	cmp byte [bgl_key_states+4bh],0 ; left pressed?
	je .key_check_right ; if not, skip
	cmp word [bumper_pres_x_pos],0 ; have we reached the left?
	jbe .key_check_right ; if so, skip
	sub word [bumper_pres_x_pos],dx ; otherwise, move
	mov byte [bumper_pres_facing_left],1
.key_check_right:
	cmp byte [bgl_key_states+4dh],0 ; right pressed?
	je .key_check_end ; if not, skip
	mov ax,320-48
	cmp word [bumper_pres_x_pos],ax ; have we reached the right?
	jae .key_check_end ; if so, skip
	add word [bumper_pres_x_pos],dx ; otherwise, move
	mov byte [bumper_pres_facing_left],0
.key_check_end:
	ret