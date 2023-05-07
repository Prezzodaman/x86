ship_init: ; yeh, thasswodidiz init m8 yeeeeeeah
	mov byte [ship_exploding],0
	mov byte [ship_explosion_finished],0
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_explosion_anim_state],0
	mov word [ship_x],ship_x_initial
	mov word [ship_y],200-ship_height-10
	ret

ship_explode:
	mov al,3
	call blaster_mix_stop_sample
	mov byte [ship_exploding],1
	mov byte [ship_explosion_anim_delay],0
	mov byte [ship_explosion_anim_state],0
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_explosion_finished],0
	mov byte [bug_bomb_active+bx],0
	push bx
	xor bx,bx
	mov al,3
	mov ah,0
	mov si,boom_sfx
	mov cx,boom_sfx_length
	call blaster_mix_play_sample
	pop bx
	ret

ship_bullet_draw:
	xor bx,bx
	mov word [bgl_buffer_offset],ship_bullet_gfx
.loop:
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	je .end ; if not, do nothing
	mov ax,[ship_bullet_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[ship_bullet_y+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx
.end:
	add bx,2
	cmp bx,ship_bullet_amount*2 ; reached last bullet?
	jne .loop ; if not, draw next bullet
	ret
	
ship_bullet_handler:
	xor bx,bx
.loop:
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	je .end ; if not, do nothing
	cmp word [ship_bullet_y+bx],-16 ; bullet reached top of screen?
	jg .top_skip ; if not, continue as normal
	mov byte [ship_bullet_moving+bx],0 ; reset bullet
	jmp .end
.top_skip:
	mov ax,ship_bullet_speed ; move bullet up
	sub word [ship_bullet_y+bx],ax
	
	mov ax,[ship_bullet_x+bx]
	mov word [bgl_collision_x1],ax
	mov ax,[ship_bullet_y+bx]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],2
	mov word [bgl_collision_h1],6
	
	cmp byte [boss],0 ; boss level?
	je .boss_skip ; if not, skip to the main bug check
	
	mov ax,[boss_x]
	add ax,[boss_x_offset]
	sar ax,boss_precision
	add ax,boss_base_x
	mov word [bgl_collision_x2],ax
	mov ax,[boss_y]
	add ax,[boss_y_offset]
	sar ax,boss_precision
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],boss_base_width
	mov word [bgl_collision_h2],boss_height
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .boss_skip
	cmp byte [boss_state],2
	je .boss_skip
	push bx
	xor bx,bx
	mov al,1
	mov ah,0
	mov si,bug_sfx
	mov cx,bug_sfx_length
	call blaster_mix_play_sample
	pop bx
	mov byte [ship_bullet_moving+bx],0
	mov byte [boss_flash],1
	dec byte [boss_health]
	cmp byte [boss_health],0
	jne .boss_skip
	call boss_explosion_init
	mov byte [boss_state],2
	mov word [boss_y_vel],-40
	push ax
	push bx
	push cx
	mov bx,1
	mov al,3
	mov ah,0
	mov si,explosion_sfx_name
	mov cx,explosion_sfx_length
	call blaster_mix_play_sample
	mov byte [boss_music_playing],0
	mov byte [bug_shot],1
	mov byte [bug_shot+2],1
	movzx bx,[player_current]
	shl bx,2
	add dword [player_score+bx],1000
	pop cx
	pop bx
	pop ax
	
.boss_skip:
	; collision checks for all bugs!
	mov word [bgl_collision_w2],bug_width ; same for all bugs
	mov word [bgl_collision_h2],bug_height
	mov cx,bx ; cx unused for now, so we're using it as temporary storage for the bullet index
	xor bx,bx ; we're now counting bugs...
.bug_loop:
	cmp byte [bugs_drawn],bug_amount ; make sure all bugs are drawn before checking...
	jne .end ; if not, skip
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_active+bx],0
	pop bx
	je .bug_loop_skip
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_shot+bx],0
	pop bx
	jne .bug_loop_skip
	cmp byte [boss],0
	jne .bug_loop_check_skip
	cmp byte [bugs_drawn],bug_amount
	jne .bug_loop_skip
.bug_loop_check_skip:
	movsx ax,[bug_x_offset+bx]
	add ax,[bug_x+bx]
	sar ax,bug_precision
	mov word [bgl_collision_x2],ax
	mov ax,[bug_y+bx]
	sar ax,bug_precision
	mov word [bgl_collision_y2],ax
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .bug_loop_skip ; no collision
	push bx
	movzx bx,[player_current]
	cmp byte [stage+bx],8 ; above or equal to level 8?
	pop bx
	jae .bug_loop_one_hit_skip ; if so, bug type 0 requires multiple hits
	cmp byte [bug_type+bx],0 ; otherwise, make sure bug type isn't 0 before doing the multiple hit check
	je .bug_loop_hit_skip ; one hit
