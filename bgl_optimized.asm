
	org 100h
	
main:
	call bgl_init
	mov al,8
	mov byte [bgl_background_colour],al
	call bgl_flood_fill
	;mov ax,es
	;mov fs,ax ; replace "temp buffer" with normal vga buffer

.loop:
	mov byte [bgl_erase],0
	call gfx_draw
	
	call bgl_write_buffer
	call bgl_wait_retrace
	
	mov byte [bgl_erase],1
	call gfx_draw
	call gfx_move
	jmp .loop
	
	mov ah,4ch
	int 21h
	
gfx_draw:
	mov bx,0

.loop:
	mov ax,gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[x_pos+bx]
	mov word [bgl_x_pos],ax
	mov ax,[y_pos+bx]
	mov word [bgl_y_pos],ax
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	call bgl_draw_gfx
	
	add bx,2
	cmp bx,amount*2
	jne .loop
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
	jl .move_check_end
	mov word [moving_up+bx],1
.move_check_end:
	
	add bx,2
	cmp bx,amount*2
	jne .loop
	ret

gfx: incbin "bloke_small.gfx"
amount equ 40

x_pos:
%assign a 0
%rep amount
dw a*10
%assign a a+1
%endrep

y_pos:
%assign a 0
%rep amount
dw a*10
%assign a a+1
%endrep

moving_left times amount dw 0
moving_up times amount dw 0

%include "bgl.asm"