bumper_other_x_pos dw 0
bumper_other_y_pos dw 90
bumper_other_x_vel dw 0 ; these will always be positive
bumper_other_y_vel dw 0 ; -'-
bumper_other_speed dw 3,2,6,5 ; for each type
bumper_other_moving_up db 0
bumper_other_facing_left db 0
bumper_other_moving_left db 0
bumper_other_hit_points_default db 4,3,2,5 ; for each type
bumper_other_hit_points db 0
bumper_other_type db 0
bumper_other_next_type db 0 ; pseudo random numbers, increasing on every frame
bumper_other_next_y_pos dw 0 ; same here
bumper_other_next_right db 0 ; decides whether the next bumper spawns at the right of the screen
bumper_other_y_neg_chance db 0 ; increases constantly, never resetting. negates "moving up" when it reaches a value

bumper_other_gfx: ; each one is 1,538 bytes large
	incbin "bumper_cool.gfx"
	incbin "bumper_dog.gfx"
	incbin "bumper_woah.gfx"
	incbin "bumper_rye.gfx"
bumper_cool_2_gfx:
	incbin "bumper_cool_2.gfx"

; this bumper doesn't require initializing, it'll always be moving no matter what!

bumper_other_draw:
	inc byte [bumper_other_y_neg_chance]
	cmp byte [bumper_other_y_neg_chance],70 ; any number really
	jne .y_neg_skip
	not byte [bumper_other_moving_up]
	mov byte [bumper_other_y_neg_chance],0
	
.y_neg_skip:
	mov al,[bumper_other_next_right]
	inc al
	and al,1
	mov byte [bumper_other_next_right],al

	mov al,[bumper_other_next_type] ; "random number generator"
	inc al
	and al,3
	mov byte [bumper_other_next_type],al
	
	cmp word [bumper_other_next_y_pos],0 ; next y 0?
	jne .next_y_pos_skip ; if not, skip
	mov ax,[road_start_y]
	mov word [bumper_other_next_y_pos],ax
	jmp .next_y_pos_skip2
.next_y_pos_skip:
	inc word [bumper_other_next_y_pos]
	cmp word [bumper_other_next_y_pos],200-32 ; next y reached bottom?
	jne .next_y_pos_skip2 ; if not, skip
	mov ax,[road_start_y]
	mov word [bumper_other_next_y_pos],ax

.next_y_pos_skip2:
	mov byte [bgl_opaque],0
	xor bx,bx ; get x vel for this type
	mov bl,[bumper_other_type]
	shl bx,1
	
	mov ax,[bumper_amount_hit]
	shr ax,4 ; make the speed increase GRADUAL...
	add ax,[bumper_other_speed+bx]
	mov word [bumper_other_x_vel],ax

	mov al,[bumper_other_facing_left]
	mov byte [bgl_flip],al
	;mov al,[bgl_collision_flag]
	;mov byte [bgl_erase],al
	mov byte [bgl_erase],0
	
	cmp byte [bumper_other_type],0 ; is the bumper driver Coooool?
	jne .skip ; if not, skip
	cmp byte [bumper_collision_flag],0 ; is the other bumper hit?
	je .skip ; if not, skip
	mov ax,bumper_cool_2_gfx
	jmp .skip2
.skip:
	xor ax,ax ; get graphic for this type
	mov al,[bumper_other_type]
	mov bx,1538
	mul bx ; ax*=bx
	mov bx,ax
	mov ax,bumper_other_gfx
	add ax,bx
.skip2:
	mov word [bgl_buffer_offset],ax
	;mov al,[background_colour]
	;mov byte [bgl_background_colour],al
	mov ax,[bumper_other_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[bumper_other_y_pos]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx
	
	ret
	
bumper_other_movement:
	mov ax,[bumper_other_y_vel]
	cmp byte [bumper_other_moving_up],0 ; moving up?
	jne .skip ; if not, skip
	add word [bumper_other_y_pos],ax
	jmp .bound_check

.skip:
	sub word [bumper_other_y_pos],ax

.bound_check:
	cmp word [bumper_other_y_pos],200-32 ; reached the bottom of the screen? (-height)
	jl .bound_check_skip ; if not, skip
	mov byte [bumper_other_moving_up],-1
	mov si,bound_hit_sfx
	call beep_play_sfx
	
.bound_check_skip:
	mov ax,[road_start_y]
	sub ax,16 ; half the height
	cmp word [bumper_other_y_pos],ax ; reached the top?
	jg .bound_check_skip2 ; if not, skip
	mov byte [bumper_other_moving_up],0
	mov si,bound_hit_sfx
	call beep_play_sfx

.bound_check_skip2:
	mov ax,[bumper_other_x_vel]
	cmp byte [bumper_other_moving_left],0 ; moving left?
	jne .skip2 ; if not, skip
	add word [bumper_other_x_pos],ax
	jmp .skip3
.skip2:
	sub word [bumper_other_x_pos],ax
.skip3:
	mov ax,[bumper_pres_x_vel]
	cmp byte [bumper_pres_moving_left],0 ; am i moving left?
	jne .skip4 ; if not, skip
	sub word [bumper_other_x_pos],ax
	jmp .skip5
.skip4:
	add word [bumper_other_x_pos],ax
.skip5:
	cmp word [bumper_other_x_pos],320 ; reached right of screen?
	jl .bound_check_skip3
	mov word [bumper_other_x_pos],-48
	mov byte [bumper_other_next_right],0 ; spawn at left
	call bumper_other_spawn_next
	
.bound_check_skip3:
	cmp word [bumper_other_x_pos],-48 ; reached left of screen?
	jge .skip_end
	mov word [bumper_other_x_pos],320
	mov byte [bumper_other_next_right],1 ; spawn at right
	call bumper_other_spawn_next
	
.skip_end:
	ret
	
bumper_other_spawn_next:
	mov al,[bumper_other_next_type]
	mov byte [bumper_other_type],al
	xor bx,bx
	mov bl,al
	mov al,[bumper_other_hit_points_default+bx]
	mov byte [bumper_other_hit_points],al
	
	mov ax,[bumper_other_next_y_pos]
	mov word [bumper_other_y_pos],ax
	
	mov word [bumper_other_y_vel],1
	mov ax,[bumper_other_next_y_pos] ; randomize the y vel
	and ax,7
	shr ax,1
	add word [bumper_other_y_vel],ax
	
	mov ax,[bumper_other_y_vel] ; base the "moving up" off the y vel
	and ax,1
	shl ax,8 ; make it ff because that's how it works
	mov byte [bumper_other_moving_up],al
	
	cmp byte [bumper_other_next_right],0 ; spawning at right of screen?
	jne .spawn_left ; if not, skip
	mov word [bumper_other_x_pos],-48
	mov byte [bumper_other_facing_left],0
	mov byte [bumper_other_moving_left],0
	jmp .end
.spawn_left:
	mov word [bumper_other_x_pos],320
	mov byte [bumper_other_facing_left],-1
	mov byte [bumper_other_moving_left],-1
.end:
	ret