boss_explosion_init:
	mov ax,[boss_x]
	add ax,[boss_x_offset]
	sar ax,boss_precision
	add ax,boss_explosion_width/3
	mov word [boss_explosion_x],ax
	mov ax,[boss_y]
	add ax,[boss_y_offset]
	sar ax,boss_precision
	add ax,boss_explosion_height/2
	mov word [boss_explosion_y],ax
	mov byte [boss_explosion_flip],0
	mov byte [boss_explosion_inning],0
	mov dword [boss_explosion_scale],240
	mov byte [boss_explosion_active],1
	ret

boss_explosion_handler:
	cmp byte [boss_explosion_active],0
	je .end
	inc byte [boss_explosion_flip]
	and byte [boss_explosion_flip],3
	cmp byte [boss_explosion_inning],0
	je .outing
	add dword [boss_explosion_scale],boss_explosion_inning_speed
	cmp dword [boss_explosion_scale],600
	jl .end
	mov byte [boss_explosion_active],0
	movzx bx,[player_current]
	mov byte [bugs_shot+bx],bug_amount
	jmp .end
.outing:
	sub dword [boss_explosion_scale],boss_explosion_outing_speed
	cmp dword [boss_explosion_scale],boss_explosion_outing_speed
	jg .end
	mov byte [boss_explosion_inning],1
.end:
	ret
	
boss_explosion_draw:
	cmp byte [boss_explosion_active],0
	je .end
	mov byte [bgl_scale_centre],1
	mov ax,[boss_explosion_x]
	mov word [bgl_x_pos],ax
	mov ax,[boss_explosion_y]
	mov word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],boss_explosion_gfx
	mov eax,[boss_explosion_scale]
	mov dword [bgl_scale_x],eax
	mov dword [bgl_scale_y],eax
	mov al,[boss_explosion_flip]
	shr al,1
	mov byte [bgl_flip],al
	mov byte [bgl_scale_square],1
	call bgl_draw_gfx_scale
	mov byte [bgl_flip],0
.end:
	ret

boss_init:
	mov byte [boss_active],1
	mov byte [boss_state],0
	mov word [boss_intro_delay],0
	mov word [boss_x],((320/2)-(boss_width/2))<<boss_precision
	mov word [boss_y],(0-boss_height)-80<<boss_precision
	mov word [boss_y_vel],0
	mov word [boss_x_index],0
	mov word [boss_y_index],0
	mov word [boss_x_offset],0
	mov word [boss_y_offset],0
	mov byte [boss_type],0
	mov word [boss_bugs_delay],0
	mov byte [boss_bugs_x_moving],0
	mov byte [boss_bugs_x_moving_left],0
	mov byte [bugs_drawn],bug_amount
	mov byte [boss_health],40
	
	mov byte [boss_music_state],-2
	mov byte [boss_music_delay],-2
	mov byte [boss_music_playing],1
	xor bx,bx
.loop:
	mov byte [bug_active+bx],0
	add bx,2
	cmp bx,bug_amount*2
	jne .loop
	ret
	
boss_music_handler:
	cmp byte [boss_music_playing],0
	je .end
	inc byte [boss_music_delay]
	cmp byte [boss_music_delay],(boss_music_section_length/2)/blaster_mix_buffer_size
	jb .end
	mov byte [boss_music_delay],0
	inc byte [boss_music_state]
	cmp byte [boss_music_state],boss_music_length
	jb .state_check
	mov byte [boss_music_state],0
.state_check:
	movzx bx,[boss_music_state]
	mov al,[boss_music+bx]
	
	cmp al,0
	je .state_1
	cmp al,1
	je .state_2
	cmp al,2
	je .state_3
	cmp al,3
	je .state_4
	cmp al,4
	je .state_5
	cmp al,5
	je .state_6
	jmp .end ; none of the above, ignore
.state_1:
	mov si,boss_music_1_name
	mov cx,boss_music_section_length
	jmp .play
.state_2:
	mov si,boss_music_2_name
	mov cx,boss_music_section_length
	jmp .play
.state_3:
	mov si,boss_music_3_name
	mov cx,boss_music_section_length
	jmp .play
.state_4:
	mov si,boss_music_4_name
	mov cx,boss_music_section_length/2
	jmp .play
.state_5:
	mov si,boss_music_5_name
	mov cx,boss_music_section_length/2
	jmp .play
