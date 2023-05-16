
	org 100h
	
	call bgl_init

main:
	call randomize
	mov ax,254
	call random_range
	inc al
	mov byte [bgl_width],al
	mov ax,254
	call random_range
	inc al
	mov byte [bgl_height],al
	
	mov ax,320
	movzx bx,[bgl_width]
	sub ax,bx
	call random_range
	mov word [bgl_x_pos],ax
	mov ax,200
	movzx bx,[bgl_height]
	sub ax,bx
	call random_range
	mov word [bgl_y_pos],ax
	
	mov ax,15
	call random_range
	call bgl_draw_box_fast
	
	call bgl_write_buffer_fast
	
	jmp main
	
%include "lib/bgl.asm"
%include "lib/random.asm"