game:
	call bugs_init
	
	mov byte [player_1_lives],3
	mov byte [player_2_lives],3
	mov byte [stage],0
	
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
	call game_handler
	
	call blaster_mix_retrace
	;call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
game_handler:
	cmp byte [stage_started],0
	jne .skip
	inc byte [stage_delay]
	cmp byte [stage_delay],150
	jne .skip
	mov byte [stage_delay],0
	mov byte [stage_started],1
	mov byte [bugs_drawn],0
	call bugs_init
.skip:
	cmp byte [bugs_shot],bug_amount ; all bugs shot?
	jne .delay_reset ; if not, end
	inc byte [stage_started_delay] ; all bugs shot, increase this delay
	cmp byte [stage_started_delay],150
	jne .end
	mov byte [stage_started_delay],0
	mov byte [stage_started],0
	mov byte [stage_delay],0
	movzx bx,[player_current]
	inc byte [stage+bx]
	jmp .end
.delay_reset:
	mov byte [stage_started_delay],0
.end:
	ret
	
hud_draw:
	cmp byte [stage_started],0
	jne .stage_end
	mov word [bgl_x_pos],130
	mov word [bgl_y_pos],70
	mov word [bgl_font_string_offset],stage_text
	call bgl_draw_font_string
	add word [bgl_x_pos],8*5
	
	movzx bx,[player_current]
	movzx eax,byte [stage+bx]
	inc eax
	mov cx,1
	cmp byte [stage+bx],10
	ja .stage_above_10
	jmp .stage_skip
.stage_above_10:
	inc cx
.stage_skip:
	call bgl_draw_font_number

.stage_end:
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov ax,bgl_get_font_offset("1",font_gfx)
	cmp byte [player_current],0
	je .player_skip
	mov ax,bgl_get_font_offset("2",font_gfx)
.player_skip:
	mov word [bgl_buffer_offset],ax
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
	
	mov word [bgl_x_pos],8*3
	xor cx,cx ; amount of digits to draw
	cmp byte [player_current],0
	jne .player_2_score
	mov eax,[player_1_score]
	jmp .score
.player_2_score:
	mov eax,[player_2_score]
.score:
	mov cx,6
	call bgl_draw_font_number
	
	mov word [bgl_x_pos],320-16
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],ship_small_rle
	cmp byte [player_current],0
	jne .player_2_lives
	movzx cx,[player_1_lives]
	jmp .player_lives
.player_2_lives:
	movzx cx,[player_2_lives]
.player_lives:
	call bgl_draw_gfx_rle_fast
	sub word [bgl_x_pos],18
	loop .player_lives
.end:
	ret

%include "ship.asm"
%include "bugs.asm"

player_2_mode db 1 ; if 1, players will alternate once the ship is blown up
player_1_score dd 0 ; yes, there's support for 2 players!
player_2_score dd 0
player_current db 0 ; 0 if 1, 1 if 2
player_1_shots dw 0
player_2_shots dw 0
player_1_hits dw 0
player_2_hits dw 0
player_1_lives db 0
player_2_lives db 0
stage db 0,0 ; for each player
stage_delay db 0 ; delay before this stage begins
stage_started db 0
stage_started_delay db 0 ; all bugs shot, this gives a bit of a pause before displaying the next stage
player_2_started db 0

stage_text db "STAGE",0

boom_sfx: incbin "boom.raw"
boom_sfx_length equ $-boom_sfx
lazer_sfx: incbin "lazer.raw" ; xtreme kool letterz
lazer_sfx_length equ $-lazer_sfx
bug_sfx: incbin "bug.raw" ; nicked from space invaders, very naughty ;)
bug_sfx_length equ $-bug_sfx
bester_sfx: incbin "bester_11.raw"
bester_sfx_length equ $-bester_sfx

ship_small_rle: incbin "ship_small.rle"