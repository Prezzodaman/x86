game:
	call bugs_init
.loop:
	mov al,0
	call bgl_flood_fill_full
	
	call stars_draw
	call ship_draw
	call ship_bullet_draw
	call bugs_draw
	call bugs_bomb_draw
	call hud_draw
	
	call stars_handler
	call ship_handler
	call ship_bullet_handler
	call bugs_handler
	call bugs_bomb_handler
	
	call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
hud_draw:
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],bgl_get_font_offset("1",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("U",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("P",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":",font_gfx)
	call bgl_draw_gfx_fast
	
	mov word [bgl_x_pos],(8*4)+(8*5)
	xor cx,cx ; amount of digits to draw
	mov eax,[player_1_score]
	push eax ;
.loop:
	mov bx,10
	pop eax ;
	xor edx,edx
	div ebx ; dx will contain the remainder...
	push eax ; the value to multiply again
	mov eax,edx
	add eax,15
	mov ebx,(8*8)+2
	mul ebx
	mov ebx,eax
	mov word [bgl_buffer_offset],font_gfx
	add word [bgl_buffer_offset],bx
	call bgl_draw_gfx_fast
	sub word [bgl_x_pos],8
.loop_skip:
	inc cl
	cmp cl,6
	jne .loop
	
	pop eax
	ret

%include "ship.asm"
%include "bugs.asm"

player_1_score dd 0 ; yes, there's support for 2 players!
player_2_score dd 0
player_current db 0 ; 0 if 1, 1 if 2
player_1_shots dw 0
player_2_shots dw 0
player_1_hits dw 0
player_2_hits dw 0