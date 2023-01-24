intro:
	mov byte [bumper_pres_active],1
	mov word [bumper_pres_y_pos],200-32
	mov word [bumper_pres_x_pos],0
	mov byte [bumper_pres_facing_left],0
	mov byte [bumper_pres_moving_left],0

	;mov al,0 ; colour index
	;mov dx,3c8h
	;out dx,al
	;inc dx ; go to 3c9h, where you give it the rgb values
	;mov al,11h
	;out dx,al ; r
	;mov al,22h
	;out dx,al ; g
	;mov al,33h
	;out dx,al ; b
	
	;call bgl_get_orig_palette

.loop:
	mov al,0
	call bgl_flood_fill
	;call bgl_fade_in
	
	mov byte [bgl_erase],0
	mov byte [bgl_flip],0
	mov byte [bgl_opaque],0
	
	; find the offsets
	
	mov bx,0
.wave_loop:
	push bx ; save letter offset for later (0, 2, 4 or 6)
	shr bx,1 ; because byte
	add byte [intro_letter_wave_index_y+bx],2
	cmp byte [intro_letter_wave_index_y+bx],62*2 ; reached last index for this letter?
	jb .wave_loop_skip ; if not, continue
	mov byte [intro_letter_wave_index_y+bx],0 ; reset it
.wave_loop_skip:
	
	xor ax,ax
	mov al,[intro_letter_wave_index_y+bx] ; the wave index to read!
	mov bx,ax ; move it to bx so we can use it as an offset
	
	mov ax,[wave_table+bx]
	sar ax,3
	add ax,30
	pop bx ; restore letter offset
	mov word [intro_letter_y_pos+bx],ax

	add bx,2 ; next letter!
	cmp bx,8 ; reached the last letter?
	jb .wave_loop
	
	; draw the letters
	
	mov ax,intro_b_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[intro_letter_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,[intro_letter_x_pos]
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	
	mov ax,intro_p_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[intro_letter_y_pos+2]
	mov word [bgl_y_pos],ax
	mov ax,[intro_letter_x_pos+2]
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	
	mov ax,intro_d_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[intro_letter_y_pos+4]
	mov word [bgl_y_pos],ax
	mov ax,[intro_letter_x_pos+4]
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	
	mov ax,intro_i_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[intro_letter_y_pos+6]
	mov word [bgl_y_pos],ax
	mov ax,[intro_letter_x_pos+6]
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	
	mov ax,intro_space_gfx
	mov word [bgl_buffer_offset],ax
	mov word [bgl_x_pos],100
	mov word [bgl_y_pos],140
	call bgl_draw_gfx
	
.bumper_pres:
	xor ax,ax
	mov al,[bumper_pres_speed]
	cmp byte [bumper_pres_moving_left],0
	jne .bumper_pres_move_left
	add word [bumper_pres_x_pos],ax
	jmp .bumper_pres_right_bounds
	
.bumper_pres_move_left:
	sub word [bumper_pres_x_pos],ax
.bumper_pres_right_bounds:
	cmp word [bumper_pres_x_pos],320-48
	jl .bumper_pres_left_bounds
	mov byte [bumper_pres_facing_left],1
	mov byte [bumper_pres_moving_left],1
	mov si,bound_hit_sfx
	call beep_play_sfx
.bumper_pres_left_bounds:
	cmp word [bumper_pres_x_pos],0
	jg .bumper_pres_end
	mov byte [bumper_pres_facing_left],0
	mov byte [bumper_pres_moving_left],0
	mov si,bound_hit_sfx
	call beep_play_sfx
.bumper_pres_end:
	call bumper_pres_draw

	cmp byte [bgl_key_states+39h],0
	je .space_skip
	jmp game

.space_skip:
	call bgl_write_buffer
	call bgl_wait_retrace
	call beep_handler
	jmp .loop
	
%include "..\wave_table.asm"
intro_letter_spacing equ 72
intro_letter_index_spacing equ 32
intro_letter_wave_index_y db 0,intro_letter_index_spacing,intro_letter_index_spacing*2,intro_letter_index_spacing*3 ; one for each letter
intro_letter_x_pos dw 24,24+intro_letter_spacing,24+(intro_letter_spacing*2),24+(intro_letter_spacing*3)
intro_letter_y_pos dw 0,0,0,0

intro_b_gfx: incbin "intro_b.gfx"
intro_p_gfx: incbin "intro_p.gfx"
intro_d_gfx: incbin "intro_d.gfx"
intro_i_gfx: incbin "intro_i.gfx"
intro_space_gfx: incbin "intro_space.gfx"