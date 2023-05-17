game:
	call bugs_init
	;call boss_init
	call ship_init
	
	mov byte [ship_shot],1
	mov byte [player_lives],4
	mov byte [player_lives+1],4
	mov byte [stage],0
	mov byte [stage+1],0
	mov byte [boss],0
	
	mov dword [player_score],0
	mov dword [player_score+4],0
	mov byte [player_current],0
	mov word [player_shots],0
	mov word [player_shots+2],0
	
	mov byte [stage_started],0
	mov byte [stage_started_delay],0
	mov byte [player_2_started],0
	
	mov byte [game_over],0
	
	call boss_check
	
.loop:
	mov al,0
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	
	call stars_draw
	call bugs_draw
	call boss_draw
	call ship_draw
	call hud_draw
	call game_over_draw
	
	call stars_handler
	call bugs_handler
	call ship_handler
	call game_handler
	call boss_handler
	
	call bgl_escape_exit_fade
	call bgl_joypad_handler
	call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
players_alternate:
	cmp byte [player_lives],0 ; first, check if either player has any lives left
	jne .start
	cmp byte [player_lives+1],0 ; player 1 has no lives, does player 2 have any?
	jne .start ; if so, skip
	jmp title_screen ; neither player has any lives
.start:
	mov word [bug_flying_timer],0
	cmp byte [player_current],0 ; one occasion where a not isn't the best option here!
	je .p2
	cmp byte [player_lives],0 ; player 1 have any lives left?
	je .p2_set ; if not, skip
	mov byte [player_current],0
	jmp .end
.p2_set:
	mov byte [player_current],1
	jmp .end
.p2:
	cmp byte [player_lives+1],0 ; player 2 have any lives left?
	je .p1_set ; if not, skip
	mov byte [player_current],1
	jmp .end
.p1_set:
	mov byte [player_current],0
	jmp .end
.end:
	ret
	
game_over_draw:
	cmp byte [game_over],0
	je .end
	mov byte [bgl_scale_square],0
	mov word [bgl_buffer_offset],game_over_gfx
	mov byte [bgl_scale_centre],1
	mov word [bgl_x_pos],(320/2)-(135/2)
	mov word [bgl_y_pos],(200/2)-(33/2)
	mov ax,[game_over_scale]
	cmp word [game_over_scale],64+game_over_scale_speed
	jle .skip
	sub word [game_over_scale],game_over_scale_speed
	jmp .skip2
.skip:
	call bgl_draw_gfx_fast
	jmp .end
.skip2:
	mov word [bgl_scale_x],ax
	mov word [bgl_scale_y],ax
	call bgl_draw_gfx_scale
.end:
	ret
	
game_handler:
	mov al,[bgl_joypad_states_1]
	cmp byte [player_current],0
	je .joypad_skip
	mov al,[bgl_joypad_states_2]
.joypad_skip:
	mov byte [joypad_states],al
	cmp byte [game_over],0
	jne .game_over
	cmp byte [stage_started],0
	jne .skip
	inc byte [stage_delay]
	cmp byte [stage_delay],150
	jne .skip
	mov byte [stage_delay],0 ; maximum stage delay reached, stage has begun
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount-1 ; more than one bug on screen?
	je .bugs_shot_skip
	cmp byte [boss],0 ; boss level?
	jne .bugs_shot_skip ; don't play bug sound
	mov si,bugs_sfx
	mov cx,bugs_sfx_length
	mov al,3
	mov ah,1
	mov bx,0
	call blaster_mix_play_sample
.bugs_shot_skip:
	mov byte [stage_started],1
	cmp byte [boss],0 ; if it's a boss level, skip bug init
	je .boss_skip
	jmp .skip
.boss_skip:
	movzx bx,[player_current]
	shl bx,1
	cmp byte [player_2_mode],0
	je .skip
	cmp byte [bugs_shot+bx],0
	jne .skip
	call bugs_init
.skip:
	movzx bx,[player_current]
	shl bx,2 ; dword
	mov eax,[player_score+bx]
	cmp dword [high_score],eax ; player's score greater than the high score?
	jg .high_score_skip ; if not, skip
	mov dword [high_score],eax
.high_score_skip:
	movzx bx,[player_current]
	shl bx,1 ; word to ya mutha
	cmp byte [bugs_shot+bx],bug_amount ; all bugs shot?
	jne .delay_reset ; if not, skip the stage resetting routine
	cmp byte [ship_exploding],0 ; ship exploding?
	jne .delay_reset ; if so, wait until it's not exploding before increasing delay
	mov al,3
	call blaster_mix_stop_sample
	inc byte [stage_started_delay] ; all bugs shot, increase this delay
	cmp byte [stage_started_delay],150
	jne .end
	mov byte [stage_started_delay],0
	mov byte [stage_started],0
	mov byte [stage_delay],0
	call bugs_init
	mov byte [bugs_shot+bx],0
	movzx bx,[player_current]
	inc byte [stage+bx]
	call boss_check
	jmp .end
