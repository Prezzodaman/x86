employees_move:
	call employee_attacker_move
	call employee_defender_move
	ret
	
employee_attacker_init:
	mov word [employee_attacker_spawn_timer_max],80
	ret
	
employee_attacker_bullet_reset:
	push ax
	push si
	cmp byte [employee_attacker_active],0
	je .end
	mov byte [employee_attacker_bullet_delay],0
	mov ax,[employee_attacker_x_pos] ; move bullet to attacker
	sub ax,30
	mov word [employee_attacker_bullet_x_pos],ax
	mov ax,[employee_attacker_y_pos]
	add ax,38
	mov word [employee_attacker_bullet_y_pos],ax
	mov si,employee_gun_shoot_sfx
	call beep_play_sfx
	jmp .end
.end:
	pop si
	pop ax
	ret
	
employee_attacker_bullet_handler:
	push ax
	
	cmp byte [employee_attacker_bullet_active],0 ; bullet active?
	je .delay_skip ; if not, increase delay
	xor ah,ah ; move bullet
	mov al,[employee_attacker_bullet_speed]
	sub word [employee_attacker_bullet_x_pos],ax
	cmp word [employee_attacker_bullet_x_pos],-4 ; reached left side of screen?
	jg .collision ; if not, skip
	mov byte [employee_attacker_bullet_active],0 ; otherwise, make bullet inactive
	
.delay_skip:
	cmp byte [employee_attacker_active],0 ; only increase delay if the attacker is active
	je .end
	cmp byte [employee_attacker_state],1 ; ...and kneeling
	jne .end
	cmp byte [employee_attacker_type],1 ; ...and holding a gun
	jne .end
	cmp byte [employee_attacker_killed],0 ; ...and not dead
	jne .end
	inc byte [employee_attacker_bullet_delay]
	cmp byte [employee_attacker_bullet_delay],30 ; reached maximum delay?
	jb .end ; if not, skip
	call employee_attacker_bullet_reset
	mov byte [employee_attacker_bullet_active],1
	
.collision:
	mov ax,[employee_attacker_bullet_x_pos]
	mov word [bgl_collision_x2],ax
	mov ax,[employee_attacker_bullet_y_pos]
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],4
	mov word [bgl_collision_h2],2
	
	mov ax,[ape_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[ape_y_pos]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],39
	mov word [bgl_collision_h1],52
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .collision_fen ; no collision, continue as normal
	mov byte [employee_attacker_bullet_active],0
	;mov si,ape_pwm
	;mov cx,beep_11025
	;mov dx,[ape_pwm_length]
	;call beep_play_sample
	
.collision_fen:
	mov ax,[fen_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[fen_y_pos]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],30
	mov word [bgl_collision_h1],54
	
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .end ; no collision, continue as normal
	mov byte [employee_attacker_bullet_active],0
	call fen_do_hurt
.end:
	pop ax
	ret
	
employee_attacker_bullet_draw:
	push ax
	xor ah,ah
	mov al,[bgl_opaque]
	push ax
	mov byte [bgl_opaque],1
	cmp byte [employee_attacker_bullet_active],0
	je .end
	mov ax,[employee_attacker_bullet_x_pos] ; draw bullet
	mov word [bgl_x_pos],ax
	mov ax,[employee_attacker_bullet_y_pos]
	;add ax,40
	mov word [bgl_y_pos],ax
	mov ax,bullet_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
.end:
	pop ax
	mov byte [bgl_opaque],al
	pop ax
	ret
	
employee_attacker_spawn:
	cmp byte [employee_attacker_active],0
	jne .end
	mov byte [employee_attacker_active],1
	mov byte [employee_attacker_state],0
	mov byte [employee_attacker_delay],0
	mov word [employee_attacker_x_pos],320+40
	mov byte [employee_attacker_bullet_active],0
	mov byte [employee_attacker_bullet_delay],0
	mov byte [employee_attacker_killed],0
.end:
	ret
	
employee_attacker_move:
	call employee_attacker_bullet_handler
	cmp byte [employee_attacker_active],0 ; active?
	je .spawn_timer ; if not, increase the spawn timer
	cmp byte [employee_attacker_killed],0 ; killed yet?
	je .killed_skip ; if not, do normal movey things
	add word [employee_attacker_x_pos],8 ; make him fly off screen!
	sub word [employee_attacker_y_pos],4
	cmp word [employee_attacker_x_pos],320+80 ; reached right side? (plus some indeterminate width value)
	jb .end ; if not, skip
	mov byte [employee_attacker_active],0 ; make employee inactive again
	mov word [employee_attacker_spawn_timer],0 ; reset spawn timer
	jmp .spawn_timer
	