.bug_loop_one_hit_skip:
	push bx
	movzx bx,[player_current]
	mov al,[stage+bx]
	shr al,2
	add al,2 ; maximum bug hits (for types above 0), increases as the level... increases
	pop bx
	push bx
	call bugs_player_loop_offset
	inc byte [bug_hits+bx]
	mov al,2
	cmp byte [bug_hits+bx],al ; maximum hits?
	pop bx
	jne .bug_loop_bullet_reset
	call bugs_add_score
.bug_loop_hit_skip:
	call bugs_add_score
	push bx
	call bugs_player_loop_offset
	mov byte [bug_shot+bx],1
	mov byte [bug_explose_frame+bx],0
	movzx bx,[player_current]
	inc byte [bugs_shot+bx]
	pop bx
	push cx
	push bx
	xor bx,bx
	mov al,1
	mov ah,0
	mov si,bug_sfx
	mov cx,bug_sfx_length
	call blaster_mix_play_sample
	pop bx
	cmp byte [bug_flying+bx],0
	je .bug_loop_hit_skip_end
	mov al,2
	call blaster_mix_stop_sample
.bug_loop_hit_skip_end:
	pop cx
.bug_loop_bullet_reset:
	push bx
	mov bx,cx
	mov byte [ship_bullet_moving+bx],0
	pop bx
.bug_loop_skip:
	add bx,2
	cmp bx,bug_amount*2
	jne .bug_loop
.bug_loop_end:
	mov bx,cx
.end:
	add bx,2
	cmp bx,ship_bullet_amount*2 ; reached last bullet?
	jne .loop ; if not, handle next bullet
	ret
	
ship_handler:
	cmp byte [ship_exploding],0
	jne .exploding
.left:
	test byte [joypad_states],00000100b ; left pressed?
	jz .right ; if not, check for right key
	sub word [ship_x],ship_speed
	cmp word [ship_x],0 ; reached left bounds
	jg .right ; if not, skip
	mov word [ship_x],0 ; clip to left bounds
.right:
	test byte [joypad_states],00001000b ; right pressed?
	jz .shoot ; if not, skip
	add word [ship_x],ship_speed
	cmp word [ship_x],320-ship_width ; reached right bounds?
	jl .shoot ; if not, skip
	mov word [ship_x],320-ship_width ; clip to right bounds
.shoot:
	mov al,[joypad_states]
	and al,00110000b
	cmp al,0 ; button 1 or 2 pressed?
	je .shoot_shot ; if not, reset ship shot flag
	cmp byte [ship_shot],0 ; has the ship shot a bullet?
	jne .end ; if so, skip
	inc byte [ship_bullet_current]
	cmp byte [ship_bullet_current],ship_bullet_amount ; not shot yet, check that current bullet is in range
	jb .shoot_skip ; if it's in range, continue as normal
	mov byte [ship_bullet_current],0 ; reset current bullet
.shoot_skip:
	movzx bx,[ship_bullet_current]
	shl bx,1
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	jne .end ; if so, skip
	mov byte [ship_bullet_moving+bx],1 ; bullet isn't moving... make it
	mov byte [ship_shot],1
	mov ax,[ship_x]
	add ax,(ship_width/2)-1
	mov word [ship_bullet_x+bx],ax
	mov ax,[ship_y]
	mov word [ship_bullet_y+bx],ax
	call ship_add_shot
	push bx
	xor bx,bx
	mov al,0
	mov ah,0
	mov si,lazer_sfx
	mov cx,lazer_sfx_length
	call blaster_mix_play_sample
	pop bx
	jmp .end
.shoot_shot: ; best l'bale name
	mov byte [ship_shot],0
	jmp .end
.exploding:
	cmp byte [game_over],0 ; if the game is over, explosion will never finish
	jne .end
	inc byte [ship_explosion_finished_delay]
	cmp byte [ship_explosion_finished_delay],150
	jne .end
	
	xor bx,bx
	; make sure no bug is flying
.bug_loop:
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_active+bx],0
	pop bx
	je .bug_loop_skip
	cmp byte [bug_flying+bx],0 ; skip all the checks if a bug is flying
	jne .end
	; bug isn't flying!
.bug_loop_skip:
	add bx,2
	cmp bx,bug_amount*2
	jne .bug_loop
	
	movzx bx,[player_current]
	cmp byte [player_lives+bx],1 ; current player have any lives left?
	je .lives_skip2 ; if not, game over
	dec byte [player_lives+bx] ; if so, decrease lives
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_exploding],0
	mov byte [ship_explosion_anim_delay],0
	mov byte [ship_explosion_anim_state],0
	jmp .lives_skip
.lives_skip2:
	cmp byte [game_over],0
	jne .end
	mov byte [player_lives+bx],0
	mov byte [game_over],1 ; game is over!
	mov word [game_over_delay],0
	mov word [game_over_scale],game_over_scale_initial
	jmp .end
