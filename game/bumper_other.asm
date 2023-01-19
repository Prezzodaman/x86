bumper_other_x_pos dw 255-48
bumper_other_y_pos dw 90
bumper_other_x_vel dw 0 ; these will always be positive
bumper_other_y_vel dw 0 ; -'-
bumper_other_speed dw 2
bumper_other_moving_up db 0
bumper_other_facing_left db 0
bumper_other_moving_left db 0
bumper_other_hit_points db 5

bumper_cool_gfx: incbin "bumper_cool.gfx"
bumper_cool_2_gfx: incbin "bumper_cool_2.gfx"
bumper_dog_gfx: incbin "bumper_dog.gfx"
bumper_woah_gfx: incbin "bumper_woah.gfx"
bumper_rye_gfx: incbin "bumper_rye.gfx"

bumper_other_draw:
	mov byte [bgl_opaque],0
	mov al,[bumper_other_facing_left]
	mov byte [bgl_flip],al
	;mov al,[bgl_collision_flag]
	;mov byte [bgl_erase],al
	mov byte [bgl_erase],0
	mov ax,bumper_cool_gfx
	mov word [bgl_buffer_offset],ax
	;mov al,[background_colour]
	;mov byte [bgl_background_colour],al
	mov ax,[bumper_other_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[bumper_other_y_pos]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx
	ret
	
bumper_other_movement:
	mov ax,[bumper_other_y_vel]
	cmp byte [bumper_other_moving_up],0 ; moving up?
	jne .skip ; if not, skip
	add word [bumper_other_y_pos],ax
	jmp .bound_check

.skip:
	sub word [bumper_other_y_pos],ax

.bound_check:
	cmp word [bumper_other_y_pos],200-32 ; reached the bottom of the screen? (-height)
	jl .bound_check_skip ; if not, skip
	not byte [bumper_other_moving_up]
	
.bound_check_skip:
	mov ax,[road_start_y]
	sub ax,16 ; half the height
	cmp word [bumper_other_y_pos],ax ; reached the top?
	jg .bound_check_skip2 ; if not, skip
	not byte [bumper_other_moving_up]

.bound_check_skip2:
	xor ax,ax
	mov ax,[bumper_other_x_vel]
	cmp byte [bumper_other_moving_left],0 ; moving left?
	jne .skip2 ; if not, skip
	add word [bumper_other_x_pos],ax
	jmp .skip3
.skip2:
	sub word [bumper_other_x_pos],ax
.skip3:
	mov ax,[bumper_pres_x_vel] ; move the other bumper along with me
	cmp byte [bumper_pres_moving_left],0 ; am i moving left?
	jne .skip4 ; if not, skip
	sub word [bumper_other_x_pos],ax
	jmp .skip5
.skip4:
	add word [bumper_other_x_pos],ax
.skip5:
	mov ax,[bumper_other_x_pos]
	cmp ax,320
	jl .bound_check_skip3
	mov word [bumper_other_x_pos],-48
	
.bound_check_skip3:
	mov ax,[bumper_other_x_pos]
	cmp ax,-48
	jge .skip_end
	mov word [bumper_other_x_pos],320
	
.skip_end:
	ret