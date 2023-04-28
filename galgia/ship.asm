ship_explode:
	mov byte [ship_exploding],1
	mov byte [ship_explosion_anim_delay],0
	mov byte [ship_explosion_anim_state],0
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_explosion_finished],0
	mov byte [bug_bomb_active+bx],0
	mov al,0
	mov ah,0
	mov si,boom_sfx
	mov cx,boom_sfx_length
	call blaster_mix_play_sample
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
	
	; collision checks for all bugs!
	mov ax,[ship_bullet_x+bx]
	mov word [bgl_collision_x1],ax
	mov ax,[ship_bullet_y+bx]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],2
	mov word [bgl_collision_h1],6
	mov word [bgl_collision_w2],bug_width ; same for all bugs
	mov word [bgl_collision_h2],bug_height
	mov cx,bx ; cx unused for now, so we're using it as temporary storage for the bullet index
	xor bx,bx ; we're now counting bugs...
.bug_loop:
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
	cmp byte [bugs_drawn],bug_amount
	jne .bug_loop_skip
	mov ax,[bug_x+bx]
	sar ax,bug_precision
	mov word [bgl_collision_x2],ax
	mov ax,[bug_y+bx]
	sar ax,bug_precision
	mov word [bgl_collision_y2],ax
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .bug_loop_skip ; no collision
	cmp byte [bug_type+bx],0 ; check if this bug type requires multiple hits
	je .bug_loop_hit_skip ; one hit
	push bx
	call bugs_player_loop_offset
	inc byte [bug_hits+bx]
	cmp byte [bug_hits+bx],2 ; maximum hits?
	pop bx
	jne .bug_loop_bullet_reset
	call bugs_add_score
.bug_loop_hit_skip:
	call bugs_add_score
	push bx
	call bugs_player_loop_offset
	mov byte [bug_shot+bx],1
	mov byte [bug_explose_frame+bx],0
	pop bx
	inc byte [bugs_shot]
	push cx
	mov al,1
	mov ah,0
	mov si,bug_sfx
	mov cx,bug_sfx_length
	call blaster_mix_play_sample
	pop cx
.bug_loop_bullet_reset:
	push bx
	mov bx,cx
	;mov byte [ship_bullet_moving+bx],0
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
	cmp byte [bgl_key_states+4bh],0 ; left key pressed?
	je .right ; if not, check for right key
	sub word [ship_x],ship_speed
	cmp word [ship_x],0 ; reached left bounds
	jg .right ; if not, skip
	mov word [ship_x],0 ; clip to left bounds
.right:
	cmp byte [bgl_key_states+4dh],0 ; right key pressed?
	je .shoot ; if not, skip
	add word [ship_x],ship_speed
	cmp word [ship_x],320-ship_width ; reached right bounds?
	jl .shoot ; if not, skip
	mov word [ship_x],320-ship_width ; clip to right bounds
.shoot:
	cmp byte [bgl_key_states+39h],0 ; space pressed?
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
	mov al,0
	mov ah,0
	mov si,lazer_sfx
	mov cx,lazer_sfx_length
	call blaster_mix_play_sample
	jmp .end
.shoot_shot: ; best l'bale name
	mov byte [ship_shot],0
	jmp .end
.exploding:
	inc byte [ship_explosion_finished_delay]
	cmp byte [ship_explosion_finished_delay],100
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
	
	mov byte [ship_explosion_finished_delay],0
	mov byte [ship_exploding],0
	mov byte [ship_explosion_anim_delay],0
	mov byte [ship_explosion_anim_state],0
	
	cmp byte [player_current],0
	jne .explode_p2
	dec byte [player_1_lives]
	mov byte [bugs_shot_lives],0
	jmp .alternate
.explode_p2:
	dec byte [player_2_lives]
	mov byte [bugs_shot_lives+1],0
.alternate: ; as in alter-8
	cmp byte [player_2_mode],0 ; 2 player mode?
	je .end ; if so, skip all the alternating code
	cmp byte [player_current],0 ; can't use not, because other parts of the code rely on this being 0 or 1, making life easier
	je .alternate_p2
	mov byte [player_current],0
	jmp .alternate_end
.alternate_p2:
	mov byte [player_current],1
	cmp byte [stage+1],0 ; player 2 on first stage after alternating?
	jne .alternate_end ; if not, skip
	cmp byte [player_2_started],0 ; game started for player 2?
	jne .alternate_end ; if so, skip
	mov byte [stage_started],0 ; restart stage
	mov byte [stage_delay],0
	mov byte [stage_started_delay],0
.alternate_end:
	mov byte [ship_explosion_finished],0
	mov byte [player_2_started],1
	mov word [ship_x],ship_x_initial
	mov byte [bug_flying_delay],0
.end:
	ret
	
ship_add_shot:
	cmp byte [player_current],0
	jne .p2
	inc word [player_1_shots]
	jmp .end
.p2:
	inc word [player_2_shots]
.end:
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
	call bgl_draw_gfx_rle_fast
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
	call bgl_draw_gfx_rle_fast
	
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
	mov byte [ship_explosion_finished],1
	mov byte [ship_explosion_finished_delay],0
.end:
	ret

ship_rle: incbin "ship.rle"
ship_width equ 30
ship_height equ 29
ship_speed equ 3
ship_x_initial equ (320/2)-(ship_width/2)

ship_x dw ship_x_initial
ship_y dw 200-ship_height-16
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