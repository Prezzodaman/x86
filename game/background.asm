background_scroll:
	mov ax,126
	mov bx,[bumper_pres_x_vel]
	shr bx,1 ; a cheap way of getting "parallax" scrolling
	sub ax,bx
	
	cmp word [background_x],ax
	jle .skip
	mov word [background_x],0
	jmp .skip2
	
.skip:
	cmp word [background_x],0
	jge .skip2
	mov word [background_x],ax

.skip2:
	cmp word [background_arrow_x],8
	jge .arrow_skip
	mov word [background_arrow_x],38
	
.arrow_skip:
	cmp word [background_arrow_x],38
	jle .arrow_skip2
	mov word [background_arrow_x],8
.arrow_skip2:
	ret
	
background_draw:
	mov ax,[background_x]
	sub ax,126 ; so the x is easier to deal with
	mov cx,0
.loop:
	mov byte [bgl_opaque],1
	push cx ;
	and cx,1 ; so the flip (cx) constantly toggles between 0 and 1 on every inc
	mov byte [bgl_flip],cl
	pop cx ;
	mov byte [bgl_erase],0
	
	push ax
	xor ax,ax
	mov al,[background_flash_frame]
	mov bx,1703
	mul bx ; ax*=bx
	mov bx,ax
	mov ax,background_chunk_gfx
	add ax,bx
	mov word [bgl_buffer_offset],ax
	pop ax
	
	mov word [bgl_x_pos],ax
	mov word [bgl_y_pos],14
	call bgl_draw_gfx
	add ax,62
	inc cx
	cmp cx,9 ; how many chunks of background to draw
	jl .loop

.arrows:
	mov ax,[background_arrow_x]
	sub ax,38
	mov cx,0
.arrows_loop:
	mov byte [bgl_opaque],1
	mov byte [bgl_flip],0
	mov byte [bgl_erase],0
	push ax
	mov ax,background_arrow_gfx
	mov word [bgl_buffer_offset],ax
	pop ax
	mov word [bgl_x_pos],ax
	mov word [bgl_y_pos],56
	call bgl_draw_gfx
	add ax,32
	inc cx
	cmp cx,12
	jl .arrows_loop
	
.flash:
	inc byte [background_flash_delay]
	cmp byte [background_flash_delay],6
	jne .flash_skip
	mov byte [background_flash_delay],0
	inc byte [background_flash_frame]
	cmp byte [background_flash_frame],3
	jne .flash_skip
	mov byte [background_flash_frame],0
.flash_skip:
	ret

background_road_gfx: incbin "background_road.gfx"
background_chunk_gfx: ; all 1,703 bytes
	incbin "background_chunk_1.gfx"
	incbin "background_chunk_2.gfx"
	incbin "background_chunk_3.gfx"
background_arrow_gfx: incbin "background_arrow.gfx"
background_draw_x dw 0
background_x dw 0
background_arrow_x dw 38
background_flash_delay db 0
background_flash_frame db 0
road_start_y dw 70