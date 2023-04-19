ball_handler:
	cmp byte [ball_served],0 ; has the ball been served?
	je .not_served ; if not, clip ball to bat
	; ball is served!
	cmp byte [game_over],0 ; has game ended?
	jne .end ; if so, skip the entire ball handler
	mov al,[ball_out_x] ; ball served, game running!
	or al,[ball_out_z] ; get your mind out of the gutter
	mov byte [ball_out],al
	inc byte [ball_x_vel_add_timer]
	cmp byte [ball_x_vel_add_timer],3
	jne .x_vel_add_skip
	mov byte [ball_x_vel_add_timer],0
	cmp word [ball_x_vel],0 ; is x vel positive?
	jge .x_vel_sub ; if so, subtract
	inc word [ball_x_vel] ; x vel is negative, add
	jmp .x_vel_add_skip
.x_vel_sub:
	dec word [ball_x_vel]
.x_vel_add_skip:
	mov ax,[ball_x_vel] 
	add word [ball_x_pos],ax
	sub word [ball_rotation],14
	; move ball "forward" or "backward"
	mov ax,ball_z_speed ; putting it in ax in case we need to do any maths to speed up/slow down the ball
	cmp byte [bat_batting],0 ; player 1 batting?
	je .move_away ; move the ball towards the other player
	add word [ball_z_pos],ax ; player 2 is batting, move ball towards me
	;cmp byte [ball_out],0 ; don't check if the ball's z is out of bounds, if already out based on the left/right
	;jne .y
	mov byte [ball_out_x],0 ; if none of the checks below are true, this remains 0
	mov byte [ball_out_z],0 ; ditto
	cmp word [ball_z_pos],ball_z_out ; check if the ball's out of bounds, way out of bounds, so out of bounds it isn't part of the inbounds
	jl .z_skip
	mov byte [ball_out_z],1
.move_away:
	sub word [ball_z_pos],ax
	cmp word [ball_z_pos],0-ball_z_out
	jg .z_skip
	mov byte [ball_out_z],1
.z_skip:
	mov ax,((table_x+table_width+table_width)-table_top_edge)<<ball_precision ; work out right table bounds
	mov bx,[ball_z_pos]
	shl bx,1 ; this works because rather conveniently, the angle of the table is in 2 pixel steps
	add ax,bx
	add ax,ball_table_z_offset<<ball_precision ; offset because negative z
	cmp word [ball_x_pos],ax ; reached right bounds?
	jl .left_bounds ; if not, check for left bounds
	mov byte [ball_out_x],1 ; out of right bounds
.left_bounds:
	mov ax,table_x+table_top_edge<<ball_precision ; bx already contains the shifted z pos
	;mov bx,[ball_z_pos]
	;shl bx,1
	sub ax,bx
	sub ax,ball_table_z_offset<<ball_precision
	cmp word [ball_x_pos],ax
	jg .y
	mov byte [ball_out_x],1 ; out of left bounds
.y:
	movzx ax,[ball_weight] ; ball's still in bounds
	add word [ball_y_vel],ax ; increase y vel
	mov ax,[ball_y_vel]
	add word [ball_y_pos],ax ; increase y pos based on y vel
	cmp byte [ball_out],0 ; is ball out?
	jne .y_bottom_check ; if so, do some different y checks
	; get ball bounce y
	mov ax,ball_bounce_y_base
	add ax,[ball_z_pos]
	cmp word [ball_y_pos],ax ; has the ball hit the table?
	jl .bounce_skip ; if not, skip
	; work out bounciness based on the base value (always in ball_bounceness) and the z pos. only in ax, temporarily
	mov ax,[ball_z_pos] ; remember, a higher bounciness makes the ball... bounce higher
	sar ax,4 ; reduce the z pos first (by some value)
	add ax,ball_bounceness_base
	neg ax
	mov word [ball_bounceness],ax
	mov word [ball_y_vel],ax
	mov si,table_sfx
	call beep_play_sfx
	jmp .bounce_skip
.y_bottom_check:
	cmp word [ball_y_pos],200<<ball_precision ; reached bottom of screen?
	jl .bounce_skip ; if not, skip
	call bat_score
	call ball_reset
	cmp byte [game_over],0 ; bat_score determines if game_over is true or not
	jne .end ; if the game is over, skip the rest of this code!
	mov byte [ball_served],0
	mov si,out_sfx
	call beep_play_sfx
