title_screen:
	mov word [logo_x],(320/2)-(172/2)
	mov word [logo_y],200

.loop:
	mov al,0
	call bgl_flood_fill_full
	
	call stars_draw
	
	mov word [bgl_buffer_offset],logo_rle
	mov ax,[logo_x]
	mov word [bgl_x_pos],ax
	mov ax,[logo_y]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	
	cmp word [logo_y],20
	je .logo_drawn
	dec word [logo_y]
	jmp .end
.logo_drawn:
	mov word [bgl_x_pos],(8*4)-4
	mov word [bgl_y_pos],200-(8*4)
	mov word [bgl_font_string_offset],title_string_1a
	call bgl_draw_font_string
	mov word [bgl_font_string_offset],title_string_1b
	add word [bgl_y_pos],8
	mov word [bgl_x_pos],(8*9)
	call bgl_draw_font_string
	
	mov word [bgl_x_pos],8*17
	mov word [bgl_y_pos],8*15
	mov word [bgl_font_string_offset],title_string_2a
	call bgl_draw_font_string
	mov word [bgl_font_string_offset],title_string_2b
	add word [bgl_y_pos],12
	call bgl_draw_font_string
	
	mov word [bgl_x_pos],8*14
	mov word [bgl_y_pos],8*15
	movzx ax,[player_2_mode]
	xor dx,dx
	mov bx,12
	mul bx
	add word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],arrow_gfx
	call bgl_draw_gfx_fast
	
.up:
	test byte [bgl_joypad_states_1],00000001b
	jz .down
	mov byte [player_2_mode],0
	jmp .end
.down:
	test byte [bgl_joypad_states_1],00000010b
	jz .start
	mov byte [player_2_mode],1
	jmp .end
.start:
	mov al,[bgl_joypad_states_1]
	and al,00110000b
	cmp al,0
	je .end
	jmp game
.end:
	call stars_handler
	
	call bgl_joypad_handler
	;call blaster_mix_retrace
	call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
logo_rle: incbin "logo.rle"
logo_x dw 0
logo_y dw 0

arrow_gfx: incbin "arrow.gfx"

title_string_1a db "PROGRAMMING AND ARTWORK BY PREZZO",0
title_string_1b db "ORIGINAL GAME BY NAMCO",0
title_string_2a db "1 PLAYER",0
title_string_2b db "2 PLAYERS",0