bumper_collisions:
	cmp byte [bumper_collision_flag],0 ; 2 cars collided?
	jne .skip ; if so, skip
	
	mov ax,[bumper_pres_x_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_x1],ax
	mov ax,[bumper_pres_y_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_y1],ax
	mov ax,[bumper_other_x_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_x2],ax
	mov ax,[bumper_other_y_pos]
	add al,[bumper_collision_offset]
	mov word [bgl_collision_y2],ax
	mov ax,48
	sub al,[bumper_collision_offset]
	mov word [bgl_collision_w1],ax
	mov word [bgl_collision_w2],ax
	mov ax,32
	sub al,[bumper_collision_offset]
	mov word [bgl_collision_h1],ax
	mov word [bgl_collision_h2],ax
	call bgl_collision_check
	
	cmp byte [bgl_collision_flag],0 ; collision happened?
	je .skip ; if not, skip
	
	mov byte [bumper_collision_flag],1
	cmp word [bumper_pres_x_vel],0 ; is my x vel 0?
	jne .vel_skip ; if not, skip
	mov ax,[bumper_other_x_vel] ; otherwise, the other car must've hit me
	mov word [bumper_pres_x_vel],ax
	shl word [bumper_pres_x_vel],2 ; increase the x vel for extra bounciness
	mov al,[bumper_other_moving_left]
	mov byte [bumper_pres_moving_left],al
	mov si,other_hit_sfx
	call beep_play_sfx
	jmp .skip
.vel_skip:
	not byte [bumper_pres_moving_left] ; negate x movement of just me
	dec byte [bumper_other_hit_points]
	add word [game_score],2
	mov si,pres_hit_sfx
	call beep_play_sfx
	cmp byte [bumper_other_hit_points],0 ; other bumper reached 0 hit points?
	jne .skip ; if not, skip
	mov ax,[bumper_other_x_pos] ; otherwise, make that mutha EXPLODE.
	add ax,12
	mov word [explosion_x_pos],ax
	mov ax,[bumper_other_y_pos]
	sub ax,12
	mov word [explosion_y_pos],ax
	call explosion_spawn
	mov si,explosion_sfx
	call beep_play_sfx
	call bumper_other_spawn_next
	add word [game_score],8
.skip:
	ret
	
bumper_collision_offset db 14
bumper_collision_flag db 0 ; true if two bumpers have collided

%include "bumper_pres.asm"
%include "bumper_other.asm"