
	org 100h
	
	call bgl_init
menu:
	mov byte [bgl_no_bounds],1
	
.loop:
	call draw_gradient
	
	mov word [bgl_x_pos],64
	mov word [bgl_y_pos],10
	
	mov word [bgl_font_offset],font_gfx
	mov byte [bgl_font_size],24
	mov byte [bgl_font_spacing],22
	
	mov word [bgl_font_string_offset],intro_string_1
	call bgl_draw_font_string
	mov word [bgl_x_pos],54
	add word [bgl_y_pos],24
	mov word [bgl_font_string_offset],intro_string_2
	call bgl_draw_font_string
	
	mov word [bgl_x_pos],2
	add word [bgl_y_pos],40
	mov word [bgl_font_string_offset],intro_string_3
	call bgl_draw_font_string
	add word [bgl_y_pos],24
	mov word [bgl_font_string_offset],intro_string_4
	call bgl_draw_font_string
	add word [bgl_y_pos],24
	mov word [bgl_font_string_offset],intro_string_5
	call bgl_draw_font_string
	mov word [bgl_x_pos],8
	add word [bgl_y_pos],48
	mov word [bgl_font_string_offset],intro_string_6
	call bgl_draw_font_string
	
	call bgl_wait_retrace
	call fade_in
	call bgl_write_buffer_fast
	
	inc word [gradient_offset]
	
	cmp byte [bgl_key_states+2],1
	je scaling
	cmp byte [bgl_key_states+3],1
	je rotation
	cmp byte [bgl_key_states+4],1
	je hundred
	cmp byte [bgl_key_states+1],1
	je exit
	jmp .loop
	
scaling:
	mov byte [faded],0
	mov word [scale_sine_index],0
	mov word [scale_sine_index_2],0
	xor bx,bx
.loop:
	mov al,17
	mov di,0
	mov cx,(320*70)/2
	call bgl_flood_fill_fast
	
	mov cx,0
	mov di,320*70
	xor al,al
.gradient_loop:
	push ax
	shr al,1
	add al,17
	stosb
	pop ax
	inc cx
	cmp cx,320
	jb .gradient_loop
	xor cx,cx
	inc al
	cmp al,14*2
	jb .gradient_loop
	
	mov al,30
	mov di,320*98
	mov cx,64000
	call bgl_flood_fill
	
	mov ax,[scale_sine_index]
	mov bx,360*2
	xor dx,dx
	div bx
	mov bx,dx
	
	mov byte [bgl_scale_centre],1
	movsx eax,word [wave_table_deg+bx]
	sar ax,2
	add ax,rotation_centre_x_pos
	mov word [bgl_x_pos],ax
	
	add bx,90*2
	mov ax,bx
	mov bx,360*2
	xor dx,dx
	div bx
	mov bx,dx
	movsx eax,word [wave_table_deg+bx]
	push eax
	sar eax,4
	mov dword [bgl_scale_x],eax
	mov dword [bgl_scale_y],eax
	mov word [bgl_y_pos],rotation_centre_y_pos-16
	mov word [bgl_buffer_offset],rotation_gfx
	call bgl_draw_gfx_scale
	
	mov word [bgl_x_pos],(320/2)-(32/2)
	pop eax
	sar eax,2
	add word [bgl_x_pos],ax
	mov ax,[scale_sine_index_2]
	mov bx,360*2
	xor dx,dx
	div bx
	mov bx,dx
	
	mov ax,[wave_table_deg+bx]
	sar ax,3
	add ax,(200/2)-(32/2)
	mov word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],scale_gfx

	add bx,90*2
	mov ax,bx
	mov bx,360*2
	xor dx,dx
	div bx
	mov bx,dx	
	movsx eax,word [wave_table_deg+bx]
	sar eax,5
	mov dword [bgl_scale_x],eax
	mov dword [bgl_scale_y],eax
	;mov dword [bgl_scale_y],eax
	call bgl_draw_gfx_scale
	
	call bgl_wait_retrace
	call fade_in
	
	add word [scale_sine_index],6
	add word [scale_sine_index_2],8
	
	cmp byte [bgl_key_states+1],0
	je .end
	mov byte [faded],0
	jmp menu
.end:
	call bgl_write_buffer_fast
	jmp .loop
	
rotation:

	mov byte [faded],0
	mov word [rotation_x_pos],0
	mov word [rotation_x_pos+2],64
	;mov word [rotation_y_pos],0
	;mov word [rotation_y_pos+2],10
	mov word [rotation_x_vel],2
	mov word [rotation_x_vel+2],3
	mov word [rotation_y_vel],0
	mov word [rotation_y_vel+2],0
	mov word [rotation_bounciness],-30
	mov word [rotation_bounciness+2],-26
	mov word [rotation_angle],0
	mov byte [rotation_moving_left],0
