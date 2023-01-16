bumper_other_x_pos dw 255-48
bumper_other_y_pos dw 10h

bumper_cool_gfx: incbin "bumper_cool.gfx"
bumper_cool_2_gfx: incbin "bumper_cool_2.gfx"
bumper_dog_gfx: incbin "bumper_dog.gfx"
bumper_woah_gfx: incbin "bumper_woah.gfx"
bumper_rye_gfx: incbin "bumper_rye.gfx"

bumper_other_draw:
	push 0 ; flip
	push word [collision_flag] ; erase
	push bumper_cool_gfx ; gfx buffer
	push word [background_colour]
	push word [bumper_other_x_pos]
	push word [bumper_other_y_pos]
	call bgl_draw_gfx
	ret
	
bumper_other_movement:
	add word [bumper_other_x_pos],5
	mov ax,[bumper_other_x_pos]
	cmp ax,320
	jb .skip
	mov word [bumper_other_x_pos],0
.skip:
	ret