.state_6:
	mov si,boss_music_6_name
	mov cx,boss_music_section_length
.play:
	mov bx,1
	mov al,3
	mov ah,0
	
	call blaster_mix_play_sample
.end:
	ret	
	
boss_handler:
	cmp byte [boss],0
	je .end
	call boss_explosion_handler
	call boss_music_handler
	cmp byte [boss_active],0
	je .end
	cmp byte [boss_state],0
	je .move_down
	cmp byte [boss_state],1
	je .main
	cmp byte [boss_state],2
	je .exploded
	jmp .end
.move_down:
	add word [boss_y],1<<boss_precision
	cmp word [boss_y],20<<boss_precision
	jl .end
	mov byte [boss_state],1
	jmp .end
.main:
	mov ax,[boss_x_index]
	call bgl_get_sine
	shl ax,2
	mov word [boss_x_offset],ax
	
	mov ax,[boss_y_index]
	call bgl_get_sine
	sar ax,1
	mov word [boss_y_offset],ax
	add word [boss_y_index],3
	
	cmp byte [boss_bugs_x_moving],0 ; moving horizontally?
	je .not_moving ; if not, skip
	add word [boss_x_index],1
	cmp byte [boss_bugs_x_moving_left],0 ; moving left?
	jne .x_left ; if so, check for a different value
	cmp word [boss_x_index],360
	jl .x_skip
	mov byte [boss_bugs_x_moving],0
	mov byte [boss_bugs_x_moving_left],0
	mov word [boss_x_index],0
	jmp .end
.x_skip:
	cmp word [boss_x_index],90
	jl .end
	cmp word [boss_x_index],180+90 ; the wonders of guesswork
	jg .end
	mov byte [boss_bugs_x_moving],0
	mov byte [boss_bugs_x_moving_left],1
	jmp .end
.x_left:
	cmp word [boss_x_index],180+90
	jl .end
	mov byte [boss_bugs_x_moving],0
	mov byte [boss_bugs_x_moving_left],0
	jmp .end
.not_moving:
	inc word [boss_bugs_delay]
	cmp word [boss_bugs_delay],boss_bugs_delay_shoot
	jl .end
	cmp word [boss_bugs_delay],boss_bugs_delay_shoot
	jne .x_move_check
	mov ax,[boss_x]
	add ax,[boss_x_offset]
	sar ax,boss_precision
	add ax,(boss_width/2)-(bug_width/2)
	shl ax,bug_precision
	mov word [bug_x],ax
	mov word [bug_x+2],ax
	mov ax,[boss_y]
	add ax,[boss_y_offset]
	add ax,boss_height/2
	sar ax,boss_precision
	add ax,boss_height/2
	shl ax,bug_precision
	mov word [bug_y],ax
	mov word [bug_y+2],ax
	mov byte [bug_active],1
	mov byte [bug_active+2],1
	mov byte [bug_type],1
	mov byte [bug_type+2],1
	mov byte [bug_shot],0
	mov byte [bug_shot+2],0
	mov byte [bug_flying],1
	mov byte [bug_flying+2],1
	mov byte [bug_flying_reset],0
	mov byte [bug_flying_reset+2],0
	mov word [bug_angle],-40
	mov word [bug_angle+2],40
	mov byte [bug_hits],0
	mov byte [bug_hits+2],0
	mov byte [boss_bugs_anim_playing],1
	mov byte [boss_bugs_anim_delay],0
	jmp .not_moving_skip
.x_move_check:
	cmp word [boss_bugs_delay],boss_bugs_delay_x_move
	jne .not_moving_skip
	mov byte [boss_bugs_x_moving],1
.not_moving_skip:
	cmp word [boss_bugs_delay],boss_bugs_delay_end
	jne .end_skip
	mov word [boss_bugs_delay],0
	mov byte [boss_bugs_x_moving],0
	jmp .end
.end_skip:
	cmp word [boss_bugs_delay],boss_bugs_delay_end*2
	jb .end
	mov word [boss_bugs_delay],0
	mov byte [boss_bugs_x_moving],0
	jmp .end
.exploded:
	inc word [boss_y_vel]
	mov ax,[boss_y_vel]
	add word [boss_y],ax
	cmp word [boss_y],(200+boss_height)<<boss_precision
	jl .end
	mov byte [boss_active],0
.end:
	ret
	
