
	bits 32
	
segment code

..start:
	mov ax,stack
	mov ss,ax
	mov sp,stack_top

	mov ax,gfx
	mov ds,ax
	
	call bgl_init_seg
	
	mov word [bgl_buffer_offset],bloke_gfx
.loop:
	mov al,1
	call bgl_flood_fill_full
	
	mov ax,[bloke_x]
	mov word [bgl_x_pos],ax
	mov ax,[bloke_y]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast

	call bgl_wait_retrace
	call bgl_write_buffer
	
.left:
	cmp byte [bgl_key_states+4bh],0
	je .right
	dec word [bloke_x]
.right:
	cmp byte [bgl_key_states+4dh],0
	je .up
	inc word [bloke_x]
.up:
	cmp byte [bgl_key_states+48h],0
	je .down
	dec word [bloke_y]
.down:
	cmp byte [bgl_key_states+50h],0
	je .end
	inc word [bloke_y]
.end:
	jmp .loop
	
	mov ah,4ch
	int 21h

segment gfx
%include "bgl.asm"

bloke_x dw 0
bloke_y dw 0
bloke_gfx: incbin "bloke.gfx"

segment stack stack
	resb 256
stack_top:



