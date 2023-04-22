
blaster_buffer_size equ blaster_mix_buffer_size
%include "../blaster.asm"
%include "../bgl.asm"
%include "../random.asm"

	org 100h
	
	call bgl_init
	
game:
	call bugs_init
.loop:
	mov al,0
	call bgl_flood_fill_full
	
	call ship_draw
	call ship_bullet_draw
	call bugs_draw
	
	call ship_handler
	call ship_bullet_handler
	call bugs_handler
	
	call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
%include "ship.asm"
%include "bugs.asm"