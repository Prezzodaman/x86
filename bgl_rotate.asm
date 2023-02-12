
	org 100h
	
	call bgl_init
	call bgl_restore_orig_key_handler
	
	mov word [bgl_buffer_offset],gfx
	mov word [bgl_rotate_angle],0
yes:
	mov al,3
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	
	call bgl_draw_gfx_rotate
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	
	;mov ax,3
	;int 33h
	;mov word [bgl_rotate_angle],cx
	add word [bgl_rotate_angle],4

	jmp yes
	
gfx: incbin "hapi.gfx"
%include "bgl.asm"