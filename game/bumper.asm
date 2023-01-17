bumper_collisions:
	mov ax,[bumper_pres_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[bumper_pres_y_pos]
	mov word [bgl_collision_y1],ax
	mov ax,[bumper_other_x_pos]
	mov word [bgl_collision_x2],ax
	mov ax,[bumper_other_y_pos]
	mov word [bgl_collision_y2],ax
	mov ax,48
	mov word [bgl_collision_w1],ax
	mov word [bgl_collision_w2],ax
	mov ax,32
	mov word [bgl_collision_h1],ax
	mov word [bgl_collision_h2],ax
	call bgl_collision_check
	ret

%include "bumper_pres.asm"
%include "bumper_other.asm"