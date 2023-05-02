
	org 100h
	
	call bgl_init
	mov word [bgl_buffer_offset],sunset
	call bgl_draw_full_gfx_pal
	
	call bgl_write_buffer_fast
hi:
	jmp hi
	
sunset: incbin "sunset.pal"
%include "bgl.asm"