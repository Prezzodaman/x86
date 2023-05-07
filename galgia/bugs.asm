; there'll be plenty of these phwwoaaaa let me tell ya

bugs_player_loop_offset:
	; this is a super ultra hyper mega specialized function. for certain arrays, there are 2 sets, one for each player. loops use bx as the offset for the current bug. this changes the offset of bx depending on the current player. remember to push bx before calling, and pop afterwards.
	; told you it was specialized :P
	cmp byte [boss],0 ; use the same bugs if it's a boss level
	jne .end
	cmp byte [player_current],0
	je .end ; player 1, no need to offset the... offset
	add bx,bug_amount*2 ; next set of bugs
.end:
	ret

bugs_add_score:
	push ax
	push si
	push cx
	push bx

	movzx bx,[player_current]
	shl bx,2
	add dword [player_score+bx],bug_score
	shr bx,2
	inc byte [bugs_shot_lives+bx]
	cmp byte [bugs_shot_lives+bx],bugs_shot_lives_amount
	jne .end
	mov byte [bugs_shot_lives+bx],0
	inc byte [player_lives+bx]
	push bx
	xor bx,bx
	mov al,0
	mov ah,0
	mov si,bester_sfx
	mov cx,bester_sfx_length
	call blaster_mix_play_sample
	pop bx
.end:
	pop bx
	pop cx
	pop si
	pop ax
	ret

bugs_init: ; m8
	mov word [bug_flying_delay],0
	mov byte [bug_bomb_delay],0
	
	;cmp byte [player_2_mode],0
	;je .bugs_drawn
.bugs_drawn:
	mov byte [bugs_drawn],0
.bugs_drawn_skip:
	mov byte [bug_x_offset],0
	mov byte [bug_x_add],0
	mov byte [bug_x_timer],0
	movzx bx,[player_current]
	mov byte [bugs_shot+bx],0

	xor bx,bx
	mov cx,bug_1_amount
.types_loop_1:
	mov byte [bug_type+bx],0
	add bx,2
	loop .types_loop_1

	mov cx,bug_2_amount
.types_loop_2:
	mov byte [bug_type+bx],1
	add bx,2
	loop .types_loop_2

	mov cx,bug_3_amount
.types_loop_3:
	mov byte [bug_type+bx],2
	add bx,2
	loop .types_loop_3

	xor bx,bx
	xor cx,cx ; x offset
	xor dx,dx ; y offset
.loop:
	push bx
	call bugs_player_loop_offset
	mov byte [bug_active+bx],1
	mov byte [bug_shot+bx],0
	mov byte [bug_hits+bx],0
	pop bx
	mov byte [bug_flying+bx],0
	mov word [bug_angle+bx],0
	mov word [bug_flying_timer+bx],0
	mov byte [bug_flying_reset+bx],0
	
	cmp byte [bug_type+bx],1
	je .bugs_start_2
	cmp byte [bug_type+bx],2
	je .bugs_start_3
	mov word [bug_x+bx],bug_x_start
	jmp .bugs_start_skip
.bugs_start_2:
	mov word [bug_x+bx],bug_x_start+(bug_x_spacing*2)
	jmp .bugs_start_skip
.bugs_start_3:
	mov word [bug_x+bx],bug_x_start+(bug_x_spacing*4)
.bugs_start_skip:
	add word [bug_x+bx],cx
	add cx,bug_x_spacing
	mov word [bug_y+bx],bug_y_start
	add word [bug_y+bx],dx
	
	cmp byte [bug_type+bx],1 ; perform bound checks for bug type 2
	je .bugs_x_2
	cmp byte [bug_type+bx],2 ; bug type 3...
	je .bugs_x_3
	cmp cx,300<<bug_precision ; checks for bug type 1
	jl .end
	jmp .bugs_x_skip
.bugs_x_2:
	cmp cx,200<<bug_precision
	jl .end
	jmp .bugs_x_skip
.bugs_x_3:
	cmp cx,130<<bug_precision
	jl .end
	jmp .bugs_x_skip
.bugs_x_skip:
	xor cx,cx
	add dx,bug_y_spacing
