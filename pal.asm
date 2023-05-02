
	org 100h
	
	call bgl_init
	mov word [bgl_buffer_offset],pic
	call bgl_draw_full_gfx_pal
	
	call bgl_write_buffer_fast
hi:
	jmp hi
	
pic: incbin "sauce.pal"
%include "bgl.asm"