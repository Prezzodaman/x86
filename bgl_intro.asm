
	org 100h
	
	call bgl_init
	mov word [bgl_buffer_offset],bgl_intro_rle
	call bgl_intro
	call bgl_reset
	mov ah,4ch
	int 21h
	
%include "bgl.asm"

bgl_intro_rle: incbin "bgl_intro.rle"