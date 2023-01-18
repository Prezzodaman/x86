bumper_collisions:
	cmp byte [bumper_collision_flag],0 ; 2 cars collided?
	jne .skip ; if so, skip
	
	mov ax,[bumper_pres_x_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_x1],ax
	mov ax,[bumper_pres_y_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_y1],ax
	mov ax,[bumper_other_x_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_x2],ax
	mov ax,[bumper_other_y_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_y2],ax
	mov ax,48
	sub al,[bumper_collision_offset]
	mov word [bgl_collision_w1],ax
	mov word [bgl_collision_w2],ax
	mov ax,32
	sub al,[bumper_collision_offset]
	mov word [bgl_collision_h1],ax
	mov word [bgl_collision_h2],ax
	call bgl_collision_check
	
	cmp byte [bgl_collision_flag],0 ; collision happened?
	je .skip ; if not, skip
	cmp byte [bumper_pres_x_vel],0 ; am i moving?
	je .skip ; if not, skip
	
	; this part is probably going to take all day

	; hit logic:
	; set hit flag to true when hit, but only if my x vel is above 0
	; then, check if hit flag is true, is so, then remove my left and right movement ONLY when x vel is 0

	; bounce logic:
	; other bumper will have an x vel. when hit, the "moving left" flag will be toggled, and while the hit flag is set, and x vel will be decreased.
	; also while hit flag is set, check if x vel is 0, and if not, keep moving as usual.
	; when x vel reaches 0, turn flag off again
	; other bumper will also have a y vel, which will be set depending on whether i'm above or below
	
	mov byte [bumper_collision_flag],1
	not byte [bumper_pres_moving_left] ; negate x movement of just me
	shl word [bumper_pres_x_vel],1 ; increase the x vel for extra bounciness
	
.skip:
	ret
	
bumper_collision_offset db 14
bumper_collision_flag db 0 ; true if two bumpers have collided

%include "bumper_pres.asm"
%include "bumper_other.asm"