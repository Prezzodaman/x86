bumper_collisions:
	push word [bumper_pres_x_pos]
	push word [bumper_pres_y_pos]
	push 48
	push 32
	push word [bumper_other_x_pos]
	push word [bumper_other_y_pos]
	push 48
	push 32
	call bgl_collision_check
	xor ax,ax
	pop ax
	mov byte [collision_flag],al
	ret

%include "bumper_pres.asm"
%include "bumper_other.asm"