.loop:
	mov al,1
	call bgl_flood_fill_full
	
	;mov word [bgl_buffer_offset],bgl_full_gfx
	;call bgl_draw_full_gfx_rle

	mov word [bgl_buffer_offset],rotation_gfx
	mov word [bgl_x_pos],rotation_centre_x_pos
	mov word [bgl_y_pos],rotation_centre_y_pos
	mov ax,3
	int 33h
	neg cx
	sub cx,16
	mov word [bgl_rotate_angle],cx
	call bgl_draw_gfx_rotate
	
	mov bx,0
	mov word [bgl_buffer_offset],rotation2_gfx
.draw_loop:
	mov ax,[rotation_x_pos+bx]
	mov word [bgl_x_pos],ax
	;mov word [bgl_collision_x1],ax
	mov ax,[rotation_y_pos+bx]
	mov word [bgl_y_pos],ax
	;mov word [bgl_collision_y1],ax
	mov ax,[rotation_angle+bx]
	mov word [bgl_rotate_angle],ax
	call bgl_draw_gfx_rotate
	
	;mov word [bgl_collision_w1],48
	;mov word [bgl_collision_h1],48
	;mov word [bgl_collision_x2],rotation_centre_x_pos
	;mov word [bgl_collision_y2],rotation_centre_y_pos
	;mov word [bgl_collision_w2],64
	;mov word [bgl_collision_h2],64
	;call bgl_collision_check
	;cmp byte [bgl_collision_flag],0
	;je .collision_skip
	;cmp word [rotation_y_pos+bx],rotation_centre_y_pos-48
	;jle .bounce_vertical
	;cmp word [rotation_y_pos+bx],rotation_centre_y_pos+64
	;jge .bounce_vertical
	;jmp .collision_skip
	
;.bounce_vertical:
;	neg word [rotation_y_vel+bx]
;.collision_skip:
	
	mov ax,[rotation_x_vel+bx]
	shl ax,1
	sub word [rotation_angle+bx],ax
	cmp word [rotation_moving_left+bx],0
	mov ax,[rotation_x_vel+bx]
	je .move_right
	sub word [rotation_x_pos+bx],ax
	cmp word [rotation_x_pos+bx],ax
	jg .y_vel
	mov word [rotation_moving_left+bx],0
	jmp .y_vel
.move_right:
	add word [rotation_x_pos+bx],ax
	cmp word [rotation_x_pos+bx],320-48-2
	jl .y_vel
	mov word [rotation_moving_left+bx],1
.y_vel:
	mov ax,[rotation_y_vel+bx]
	sar ax,2
	add word [rotation_y_pos+bx],ax
	inc word [rotation_y_vel+bx]
	cmp word [rotation_y_pos+bx],200-48
	jl .draw_end
	mov word [rotation_y_pos+bx],200-48
	mov ax,[rotation_bounciness+bx]
	mov word [rotation_y_vel+bx],ax
.draw_end:
	cmp bx,2
	je .end
	add bx,2
	jmp .draw_loop

.end:
	
	mov word [bgl_font_offset],font_gfx
	mov word [bgl_x_pos],4
	mov word [bgl_y_pos],4
	mov word [bgl_font_string_offset],rotation_string
	mov byte [bgl_font_size],24
	mov byte [bgl_font_spacing],21
	call bgl_draw_font_string

	call bgl_wait_retrace
	call fade_in
	
	cmp byte [bgl_key_states+1],0
	je .end_skip
	mov byte [faded],0
	jmp menu
.end_skip:
	call bgl_write_buffer_fast
	jmp .loop
	
hundred:
	mov byte [faded],0
	
	xor bx,bx
	mov word [obj_spawn_timer],0
	mov word [obj_current],0
.init_loop:
	cmp bx,obj_amount
	je .init_loop_end
	push bx
	shl bx,1
	mov word [obj_x_pos+bx],0
	mov word [obj_y_pos+bx],0
	mov word [obj_active+bx],0
	mov word [obj_moving_left+bx],0
	mov word [obj_moving_up+bx],0
	pop bx
	inc bx
	jmp .init_loop
	
.init_loop_end:
	mov word [obj_active],1
	
.loop:
	;mov word [bgl_buffer_offset],bgl_full_gfx
	;call bgl_draw_full_gfx_rle
	mov al,8
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast

	mov word [bgl_buffer_offset],obj_gfx
	xor bx,bx
