ape_draw:
	mov byte [bgl_opaque],0
	
	mov ax,[ape_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[ape_y_pos]
	mov word [bgl_y_pos],ax
	add word [bgl_x_pos],30
	add word [bgl_y_pos],10
	mov ax,gun_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	mov ax,[ape_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[ape_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,ape_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	cmp byte [ape_bullet_moving],0
	je .end
	mov byte [bgl_opaque],1
	mov ax,[ape_bullet_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[ape_bullet_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,bullet_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
.end:
	ret

ape_move:
	call ape_bullet_move
	cmp byte [fen_controllable],1
	je .trolley
	cmp byte [ape_jumping_delay],37 ; reached maximum delay?
	ja .jump_stop ; if so, skip
	inc word [ape_y_vel] ; if not, do jumpy stuff
	mov ax,[ape_y_vel]
	sar ax,2
	add word [ape_y_pos],ax ; only add to y vel while jumping
	cmp byte [ape_jumping_in],0 ; jumping in?
	jne .jump_in ; if so, move left
	inc word [ape_x_pos]
	jmp .jump_skip
.jump_in:
	dec word [ape_x_pos]
.jump_skip:
	inc byte [ape_jumping_delay]
	jmp .right
.jump_stop:
	mov byte [ape_jumping],0
	cmp byte [ape_jumping_in],1
	jne .right
	cmp byte [fen_controllable],0
	jne .right
	mov byte [fen_controllable],1

.right:
	cmp byte [ape_jumping],0
	jne .end

	xor ax,ax
	mov al,[ape_speed]
	
	cmp byte [bgl_key_states+4dh],0 ; right pressed?
	je .left ; if not, skip
	cmp word [ape_x_pos],240
	jge .left
	add word [ape_x_pos],ax
.left:
	cmp byte [bgl_key_states+4bh],0 ; left pressed?
	je .up
	push ax
	mov ax,[fen_x_pos]
	add ax,[ape_trolley_x]
	cmp word [ape_x_pos],ax
	pop ax
	jle .up
	sub word [ape_x_pos],ax
.up:
	cmp byte [bgl_key_states+48h],0 ; up pressed?
	je .down
	push ax
	mov ax,[fen_y_pos]
	add ax,[ape_trolley_y]
	cmp word [ape_y_pos],ax
	pop ax
	jle .down
	sub word [ape_y_pos],ax
.down:
	cmp byte [bgl_key_states+50h],0 ; down pressed?
	je .shoot
	cmp word [ape_y_pos],143
	jge .shoot
	add word [ape_y_pos],ax
.shoot:
	cmp byte [bgl_key_states+39h],0 ; space pressed?
	je .end
	cmp byte [ape_bullet_moving],0
	jne .end
	mov ax,[ape_x_pos]
	add ax,76
	mov word [ape_bullet_x_pos],ax
	mov ax,[ape_y_pos]
	add ax,11
	mov word [ape_bullet_y_pos],ax
	mov byte [ape_bullet_moving],1
	mov si,gun_shoot_sfx
	call beep_play_sfx
	jmp .end
	
.trolley:
	call ape_clip_to_trolley
.end:
	ret
	
ape_bullet_move:
	cmp byte [ape_bullet_moving],0
	je .end
	xor ax,ax
	mov al,[ape_bullet_speed]
	add word [ape_bullet_x_pos],ax
	cmp word [ape_bullet_x_pos],340
	jb .end
	mov byte [ape_bullet_moving],0
.end:
	ret
	
ape_jump_out:
	cmp byte [fen_controllable],0
	je .end
	cmp byte [ape_jumping],0
	jne .end
	mov byte [fen_controllable],0 ; remove my controls (this also makes sure the jump animation doesn't trigger continously)
	mov byte [ape_jumping_delay],0
	mov byte [ape_jumping_in],0
	mov byte [ape_jumping],1
	xor ax,ax
	mov al,[ape_jumping_height]
	not ax
	mov word [ape_y_vel],ax
	call ape_clip_to_trolley
	mov si,jump_out_sfx
	call beep_play_sfx
.end:
	ret
	
ape_jump_in:
	cmp byte [fen_controllable],0
	jne .end
	
	cmp byte [ape_jumping],0
	jne .end
	
	mov ax,[fen_x_pos]
	add ax,[ape_trolley_x]
	cmp word [ape_x_pos],ax
	jg .end
	
	mov ax,[fen_y_pos]
	add ax,[ape_trolley_y]
	cmp word [ape_y_pos],ax
	jg .end
	
	
	mov byte [ape_jumping_delay],0
	mov byte [ape_jumping_in],1
	mov byte [ape_jumping],1
	xor ax,ax
	mov al,[ape_jumping_height]
	add al,3
	not ax
	mov word [ape_y_vel],ax
	mov si,jump_in_sfx
	call beep_play_sfx
.end:
	ret
	
ape_clip_to_trolley:
	mov ax,[fen_x_pos]
	add ax,[ape_fen_x]
	mov word [ape_x_pos],ax
	mov ax,[fen_y_pos]
	add ax,[ape_fen_y]
	mov word [ape_y_pos],ax
	ret

ape_x_pos dw 0
ape_y_pos dw 0
ape_jumping db 0 ; jumping out of trolley?
ape_jumping_in db 0 ; only effective if "ape_jumping" is true
ape_jumping_delay db 0 ; as soon as ape gets control, increase this until a certain point, where the ape can then be moved around by the player
ape_jumping_height db 16
ape_y_vel dw 0 ; only used for jumping
ape_speed db 3
ape_trolley_x dw 72
ape_trolley_y dw 26
ape_fen_x dw 32
ape_fen_y dw 13
ape_bullet_moving db 0
ape_bullet_x_pos dw 0
ape_bullet_y_pos dw 0
ape_bullet_speed db 5

ape_gfx: incbin "ape.rle"
gun_gfx: incbin "gun.rle"
bullet_gfx: incbin "bullet.rle"

gun_shoot_sfx: dw 120,400,800,1200,3000,6000,0
jump_out_sfx: dw 8000,7500,7000,6500,6000,5500,5000,4500,4000,3500,3000,2500,2000,0
jump_in_sfx: dw 2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,0
boom_sfx: dw 9000,220,9000,320,9000,420,9000,520,8700,600,8000,900,7400,1000,7000,1300,0
ape_pwm: incbin "chimp_bin.raw"
ape_pwm_length: dw $-ape_pwm