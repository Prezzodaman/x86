
	org 100h

	call bgl_init
	mov word [bgl_buffer_offset],gfx
	
	mov al,1
	mov byte [bgl_background_colour],al
	call bgl_flood_fill
	
loop:
	mov word [bgl_buffer_offset],bg
	call bgl_draw_full_gfx_rle

	mov word [bgl_buffer_offset],gfx
	mov ax,[x]
	mov word [bgl_x_pos],ax
	mov ax,[y]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	
	call bgl_wait_retrace
	call bgl_write_buffer
	
.up: ; all worked first try ;)
	cmp byte [up],0
	je .down
	dec word [y]
	cmp word [y],0
	ja .left
	mov byte [up],0
	jmp .left
.down:
	inc word [y]
	cmp word [y],200-96
	jb .left
	mov byte [up],1
.left:
	cmp byte [left],0
	je .right
	dec word [x]
	cmp word [x],0
	ja .end
	mov byte [left],0
	jmp .end
.right:
	inc word [x]
	cmp word [x],320-96
	jb .end
	mov byte [left],1
.end:
	mov al,[left]
	mov byte [bgl_flip],al
	jmp loop

%include "bgl.asm"

; the advantages of bgl's dodgy proprietary rle:
; original png is 1.38k
; raw gfx file is 9k (ouch)
; rle gfx file is 1.62k! not bad

gfx: incbin "hapi.rle"
bg: incbin "bgl_full.rle"
x dw (320/2)-(96/2)
y dw (200/2)-(96/2)
up db 0
left db 0