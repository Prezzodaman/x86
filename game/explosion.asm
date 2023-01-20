; Explosions.
; "so good they need their own file"
	
; doing this instead of having all the graphics under one label, because they're all different sizes.
; i've done this to save as much space as possible in the executable.
; remember: we've only got 64k to work with! luckily all explosion frames combined are under 10k
explosion_1_gfx: incbin "explose_1.gfx"
explosion_2_gfx: incbin "explose_2.gfx"
explosion_3_gfx: incbin "explose_3.gfx"
explosion_4_gfx: incbin "explose_4.gfx"
explosion_5_gfx: incbin "explose_5.gfx"
explosion_6_gfx: incbin "explose_6.gfx"
explosion_7_gfx: incbin "explose_7.gfx"
explosion_8_gfx: incbin "explose_8.gfx"
	
explosion_visible db 0
explosion_x_pos dw 0
explosion_y_pos dw 0
explosion_offset dw 0
explosion_anim_frame db 0 ; return of the classics (and cheetos) (r brand)
explosion_anim_delay db 0

explosion_spawn:
	mov byte [explosion_visible],1
	mov byte [explosion_anim_frame],0
	mov byte [explosion_anim_delay],0
	ret
	
explosion_draw:
	cmp byte [explosion_visible],0 ; explosion visible?
	je .end ; if not, do nothing
	
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	mov byte [bgl_erase],0
	
	mov al,[explosion_anim_frame] ; so we don't constantly refer to explosion_anim_frame directly
	cmp al,0
	je .frame_1
	cmp al,1
	je .frame_2
	cmp al,2
	je .frame_3
	cmp al,3
	je .frame_4
	cmp al,4
	je .frame_5
	cmp al,5
	je .frame_6
	cmp al,6
	je .frame_7
	jmp .frame_8 ; use frame 8 if the value is out of range
.frame_1:
	mov ax,explosion_1_gfx
	mov word [explosion_offset],13
	jmp .frame_skip
.frame_2:
	mov ax,explosion_2_gfx
	mov word [explosion_offset],10
	jmp .frame_skip
.frame_3:
	mov ax,explosion_3_gfx
	mov word [explosion_offset],6
	jmp .frame_skip
.frame_4:
	mov ax,explosion_4_gfx
	mov word [explosion_offset],6
	jmp .frame_skip
.frame_5:
	mov ax,explosion_5_gfx
	mov word [explosion_offset],6
	jmp .frame_skip
.frame_6:
	mov ax,explosion_6_gfx
	mov word [explosion_offset],9
	jmp .frame_skip
.frame_7:
	mov ax,explosion_7_gfx
	mov word [explosion_offset],12
	jmp .frame_skip
.frame_8:
	mov ax,explosion_8_gfx
.frame_skip:
	mov word [bgl_buffer_offset],ax
	
	mov ax,[explosion_x_pos]
	add ax,[explosion_offset]
	mov word [bgl_x_pos],ax
	
	mov ax,[explosion_y_pos]
	add ax,[explosion_offset]
	mov word [bgl_y_pos],ax
	
	call bgl_draw_gfx
	
	inc byte [explosion_anim_delay]
	cmp byte [explosion_anim_delay],2 ; has anim delay reached the maximum value?
	jne .end ; if not, skip
	mov byte [explosion_anim_delay],0 ; otherwise, reset delay and increase frame
	inc byte [explosion_anim_frame]
	cmp byte [explosion_anim_frame],8 ; reached last frame?
	jne .end ; if not, skip
	mov byte [explosion_visible],0 ; otherwise, remove explosion

.end:
	ret