.end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	
.x_y_i:
	xor bx,bx
.x_y_i_loop:
	mov ax,[bug_x+bx]
	mov word [bug_x_start_i+bx],ax
	mov ax,[bug_y+bx]
	mov word [bug_y_start_i+bx],ax
	add bx,2
	cmp bx,bug_amount*2
	jne .x_y_i_loop
.end_actual:
	ret

bugs_bomb_handler:
	cmp byte [boss],0
	jne .end_actual
	cmp byte [stage_started],0
	je .end_actual
	cmp byte [bugs_drawn],bug_amount
	jne .end_actual
	cmp byte [stage_started],0
	je .end_actual
	inc byte [bug_bomb_delay]
	mov ax,180
	movzx cx,[stage] ; higher stage, more frequent bomb droppage
	shl cx,1
	sub ax,cx
	call random_range
	add ax,40
	cmp byte [bug_bomb_delay],al
	jne .bombs ; haven't reached delay yet, handle bombs as normal
	mov byte [bug_bomb_delay],0
	
	cmp byte [ship_explosion_anim_state],ship_explosion_anim_frames ; has the ship exploded?
	je .end_actual ; if so, don't drop a bomb
	push bx
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount
	pop bx
	je .end_actual
	
	movzx bx,[bug_bomb_current]
	shl bx,1
	cmp byte [bug_bomb_active+bx],0 ; current bomb active?
	jne .active_skip ; if so, try next bomb
	mov byte [bug_bomb_active+bx],1 ; not active yet, make it
	mov ax,bx ; ax is bomb offset, for now
	
	push bx
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount
	pop bx
	je .bombs
	push ax ;
	call bugs_random_offset
	pop ax ;
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_shot+bx],0 ; it's active, but has it been shot?
	pop bx
	jne .bombs ; if so, skip to bomb handler
	mov cx,[bug_x+bx]
	sar cx,bug_precision
	add cx,bug_width/2
	mov dx,[bug_y+bx]
	sar dx,bug_precision
	add dx,bug_height/2
	
	mov bx,ax
	mov word [bug_bomb_x+bx],cx
	mov word [bug_bomb_y+bx],dx
	jmp .bombs
	
.active_skip:
	inc byte [bug_bomb_current]
	cmp byte [bug_bomb_current],bug_bomb_amount
	jne .bombs
	mov byte [bug_bomb_current],0
	
.bombs:
	xor bx,bx ; let's get down to business
	
	mov ax,[ship_x]
	mov word [bgl_collision_x2],ax
	mov ax,[ship_y]
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],ship_width
	mov word [bgl_collision_h2],ship_height
.bombs_loop:
	cmp byte [bug_bomb_active+bx],0
	je .end
	
	mov ax,[bug_bomb_x+bx]
	mov word [bgl_collision_x1],ax
	mov ax,[bug_bomb_y+bx]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],3
	mov word [bgl_collision_h1],6
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .bombs_skip
	cmp byte [ship_exploding],0
	jne .bombs_skip
	call ship_explode
.bombs_skip:
	add word [bug_bomb_y+bx],bug_bomb_speed
	cmp word [bug_bomb_y+bx],200 ; reached bottom of screen?
	jl .end ; if not, skip
	mov byte [bug_bomb_active+bx],0 ; otherwise, reset
.end:
	add bx,2
	cmp bx,bug_bomb_amount*2
	jne .bombs_loop
.end_actual:
	ret

bugs_random_offset: ; get offset of a random active bug, puts it in bx
	push ax
	push dx
.try_again:
	mov ax,bug_amount
	call random_range
	mov bx,ax
	shl bx,1 ; word length
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_active+bx],0 ; make sure this bug is active first!
	pop bx
	je .try_again ; if not, try again
	pop dx
	pop ax
	ret

bugs_bomb_draw:
	xor bx,bx
	mov word [bgl_buffer_offset],bug_bomb_gfx
