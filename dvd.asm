
	org 100h
	
	mov byte [dvd_moving],1
	call bgl_init
	
main:
	xor al,al
	call bgl_flood_fill_full
	
	xor bx,bx
	mov word [bgl_buffer_offset],dvd_rle
.loop:
	cmp byte [dvd_moving+bx],0
	je .not_moving
	mov ax,[dvd_x_vel+bx]
	add word [dvd_x+bx],ax
	mov ax,[dvd_y_vel+bx]
	add word [dvd_y+bx],ax
	
	cmp word [dvd_x+bx],320-dvd_width
	jl .right_bound_skip
	mov word [dvd_x_vel+bx],0-dvd_speed
	add byte [dvd_tint+bx],20
.right_bound_skip:
	cmp word [dvd_x+bx],0
	jg .left_bound_skip
	mov word [dvd_x_vel+bx],dvd_speed
	add byte [dvd_tint+bx],21
.left_bound_skip:
	cmp word [dvd_y+bx],200-dvd_height
	jl .bottom_bound_skip
	mov word [dvd_y_vel+bx],0-dvd_speed
	add byte [dvd_tint+bx],22
.bottom_bound_skip:
	cmp word [dvd_y+bx],0
	jg .top_bound_skip
	mov word [dvd_y_vel+bx],dvd_speed
	add byte [dvd_tint+bx],23
.top_bound_skip:
	mov ax,[dvd_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[dvd_y+bx]
	mov word [bgl_y_pos],ax
	mov ax,[dvd_tint+bx]
	mov byte [bgl_tint],al
	call bgl_draw_gfx_rle_fast
	jmp .loop_end
.not_moving:
	add byte [dvd_tint+bx],23
.loop_end:
	add bx,2
	cmp bx,dvd_amount*2
	jne .loop
.end:
	push bx
	mov ax,3
	int 33h
	cmp bl,1
	jne .button_skip
	cmp byte [button_state],0
	jne .button_skip
	inc word [dvd_current]
	mov bx,[dvd_current]
	shl bx,1
	mov byte [dvd_moving+bx],1
.button_skip:
	mov byte [button_state],bl
	pop bx
	
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	
	jmp main
	
%include "bgl.asm"

dvd_width equ 92
dvd_height equ 40
dvd_amount equ 60
dvd_speed equ 1

dvd_rle: incbin "dvd.rle"
dvd_x times dvd_amount dw 0
dvd_y times dvd_amount dw 0
dvd_x_vel times dvd_amount dw dvd_speed
dvd_y_vel times dvd_amount dw dvd_speed
dvd_tint times dvd_amount dw 1
dvd_moving times dvd_amount dw 0
dvd_current dw 0

button_state db 0