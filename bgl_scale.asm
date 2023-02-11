
	org 100h
	
	call bgl_init
	mov dword [bgl_scale],-30
	;mov byte [bgl_erase],1
yes:
	mov al,3
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	
	mov word [bgl_buffer_offset],gfx
	call bgl_draw_gfx_scale
	call bgl_write_buffer
	call bgl_wait_retrace

	cmp byte [inning],0
	je .in
	dec dword [bgl_scale]
	jmp .skip
.in:
	inc dword [bgl_scale]
.skip:
	inc byte [inning_delay]
	cmp byte [inning_delay],40
	jb .end
	not byte [inning]
	mov byte [inning_delay],0
.end:
	jmp yes
	
gfx: incbin "birz.gfx"
%include "bgl.asm"

inning db 0
inning_delay db 0