.loop:
	cmp byte [bug_bomb_active+bx],0
	je .end
	mov ax,[bug_bomb_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[bug_bomb_y+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx
.end:
	add bx,2
	cmp bx,bug_bomb_amount*2
	jne .loop
.end_actual:
	ret

bugs_draw:
	cmp byte [stage_started],0
	je .stage_not_started
	jmp .start
	; draw only if stage has started and 
	;jmp .end
	;cmp byte [player_2_started],0 ; stage hasn't started and it's 2 player mode, is it player 2's first time?
	;je .end ; if so, end
	;movzx bx,[player_current]
	;cmp byte [bugs_shot+bx],0
.stage_not_started:
	movzx bx,[player_current]
	shl bx,1
	cmp byte [bugs_shot+bx],0
	je .end_actual ; if not, only draw the bombs
.start:
	xor bx,bx
.loop:
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_active+bx],0 ; is the current bug active/visible?
	pop bx
	je .end ; if not, skip this bug
	
	push bx
	shr bx,1
	cmp byte [bugs_drawn],bl
	pop bx
	jb .end
	
	movsx ax,[bug_x_offset]
    add ax,[bug_x+bx]
	sar ax,bug_precision
	mov word [bgl_x_pos],ax
	mov ax,[bug_y+bx]
	sar ax,bug_precision
	mov word [bgl_y_pos],ax
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_shot+bx],0 ; current bug shot?
	pop bx
	jne .shot ; if so, draw explosion
	
	cmp byte [bug_type+bx],1
	je .bug_2
	cmp byte [bug_type+bx],2
	je .bug_3
	mov word [bgl_buffer_offset],bug_1_gfx
	jmp .type_skip
.bug_2:
	mov word [bgl_buffer_offset],bug_2_gfx
	jmp .type_skip
.bug_3:
	mov word [bgl_buffer_offset],bug_3_gfx
.type_skip:
	push bx
	call bugs_player_loop_offset
	mov al,[bug_hits+bx]
	pop bx
	shl al,3
	mov byte [bgl_tint],al
	cmp byte [bug_flying+bx],0
	jne .flying
	call bgl_draw_gfx_fast
	jmp .end
.flying:
	mov ax,[bug_angle+bx]
	add ax,360
	mov word [bgl_rotate_angle],ax
	call bgl_draw_gfx_rotate
	jmp .end
.shot:
	add word [bgl_x_pos],5
	add word [bgl_y_pos],4
	push bx
	call bugs_player_loop_offset
	mov ax,[bug_explose_frame+bx]
	pop bx
	shr ax,bug_explose_speed
	cmp ax,1
	je .shot_2
	cmp ax,2
	je .shot_3
	cmp ax,3
	je .shot_4
	cmp ax,4
	je .shot_5
	mov word [bgl_buffer_offset],bug_explose_1_rle
	jmp .shot_skip
.shot_2:
	sub word [bgl_x_pos],4
	sub word [bgl_y_pos],4
	mov word [bgl_buffer_offset],bug_explose_2_rle
	jmp .shot_skip
.shot_3:
	sub word [bgl_x_pos],6
	sub word [bgl_y_pos],5
	mov word [bgl_buffer_offset],bug_explose_3_rle
	jmp .shot_skip
.shot_4:
	sub word [bgl_x_pos],11
	sub word [bgl_y_pos],8
	mov word [bgl_buffer_offset],bug_explose_4_rle
	jmp .shot_skip
.shot_5:
	sub word [bgl_x_pos],15
	sub word [bgl_y_pos],10
	mov word [bgl_buffer_offset],bug_explose_5_rle
.shot_skip:
	mov byte [bgl_tint],0
	call bgl_draw_gfx_rle_fast ; REALLY FAST.
.end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	
	mov byte [bgl_tint],0
.end_actual:
	call bugs_bomb_draw
	ret

bugs_handler:
	; bugs are handled even if the stage hasn't started, so the left/right movement persists, but the flying is skipped
	cmp byte [boss],0 ; boss level?
	jne .start_actual ; if so, skip the bugs_drawn check
	cmp byte [bugs_drawn],bug_amount
	jne .start
.start_actual: ; i'll never improve my label naming HabTis(s)
	xor bx,bx
