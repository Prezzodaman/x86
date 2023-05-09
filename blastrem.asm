
%define blaster_mix_rate_22050

%include "blaster.asm"
%include "bgl.asm"

	org 100h
	
	call blaster_init
	call bgl_init
	
	mov al,0
	mov ah,1
	mov bx,1
	mov si,filename
	mov ecx,889412
	call blaster_mix_play_sample
	
hi:
	mov al,0
	call bgl_flood_fill_full
	
	mov cx,3
	mov si,blaster_mix_buffer
.loop:
	movzx dx,[si]
	sub dx,28
	call bgl_get_x_y_offset
	mov byte [fs:di],10
	inc cx
	add si,1
	cmp si,blaster_mix_buffer+blaster_mix_buffer_size
	jb .loop
	
	call blaster_mix_retrace
	call bgl_write_buffer_fast
	jmp hi
	
filename db "getshot22.raw",0