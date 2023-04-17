
	org 100h
	
	call bgl_init
	
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],yems
	mov word [bgl_rotate_angle],0
	mov byte [bgl_scale_centre],1
	mov byte [bgl_background_colour],1
	mov byte [bgl_no_bounds],0
loop:
	mov ah,84h
	mov dx,1
	int 15h
	sub ax,127
	sub bx,127
	sar ax,6
	sar bx,6
	
	add word [bgl_x_pos],ax
	add word [bgl_y_pos],bx
	shl ax,1
	sub word [bgl_rotate_angle],ax
	
	; http://www.fysnet.net/joystick.htm
	
	mov ah,84h
	mov dx,0
	int 15h
	and al,0b00010000
	shr al,4
	not al
	inc al
	not al
	shr al,7
	mov byte [bgl_erase],al
	
	mov al,[bgl_background_colour]
	call bgl_flood_fill_full
	call bgl_draw_gfx_rotate
	call bgl_wait_retrace
	call bgl_write_buffer
	call bgl_escape_exit_fade
	
	cmp byte [faded],0
	jne .end
	call bgl_fade_in
	mov byte [faded],1
.end:
	jmp loop

faded db 0

;	xor di,di
;	xor bx,bx
;hi:
	; xor cx,cx
	; xor dx,dx
; .loop:
	; call bgl_get_buffer_pixel
	; call bgl_get_x_y_offset
	; add al,bl
	; mov byte [fs:di],al
	; inc cx
	; cmp cx,320
	; jl .rep
	; xor cx,cx
	; inc dx
	; cmp dx,200
	; jl .rep
	; jmp .end
; .rep:
	; jmp .loop
; .end:
	; inc bl
	; call bgl_wait_retrace
	; jmp hi
	
yems: incbin "engineer.gfx"
	
%include "bgl.asm"