.loop:
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_active+bx],0 ; don't handle a bug if it isn't active
	pop bx
	je .loop_end
.skip:
	; move bugs side to side
	cmp byte [bug_flying+bx],0 ; is the bug flying?
	jne .flying ; do fly things, ignore side movements
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_shot+bx],0 ; bug shot?
	pop bx
	jne .side_end ; if so, explode
	jmp .loop_end
.side_end:
	push bx
	call bugs_player_loop_offset
	inc byte [bug_explose_frame+bx] ; display explosion graphic
	cmp byte [bug_explose_frame+bx],5<<bug_explose_speed ; last explosion frame?
	pop bx
	jne .loop_end ; if not, bug is still active
	push bx
	call bugs_player_loop_offset
	mov byte [bug_active+bx],0 ; last frame, bug no longer active
	pop bx
	jmp .loop_end
.flying:
	push bx
	call bugs_player_loop_offset
	cmp byte [bug_shot+bx],0
	pop bx
	jne .side_end
	cmp byte [bug_flying_reset+bx],0 ; is the bug resetting?
	jne .resetting ; if so, don't change the angle
	
	mov ax,[bug_angle+bx]
	push bx
	mov bx,360
	xor dx,dx
	div bx
	mov cx,dx

	; x vel
	
	mov bx,cx ; so we can use it as an offset
	shl bx,1
	mov ax,[wave_table_deg+bx]
	pop bx ; get back current bug offset
	mov word [bug_x_vel+bx],ax
	
	; y vel
	
	push bx ; current bug offset
	mov ax,cx
	add ax,90
	mov bx,360
	xor dx,dx
	div bx
	shl dx,1 ; word length
	mov bx,dx
	mov ax,[wave_table_deg+bx]
	pop bx ; get back current bug offset
	mov word [bug_y_vel+bx],ax
	
	mov ax,[ship_x]
	mov word [bgl_collision_x2],ax
	mov ax,[ship_y]
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],ship_width
	mov word [bgl_collision_h2],ship_height
	
	mov ax,[bug_x+bx]
	sar ax,bug_precision
	mov word [bgl_collision_x1],ax
	mov ax,[bug_y+bx]
	sar ax,bug_precision
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],bug_width
	mov word [bgl_collision_h1],bug_height
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .flying_skip
	cmp byte [ship_exploding],0
	jne .flying_skip
	call ship_explode
	
.flying_skip:
	cmp byte [boss],0 ; boss active?
	jne .boss ; skip all side-to-side movements and edge checks

	; rotate bug if it's too close to the left or right edge...
	cmp word [bug_x+bx],bug_left_edge
	jg .x_check_2
	cmp word [bug_angle+bx],bug_down_angle ; make sure it always ends up facing down (up facing down, huhuhuhuh)
	jg .x_check_skip
	add word [bug_angle+bx],bug_flying_add ; close to left, add
	;add word [bug_x+bx],2<<bug_precision
	dec word [bug_flying_timer]
	jmp .x_check_skip
.x_check_2:
	cmp word [bug_x+bx],bug_right_edge ; not close to the left, check the right
	jl .x_check_skip
	cmp word [bug_angle+bx],0-bug_down_angle
	jl .x_check_skip
	sub word [bug_angle+bx],bug_flying_add ; close to right, subtract
	;sub word [bug_x+bx],2<<bug_precision
	dec word [bug_flying_timer]
	jmp .x_check_skip
.x_check_3:
	cmp word [bug_x+bx],0-bug_width ; bug way out of left bounds?
	jg .x_check_4 ; if not, skip
	mov byte [bug_flying_reset+bx],1 ; reset bug
	mov word [bug_angle+bx],0
	jmp .x_check_skip
.x_check_4:
	cmp word [bug_x+bx],320+bug_width ; bug way out of right bounds?
	jl .x_check_skip ; if not, skip
	mov byte [bug_flying_reset+bx],1 ; reset bug
	mov word [bug_angle+bx],0
	jmp .x_check_skip
.x_check_skip:
	mov ax,[bug_x_vel+bx]
	cmp byte [bug_type+bx],0
	je .x_vel_skip
	shl ax,1