.lives_skip:
	mov byte [bugs_shot_lives+bx],0
	
	cmp byte [player_2_mode],0 ; 2 player mode?
	je .lives_flying_delay ; if so, skip all the alternating code
	call players_alternate
	mov byte [stage_started],0 ; restart stage
	mov byte [stage_delay],0
	mov byte [stage_started_delay],0
	
	mov byte [player_2_started],1
.lives_flying_delay:
	call ship_init
	mov byte [bug_bomb_delay],0
	mov word [bug_flying_delay],0
	cmp byte [boss],0
	je .lives_boss_skip
	call boss_init
	jmp .end
.lives_boss_skip:
	mov si,bugs_sfx
	mov cx,bugs_sfx_length
	mov al,3
	mov ah,1
	mov bx,0
	call blaster_mix_play_sample
.end:
	call ship_bullet_handler
	ret
	
ship_add_shot:
	push bx
	movzx bx,[player_current]
	shl bx,1
	inc byte [player_shots+bx]
	pop bx
	ret
	
ship_draw:
	mov ax,[ship_x]
	mov word [bgl_x_pos],ax
	mov ax,[ship_y]
	mov word [bgl_y_pos],ax
	
	cmp byte [ship_explosion_anim_state],ship_explosion_anim_frames
	je .explosion_end
	cmp byte [ship_exploding],0
	jne .explosion
	mov word [bgl_buffer_offset],ship_rle
	call bgl_draw_gfx_rle
	jmp .end
.explosion:
	cmp byte [ship_explosion_anim_state],1
	je .explosion_frame_2
	cmp byte [ship_explosion_anim_state],2
	je .explosion_frame_3
	cmp byte [ship_explosion_anim_state],3
	je .explosion_frame_4
	cmp byte [ship_explosion_anim_state],4
	je .explosion_frame_3
	cmp byte [ship_explosion_anim_state],5
	je .explosion_frame_4
	cmp byte [ship_explosion_anim_state],6
	je .explosion_frame_3
	cmp byte [ship_explosion_anim_state],7
	je .explosion_frame_2
	mov word [bgl_buffer_offset],ship_explosion_3_rle
	mov word [ship_explosion_offset],3
	jmp .explosion_skip
.explosion_frame_2: ; yes, they're out of order, no, i don't know why :P
	mov word [bgl_buffer_offset],ship_explosion_2_rle
	mov word [ship_explosion_offset],-3
	jmp .explosion_skip
.explosion_frame_3:
	mov word [bgl_buffer_offset],ship_explosion_1_rle
	mov word [ship_explosion_offset],-8
	jmp .explosion_skip
.explosion_frame_4:
	mov word [bgl_buffer_offset],ship_explosion_4_rle
	mov word [ship_explosion_offset],-13
.explosion_skip:
	mov ax,[ship_explosion_offset]
	add word [bgl_x_pos],ax
	add word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	
	inc byte [ship_explosion_anim_delay]
	cmp byte [ship_explosion_anim_delay],4 ; speed
	jne .end
	mov byte [ship_explosion_anim_delay],0
	cmp byte [ship_explosion_anim_state],ship_explosion_anim_frames
	je .end
	inc byte [ship_explosion_anim_state]
	jmp .end
.explosion_end:
	cmp byte [ship_explosion_finished],0
	jne .end
	cmp byte [game_over],0
	jne .end
	mov byte [ship_explosion_finished],1
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_explosion_anim_state],0
.end:
	call ship_bullet_draw
	ret

ship_rle: incbin "ship.rle"
ship_width equ 30
ship_height equ 29
ship_speed equ 3
ship_x_initial equ (320/2)-(ship_width/2)

ship_x dw ship_x_initial
ship_y dw 200-ship_height
ship_shot db 0
ship_exploding db 0
ship_explosion_anim_delay db 0 ; the classics returning once again...
ship_explosion_anim_state db 0
ship_explosion_offset dw 0
ship_explosion_finished db 0
ship_explosion_finished_delay db 0

ship_explosion_anim_frames equ 9

ship_bullet_gfx: incbin "ship_bullet.gfx"
ship_bullet_amount equ 6 ; how many on-screen at a given time
ship_bullet_speed equ 5

ship_bullet_x times ship_bullet_amount dw 0
ship_bullet_y times ship_bullet_amount dw 0
ship_bullet_moving times ship_bullet_amount dw 0
ship_bullet_current db 0

ship_explosion_1_rle: incbin "../cimit/explosion_1.rle"
ship_explosion_2_rle: incbin "../cimit/explosion_2.rle"
ship_explosion_3_rle: incbin "../cimit/explosion_3.rle"
ship_explosion_4_rle: incbin "../cimit/explosion_4.rle"