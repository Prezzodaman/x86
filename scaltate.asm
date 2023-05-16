
	org 100h
	
	call bgl_init
	
main:
	mov al,3
	call bgl_flood_fill_full

	mov word [bgl_buffer_offset],gfx
	sub word [bgl_rotate_angle],4
	mov byte [bgl_no_bounds],1
	
	mov word [bgl_y_pos],(200/2)-(64/2)
	
	mov word [bgl_x_pos],20
	mov byte [bgl_rotate_scale],1
	push word [bgl_rotate_angle]
	mov word [bgl_rotate_angle],0
	mov byte [bgl_scale_centre],1
	sar dword [bgl_scale_x],2
	sar dword [bgl_scale_y],2
	add dword [bgl_scale_x],22
	add dword [bgl_scale_y],22
	call bgl_draw_gfx_scale
	
	pop word [bgl_rotate_angle]
	mov word [bgl_x_pos],(320/2)-(64/2)
	mov byte [bgl_rotate_scale],0
	call bgl_draw_gfx_rotate_fast
	
	mov ax,[index]
	call bgl_get_sine
	call word_to_dword
	sar eax,2
	add eax,84
	mov dword [bgl_scale_x],eax
	mov dword [bgl_scale_y],eax
	add word [index],3
	mov word [bgl_x_pos],320-64-20
	mov byte [bgl_rotate_scale],1
	call bgl_draw_gfx_rotate
	
	call bgl_wait_retrace
	call bgl_write_buffer_fast

	jmp main
	
%include "lib/bgl.asm"
%include "lib/general.asm"

gfx: incbin "prezzo.gfx"
index dw 0
bg: incbin "bgl_intro.rle"