.x_vel_skip:
	sar ax,bug_flying_speed
	add word [bug_x+bx],ax
	mov ax,[bug_y_vel+bx]
	sar ax,bug_flying_speed
	add word [bug_y+bx],ax
	
	;mov ax,5
	;call random_range ; this is such a fun function :D
	;movzx cx,[bug_type+bx]
	;shl cx,3
	mov ax,260 ; sequence end value
	;sub ax,cx
	movzx cx,[stage]
	shl cx,1 ; the higher the stage, the faster bugs will start to fly
	sub ax,cx
	cmp word [bug_flying_timer+bx],ax ; reached end of sequence?
	jge .flying_angle_skip ; if so, do nothing
	inc word [bug_flying_timer+bx] ; do all the conditional angle stuff
	mov ax,60
	movzx cx,[bug_type+bx] ; higher bug type, less time
	shl cx,6
	sub ax,cx
	cmp word [bug_flying_timer+bx],ax
	jl .flying_angle_add
	;cmp byte [bug_type+bx],0
	;jne .flying_angle_skip
	movzx cx,[bug_type+bx]
	shl cx,5
	mov ax,120
	sub ax,cx
	cmp word [bug_flying_timer+bx],ax
	jg .flying_angle_subtract
	jmp .flying_angle_skip
.flying_angle_add:
	mov ax,[bug_type+bx]
	shl ax,1
	add ax,bug_flying_add
	cmp word [bug_angle_initial+bx],0 ; if angle is negative, add
	jl .flying_angle_add2
	sub word [bug_angle+bx],ax
	jmp .flying_angle_skip
.flying_angle_add2:
	add word [bug_angle+bx],ax
	jmp .flying_angle_skip
.flying_angle_subtract:
	cmp word [bug_angle_initial+bx],0 ; if angle is negative, subtract
	jl .flying_angle_subtract2
	cmp byte [bug_flying_loop+bx],0
	je .flying_angle_skip
	add word [bug_angle+bx],bug_flying_subtract
	jmp .flying_angle_skip
.flying_angle_subtract2:
	sub word [bug_angle+bx],bug_flying_subtract
.flying_angle_skip:
	cmp word [bug_y+bx],(0-bug_height)<<bug_precision ; bug reached top of screen?
	jg .flying_angle_skip2 ; if not, continue
	mov byte [bug_flying_reset+bx],1 ; bug is resetting
	mov word [bug_angle+bx],0
	jmp .flying_angle_reset_skip
.flying_angle_skip2:
	cmp word [bug_y+bx],200<<bug_precision ; bug reached bottom of the screen?
	jl .loop_end ; if not, continue
	push bx
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount-1 ; is this the last bug?
	pop bx
	je .flying_angle_reset_skip ; if so, skip the reset
	mov byte [bug_flying_reset+bx],1 ; bug is resetting
	mov word [bug_angle+bx],0
.flying_angle_reset_skip:
	cmp byte [ship_exploding],0 ; ship exploding?
	je .flying_angle_reset_skip2 ; if not, skip reset
	mov byte [bug_flying_reset+bx],1 ; bug is resetting
	mov word [bug_angle+bx],0
.flying_angle_reset_skip2:
	mov word [bug_y+bx],(0-bug_height)<<bug_precision ; move bug to top of the screen, slightly off screen (screen genie)
	jmp .loop_end
.resetting:
	mov ax,[bug_y_start_i+bx]
	cmp word [bug_y+bx],ax ; reached initial y?
	jl .resetting_y ; if not, do x chex and increase y
	jmp .resetting_x ; reached initial y, continue checking for x
.resetting_y:
	add word [bug_y+bx],bug_flying_speed<<1
.resetting_x:
	movsx ax,[bug_x_offset]
	add ax,[bug_x_start_i+bx]
	sub ax,(1<<bug_flying_speed)*2
	cmp word [bug_x+bx],ax ; bug left to the start x?
	jl .resetting_left ; if lower, move right
	add ax,(1<<bug_flying_speed)*2
	cmp word [bug_x+bx],ax ; bug right to the start x?
	jg .resetting_right ; if greater, move left
	jmp .resetting_skip ; otherwise, reset bug
