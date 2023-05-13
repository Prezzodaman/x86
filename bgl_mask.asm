
	org 100h
	
	call bgl_init
a:
	mov al,3
	call bgl_flood_fill_full
	
	mov word [bgl_buffer_offset],hapi_rle
	mov word [bgl_x_pos],(320/2)-(96/2)
	mov word [bgl_y_pos],(200/2)-(96/2)
	mov byte [bgl_tint],0
	mov byte [bgl_mask],0
	call bgl_draw_gfx_rle_fast
	
	mov byte [bgl_mask],1
	
	xor bx,bx
.loop:
	mov ax,[engineer_x_index+bx]
	call bgl_get_sine
	sar ax,2
	add ax,320/2
	mov word [engineer_x+bx],ax
	mov ax,[engineer_y_index+bx]
	call bgl_get_sine
	sar ax,3
	add ax,200/2
	mov word [engineer_y+bx],ax
	
	mov word [bgl_buffer_offset],engineer_gfx
	mov ax,[engineer_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[engineer_y+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast
	add bx,2
	cmp bx,6
	jne .loop
	
	mov word [bgl_buffer_offset],prezzo_gfx
	mov ax,[engineer_x+4]
	sub ax,32
	mov word [bgl_x_pos],ax
	mov ax,[engineer_y+2]
	sub ax,32
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast
	
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	
	add word [engineer_x_index],4
	add word [engineer_y_index],3
	add word [engineer_x_index+2],5
	add word [engineer_y_index+2],2
	add word [engineer_x_index+4],3
	add word [engineer_y_index+4],6
	
	jmp a
	
%include "bgl.asm"

engineer_gfx: incbin "engineer.gfx"
engineer_x dw 0,0,0
engineer_y dw 0,0,0
engineer_x_index dw 0,0,0
engineer_y_index dw 0,0,0
hapi_rle: incbin "hapi.rle"
prezzo_gfx: incbin "prezzo.gfx"