.killed_skip:
	cmp byte [employee_attacker_type],0 ; bomb?
	je .bomb
	cmp byte [employee_attacker_state],0 ; walking in?
	jne .collision ; if not, do shooty things (kneeling is set upon the maximum delay being reached)
	inc byte [employee_attacker_delay] ; increase delay only if walking
	sub word [employee_attacker_x_pos],1
	
	; how to random on dos:
	mov al,80 ; base value
	mov ah,[global_randomizer] ; get random "seed"
	and ah,1 ; randomize chance of the number being odd or even (ah will be 0 or 1)
	add al,ah ; if random, it'll be 81
	add word [global_randomizer],58734 ; randomness baby
	mov ah,[global_randomizer]
	and ah,2^6 ; "narrow down" the range, so to say
	shl ah,5 ; make the random value higher
	add al,ah ; base value + random value
	xor ah,ah ; clear out the high register (not needed but it makes me happy)
	
	cmp byte [employee_attacker_delay],al ; reached maximum?
	jb .collision
	mov byte [employee_attacker_state],1 ; kneel
	mov byte [employee_attacker_bullet_active],1
	call employee_attacker_bullet_reset
	jmp .collision
	
.bomb:
	

.collision:
	; collision check

	mov ax,[employee_attacker_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[employee_attacker_y_pos]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],26
	mov word [bgl_collision_h1],88
	
	mov ax,[ape_bullet_x_pos]
	mov word [bgl_collision_x2],ax
	mov ax,[ape_bullet_y_pos]
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],4
	mov word [bgl_collision_h2],2
	
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .end
	cmp byte [employee_attacker_killed],0
	jne .end
	cmp byte [ape_bullet_moving],0
	je .end
	mov byte [employee_attacker_killed],1
	mov byte [ape_bullet_moving],0
	mov si,employee_ow_sfx
	call beep_play_sfx
	jmp .end
	
.spawn_timer: ; the attacker is inactive
	inc byte [employee_attacker_hair]
	mov al,[global_randomizer]
	add byte [employee_attacker_hair],al
	cmp byte [employee_attacker_hair],2
	jbe .spawn_timer_skip
	mov byte [employee_attacker_hair],0
	
	inc byte [employee_attacker_gun_type]
	and byte [employee_attacker_gun_type],7
	
.spawn_timer_skip:
	inc word [employee_attacker_y_pos] ; "randomness"
	mov ax,[global_randomizer]
	and ax,2^2
	add word [employee_attacker_y_pos],ax ; """"RANDOMNESS""""
	cmp word [employee_attacker_y_pos],200-88 ; bottom of screen? (tap... tabaddum)
	jb .spawn_timer_skip2
	mov word [employee_attacker_y_pos],0
.spawn_timer_skip2:
	inc word [employee_attacker_spawn_timer]
	mov ax,[employee_attacker_spawn_timer_max] ; the names are so long because it makes life infinitely easier for me :D
	push bx
	mov bl,[global_randomizer]
	and bl,2^5 ; give it some "randomness" between the default value and a power of 2 (because and)
	add al,bl
	pop bx
	cmp word [employee_attacker_spawn_timer],ax ; reached maximum timer?
	jb .end ; if not, skip
	call employee_attacker_spawn ; reached maximum, it'll increase no more, and the employee will be "spawned" (reset really)
.end:
	ret
	
employee_attacker_draw:
	
	push word [employee_attacker_y_pos]
	
	call employee_attacker_bullet_draw
	
	cmp byte [employee_attacker_active],0 ; active?
	je .end ; if not, do nothing
	mov byte [bgl_opaque],1
	