boss_draw:
	cmp byte [boss],0
	je .end
	cmp byte [boss_active],0
	je .end
	mov ax,[boss_x]
	add ax,[boss_x_offset]
	sar ax,boss_precision
	mov word [bgl_x_pos],ax
	mov ax,[boss_y]
	add ax,[boss_y_offset]
	sar ax,boss_precision
	mov word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],alien_boss_1_rle
	mov byte [bgl_no_bounds],0
	mov al,[boss_flash]
	mov byte [bgl_erase],al
	mov byte [bgl_background_colour],15
	call bgl_draw_gfx_rle
	
	mov word [bgl_buffer_offset],alien_boss_1_leg_1_rle
	cmp byte [boss_bugs_anim_playing],0
	je .legs_skip
	mov word [bgl_buffer_offset],alien_boss_1_leg_2_rle
	inc byte [boss_bugs_anim_delay]
	cmp byte [boss_bugs_anim_delay],30
	jne .legs_skip
	mov byte [boss_bugs_anim_delay],0
	mov byte [boss_bugs_anim_playing],0
.legs_skip:
	add word [bgl_x_pos],9
	add word [bgl_y_pos],boss_height-7
	call bgl_draw_gfx_rle
	mov byte [bgl_flip],1
	add word [bgl_x_pos],boss_base_width+9
	call bgl_draw_gfx_rle
	
	mov byte [bgl_erase],0
	cmp byte [boss_flash],0
	je .end
	inc byte [boss_flash]
	cmp byte [boss_flash],3
	jne .end
	mov byte [boss_flash],0
.end:
	mov byte [bgl_flip],0
	call boss_explosion_draw
	ret

boss_active db 0
boss_state db 0 ; 0 = coming down, 1 = bossing, 2 = exploding
boss_intro_delay dw 0 ; if boss_state=0, this will increase until a certain point, when the boss stops moving down from the top of the screen
boss_x dw 0
boss_y dw 0
boss_y_vel dw 0 ; used for the fall after exploding
boss_x_offset dw 0
boss_y_offset dw 0
boss_x_index dw 0 ; sine
boss_y_index dw 0
boss_type db 0 ; 0=blue bug
boss_flash db 0
boss_health db 0

boss_precision equ 4 ; for the sine movements
boss_base_x equ 32 ; start of the boss' "base" (the body, if you like)
boss_base_width equ 42

boss_bugs_amount equ 3
boss_bugs_delay dw 0 ; when this reaches a certain amount, the boss will throw bugs, how many are thrown depend on the boss type
boss_bugs_anim_playing db 0 ; used for its "legs"
boss_bugs_anim_delay db 0
boss_bugs_x_moving db 0 ; when bugs are thrown, this will be set to true
boss_bugs_x_moving_left db 0

boss_bugs_delay_shoot equ 40
boss_bugs_delay_x_move equ 100
boss_bugs_delay_end equ 160

alien_boss_1_rle: incbin "alien_boss_1.rle"
alien_boss_1_leg_1_rle: incbin "alien_boss_1_leg_1.rle"
alien_boss_1_leg_2_rle: incbin "alien_boss_1_leg_2.rle"

boss_width equ 106
boss_height equ 70
boss_stage equ 4 ; counting from 0...

;;;

boss_explosion_x dw 0
boss_explosion_y dw 0
boss_explosion_active db 0
boss_explosion_inning db 0
boss_explosion_flip db 0
boss_explosion_scale dd 0

boss_explosion_width equ 62
boss_explosion_height equ 63
boss_explosion_outing_speed equ 10
boss_explosion_inning_speed equ 2

boss_explosion_gfx: incbin "explosion.gfx"

;;

boss_music_section_length equ 28260
boss_music_1_name db "boss1.raw",0
boss_music_2_name db "boss2.raw",0
boss_music_3_name db "boss3a.raw",0
boss_music_4_name db "boss3b.raw",0
boss_music_5_name db "boss3c.raw",0
boss_music_6_name db "boss4.raw",0

boss_music_playing db 0
boss_music_delay db 0
boss_music_state db 0
boss_music
	db 0,-1,0,-1
	db 0,-1,1,-1
	db 0,-1,0,-1
	db 0,-1,1,-1
	db 2,3,2,4
	db 2,3,5,-1
	db 2,3,2,4
	db 2,3,5,-1
boss_music_length equ $-boss_music