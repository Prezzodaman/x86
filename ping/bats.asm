bats_handler:
	call bat_1_handler
	call bat_2_handler
	ret

bat_2_handler:
	;mov ax,[bat_1_x_pos]
	;shr ax,1
	;add ax,320/4
	;mov word [bat_2_x_pos],ax
	mov ax,[bat_2_x_vel] ; add to the x whether or not the ball's served
	add word [bat_2_x_pos],ax
	
	;cmp byte [ball_served],0
	;je .end ; ball hasn't been served yet, do nothing
	inc byte [bat_2_x_timer]
	cmp byte [bat_2_x_timer],bat_2_dumbness ; timer reached its limit?
	jb .end ; if not, do nothing
	mov byte [bat_2_x_timer],0 ; if it's reached its limit, reset it
	mov ax,[ball_x_pos] ; CALCACLAH the distance
	cmp byte [ball_served],1 ; is ball served?
	je .served_skip ; if so, continue using ball's x position
	mov ax,bat_2_x_centre<<ball_precision ; if ball isn't served, use centred x as the base
.served_skip:
	sar ax,ball_precision ; it's using high values, because ax starts with the ball x, so now we shift it down
	sub ax,[bat_2_x_pos]
	sar ax,3 ; speed
	mov word [bat_2_x_vel],ax
.end:
	ret

bat_1_handler:
	; y
	
	mov ax,3
	int 33h
	shr dx,1
	add dx,40
	cmp dx,200-80 ; reached bottom of the screen?
	jge .y_bottom ; clip to bottom
	mov word [bat_1_y_pos],dx
	jmp .x
	
.y_bottom:
	mov word [bat_1_y_pos],200-80
	
.x:
	; x
	
	shr cx,1
	sub cx,bat_1_width/2 ; centres the bat to the mouse
	cmp cx,0 ; reached left of screen?
	jle .x_left ; clip to left
	cmp cx,320-bat_1_width ; reached right of screen?
	jge .x_right ; clip to right
	mov word [bat_1_x_pos],cx ; move and rotate as normal
	jmp .rotate
	
.x_left:
	mov word [bat_1_x_pos],0
	mov word [bat_1_x_distance],32+360
	jmp .rotate_end ; no rotation if clipped either side
	
.x_right:
	mov word [bat_1_x_pos],320-bat_1_width
	mov word [bat_1_x_distance],(0-32)+360
	jmp .rotate_end
	
.rotate:
	; find rotation angle
	
	add cx,bat_1_width/2 ; get back original cx so we can find the distance
	sub cx,320/2
	neg cx
	sar cx,2
	add cx,360
	mov word [bat_1_x_distance],cx
	
.rotate_end:
	ret
	
bat_1_draw:
	cmp byte [game_over],0
	jne .end
	
	mov byte [bgl_flip],0
	mov ax,[bat_1_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[bat_1_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,[bat_1_x_distance]
	mov word [bgl_rotate_angle],ax
	
	cmp byte [bat_1_type],0
	je .dew
	cmp byte [bat_1_type],1
	je .doong
	cmp byte [bat_1_type],2
	je .pres
.dew:
	mov word [bgl_buffer_offset],bat_dew_gfx
	jmp .skip
.doong:
	mov word [bgl_buffer_offset],bat_doong_gfx
	jmp .skip
.pres:
	mov word [bgl_buffer_offset],bat_pres_gfx
.skip:
	call bgl_draw_gfx_rotate
.end:
	ret
	
bat_2_draw:
	cmp byte [game_over],0
	jne .end
	
	mov byte [bgl_flip],0
	mov ax,[bat_2_x_pos]
	mov word [bgl_x_pos],ax
	add ax,bat_2_width/2
	sub ax,320/2
	neg ax
	sar ax,2
	add ax,360
	mov word [bgl_rotate_angle],ax
	
	mov ax,[bat_2_y_pos]
	mov word [bgl_y_pos],ax
	
	cmp byte [bat_2_type],0
	je .dew
	cmp byte [bat_2_type],1
	je .doong
	cmp byte [bat_2_type],2
	je .pres
.dew:
	mov word [bgl_buffer_offset],bat_dew_small_gfx
	jmp .skip
.doong:
	mov word [bgl_buffer_offset],bat_doong_small_gfx
	jmp .skip
.pres:
	mov word [bgl_buffer_offset],bat_pres_small_gfx
.skip:
	call bgl_draw_gfx_rotate
.end:
	ret
	
bat_score:
	; if i'm batting, (the other player needs to hit)
	; give me a point if:
	; * the ball is out z (other player missed)
	; give the other player a point if:
	; * the ball is out x (i overshot)
	
	; if the other player is batting, (i need to hit)
	; give me a point if:
	; * the ball is out x (he overshot)
	; give the other player a point if:
	; * the ball is out z (i missed)
	
	cmp byte [bat_batting],0 ; am i batting?
	jne .p2 ; if not, perform checks for player 2
	cmp byte [ball_out_x],0 ; x chex first!
	jne .p2_2
	cmp byte [ball_out_z],0
	jne .p1
	jmp .end
.p1:
	inc byte [bat_1_points]
	cmp byte [bat_1_points],9
	jne .end
	mov byte [game_winner],0
	mov byte [game_over],1
	jmp .end
.p2: ; checks
	cmp byte [ball_out_x],0
	jne .p1
	cmp byte [ball_out_z],0
	jne .p2_2
	jmp .end
.p2_2:
	inc byte [bat_2_points]
	cmp byte [bat_2_points],9
	jne .end
	mov byte [game_winner],1
	mov byte [game_over],1
	
.end:
	ret

bat_dew_gfx: incbin "bat_dew.gfx"
bat_dew_small_gfx: incbin "bat_dew_small.gfx"
bat_doong_gfx: incbin "bat_doong.gfx"
bat_doong_small_gfx: incbin "bat_doong_small.gfx"
bat_pres_gfx: incbin "bat_pres.gfx"
bat_pres_small_gfx: incbin "bat_pres_small.gfx"

bat_1_x_pos dw 0
bat_1_y_pos dw 0
bat_1_x_distance dw 0 ; distance from the centre of the screen
bat_1_points db 0 ; would be player, but I'm using bat for consistency, as consistensty is consistenkey
bat_1_width equ 59
bat_1_height equ 80
bat_1_x_centre equ (320/2)-(bat_1_width/2)

bat_2_x_pos dw 0
bat_2_x_vel dw 0
bat_2_y_pos dw 0
bat_2_points db 0
bat_2_x_distance dw 0
bat_2_x_timer db 0 ; increases, when it reaches a certain point calculates the distance between itself and the ball
bat_2_width equ 46
bat_2_height equ 43
bat_2_x_centre equ (320/2)-(bat_2_width/2)

bat_batting db 0 ; real funny this, it's 0 if you're batting, and 1 if the other is batting. to prevent any potential collision issues.
bat_2_dumbness equ 5 ; a higher value makes it dumber than ever
bat_1_collision_padding_x equ 13 ; reduces the size of the bat's hitbox
bat_2_collision_padding_x equ bat_1_collision_padding_x/2
bat_collision_padding_y equ 4 
bat_1_handle_height equ 31 ; these are used for collisions with the ball
bat_2_handle_height equ 16