.draw_loop:
	cmp word [obj_active+bx],0
	je .draw_loop_inactive
	mov ax,[obj_x_pos+bx]
	mov word [bgl_x_pos],ax
	mov ax,[obj_y_pos+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast
	
.move_left:
	cmp word [obj_moving_left+bx],0
	je .move_right
	sub word [obj_x_pos+bx],obj_speed
	cmp word [obj_x_pos+bx],0
	jg .move_up
	mov word [obj_moving_left+bx],0
	jmp .move_up
.move_right:
	add word [obj_x_pos+bx],obj_speed
	cmp word [obj_x_pos+bx],320-12
	jl .move_up
	mov word [obj_moving_left+bx],1
.move_up:
	cmp word [obj_moving_up+bx],0
	je .move_down
	sub word [obj_y_pos+bx],obj_speed
	cmp word [obj_y_pos+bx],0
	jg .draw_loop_inactive
	mov word [obj_moving_up+bx],0
	jmp .draw_loop_inactive
.move_down:
	add word [obj_y_pos+bx],obj_speed
	cmp word [obj_y_pos+bx],200-12
	jl .draw_loop_inactive
	mov word [obj_moving_up+bx],1
	
.draw_loop_inactive:
	cmp bx,(obj_amount-1)*2
	je .draw_loop_end
	add bx,2
	jmp .draw_loop
	
.draw_loop_end:
	inc word [obj_spawn_timer]
	
	cmp word [obj_spawn_timer],20
	jb .draw_loop_end_skip
	mov word [obj_spawn_timer],0
	cmp word [obj_current],100-1
	je .draw_loop_end_skip
	inc word [obj_current]
	mov bx,[obj_current]
	shl bx,1
	mov word [obj_active+bx],1
	mov word [obj_x_pos+bx],0
	mov word [obj_y_pos+bx],0
	
.draw_loop_end_skip:
	mov word [bgl_x_pos],20*2
	mov word [bgl_y_pos],0
	xor cx,cx
	mov ax,[obj_current]
	inc ax
	push ax ;;
.count_loop:
	mov bx,10
	pop ax ;;
	xor dx,dx
	div bx
	push ax ;;;
	mov ax,dx
	add ax,15
	mov bx,(24*24)+2
	mul bx
	mov bx,ax
	mov word [bgl_buffer_offset],font_gfx
	add word [bgl_buffer_offset],bx
	call bgl_draw_gfx_fast
	sub word [bgl_x_pos],20
	
.count_loop_skip2:
	inc cl
	cmp cl,3
	jne .count_loop

	pop ax ;;;
	call bgl_wait_retrace
	call fade_in
	cmp byte [bgl_key_states+1],0
	je .end
	mov byte [faded],0
	jmp menu
.end:
	call bgl_write_buffer_fast
	jmp .loop
	
exit:
	xor al,al
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	mov byte [faded],0
	call fade_in
	call bgl_reset
	
draw_gradient:
	push ax
	push dx
	push bx
	push cx
	push di
	
	xor cx,cx
	xor di,di
	mov ax,[gradient_offset]
	xor dx,dx
	mov bx,96
	div bx
	mov ax,dx
.loop:
	push ax
	mov bx,96
	xor dx,dx
	div bx
	mov ax,dx
	shr al,2
	add al,104
	mov ah,al
	stosw
	pop ax
	inc cx
	cmp cx,320
	jb .loop
	xor cx,cx
	inc ax
	cmp di,64000
	jb .loop
	
	pop di
	pop cx
	pop bx
	pop dx
	pop ax
	ret
	
fade_in:
	cmp byte [faded],0
	jne .end
	call bgl_pseudo_fade
	mov byte [faded],1
.end:
	ret
	
font_gfx:
%include "bgl_font.asm"

%include "bgl.asm"

faded db 0
gradient_offset dw 0

rotation_amount equ 2
rotation_angle dw 0,0
rotation_x_pos dw 0,0
rotation_y_pos dw 0,0
rotation_x_vel dw 0,0
rotation_y_vel dw 0,0
rotation_bounciness dw 0,0
rotation_moving_left dw 0,0
rotation_gfx: incbin "prezzo.gfx"
rotation2_gfx: incbin "birz.gfx"
rotation_string: db "MOVE THE MOUSE!",0
rotation_centre_x_pos equ (320/2)-(64/2)
rotation_centre_y_pos equ (200/2)-(64/2)

intro_string_1: db "BGL DEMO",0
intro_string_2: db "BY PREZZO",0
intro_string_3: db "1) SCALING",0
intro_string_4: db "2) ROTATION",0
intro_string_5: db "3) 100 OBJECTS",0
intro_string_6: db "PRESS A KEY...",0
;bgl_full_gfx: incbin "bgl_full.rle"

obj_amount equ 100
obj_speed equ 1
obj_gfx: incbin "bloke_small.gfx"
obj_x_pos times obj_amount dw 0
obj_y_pos times obj_amount dw 0
obj_moving_left times obj_amount dw 0
obj_moving_up times obj_amount dw 0
obj_active times obj_amount dw 0
obj_spawn_timer dw 0
obj_current dw 0

scale_sine_index dw 0
scale_sine_index_2 dw 0
scale_gfx: incbin "engineer.gfx"