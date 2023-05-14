
%define bgl_no_keys
%define bgl_no_palette
%define bgl_no_joypad
%define bgl_no_scale
%define bgl_no_rotate
%define bgl_no_collision

	org 100h
	
	call bgl_init
a:
	mov al,[colour_offset]
	shr al,1
	xor di,di
	xor cx,cx
.bg_loop:
	push ax
	and al,31
	add al,32
	mov ah,al
	push ax
	shl eax,16
	pop ax
	push di
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	pop di
	pop ax
	inc cx
	add di,4
	cmp cx,320/4
	jne .bg_loop_skip
	add di,320*3
	xor cx,cx
	inc al
.bg_loop_skip:
	cmp di,64000
	jne .bg_loop
	
	inc word [colour_offset]
	
	mov byte [bgl_mask],1
	
	mov word [bgl_buffer_offset],hapi_rle
	mov word [bgl_x_pos],(320/2)-(96/2)
	mov word [bgl_y_pos],(200/2)-(96/2)
	mov byte [bgl_tint],0
	call bgl_draw_gfx_rle_fast
	
	xor bx,bx
.loop:
	mov ax,[engineer_x_index+bx]
	call bgl_get_sine
	sar ax,2
	add ax,(320/2)-16
	mov word [engineer_x+bx],ax
	mov ax,[engineer_y_index+bx]
	call bgl_get_sine
	sar ax,3
	add ax,(200/2)-16
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
colour_offset dw 0