.bounce_skip:
	; bat collision detection
	cmp byte [ball_out],0 ; skip collision checks if ball is out
	jne .end
	mov ax,[ball_x_pos] ; get ball collision stuff ready
	shr ax,ball_precision
	mov word [bgl_collision_x2],ax
	mov ax,[ball_y_pos]
	shr ax,ball_precision
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],ball_size
	mov word [bgl_collision_h2],ball_size
	
	cmp byte [bat_batting],0 ; player 1 batting?
	je .bat_1_batting ; if so, check for player 2's collisions
	cmp word [ball_z_pos],ball_z_bat ; player 2 is batting, check for player 1's collisions
	jl .end
	mov ax,[bat_1_x_pos] ; ball/bat checks
	add ax,bat_1_collision_padding_x
	mov word [bgl_collision_x1],ax
	mov ax,[bat_1_y_pos]
	add ax,bat_collision_padding_y
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],bat_1_width-bat_1_collision_padding_x
	mov word [bgl_collision_h1],bat_1_height-bat_collision_padding_y-bat_1_handle_height
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0 ; collided?
	je .end ; if not, do nothing
	mov byte [bat_batting],0 ; player 1 is now batting
	mov ax,[bat_1_x_pos]
	add ax,bat_1_width/2
	shl ax,ball_precision
	sub ax,[ball_x_pos]
	sar ax,4 ; reduce the speed
	neg ax
	mov word [ball_x_vel],ax
	
	;mov ax,[ball_y_pos] ; make the ball bounce higher depending on bat y
	;shr ax,ball_precision
	;sub ax,[bat_1_y_pos]
	;shl ax,1
	;mov word [ball_y_vel],ax
	
	mov si,bat_1_sfx
	call beep_play_sfx
	jmp .end
.bat_1_batting:
	cmp word [ball_z_pos],0-ball_z_bat
	jg .end ; not reached, do nothing
	mov ax,[bat_2_x_pos] ; is it touching the bat?
	add ax,bat_2_collision_padding_x
	mov word [bgl_collision_x1],ax
	mov ax,[bat_2_y_pos]
	add ax,bat_collision_padding_y
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],bat_2_width-bat_2_collision_padding_x
	mov word [bgl_collision_h1],bat_2_height-bat_collision_padding_y-bat_2_handle_height
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0
	je .end ; not collided, do nothing
	mov byte [bat_batting],-1 ; because every not toggles the flag
	mov ax,[bat_2_x_pos] ; change ball x vel based on where the bat iz, y'all.
	add ax,bat_2_width/2
	shl ax,ball_precision
	sub ax,[ball_x_pos]
	sar ax,5 ; reduce the speed
	mov word [ball_x_vel],ax
	
	mov si,bat_2_sfx
	call beep_play_sfx
	jmp .end
.not_served:
	mov ax,[bat_1_x_pos]
	add ax,bat_1_width/2
	sub ax,ball_size/2
	add ax,320/2
	shl ax,ball_precision
	shr ax,1
	mov word [ball_x_pos],ax
.end:
	ret
	
ball_reset:
	mov word [ball_x_pos],((320/2)-(ball_size/2)-4)<<ball_precision
	mov word [ball_y_pos],80<<ball_precision
	mov word [ball_z_pos],0
	mov word [ball_y_vel],0
	mov word [ball_x_vel],0
	mov word [ball_bounceness],4<<ball_precision
	mov word [ball_rotation],0
	mov byte [ball_out_x],0
	mov byte [ball_out_z],0
	mov byte [bat_batting],0 ; you always serve, wrong rules, might change it sometime, but i'm not fussed, sall a bit of fun innit
	ret
	