.delay_reset:
	mov byte [stage_started_delay],0
	jmp .end
.game_over:
	inc word [game_over_delay]
	cmp word [game_over_delay],340
	jne .end
	cmp byte [player_2_mode],0 ; 2 player mode?
	je title_screen ; if not, go back to title screen
	mov byte [game_over],0
	mov byte [stage_started],0
	mov byte [stage_started_delay],0
	call ship_init
	call players_alternate
	call bugs_init_check
	call boss_check
	cmp byte [boss],0
	je .end
	mov byte [boss_active],0
	jmp .end
.end:
	ret
	
hud_draw:
	cmp byte [stage_started],0
	jne .stage_end
	cmp byte [game_over],0
	jne .stage_end
	mov word [bgl_x_pos],130
	mov word [bgl_y_pos],70
	mov word [bgl_font_string_offset],stage_text
	call bgl_draw_font_string
	add word [bgl_x_pos],8*6
	
	movzx bx,[player_current]
	movzx eax,byte [stage+bx]
	inc eax
	mov cx,1
	cmp byte [stage+bx],10
	jae .stage_above_10
	jmp .stage_skip
.stage_above_10:
	inc cx
.stage_skip:
	call bgl_draw_font_number

	cmp byte [boss],0
	je .stage_end
	mov word [bgl_x_pos],144
	mov word [bgl_y_pos],80
	mov word [bgl_font_string_offset],boss_text
	call bgl_draw_font_string

.stage_end:	
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov ax,bgl_get_font_offset("1",font_gfx)-font_reduction
	cmp byte [player_current],0
	je .player_skip
	mov ax,bgl_get_font_offset("2",font_gfx)-font_reduction
.player_skip:
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("U",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("P",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	
	mov word [bgl_x_pos],8*4
	xor cx,cx ; amount of digits to draw
	movzx bx,[player_current]
	shl bx,2 ; dword length
	mov eax,[player_score+bx]
.score:
	mov cx,6
	call bgl_draw_font_number
	
	mov word [bgl_x_pos],130
	mov word [bgl_buffer_offset],bgl_get_font_offset("H",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("I",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":",font_gfx)-font_reduction
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov eax,[high_score]
	call bgl_draw_font_number
	
	; lives
	
	cmp byte [game_over],0
	jne .end
	mov word [bgl_x_pos],320-16
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],ship_small_rle
	movzx bx,[player_current]
	movzx cx,[player_lives+bx]
	cmp cx,0 ; no lives?
	je .end ; draw no ships
.player_lives:
	call bgl_draw_gfx_rle_fast
	sub word [bgl_x_pos],18
	loop .player_lives
	jmp .end
.end:
	ret

%include "ship.asm"
%include "bugs.asm"
%include "boss.asm"

player_2_mode db 0 ; if 1, players will alternate once the ship is blown up
player_score dd 0,0 ; yes, there's support for 2 players!
high_score dd 0 ; for both players, just like the original ;)
player_current db 0 ; 0 if 1, 1 if 2
player_shots dw 0,0
player_lives db 0,0
stage db 0,0 ; for each player
stage_delay db 0 ; delay before this stage begins
stage_started db 0
stage_started_delay db 0 ; all bugs shot, this gives a bit of a pause before displaying the next stage
player_2_started db 0
game_over db 0
game_over_delay dw 0 ; a pause before restarting the stage
game_over_scale dw game_over_scale_initial
game_over_scale_initial equ 600
game_over_scale_speed equ 8
boss db 0
joypad_states db 0 ; for the current player - this makes life easier ;)

stage_text db "STAGE",0
boss_text db "BOSS",0

boom_sfx: incbin "boom.raw"
boom_sfx_length equ $-boom_sfx
lazer_sfx: incbin "shoot_noise.raw" ; xtreme kool letterz
lazer_sfx_length equ $-lazer_sfx
bug_sfx: incbin "bug.raw" ; nicked from space invaders, very naughty ;)
bug_sfx_length equ $-bug_sfx
explosion_sfx_name db "explode.raw",0
explosion_sfx_length equ 34622
bugs_sfx: incbin "bugs.raw"
bugs_sfx_length equ $-bugs_sfx
flying_sfx_name db "flying.raw",0
flying_sfx_length equ 67284

ship_small_rle: incbin "ship_small.rle"
game_over_gfx: incbin "game_over.gfx"