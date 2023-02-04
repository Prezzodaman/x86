background_draw:
	
	mov byte [bgl_opaque],1
	mov ax,[background_x]
	mov word [bgl_x_pos],ax
	mov ax,[background_y]
	mov word [bgl_y_pos],ax
	mov ax,shelf_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	xor ax,ax
	mov al,[bgl_width]
	add word [bgl_x_pos],ax
	call bgl_draw_gfx_rle
	add word [bgl_x_pos],ax
	call bgl_draw_gfx_rle
	add word [bgl_x_pos],ax
	call bgl_draw_gfx_rle
	add word [bgl_x_pos],ax
	call bgl_draw_gfx_rle
	
	ret
	
background_pattern_draw:
	mov dl,12
	mov dh,dl
	mov cx,0
	mov di,0
	mov ax,0
.loop:
	cmp cx,1
	jne .loop_skip
	push di
	mov word [fs:di],dx
	add di,320
	mov word [fs:di],dx
	pop di
.loop_skip:
	push cx
	add cx,ax
	cmp cx,471
	pop cx
	jb .loop_skip2
	mov cx,0
	add ax,1
.loop_skip2:
	inc cx
	add di,8
	cmp di,64000
	jb .loop
	ret

shelf_gfx: incbin "shelf.rle"

background_x dw 0
background_y dw 0