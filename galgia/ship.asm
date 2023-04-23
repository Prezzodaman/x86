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
	cmp byte [bug_active+bx],0
	je .bug_loop_skip
	cmp byte [bug_shot+bx],0
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
	inc byte [bug_hits+bx]
	cmp byte [bug_hits+bx],2 ; maximum hits?
	jne .bug_loop_bullet_reset
	call bugs_add_score
.bug_loop_hit_skip:
	call bugs_add_score
	mov byte [bug_shot+bx],1
	mov byte [bug_explose_frame+bx],0
	inc word [bugs_shot]
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
	jmp .end
.shoot_shot: ; best l'bale name
	mov byte [ship_shot],0
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
	mov word [bgl_buffer_offset],ship_gfx
	mov ax,[ship_x]
	mov word [bgl_x_pos],ax
	mov ax,[ship_y]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast
	ret

ship_gfx: incbin "ship.gfx"
ship_width equ 30
ship_height equ 29
ship_speed equ 3

ship_x dw (320/2)-(ship_width/2)
ship_y dw 200-ship_height-16
ship_shot db 0

ship_bullet_gfx: incbin "ship_bullet.gfx"
ship_bullet_amount equ 6 ; how many on-screen at a given time
ship_bullet_speed equ 5

ship_bullet_x times ship_bullet_amount dw 0
ship_bullet_y times ship_bullet_amount dw 0
ship_bullet_moving times ship_bullet_amount dw 0
ship_bullet_current db 0