.gun:
	mov byte [bgl_opaque],0
	cmp byte [employee_attacker_type],1 ; gun?
	jne .legs ; if not, skip
	
	; draw da gun
	mov ax,[employee_attacker_x_pos]
	sub ax,34
	mov word [bgl_x_pos],ax
	mov ax,[employee_attacker_y_pos]
	add ax,15
	mov word [bgl_y_pos],ax
	cmp byte [employee_attacker_gun_type],0 ; there are lots of guns because doing the pixel art for them was soooo much fun
	je .gun_1
	cmp byte [employee_attacker_gun_type],1
	je .gun_2
	cmp byte [employee_attacker_gun_type],2
	je .gun_3
	cmp byte [employee_attacker_gun_type],3
	je .gun_4
	cmp byte [employee_attacker_gun_type],4
	je .gun_5
	cmp byte [employee_attacker_gun_type],5
	je .gun_6
	jmp .gun_7 ; fallback
	
.gun_1:
	mov ax,nerf_1_gfx
	jmp .gun_draw
.gun_2:
	mov ax,nerf_2_gfx
	jmp .gun_draw
.gun_3:
	mov ax,nerf_3_gfx
	jmp .gun_draw
.gun_4:
	mov ax,nerf_4_gfx
	jmp .gun_draw
.gun_5:
	mov ax,nerf_5_gfx
	jmp .gun_draw
.gun_6:
	mov ax,nerf_6_gfx
	jmp .gun_draw
.gun_7:
	mov ax,nerf_7_gfx
	
.gun_draw:
	mov word [bgl_buffer_offset],ax
	mov byte [bgl_flip],1
	
	cmp byte [employee_attacker_state],1 ; kneeling?
	jne .gun_draw_skip ; if not, skip
	add word [bgl_y_pos],16
.gun_draw_skip:
	call bgl_draw_gfx_rle
	
	mov byte [bgl_flip],0

	cmp byte [employee_attacker_state],1 ; using gun and kneeling?
	jne .legs ; if not, skip
	add word [employee_attacker_y_pos],16
	