ball_serve_handler:
	cmp byte [game_over],0
	jne .end
	mov ax,3
	int 33h
	cmp bx,1 ; left button clicked?
	jne .end ; if not, do nothing
	cmp byte [ball_served],1 ; left button clicked, check if served already
	je .end ; if served, do nothing
	mov ax,[bat_1_x_pos] ; make sure ball's touching the bat
	mov word [bgl_collision_x1],ax
	add ax,bat_1_collision_padding_x
	mov ax,[bat_1_y_pos]
	add ax,bat_collision_padding_y ; hitbox leniance (empty space at the top of the bat)
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],bat_1_width-bat_1_collision_padding_x
	mov word [bgl_collision_h1],bat_1_height-bat_collision_padding_y
	mov ax,[ball_x_pos]
	shr ax,ball_precision
	mov word [bgl_collision_x2],ax
	mov ax,[ball_y_pos]
	shr ax,ball_precision
	mov word [bgl_collision_y2],ax
	mov word [bgl_collision_w2],ball_size
	mov word [bgl_collision_h2],ball_size
	call bgl_collision_check
	cmp byte [bgl_collision_flag],0 ; well? are they touching? HMMM?? WELL, ARE THEY, PUNK??? ARE THEY??!?!?
	je .end
	mov byte [ball_served],1 ; serve the ball
	mov ax,[ball_y_pos] ; make the ball bounce higher if it's closer to the top of the bat, lower if closer to bottom
	shr ax,ball_precision ; using ball y first, because it needs to be shifted - then we can add/subtract the value that doesn't need to be shifted to/from it
	sub ax,[bat_1_y_pos]
	shl ax,3 ; make the ball bounce higher/lower
	mov word [ball_y_vel],ax

	mov ax,320/2 ; set x vel based on the positioning of your paddle
	sub ax,[bat_1_x_pos]
	add ax,bat_1_width/4
	sar ax,5
	shl ax,ball_precision ; and then for the precision
	mov word [ball_x_vel],ax
.end:
	ret
	
ball_draw:
	cmp byte [game_over],0
	jne .end

	; IUMPERTENT:::: the ball x and y are shifted to the left for accuracy. make sure to shift back!
	mov ax,[ball_x_pos]
	shr ax,ball_precision
	mov word [bgl_x_pos],ax
	mov ax,[ball_y_pos]
	shr ax,ball_precision
	mov word [bgl_y_pos],ax
	
	; determine which graphic to use based on z pos
	mov ax,ball_6_gfx
	cmp word [ball_z_pos],-40
	jg .gfx_skip_1
	mov ax,ball_5_gfx
	jmp .gfx_end
.gfx_skip_1:
	cmp word [ball_z_pos],-10
	jg .gfx_skip_2
	mov ax,ball_4_gfx
	jmp .gfx_end
.gfx_skip_2:
	cmp word [ball_z_pos],10
	jg .gfx_skip_3
	mov ax,ball_3_gfx
	jmp .gfx_end
.gfx_skip_3:
	cmp word [ball_z_pos],50
	jg .gfx_skip_4
	mov ax,ball_2_gfx
	jmp .gfx_end
.gfx_skip_4:
	mov ax,ball_1_gfx
.gfx_end:
	mov word [bgl_buffer_offset],ax
	mov ax,[ball_rotation]
	mov word [bgl_rotate_angle],ax
	call bgl_draw_gfx_rotate
.end:
	ret

ball_served db 0
ball_x_pos dw 0
ball_y_pos dw 0
ball_z_pos dw 0 ; phew, here's a new one - because we're working in a 3d space, we'll need 3 dimensions (duh) so we got the x and y (horiz and vert positions), and then z, which is how far or close the ball is. this also decides the size of the ball
ball_rotation dw 0
ball_y_vel dw 0 ; using all words to make life easier
ball_bounceness dw 0 ; how high the ball bounces
ball_x_vel dw 0
ball_weight db 2 ; higher values, heavier ball
ball_x_vel_add_timer db 0 ; keeps increasing, when it reaches an amount, add some swerve
ball_out_x db 0
ball_out_z db 0
ball_out db 0

ball_precision equ 4 ; any time this isn't used in a BitShit Operation and the value happens to match, it's not being used for precision, it's being used for its own thing
ball_bounce_y_base equ 123<<ball_precision ; more like the table y... this is added to/subtracted from depending on how far away the ball is
ball_bounceness_base equ 3<<ball_precision
ball_z_speed equ 5
ball_z_bat equ 110
ball_z_out equ 300 ; don't be suPROYsed, for this value is higher than you'd expect
ball_size equ 13 ; covers both width and height
ball_table_z_offset equ 32 ; to compensate for the negative z values