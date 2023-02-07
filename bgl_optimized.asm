
	org 100h
	
main:
	call bgl_replace_key_handler
	call bgl_init
	
	mov ax,2
	int 33h
	
	
	;mov ax,es
	;mov fs,ax ; replace "temp buffer" with normal vga buffer

.loop:
	mov di,0
	mov cx,64000/2
	mov al,8
	call bgl_flood_fill
	
	call get_mouse_position
	mov byte [bgl_erase],0
	call gfx_draw
	
	call bgl_write_buffer
	call bgl_wait_retrace
	
	call gfx_move
	
	call bgl_escape_exit
	jmp .loop
	
	mov ah,4ch
	int 21h
	
gfx_draw:
	mov bx,0

.loop:
	mov ax,[x_pos+bx]
	mov word [bgl_collision_x1],ax
	mov ax,[y_pos+bx]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],12
	mov word [bgl_collision_h1],12
	
	mov ax,[mouse_x_pos]
	mov word [bgl_collision_x2],ax
	mov ax,[mouse_y_pos]
	mov word [bgl_collision_y2],ax
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],0
	jne .skip
	
	mov ax,gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[x_pos+bx]
	mov word [bgl_x_pos],ax
	mov ax,[y_pos+bx]
	mov word [bgl_y_pos],ax
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	call bgl_draw_gfx_fast
	
.skip:
	add bx,2
	cmp bx,amount*2
	jne .loop
	
	mov ax,[mouse_x_pos]
	sub ax,6
	mov word [bgl_x_pos],ax
	mov ax,[mouse_y_pos]
	sub ax,6
	mov word [bgl_y_pos],ax
	mov byte [bgl_opaque],0
	call bgl_draw_gfx_fast
	
	ret
	
gfx_move:
	mov bx,0
	
.loop:
	cmp word [moving_left+bx],0
	je .move_right
	dec word [x_pos+bx]
	jmp .move_up
.move_right:
	inc word [x_pos+bx]
.move_up:
	cmp word [moving_up+bx],0
	je .move_down
	dec word [y_pos+bx]
	jmp .move_check_right
.move_down:
	inc word [y_pos+bx]
	
.move_check_right:
	cmp word [x_pos+bx],320-12
	jl .move_check_left
	mov word [moving_left+bx],1
.move_check_left:
	cmp word [x_pos+bx],0
	jg .move_check_top
	mov word [moving_left+bx],0
.move_check_top:
	cmp word [y_pos+bx],0
	jg .move_check_bottom
	mov word [moving_up+bx],0
.move_check_bottom:
	cmp word [y_pos+bx],200-12
	jl .end
	mov word [moving_up+bx],1
.end:
	
	add bx,2
	cmp bx,amount*2
	jne .loop
	
	ret

get_mouse_position:
	push cx
	push dx
	
	mov ax,3 ; get mouse position (cx=x,dx=y)
	int 33h
	shr cx,1
	mov word [mouse_x_pos],cx
	mov word [mouse_y_pos],dx
	
	pop dx
	pop cx
	ret

gfx: incbin "bloke_small.gfx"
amount equ 30

x_pos:
%assign a 0
%rep amount
dw (a*10)
%assign a a+1
%endrep

y_pos:
%assign a 0
%rep amount
dw (a*10)
%assign a a+1
%endrep

moving_left times amount dw 0
moving_up times amount dw 0

mouse_x_pos dw 0
mouse_y_pos dw 0

%include "bgl.asm"