.legs:
	; legs
	
	mov ax,[employee_attacker_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[employee_attacker_y_pos]
	add ax,52
	mov word [bgl_y_pos],ax
	cmp byte [employee_attacker_killed],1
	je .legs_killed ; if killed, use "killed" legs
	cmp byte [employee_attacker_type],1 ; gun?
	je .legs_gun ; if so, do another check
	jmp .legs_normal ; otherwise, just use normal legs
.legs_killed:
	mov ax,employee_legs_2_gfx
	jmp .legs_draw
.legs_gun:
	cmp byte [employee_attacker_state],1
	jne .legs_normal ; if gun type but not kneeling, use normal legs
	mov ax,employee_legs_squat_gfx
	jmp .legs_draw
.legs_normal:
	mov ax,employee_legs_gfx
.legs_draw:
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	; body
	
	add word [bgl_x_pos],3
	sub word [bgl_y_pos],29
	mov ax,employee_body_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
.head:
	; head
	mov ax,[employee_attacker_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[employee_attacker_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,employee_head_gfx
	cmp byte [employee_attacker_killed],0 ; killed?
	je .head_draw ; if not, skip
	mov ax,employee_head_hurt_gfx
.head_draw:
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	; hair
	
	cmp byte [employee_attacker_hair],0
	je .hair_1
	cmp byte [employee_attacker_hair],1
	je .hair_2
	jmp .hair_3 ; fallback
.hair_1:
	mov ax,employee_hair_1_gfx
	jmp .hair_skip
.hair_2:
	mov ax,employee_hair_2_gfx
	jmp .hair_skip
.hair_3:
	mov ax,employee_hair_3_gfx
.hair_skip:
	mov word [bgl_buffer_offset],ax
	sub word [bgl_y_pos],8
	call bgl_draw_gfx_rle
	
	; arm
	
	mov ax,[employee_attacker_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[employee_attacker_y_pos]
	mov word [bgl_y_pos],ax
	
	cmp byte [employee_attacker_type],0 ; throwing a bomb?
	jne .arm_gun ; if so, put arm in air
	cmp byte [employee_attacker_killed],0 ; killed?
	jne .arm_gun ; if so, put arm in air
	jmp .arm_air ; if not throwing a bomb, or still alive, use gun arm
.arm_gun:
	mov ax,employee_arm_2_gfx
	sub word [bgl_x_pos],8
	add word [bgl_y_pos],27
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	jmp .end
.arm_air:
	mov ax,employee_arm_gfx
	add word [bgl_x_pos],13
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	jmp .end

.end:

	pop word [employee_attacker_y_pos]

	ret
	
employee_defender_move:
	ret
	
employee_defender_draw:
	ret

nerf_1_gfx: incbin "nerf_1.rle"
nerf_2_gfx: incbin "nerf_2.rle"
nerf_3_gfx: incbin "nerf_3.rle"
nerf_4_gfx: incbin "nerf_4.rle"
nerf_5_gfx: incbin "nerf_5.rle"
nerf_6_gfx: incbin "nerf_6.rle"
nerf_7_gfx: incbin "nerf_7.rle"

employee_head_gfx: incbin "employee_head.rle"
employee_head_hurt_gfx: incbin "employee_head_hurt.rle"
employee_hair_1_gfx: incbin "employee_hair_1.rle" ; all hair is drawn 8 pixels above the head
employee_hair_2_gfx: incbin "employee_hair_2.rle"
employee_hair_3_gfx: incbin "employee_hair_3.rle"
employee_legs_gfx: incbin "employee_legs.rle"
employee_legs_squat_gfx: incbin "employee_legs_squat.rle"
employee_legs_2_gfx: incbin "employee_legs_2.rle"
employee_body_gfx: incbin "employee_body.rle"
employee_arm_gfx: incbin "employee_arm.rle"
employee_arm_2_gfx: incbin "employee_arm_2.rle"
employee_arm_3_gfx: incbin "employee_arm_3.rle"
bomb_gfx: incbin "bomb.rle"

; there are 2 kinds of employee, one of each on screen at any given time:
; the attacker: pops up occasionally, either throwing a BOMB, or shooting a nerf gun. (bullets out of it, not the whole gun) only requires one hit to "kill". when shooting the gun, he'll squat down like a proper mattle ban battling man battling the man and the ape.

; bosnian ape acts as a protective shield for phenice, so when he's off the trolley, phenice becomes totally vulnerable

employee_attacker_x_pos dw 190
employee_attacker_y_pos dw 40 ; when not active, constantly increase for "randomness"
employee_attacker_hair db 0 ; more pseudo randomness, constantly increasing on every frame until the attacker is active
employee_attacker_spawn_timer dw 0 ; increases until a certain point, when employee_attacker_active is set and this is increased no more
employee_attacker_spawn_timer_max dw 0 ; DEcreases as the difficulty INcreases (lots of creases)
employee_attacker_active db 0
employee_attacker_type db 1 ; toggles between on and off on every frame until the attacker is spawned, 0: bomb, 1: gun
employee_attacker_state db 0 ; if of type 0 (bomb), 0 is coming in from side of screen, 1 is idle, 2 is coming off screen. if of type 1, 0 is coming in, 1 is infinitely kneeling and shooting
employee_attacker_killed db 0
employee_attacker_delay db 0 ; this is increased, or not, depending on the state. if on the last state, this'll probably remain as-is
employee_attacker_weapon_x_pos dw 0 ; for both bomb and gun
employee_attacker_weapon_y_pos dw 0
employee_attacker_bomb_y_vel dw 0 ; for the throwing effect
employee_attacker_bomb_timer db 0 ; 0 until the bomb is dropped, when it increases, then it hits a certain amount, then it go BOOOM!!!!
employee_attacker_bomb_active db 0
employee_attacker_gun_type db 0 ; what kinda gun is it??? (shrugs) uhhh idunno
employee_attacker_bullet_x_pos dw 0
employee_attacker_bullet_y_pos dw 0
employee_attacker_bullet_active db 0
employee_attacker_bullet_speed db 3
employee_attacker_bullet_delay db 0

; the defender: has no attack, but always appears in front of the attacker. he has no form of attack, but requires multiple hits to "kill", and stops any bullets from hitting the attacker. his main purpose is to get in the way and nothing else

employee_defender_x_pos dw 0
employee_defender_y_pos dw 0 ; do same as the attacker
employee_defender_spawn_timer dw 0 ; spawm... nope try again... spawb... uhh
employee_defender_active db 0
employee_defender_walking db 0
employee_defender_hit_points db 0 ; 5 on every spawn
employee_defender_killed db 0

employee_ow_sfx: dw 800,700,500,400,300,280,260,290,400,800,1000,3000,4000,5000,6000,0
employee_gun_shoot_sfx: dw 2000,3000,4000,5000,7000,9000,12000,0