.resetting_left:
	add word [bug_x+bx],1<<bug_flying_speed
	jmp .loop_end
.resetting_right:
	sub word [bug_x+bx],1<<bug_flying_speed
	jmp .loop_end
.resetting_skip:
	mov ax,[bug_y_start_i+bx] ; do y checks again!
	cmp word [bug_y+bx],ax
	jl .loop_end ; haven't reached initial y, skip to end
	mov byte [bug_flying_reset+bx],0
	mov word [bug_flying_timer+bx],0
	mov byte [bug_flying+bx],0
	movsx ax,[bug_x_offset]
	add ax,[bug_x_start_i+bx]
	mov word [bug_x+bx],ax
	mov ax,[bug_y_start_i+bx]
	mov word [bug_y+bx],ax
.loop_end: ; the sidewalk... docta. step aside
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	
	cmp byte [boss],0 ; boss level?
	jne .end ; if so, do nothing else
	; behaviours for a normal level
	inc byte [bug_x_timer]
	cmp byte [bug_x_timer],50
	jne .x_offset
	mov byte [bug_x_timer],0
	not byte [bug_x_add]
.x_offset:
	cmp byte [bug_x_add],0
	je .x_offset_subtract
	add byte [bug_x_offset],bug_side_speed
	jmp .flying_delay
.x_offset_subtract:
	sub byte [bug_x_offset],bug_side_speed
	
.flying_delay:
	cmp byte [ship_explosion_anim_state],ship_explosion_anim_frames ; has the ship exploded?
	je .end ; if so, don't fly
	cmp byte [ship_explosion_finished],0 ; has the ship's explosion animation finished?
	jne .end ; if so, don't fly
	
	push bx
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount
	pop bx
	je .end
	cmp byte [stage_started],0
	je .end
	inc word [bug_flying_delay]
	mov ax,200 ; random chance
	call random_range
	add ax,240 ; minimum value
	movzx cx,[stage] ; higher stage, less time until a bug starts flying
	shl cx,1
	sub ax,cx
	cmp word [bug_flying_delay],ax ; reached maximum delay yet?
	jb .end ; if not, do nothing
	
	call bugs_random_offset ; get a random bug, reset it
	cmp byte [bug_flying+bx],0 ; make sure this bug isn't flying already
	jne .end
	mov word [bug_flying_delay],0
	mov byte [bug_flying+bx],1
	push bx
	movzx bx,[player_current]
	cmp byte [bugs_shot+bx],bug_amount-1
	pop bx
	jne .flying_sound_skip
	mov al,3
	call blaster_mix_stop_sample
.flying_sound_skip:
	mov ax,[bug_x+bx] ; get distance of this bug's x to the screen's centre x
	sar ax,bug_precision
	sub ax,320/2
	sar ax,1
	mov word [bug_angle+bx],ax
	mov word [bug_angle_initial+bx],ax
	call random
	and al,1
	mov byte [bug_flying_loop+bx],al
	
	push bx
	push ecx
	mov bx,1
	mov al,2
	mov ah,0
	mov si,flying_sfx_name
	mov ecx,flying_sfx_length
	call blaster_mix_play_sample
	pop ecx
	pop bx
	
	jmp .end
.start: ; right, from the beginning we're gonna start with the beginning
	cmp byte [stage_started],0 ; has the stage started?
	je .end ; if not, skip
	cmp byte [boss],0 ; is it a boss level?
	jne .end ; if so, don't draw any bugs, only the big bug of biggity bugginess (just like this game)
	inc byte [bugs_drawn]
	jmp .end
.boss:
	mov ax,[bug_x_vel+bx]
	sar ax,bug_flying_speed
	add word [bug_x+bx],ax
	mov ax,[bug_y_vel+bx]
	sar ax,bug_flying_speed
	add word [bug_y+bx],ax
	
	mov ax,[ship_x]
	shl ax,bug_precision
	cmp word [bug_x+bx],ax ; bug to left of ship?
	jg .boss_x_right ; if not, check if it's to the right
	add word [bug_angle+bx],1
	jmp .boss_skip
.boss_x_right:
	sub word [bug_angle+bx],1
.boss_skip:
	cmp word [bug_y+bx],200<<bug_precision
	jl .boss_end
	mov byte [bug_active+bx],0
.boss_end:
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
.end:
	call bugs_bomb_handler
	ret

bug_1_amount equ 12*2 ; yes i can work out 12*2, but it's here to let me know that there'll be 2 rows of bug 1 :)
bug_2_amount equ 8
bug_3_amount equ 4
bug_amount equ bug_1_amount+bug_2_amount+bug_3_amount ; much, much easier to handle as one set of variables instead of bug 1 x, bug 2 x, bug 3 x, etc...
bug_width equ 19
bug_height equ 16
bug_x_start equ 16<<bug_precision
bug_y_start equ 10<<bug_precision
bug_x_spacing equ (6+bug_width)<<bug_precision
bug_y_spacing equ (3+bug_height)<<bug_precision
bug_precision equ 4 ; always the safe bet
bug_side_speed equ 2
bug_score equ 100
bug_flying_speed equ 4
bug_flying_add equ 2
bug_flying_subtract equ 3
bug_left_edge equ 60<<bug_precision
bug_right_edge equ (320-(bug_left_edge>>bug_precision)-bug_width)<<bug_precision
bug_down_angle equ 50
bugs_shot_lives_amount equ 200 ; how many shot bugs until the player gets an extra life?

bug_bomb_amount equ 3
bug_bomb_speed equ 3

bug_bomb_active times bug_bomb_amount dw 0
bug_bomb_x times bug_bomb_amount dw 0
bug_bomb_y times bug_bomb_amount dw 0
bug_bomb_delay db 0 ; overall, not per bug
bug_bomb_current db 0

bug_flying_delay dw 0 ; also overall!

bug_x_add db 0 ; adding or subtracting
bug_x_timer db 0
bug_x_offset db 0

bug_x_start_i times bug_amount dw 0 ; for each individual bug, used for when it resets after flying
bug_y_start_i times bug_amount dw 0
bug_x times bug_amount dw 0
bug_y times bug_amount dw 0
bug_active times bug_amount*2 dw 0 ; *2, because we need states for both players
bug_x_vel times bug_amount dw 0
bug_y_vel times bug_amount dw 0
bug_angle times bug_amount dw 0
bug_angle_initial times bug_amount dw 0
bug_flying times bug_amount dw 0
bug_flying_timer times bug_amount dw 0 ; increases, when it reaches a certain amount, the angle stops getting added to
bug_flying_loop times bug_amount dw 0
bug_shot times bug_amount*2 dw 0
bug_hits times bug_amount*2 dw 0 ; for bugs that require multiple hits
bug_flying_reset times bug_amount dw 0 ; is it resetting after flying? (in other words, has it reached the bottom of the screen while flying)
bug_type times bug_1_amount+bug_2_amount+bug_3_amount dw 0
bugs_shot db 0,0 ; per level (player 1 and 2)
bugs_shot_lives db 0,0 ; increases when a bug is shot, when it reaches a certain value, reset and give the player an extra life, if the player loses his ship, this is reset
bugs_drawn db 0 ; when the stage begins, bugs won't be handled until all of them are drawn
	
bug_explose_speed equ 2

bug_explose_frame times bug_amount*2 dw 0

bug_1_gfx: incbin "alien_1.gfx"
bug_2_gfx: incbin "alien_2.gfx"
bug_3_gfx: incbin "alien_3.gfx"
bug_bomb_gfx: incbin "alien_bomb.gfx"

bug_explose_1_rle: incbin "alien_explose_1.rle"
bug_explose_2_rle: incbin "alien_explose_2.rle"
bug_explose_3_rle: incbin "alien_explose_3.rle"
bug_explose_4_rle: incbin "alien_explose_4.rle"
bug_explose_5_rle: incbin "alien_explose_5.rle"