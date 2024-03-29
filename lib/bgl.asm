; BGL (best graphics library)
; by: me

; references:
;	http://www.brackeen.com/vga/index.html
; 	https://stackoverflow.com/questions/6560343/double-buffer-video-in-assembler
	
	jmp bgl_end

%define bgl ; used in other libraries to detect!

%ifndef bgl_no_font
	%define bgl_get_font_offset(a,b) b+(((8*8)+2)*(a-33))
	%define bgl_get_font_number_offset(a,b) b+((a+15)*((8*8)+2))
%endif

%ifndef bgl_no_rle
	bgl_rle_word dw 0
%endif
bgl_flip db 0
bgl_erase db 0
bgl_width db 0
bgl_height db 0
bgl_transparent db 0 ; the index used for transparency
bgl_x_pos dw 0
bgl_y_pos dw 0
bgl_buffer_offset dw 0
bgl_background_colour db 0
bgl_opaque db 0
%ifndef bgl_no_collision
	bgl_collision_flag db 0
	bgl_collision_x1 dw 0
	bgl_collision_x2 dw 0
	bgl_collision_y1 dw 0
	bgl_collision_y2 dw 0
	bgl_collision_w1 dw 0
	bgl_collision_w2 dw 0
	bgl_collision_h1 dw 0
	bgl_collision_h2 dw 0
	bgl_collision_debug db 0
	bgl_collision_c1 db 0
	bgl_collision_c2 db 0
%endif
%ifndef bgl_no_keys
	bgl_key_states resb 128
	bgl_key_handler_orig dw 0,0
%endif
bgl_y_clip db 0
bgl_no_bounds db 0
bgl_tint db 0
bgl_mask db 0

%ifndef bgl_no_scale
	bgl_scale_x dd 0
	bgl_scale_y dd 0
	bgl_scale_factor_width dd 0
	bgl_scale_factor_height dd 0
	bgl_scale_width dw 0
	bgl_scale_height dw 0
	bgl_scale_centre db 0
	bgl_scale_square db 0

	bgl_scale_precision equ 8
%endif

%ifndef bgl_no_rotate
	bgl_rotate_angle dw 0
	bgl_rotate_angle_sin dw 0
	bgl_rotate_angle_cos dw 0
	bgl_rotate_x_centre dw 0
	bgl_rotate_y_centre dw 0
	bgl_rotate_x_adjusted dw 0
	bgl_rotate_y_adjusted dw 0
	bgl_rotate_width db 0
	bgl_rotate_height db 0
	bgl_rotate_x_counter db 0
	bgl_rotate_y_counter db 0
	bgl_rotate_scale db 0
	bgl_rotate_bounds db 0
%endif

%ifndef bgl_no_font
	bgl_font_offset dw 0
	bgl_font_size db 0
	bgl_font_spacing db 0
	bgl_font_string_offset dw 0
%endif

%ifndef bgl_no_joypad
	bgl_joypad_states_1 db 00000000b
	bgl_joypad_states_2 db 00000000b
%endif

%ifndef bgl_no_keys
	bgl_key_escape equ 01h
	bgl_key_1 equ 02h
	bgl_key_2 equ 03h
	bgl_key_3 equ 04h
	bgl_key_4 equ 05h
	bgl_key_5 equ 06h
	bgl_key_6 equ 07h
	bgl_key_7 equ 08h
	bgl_key_8 equ 09h
	bgl_key_9 equ 0ah
	bgl_key_0 equ 0bh
	bgl_key_minus equ 0ch
	bgl_key_equals equ 0dh
	bgl_key_backspace equ 0eh
	bgl_key_tab equ 0fh
	bgl_key_q equ 10h
	bgl_key_w equ 11h
	bgl_key_e equ 12h
	bgl_key_r equ 13h
	bgl_key_t equ 14h
	bgl_key_y equ 15h
	bgl_key_u equ 16h
	bgl_key_i equ 17h
	bgl_key_o equ 18h
	bgl_key_p equ 19h
	bgl_key_leftbracket equ 1ah
	bgl_key_rightbracket equ 1bh
	bgl_key_enter equ 1ch
	bgl_key_control equ 1dh
	bgl_key_a equ 1eh
	bgl_key_s equ 1fh
	bgl_key_d equ 20h
	bgl_key_f equ 21h
	bgl_key_g equ 22h
	bgl_key_h equ 23h
	bgl_key_j equ 24h
	bgl_key_k equ 25h
	bgl_key_l equ 26h
	bgl_key_semicolon equ 27h
	bgl_key_quote equ 28h
	bgl_key_tilde equ 29h
	bgl_key_lshift equ 2ah
	bgl_key_backslash equ 2bh
	bgl_key_z equ 2ch
	bgl_key_x equ 2dh
	bgl_key_c equ 2eh
	bgl_key_v equ 2fh
	bgl_key_b equ 30h
	bgl_key_n equ 31h
	bgl_key_m equ 32h
	bgl_key_comma equ 33h
	bgl_key_period equ 34h
	bgl_key_slash equ 35h
	bgl_key_rshift equ 36h
	bgl_key_multiply equ 37h
	bgl_key_alt equ 38h
	bgl_key_space equ 39h
	bgl_key_capslock equ 3ah
	bgl_key_f1 equ 3bh
	bgl_key_f2 equ 3ch
	bgl_key_f3 equ 3dh
	bgl_key_f4 equ 3eh
	bgl_key_f5 equ 3fh
	bgl_key_f6 equ 40h
	bgl_key_f7 equ 41h
	bgl_key_f8 equ 42h
	bgl_key_f9 equ 43h
	bgl_key_f10 equ 44h
	bgl_key_numlock equ 45h
	bgl_key_scrolllock equ 46h
	bgl_key_home equ 47h
	bgl_key_up equ 48h
	bgl_key_pageup equ 49h
	bgl_key_left equ 4bh
	bgl_key_right equ 4dh
	bgl_key_plus equ 4eh
	bgl_key_end equ 4fh
	bgl_key_down equ 50h
	bgl_key_pagedown equ 51h
	bgl_key_insert equ 52h
	bgl_key_delete equ 53h
	bgl_key_f11 equ 57h
	bgl_key_f12 equ 58h
%endif
	
%ifdef blaster
bgl_blaster_visualize:
	push cx
	push dx
	push si
	push di
	
	xor cx,cx
	mov si,blaster_mix_buffer
.loop:
	cmp cx,0
	jl .skip
	cmp cx,320
	jge .skip
	movzx dx,[si]
	sub dx,28
	call bgl_get_x_y_offset
	mov byte [es:di],al
.skip:
	inc cx
%ifdef blaster_mix_rate_11025
	add si,1
%endif
%ifdef blaster_mix_rate_22050
	add si,3
%endif
%ifdef blaster_mix_rate_44100
	add si,7
%endif
	cmp si,blaster_mix_buffer+blaster_mix_buffer_size
	jb .loop
	
	pop di
	pop si
	pop dx
	pop cx
	ret
%endif
	
bgl_draw_box_fast:
	push bx
	push cx
	push dx

	; width and height are divided by 4 for speed, and boundary checks are skipped
	
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	xor cx,cx
	xor dx,dx
	call bgl_spread_8_32
	
	cmp byte [bgl_width],4
	jae .loop
	mov byte [bgl_width],4
	cmp byte [bgl_height],4
	jae .loop
	mov byte [bgl_height],4
	
.loop:
	
	push di
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	pop di

	inc di
	inc cl
	mov bl,[bgl_width]
	sub bl,3
	cmp cl,bl
	jb .skip
	xor cl,cl
	add di,320
	sub di,bx
	inc dl
	mov bl,[bgl_height]
	sub bl,3
	cmp dl,bl
	jae .end
.skip:
	jmp .loop
.end:
	pop dx
	pop cx
	pop bx
	ret
	
bgl_draw_box:
	push bx
	push cx
	push dx

	; bgl_x_pos = x
	; bgl_y_pos = y
	; bgl_width = width
	; bgl_height = height
	; al = colour
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	xor cx,cx
	xor dx,dx
.loop:
	push cx
	push dx
	add cx,[bgl_x_pos]
	cmp cx,320
	jge .skip
	cmp cx,0
	jl .skip
	add dx,[bgl_y_pos]
	cmp dx,200
	jge .skip
	cmp dx,0
	jl .skip

	push ax
	call bgl_get_mask_value
	mov byte [es:di],al
	pop ax

.skip:
	inc di
	pop dx
	pop cx
	inc cl
	cmp cl,[bgl_width]
	jne .skip2
	xor cl,cl
	movzx bx,[bgl_width]
	add di,320
	sub di,bx
	inc dl
	cmp dl,[bgl_height]
	je .end
.skip2:
	jmp .loop
.end:
	pop dx
	pop cx
	pop bx
	ret
	
bgl_spread_16_32: ; input = ax, output = eax
	push ax
	shl eax,16
	pop ax
	ret
	
bgl_spread_8_16: ; input = al, output = ax
	mov ah,al
	ret
	
bgl_spread_8_32:
	call bgl_spread_8_16
	call bgl_spread_16_32
	ret
	
bgl_extend_8_16:
	push dx
	xor dx,dx
	cbw
	shl dx,8
	add ax,dx
	pop dx
	ret
	
bgl_extend_16_32:
	push edx
	xor edx,edx
	cwd
	shl edx,16
	add eax,edx
	pop edx
	ret
	
bgl_extend_8_32:
	call bgl_extend_8_16
	call bgl_extend_16_32
	ret
	
%ifndef bgl_no_scale
bgl_square: ; eax = number to square, output in eax
	push ebx
	push ecx
	push edx
	cmp eax,0
	jl .negative
	mov edx,eax
	mov ecx,eax
	xor eax,eax
.positive_loop:
	add eax,edx
	loop .positive_loop
	jmp .end
.negative:
	neg eax
	mov edx,eax
	mov ecx,eax
	xor eax,eax
.negative_loop:
	add eax,edx
	loop .negative_loop
	neg eax
.end:
	pop edx
	pop ecx
	pop ebx
	ret
%endif
	
%ifndef bgl_no_wave
bgl_get_sine: ; value in ax, result in ax
	push bx
	push dx
	xor dx,dx
	mov bx,360
	div bx
	mov bx,dx
	shl bx,1
	mov ax,[wave_table_deg+bx]
	pop dx
	pop bx
	ret
	
bgl_get_cosine: ; value in ax, result in ax
	push bx
	push dx
	xor dx,dx
	add ax,90
	mov bx,360
	div bx
	mov bx,dx
	shl bx,1
	mov ax,[wave_table_deg+bx]
	pop dx
	pop bx
	ret
	
bgl_get_sine_255: ; value in ax, result in al
	push bx
	mov bx,ax
	xor bh,bh ; quick way of getting remainder, but limited to 255
	mov al,[wave_table_255+bx]
	pop bx
	ret

bgl_get_cosine_255: ; value in ax, result in al
	push bx
	mov bx,ax
	add bx,63
	xor bh,bh
	mov al,[wave_table_255+bx]
	pop bx
	ret
%endif
	
%ifndef bgl_no_palette
bgl_draw_full_gfx_pal:
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	; get palette
	
	mov si,[bgl_buffer_offset]
	mov dx,3c8h ; palette write - index
	xor al,al
	out dx,al
	
	mov dx,3c9h ; palette write - data
	mov cx,768
	mov bx,64000
.palette_loop:
	mov al,[si]
	mov byte [fs:bx],al
	out dx,al
	inc si
	inc bx
	loop .palette_loop
	
	; draw rle encoded image
	
	xor di,di
.draw_loop_start:
	mov ax,[si] ; get a word, with al containing the index, and ah the amount of times to draw
.draw_loop: ; draw al ah times
	cmp ah,0
	je .draw_end
	mov byte [es:di],al
	inc di
	dec ah
	cmp ah,0
	jne .draw_loop
	
.draw_end:
	add si,2
	cmp di,64000
	jne .draw_loop_start
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bgl_intro:
	push cx
	call bgl_get_orig_palette
	call bgl_draw_full_gfx_pal
	call bgl_write_buffer_fast
	call bgl_fade_in
	mov cx,150
delay:
	call bgl_wait_retrace
	loop delay
	call bgl_fade_out
	call bgl_restore_orig_palette
	pop cx
	ret
%endif
	
%ifndef bgl_no_joypad
bgl_joypad_handler:
	push ax
	push bx
	push cx
	push dx
	
	; http://www.fysnet.net/joystick.htm
	
	; bgl_joypad_states:
	; 87654321
	; --------
	; --21rldu
	
	; directions
	
	mov byte [bgl_joypad_states_1],00000000b
	mov byte [bgl_joypad_states_2],00000000b
	
	mov ah,84h
	mov dx,1
	int 15h
	
	; left
	
	push ax
	push cx
	sub ax,126
	shr ax,15
	shl ax,2
	sub cx,126
	shr cx,15
	shl cx,2
	or byte [bgl_joypad_states_1],al
	or byte [bgl_joypad_states_2],cl
	
	; right
	
	pop cx
	pop ax
	sub ax,160
	shr ax,15
	shl ax,15
	not ax
	shr ax,15
	shl ax,3
	sub cx,160
	shr cx,15
	shl cx,15
	not cx
	shr cx,15
	shl cx,3
	or byte [bgl_joypad_states_1],al
	or byte [bgl_joypad_states_2],cl
	
	; up
	
	push bx
	push dx
	sub bx,126
	shr bx,15
	sub dx,126
	shr dx,15
	or byte [bgl_joypad_states_1],bl
	or byte [bgl_joypad_states_2],dl
	
	; down
	
	pop dx
	pop bx
	sub bx,160
	shr bx,15
	shl bx,15
	not bx
	shr bx,15
	shl bx,1
	sub dx,160
	shr dx,15
	shl dx,15
	not dx
	shr dx,15
	shl dx,1
	
	or byte [bgl_joypad_states_1],bl
	or byte [bgl_joypad_states_2],dl
	mov al,[bgl_joypad_states_1]
	
	; BAH'uns
	
	mov ah,84h
	mov dx,0
	int 15h
	
	; 1
	
	push ax
	and al,00010000b
	shr al,4
	not al
	inc al
	not al
	shr al,7
	shl al,4
	or byte [bgl_joypad_states_1],al
	
	pop ax
	push ax
	and al,01000000b
	shr al,4
	not al
	inc al
	not al
	shr al,7
	shl al,4
	or byte [bgl_joypad_states_2],al
	
	; 2
	
	pop ax
	push ax
	and al,00100000b
	shr al,4
	not al
	inc al
	not al
	shr al,7
	shl al,5
	or byte [bgl_joypad_states_1],al
	
	pop ax
	and al,10000000b
	shr al,4
	not al
	inc al
	not al
	shr al,7
	shl al,5
	or byte [bgl_joypad_states_2],al
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
%endif

%ifndef bgl_no_font
bgl_get_font_number_offset: ; input in ax (number 0-9), font label in bx, result will be in ax
	push dx
	push bx
	add ax,15
	mov bx,(8*8)+2
	xor dx,dx
	mul bx
	pop bx
	add ax,bx
	pop dx
	ret
%endif
	
bgl_pseudo_fade:
	push di
	push cx
	push dx
	push ax
	xor di,di
	xor cx,cx
	xor dx,dx
.first_loop:
	mov al,[es:di]
	mov byte [fs:di],al
	add di,320
	inc dx
	cmp dx,200
	ja .first_loop_skip
	jmp .first_loop
.first_loop_skip:
	push cx
	and cx,2
	cmp cx,0
	pop cx
	je .first_loop_skip2
	call bgl_wait_retrace
.first_loop_skip2:
	add cx,2
	mov di,cx
	xor dx,dx
	cmp cx,320
	jbe .first_loop

	mov cx,319
	mov di,319
.second_loop:
	mov al,[es:di]
	mov byte [fs:di],al
	add di,320
	inc dx
	cmp dx,200
	je .second_loop_skip
	jmp .second_loop
.second_loop_skip:
	push cx
	and cx,2
	cmp cx,0
	pop cx
	je .second_loop_skip2
	call bgl_wait_retrace
.second_loop_skip2:
	sub cx,2
	mov di,cx
	xor dx,dx
	cmp cx,0
	jg .second_loop
.end:
	pop ax
	pop dx
	pop cx
	pop di
	ret
	
%ifndef bgl_no_rotate
%ifndef bgl_no_wave
bgl_draw_gfx_rotate:
	; reference:
	; https://www.codingame.com/playgrounds/2524/basic-image-manipulation/transformation
	; test written in python, "converted over" to assembly by hand

	pusha

	; find sin of angle..
	mov ax,[bgl_rotate_angle]
	mov bx,360
	xor dx,dx
	div bx ; dx = angle % 360
	mov bx,dx
	
	shl bx,1 ; word length
	mov ax,[wave_table_deg+bx]
	mov word [bgl_rotate_angle_sin],ax
	
	; find cos of angle..
	add bx,90*2
	mov ax,bx
	mov bx,360*2
	xor dx,dx
	div bx ; dx = (angle+90) % 360
	mov bx,dx
	
	mov ax,[wave_table_deg+bx]
	mov word [bgl_rotate_angle_cos],ax

	;;;

	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	; get x and y centre points
	
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip
	movzx ax,[bgl_rotate_width]
	shr ax,1
	mov word [bgl_rotate_x_centre],ax
	movzx ax,[bgl_rotate_height]
	shr ax,1
	mov word [bgl_rotate_y_centre],ax
	jmp .bounds_skip2
.bounds_skip:
	movzx ax,[bgl_width]
	shr ax,1
	mov word [bgl_rotate_x_centre],ax
	movzx ax,[bgl_height]
	shr ax,1
	mov word [bgl_rotate_y_centre],ax
.bounds_skip2:
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
	mov byte [bgl_rotate_x_counter],0 ; used for width/height
	mov byte [bgl_rotate_y_counter],0
	xor cx,cx ; cx and dx are used for getting the pixel
	xor dx,dx
.loop:
	push bx
	
	; x
	
	push cx
	push dx
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	xor dx,dx
	mul bx ; x*cos(angle)
	mov cx,ax ; cx = x*cos(angle)
	
	pop bx ; original y counter into bx
	push bx ;;
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; y*sin(angle)
	mov dx,ax ; dx = y*sin(angle)
	sub cx,dx
	
	push bx
	mov ax,[bgl_rotate_x_centre]
	mov bx,360
	sub bx,[bgl_scale_x]
	mul bx
	add cx,ax
	pop bx
	
	mov word [bgl_rotate_x_adjusted],cx
	
	pop dx
	pop cx
	
	; y
	
	push cx
	push dx
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; x*sin(angle)
	mov cx,ax ; cx = x*sin(angle)
	
	pop bx ;; original y counter into bx
	push bx
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	xor dx,dx
	mul bx ; y*cos(angle)
	mov dx,ax ; dx = y*cos(angle)
	add cx,dx
	
	push bx
	mov ax,[bgl_rotate_y_centre]
	mov bx,360
	sub bx,[bgl_scale_x]
	mul bx
	add cx,ax
	pop bx
	
	mov word [bgl_rotate_y_adjusted],cx
	
	mov ax,[bgl_rotate_x_adjusted]
	mov bx,360-1 ; maximum sine value, minus 1
	sub bx,[bgl_scale_x]
	xor dx,dx
	div bx
	mov cx,ax
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip3
	movzx ax,[bgl_rotate_width]
	shr ax,1
	push bx
	movzx bx,[bgl_width]
	shr bx,1
	sub ax,bx
	pop bx
	sub cx,ax
.bounds_skip3:
	
	mov ax,[bgl_rotate_y_adjusted]
	xor dx,dx
	div bx
	mov dx,ax
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip4
	movzx ax,[bgl_rotate_height]
	shr ax,1
	push bx
	movzx bx,[bgl_height]
	shr bx,1
	sub ax,bx
	pop bx
	sub dx,ax
	
.bounds_skip4:
	call bgl_get_gfx_pixel
	
	movzx bx,[bgl_width]
	cmp cx,bx
	jb .width_skip
	mov al,[bgl_transparent]
.width_skip:
	movzx bx,[bgl_height]
	cmp dx,bx
	jb .height_skip
	mov al,[bgl_transparent]
.height_skip:
	
	pop dx
	pop cx
	
	;;;
	
	pop bx
	
	cmp byte [bgl_no_bounds],0
	jne .bounds_skip5
	
	push ax ; colour index
	mov ax,[bgl_x_pos]
	add ax,cx
	cmp ax,320
	pop ax
	jge .skip
	push ax
	mov ax,[bgl_x_pos]
	add ax,cx
	cmp ax,0
	pop ax
	jl .skip
	
	push ax
	mov ax,[bgl_y_pos]
	add ax,dx
	cmp ax,200
	pop ax
	jg .skip
	push ax
	mov ax,[bgl_y_pos]
	add ax,dx
	cmp ax,0
	pop ax
	jl .skip
	
.bounds_skip5:
	cmp byte [bgl_opaque],0
	jne .draw
	cmp al,[bgl_transparent]
	je .skip
	cmp byte [bgl_erase],0
	je .draw
	mov al,[bgl_background_colour]
	
.draw:
	add al,[bgl_tint]
	call bgl_get_mask_value
	mov byte [es:di],al
.skip:
	inc di
	cmp byte [bgl_rotate_bounds],0
	je .scale_skip9
	inc byte [bgl_rotate_x_counter]
	movzx ax,[bgl_rotate_width]
	cmp byte [bgl_rotate_x_counter],al ; reached overall width?
	jb .skip2 ; if not, do pixel x checks
	inc byte [bgl_rotate_y_counter] ; otherwise, increase overall y...
	mov byte [bgl_rotate_x_counter],0 ; reset overall x...
	push ax
	push bx
	mov ax,320 ; move down a line
	movzx bx,[bgl_rotate_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	
	mov ax,[bgl_rotate_height]
	cmp byte [bgl_rotate_y_counter],al ; reached overall height?
	je .end ; if so, end
.skip2:
	inc cx
	cmp cl,[bgl_width] ; reached graphic width?
	jb .loop_end ; if not, skip
	cmp byte [bgl_rotate_x_counter],0 ; is overall x 0?
	jne .loop_end ; if not, skip
	xor cx,cx ; otherwise, reset pixel x
	inc dx ; increase pixel y
	jmp .loop_end
.scale_skip9:
	inc cx
	cmp cl,[bgl_width]
	jb .loop_end
	push ax
	push bx
	mov ax,320
	movzx bx,[bgl_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	xor cx,cx
	inc dx
	cmp dl,[bgl_height]
	jb .loop_end
	jmp .end
.loop_end:
	jmp .loop
.end:

	popa
	ret
	
bgl_draw_gfx_rotate_fast:
	; using multiples of 255 instead of 360!
	pusha

	; find sin of angle..
	mov ax,[bgl_rotate_angle]
	call bgl_get_sine_255
	cbw
	mov word [bgl_rotate_angle_sin],ax
	
	; find cos of angle..
	mov ax,[bgl_rotate_angle]
	call bgl_get_cosine_255
	cbw
	mov word [bgl_rotate_angle_cos],ax

	;;;

	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	; get x and y centre points
	
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip
	movzx ax,[bgl_rotate_width]
	shr ax,1
	mov word [bgl_rotate_x_centre],ax
	movzx ax,[bgl_rotate_height]
	shr ax,1
	mov word [bgl_rotate_y_centre],ax
	jmp .bounds_skip2
.bounds_skip:
	movzx ax,[bgl_width]
	shr ax,1
	mov word [bgl_rotate_x_centre],ax
	movzx ax,[bgl_height]
	shr ax,1
	mov word [bgl_rotate_y_centre],ax
.bounds_skip2:
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
	mov byte [bgl_rotate_x_counter],0 ; used for width/height
	mov byte [bgl_rotate_y_counter],0
	xor cx,cx
	xor dx,dx
	
.loop:
	push bx
	
	; x
	
	push cx
	push dx
	
	; 16-bit multiplication still has to be done :(
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	inc ax ; weird fix for stupidness that i still don't understand
	xor dx,dx
	mul bx ; x*cos(angle)
	mov cx,ax ; cx = x*cos(angle)
	
	pop bx ; original y counter into bx
	push bx ;;
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; y*sin(angle)
	mov dx,ax ; dx = y*sin(angle)
	sub cx,dx
	
	mov ax,[bgl_rotate_x_centre]
	shl ax,7
	add cx,ax
	
	mov word [bgl_rotate_x_adjusted],cx
	
	pop dx
	pop cx
	
	; y
	
	push cx
	push dx
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; x*sin(angle)
	mov cx,ax ; cx = x*sin(angle)
	
	pop bx ;; original y counter into bx
	push bx
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	inc ax ; seriously why does this work
	xor dx,dx
	mul bx ; y*cos(angle)
	mov dx,ax ; dx = y*cos(angle)
	add cx,dx
	
	mov ax,[bgl_rotate_y_centre]
	shl ax,7
	add cx,ax
	
	mov dx,cx
	shr dx,7
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip3
	movzx ax,[bgl_rotate_height]
	shr ax,1
	push bx
	movzx bx,[bgl_height]
	shr bx,1
	sub ax,bx
	pop bx
	sub dx,ax
.bounds_skip3:
	mov cx,[bgl_rotate_x_adjusted]
	shr cx,7
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip4
	movzx ax,[bgl_rotate_width]
	shr ax,1
	push bx
	movzx bx,[bgl_width]
	shr bx,1
	sub ax,bx
	pop bx
	sub cx,ax
	
.bounds_skip4:
	call bgl_get_gfx_pixel
	
	movzx bx,[bgl_width]
	cmp cx,bx
	jb .width_skip
	mov al,[bgl_transparent]
.width_skip:
	movzx bx,[bgl_height]
	cmp dx,bx
	jb .height_skip
	mov al,[bgl_transparent]
.height_skip:
	
	pop dx
	pop cx
	
	;;;
	
	pop bx
	
	cmp byte [bgl_opaque],0
	jne .draw
	cmp al,[bgl_transparent]
	je .skip
	cmp byte [bgl_erase],0
	je .draw
	mov al,[bgl_background_colour]
	
.draw:
	add al,[bgl_tint]
	call bgl_get_mask_value
	mov byte [es:di],al
.skip:
	inc di
	cmp byte [bgl_rotate_bounds],0
	je .bounds_skip5
	inc byte [bgl_rotate_x_counter]
	movzx ax,[bgl_rotate_width]
	cmp byte [bgl_rotate_x_counter],al ; reached overall width?
	jb .skip2 ; if not, do pixel x checks
	inc byte [bgl_rotate_y_counter] ; otherwise, increase overall y...
	mov byte [bgl_rotate_x_counter],0 ; reset overall x...
	push ax
	push bx
	mov ax,320 ; move down a line
	movzx bx,[bgl_rotate_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	
	mov ax,[bgl_rotate_height]
	cmp byte [bgl_rotate_y_counter],al ; reached overall height?
	je .end ; if so, end
.skip2:
	inc cx
	cmp cl,[bgl_width] ; reached graphic width?
	jb .loop_end ; if not, skip
	cmp byte [bgl_rotate_x_counter],0 ; is overall x 0?
	jne .loop_end ; if not, skip
	xor cx,cx ; otherwise, reset pixel x
	inc dx ; increase pixel y
	jmp .loop_end
	
.bounds_skip5:
	inc cx
	cmp cl,[bgl_width]
	jb .loop_end
	push ax
	push bx
	mov ax,320
	movzx bx,[bgl_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	xor cx,cx
	inc dx
	cmp dl,[bgl_height]
	jb .loop_end
	jmp .end
.loop_end:
	jmp .loop
.end:

	popa
	ret
%endif
%endif
	
%ifndef bgl_no_scale
bgl_draw_gfx_scale:

	; the simplest and most functional algorithm: (used as a reference)
	; https://www.researchgate.net/figure/Nearest-neighbour-image-scaling-algorithm_fig2_272092207

	push dword [bgl_scale_x]
	push dword [bgl_scale_y]
	pusha
	
.start:

	xor edx,edx ; when dividing 16/32 bit numbers, dx is used as the "high register"

	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	cmp byte [bgl_scale_square],0
	je .square_skip5
	mov eax,[bgl_scale_x]
	cmp eax,0
	jl .square_skip2
	call bgl_square
	sar eax,bgl_scale_precision
	jmp .square_skip3
.square_skip2:
	sar eax,bgl_scale_precision/2
.square_skip3:
	mov dword [bgl_scale_x],eax
	mov eax,[bgl_scale_y]
	cmp eax,0
	jl .square_skip4
	call bgl_square
	sar eax,bgl_scale_precision
	jmp .square_skip
.square_skip4:
	sar eax,bgl_scale_precision/2
.square_skip:
	mov dword [bgl_scale_y],eax
.square_skip5:
	
	push ebx ; ebx is our temporary register here
	
	; get scale factor based off the width
	mov eax,[bgl_scale_x]
	movzx ebx,byte [bgl_width]
	add eax,ebx ; scale amount + original width
	shl eax,bgl_scale_precision
	movzx ebx,byte [bgl_width]
	div ebx ; new size/original size
	sub eax,ebx
	mov dword [bgl_scale_factor_width],eax
	
	mov eax,[bgl_scale_y]
	movzx ebx,byte [bgl_width]
	add eax,ebx ; scale amount + original width
	shl eax,bgl_scale_precision
	movzx ebx,byte [bgl_width]
	xor edx,edx
	div ebx ; new size/original size
	sub eax,ebx
	mov dword [bgl_scale_factor_height],eax

	; get width and height
	xor ebx,ebx
	mov ebx,[bgl_scale_factor_width]
	movzx eax,byte [bgl_width]
	shl eax,bgl_scale_precision
	xor edx,edx
	div ebx
	mov word [bgl_scale_width],ax
	movzx eax,byte [bgl_height]
	shl eax,bgl_scale_precision
	xor edx,edx
	mov ebx,[bgl_scale_factor_height]
	div ebx
	mov word [bgl_scale_height],ax
	
	pop ebx

	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	cmp byte [bgl_scale_centre],0
	je .x_y_skip
	mov ax,[bgl_scale_width]
	sar ax,1
	sub cx,ax
	mov ax,[bgl_scale_height]
	sar ax,1
	sub dx,ax
	movzx ax,[bgl_width]
	sar ax,1
	add cx,ax
	movzx ax,[bgl_height]
	sar ax,1
	add dx,ax
	
.x_y_skip:
	call bgl_get_x_y_offset
	
	xor cx,cx
	xor dx,dx
	cmp byte [bgl_flip],0
	je .loop
	mov cx,[bgl_scale_width]
.loop:
	push ebx
	push ecx
	push edx
	
	
	movzx eax,cx
	xor edx,edx
	mov ebx,[bgl_scale_factor_width]
	mul ebx
	shr eax,bgl_scale_precision
	mov cx,ax
	
	pop edx
	push edx
	movzx eax,dx
	mov ebx,[bgl_scale_factor_height]
	mul ebx
	push ecx
	shr eax,bgl_scale_precision
	mov dx,ax
	pop ecx
	
	call bgl_get_gfx_pixel
	
	pop edx
	pop ecx
	pop ebx
	
	cmp byte [bgl_no_bounds],0
	jne .bounds_skip
	
	push ax
	mov ax,[bgl_x_pos]
	add ax,cx
	cmp ax,319
	pop ax
	jg .skip
	push ax
	mov ax,[bgl_x_pos]
	add ax,dx
	cmp ax,0
	pop ax
	jl .skip
	
	push ax
	mov ax,[bgl_y_pos]
	add ax,dx
	cmp ax,200
	pop ax
	jg .skip
	push ax
	mov ax,[bgl_y_pos]
	add ax,dx
	cmp ax,0
	pop ax
	jl .skip
	
.bounds_skip:
	cmp byte [bgl_opaque],0
	jne .draw
	cmp al,[bgl_transparent]
	je .skip
	cmp byte [bgl_erase],0
	je .draw
	mov al,[bgl_background_colour]
	
.draw:
	add al,[bgl_tint]
	push cx
	push dx
	add cx,[bgl_scale_width]
	add dx,[bgl_scale_height]
	call bgl_get_mask_value
	pop dx
	pop cx
	mov byte [es:di],al
.skip:
	inc di
	cmp byte [bgl_flip],0
	je .flip_skip
	dec cx
	cmp cx,0
	ja .loop_end
	jmp .flip_skip2
.flip_skip:
	inc cx
	cmp cx,[bgl_scale_width]
	jb .loop_end
.flip_skip2:
	push ax
	push bx
	mov ax,320
	movzx bx,[bgl_scale_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	xor cx,cx
	cmp byte [bgl_flip],0
	je .flip_skip3
	mov cx,[bgl_scale_width]
.flip_skip3:
	inc dx
	cmp dl,[bgl_scale_height]
	jb .loop_end
	jmp .end
.loop_end:
	jmp .loop
.end:
	popa
	pop dword [bgl_scale_y]
	pop dword [bgl_scale_x]
	ret
%endif

bgl_get_buffer_pixel:
	push cx
	push dx
	push di
	; input: cx, dx = x, y (of screen)
	; output: al = pixel
	; gets the value of a pixel from the bgl's buffer
	call bgl_get_x_y_offset ; returns offset in di
	mov al,[es:di] ; aHits ThaHat Easy! (tm)
	pop di
	pop dx
	pop cx
	ret

bgl_get_gfx_pixel:
	push bx
	push cx
	push dx
	; input: cl, dl = x, y (of graphic, not the screen)
	; output: al = pixel
	; formula: (y*width)+x
	
	movzx ax,dl ; y*width
	movzx bx,[bgl_width]
	xor dx,dx
	mul bx
	
	mov bx,[bgl_buffer_offset]
	add bx,2 ; skip header
	
	xor ch,ch
	add ax,cx ; +x
	add bx,ax
	
	mov al,[bx]
	pop dx
	pop cx
	pop bx
	ret

bgl_get_mask_value: ; input: cx, dx = internal x and y counter (from 0), al = original colour index, output: al = tinted colour index
	cmp byte [bgl_mask],0
	je .end
	push bx
	push cx
	push dx
	add cx,[bgl_x_pos]
	add dx,[bgl_y_pos]
	push ax
	call bgl_get_buffer_pixel
	mov bl,al
	pop ax
	add al,bl
	pop dx
	pop cx
	pop bx
.end:
	ret

bgl_draw_gfx_fast:
	push ax
	push bx
	push cx
	push dx
	push si

	; this exists as a challenge to see... just how FUAHST. i can do it.
	; there will be sacrifices, namely the lack of edge clipping
	; it'll draw based off a fixed offset instead of repeatedly calculating the x/y because that ate up tons of cycles
	
	mov si,[bgl_buffer_offset]
	mov al,[si]
	mov byte [bgl_width],al
	mov al,[si+1]
	mov byte [bgl_height],al
	mov al,[si+2]
	mov byte [bgl_transparent],al
	add si,2
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset ; get initial offset based off x and y
	
	xor cx,cx ; now we use cx and dx as x/y counters
	xor dx,dx
	
.draw:
	; per byte instead of words, in case the width/height isn't a multiple of 4 (i could reinforce that, but ueeEEeeaAauAHGHgh)
	mov al,[si]
	inc si
	cmp al,[bgl_transparent]
	je .draw_skip
	cmp byte [bgl_erase],0
	je .erase_skip
	mov al,[bgl_background_colour]
.erase_skip:
	add al,[bgl_tint]
	call bgl_get_mask_value
	mov byte [es:di],al
.draw_skip:
	inc di
	inc cx
	cmp cl,[bgl_width] ; reached end of line?
	jne .draw_end ; if not, skip
	xor cx,cx ; reset x counter
	inc dx
	mov ax,320
	movzx bx,[bgl_width] ; bx only used as a temporary register here
	sub ax,bx
	add di,ax ; move down a line starting from current x
	mov al,[bgl_height]
	sub al,[bgl_y_clip]
	cmp dl,al ; reached baddum udda grafic?
	jne .draw_end ; if not, skip
	jmp .end ; if so, finished drawing graphic
.draw_end:
	jmp .draw
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret

bgl_draw_gfx:
	push ax
	push bx
	push cx
	push dx
	push si
	
	cmp word [bgl_x_pos],320 ; check if it's in range before drawing
	jge .end
	cmp word [bgl_y_pos],200
	jge .end
	
	; graphics are stored x first, then y
	
	mov si,[bgl_buffer_offset]
	
	mov al,[si] ; first byte should contain the width
	mov byte [bgl_width],al
	mov al,[si+1] ; second byte should contain the height
	mov byte [bgl_height],al
	
	mov al,[si+2] ; top left pixel is assumed transparent
	mov byte [bgl_transparent],al
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	add si,2 ; beginning of actual graphic data
    mov cx,[bgl_x_pos] ; x
    mov dx,[bgl_y_pos] ; y
	
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .flip_skip ; if not, carry on as usual
	xor ax,ax
	mov al,[bgl_width]
	add cx,ax ; otherwise, start from the end
.flip_skip:
	call bgl_get_x_y_offset
.loop:
	
    mov al,[si] ; pixel colour
	cmp al,[bgl_transparent]
	je .skip ; if the pixel is "transparent", skip drawing
	cmp byte [bgl_no_bounds],0 ; are we performing the bound check?
	jne .bounds_skip ; if not, skip it
	cmp cx,320
	jge .skip ; if the pixel has exceeded the horizontal boundaries, skip
	cmp cx,0
	jl .skip ; -'-
	cmp dx,200
	jge .skip ; if the pixel has exceeded the vertical boundaries, skip
	cmp dx,0
	jl .skip ; -'-
	
.bounds_skip:
	cmp byte [bgl_erase],0 ; otherwise, check if we're erasing so we use the right colour
	je .erase_skip ; if not, use the proper colour as set earlier
	mov al,[bgl_background_colour] ; otherwise, use background colour
.erase_skip:
	add al,[bgl_tint]
	push cx
	push dx
	sub cx,[bgl_x_pos]
	sub dx,[bgl_y_pos]
	call bgl_get_mask_value
	pop dx
	pop cx
	mov byte [es:di],al
	
.skip:
	inc si ; next byte
	inc cx ; increase x
	inc di
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .skip2 ; if not, carry on as usual
	sub cx,2 ; otherwise, decrease x
	sub di,2
.skip2:
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .skip3 ; if not, carry on as usual
	cmp cx,[bgl_x_pos] ; otherwise, compare the current x to the original x
	mov ax,[bgl_x_pos]
	jne .loop
	jmp .skip4 ; reached the end of this line
.skip3:
	mov ax,cx
	sub ax,[bgl_x_pos] ; new x - original x
	cmp al,[bgl_width] ; reached the end of the line?
	jb .loop ; if not, go to next horizontal pixel (using unsigned checks to support widths over 127)
	mov cx,[bgl_x_pos] ; we've reached the end of the line, so reset x and increase y
	push cx
	movzx cx,[bgl_width]
	sub di,cx
	add di,320
	pop cx
	jmp .skip5
.skip4:
	mov cx,[bgl_x_pos]
	push ax
	xor ax,ax
	mov al,[bgl_width]
	add cx,ax
	pop ax
.skip5:
	inc dx
	
	mov ax,dx
	sub ax,[bgl_y_pos] ; new y - original y
	cmp al,[bgl_height] ; reached the bottom of the graphic?
	jb .loop ; if not, go to next line (using unsigned checks to support heights over 127)
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bgl_draw_full_gfx:
	push ax
	push bx
	push si
	push di
	
	mov si,[bgl_buffer_offset] ; starting from 2 to avoid the width/height - they're not necessary here
	add si,2 ; henceforth
	xor di,di
.loop:
	mov eax,[si] ; get source pixel
	mov dword [es:di],eax ; move to temporary graphics buffer
	add si,4
	add di,4
	cmp di,64000
	jb .loop
	
	pop di
	pop si
	pop bx
	pop ax
	ret
	
%ifndef bgl_no_rle
bgl_draw_full_gfx_rle:
	push ax
	push bx
	push cx
	push si
	push di
	
	xor di,di
	mov si,[bgl_buffer_offset]
	add si,2
	xor cx,cx
	mov dx,0
.loop:
	mov ax,[si] ; get the word
	mov word [bgl_rle_word],ax
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word]
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah
	mov word [bgl_rle_word],ax
	mov byte [es:di],al
	inc di
	cmp di,64000 ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end:
	add si,2 ; x and y are still in bounds, go to next byte
	jmp .loop
	
.end:
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	ret

bgl_draw_gfx_rle: ; "draw graphics... really?"
	push ax
	push bx
	push cx
	push dx
	push si
	
	cmp word [bgl_x_pos],320 ; check if it's even in range before drawing
	jge .end
	cmp word [bgl_y_pos],200
	jge .end
	
	mov cx,[bgl_x_pos]
	cmp byte [bgl_flip],0
	je .flip_skip
	movzx bx,[bgl_width]
	add cx,bx
.flip_skip:
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
.init: ; bruv
	mov si,[bgl_buffer_offset]
	mov al,[si]
	mov byte [bgl_width],al
	mov al,[si+1]
	mov byte [bgl_height],al
	mov al,[si+2]
	mov byte [bgl_transparent],al
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	xor cx,cx
	xor dx,dx
	
	add si,2 ; increased by 2 each time to get each byte and its repeats as a word
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .loop ; if not, skip
	mov cl,[bgl_width] ; if drawing flipped, start from the right side
.loop:
	mov ax,[si] ; get the word - low byte is colour index, high byte is amount of repeats
	mov word [bgl_rle_word],ax ; we'll need to affect ax later, and the stack can't be used in this situation
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word] ; -- equivalent to "pop ax" if the stack wasn't wacky here, this restores the affected word
	
	; \/ the positioning of this code is very very important!!! \/
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah ; decadecAhhh, decah decAhhh BUM. BUM. oooOOOoOoohhHYYyeEEaaAAHhhh.
	
	; /\ the positioning of this code is very very important!!! /\
	
	cmp al,[bgl_transparent] ; if the pixel about to be drawn is transparent, don't even draw it, just skip
	je .draw_loop_skip
	
	cmp byte [bgl_no_bounds],0 ; are we performing the bound check?
	jne .bounds_skip ; if not, skip it
	
	push ax
	mov ax,cx
	add ax,[bgl_x_pos]
	cmp ax,0 ; check if x and y are within boundaries
	pop ax
	jl .draw_loop_skip
	
	push ax
	mov ax,cx
	add ax,[bgl_x_pos]
	cmp ax,320
	pop ax
	jge .draw_loop_skip
	
	push ax
	mov ax,dx
	add ax,[bgl_y_pos]
	cmp ax,0
	pop ax
	jl .draw_loop_skip
	
	push ax
	mov ax,dx
	add ax,[bgl_y_pos]
	cmp ax,200
	pop ax
	jge .draw_loop_skip
	
.bounds_skip:
	cmp byte [bgl_erase],0 ; erasing?
	je .draw_loop_main ; if not, continue as normal
	mov al,[bgl_background_colour] ; otherwise, replace pixel colour with the background colour
	
.draw_loop_main:
	push ax
	add al,[bgl_tint]
	call bgl_get_mask_value
	mov byte [es:di],al
	pop ax
.draw_loop_skip:
	mov word [bgl_rle_word],ax
	inc di
	inc cx ; increase "internal" x position
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip2 ; if not, continue as normal
	sub cx,2 ; decrease x instead (cx + 1 - 2 = cx - 1)
	sub di,2
.draw_loop_skip2:
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip3 ; if not, continue as normal
	cmp cx,0 ; if drawing flipped, simply compare the new x with the original x
	jne .draw_loop ; haven't reached the end of the line, so continue drawing
	jmp .draw_loop_skip4 ; reached end of line
.draw_loop_skip3:
	cmp cl,[bgl_width] ; reached end of the line?
	jne .draw_loop ; if not, continue drawing
.draw_loop_skip4:
	inc dx ; reached end of line, increase y and reset x
	xor cx,cx
	mov ax,320
	movzx bx,[bgl_width]
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_flip_skip ; if not, continue as normal
	add ax,bx
	jmp .draw_loop_flip_skip2
.draw_loop_flip_skip:
	sub ax,bx
.draw_loop_flip_skip2:
	add di,ax
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip5 ; if not, continue as normal
	mov cl,[bgl_width]
.draw_loop_skip5:
	cmp dl,[bgl_height] ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end: ; get next word
	add si,2
	jmp .loop ; very complicated piece of code
	
.end:

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	

bgl_draw_gfx_rle_fast: ; "draw graphics, really fast"
	; using minimal checks and no flipping
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov cx,[bgl_x_pos]
	movzx bx,[bgl_width]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
.init:
	mov si,[bgl_buffer_offset]
	mov al,[si]
	mov byte [bgl_width],al
	mov al,[si+1]
	mov byte [bgl_height],al
	mov al,[si+2]
	mov byte [bgl_transparent],al
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	xor cx,cx
	xor dx,dx
	
	add si,2
.loop:
	mov ax,[si]
	mov word [bgl_rle_word],ax
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word]
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah
	
	cmp al,[bgl_transparent]
	je .draw_loop_skip
	
	; no bound checks!
	
	cmp byte [bgl_erase],0 ; erasing?
	je .draw_loop_main ; if not, continue as normal
	mov al,[bgl_background_colour] ; otherwise, replace pixel colour with the background colour
	
.draw_loop_main:
	push ax
	add al,[bgl_tint]
	call bgl_get_mask_value
	mov byte [es:di],al
	pop ax
.draw_loop_skip:
	mov word [bgl_rle_word],ax
	inc di
	inc cx ; increase "internal" x position
	cmp cl,[bgl_width] ; reached end of the line?
	jne .draw_loop ; if not, continue drawing
	inc dx ; reached end of line, increase y and reset x
	xor cx,cx
	mov ax,320 ; screen width - graphic width
	movzx bx,[bgl_width] ; -'-
	sub ax,bx ; -'-
	add di,ax ; -'-
	cmp dl,[bgl_height] ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end: ; get next word
	add si,2
	jmp .loop ; very complicated piece of code
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
%endif
	
bgl_get_x_y_offset: ; result: offset in di - requires: cx to contain x, dx to contain y
	push cx
	push dx
	
	; formula: (y<<8)+(y<<6)+x
	shl dx,6
	mov di,dx ; di: y<<6
	shl dx,2 ; dx: y<<8
	add di,dx
	add di,cx ; di: y<<6+y<<8+x
	
	pop dx
    pop cx
	ret
	
bgl_draw_chunky_pixel: ; colour in al, offset in di
	push ax
	push di
	
	call bgl_spread_8_16
	mov word [es:di],ax
	add di,320
	mov word [es:di],ax
	
	pop di
	pop ax
	ret
	
%ifndef bgl_no_collision
bgl_collision_debug_draw_1:
	push ax
	push cx
	push dx
	
	mov al,[bgl_collision_c1]
	call bgl_spread_8_16
	
	mov cx,[bgl_collision_x1]
	mov dx,[bgl_collision_y1]
	call bgl_get_x_y_offset
	
	call bgl_draw_chunky_pixel
	add di,[bgl_collision_w1]
	sub di,2 ; chunky pixel width
	call bgl_draw_chunky_pixel
	
	mov cx,[bgl_collision_x1]
	add dx,[bgl_collision_h1]
	sub dx,2
	call bgl_get_x_y_offset
	call bgl_draw_chunky_pixel
	add di,[bgl_collision_w1]
	sub di,2
	call bgl_draw_chunky_pixel
	
	pop dx
	pop cx
	pop ax
	ret

bgl_collision_debug_draw_2:
	push ax
	push cx
	push dx
	
	mov al,[bgl_collision_c2]
	call bgl_spread_8_16
	
	mov cx,[bgl_collision_x2]
	mov dx,[bgl_collision_y2]
	call bgl_get_x_y_offset
	
	call bgl_draw_chunky_pixel
	add di,[bgl_collision_w2]
	sub di,2
	call bgl_draw_chunky_pixel
	
	mov cx,[bgl_collision_x2]
	add dx,[bgl_collision_h2]
	sub dx,2
	call bgl_get_x_y_offset
	call bgl_draw_chunky_pixel
	add di,[bgl_collision_w2]
	sub di,2
	call bgl_draw_chunky_pixel
	
	pop dx
	pop cx
	pop ax

bgl_collision_debug_draw_2b:
	push ax
	push cx
	push dx
	
	mov al,[bgl_collision_c2]
	call bgl_spread_8_16
	
	mov cx,[bgl_collision_x2]
	mov dx,[bgl_collision_y2]
	call bgl_get_x_y_offset
	
	call bgl_draw_chunky_pixel
	
	pop dx
	pop cx
	pop ax

bgl_collision_check:
	push ax
	
    mov byte [bgl_collision_flag],0
	
	cmp byte [bgl_collision_debug],0
	je .main
	call bgl_collision_debug_draw_1
	call bgl_collision_debug_draw_2
	
	; I have no clue why I had to use jl for all of these, I tried the "logical choice" and it just didn't work.
	; If I had to guess why, it's because the result of all these comparisons will be negative if false.
	
.main:
	mov ax,[bgl_collision_x2]
	add ax,[bgl_collision_w2]
	cmp ax,[bgl_collision_x1]
	jl .skip
	mov ax,[bgl_collision_x1]
	add ax,[bgl_collision_w1]
	cmp ax,[bgl_collision_x2]
	jl .skip
	mov ax,[bgl_collision_y2]
	add ax,[bgl_collision_h2]
	cmp ax,[bgl_collision_y1]
	jl .skip
	mov ax,[bgl_collision_y1]
	add ax,[bgl_collision_h1]
	cmp ax,[bgl_collision_y2]
	jl .skip
	
	mov byte [bgl_collision_flag],1
.skip:
	pop ax
	ret	

bgl_point_collision_check:
	push ax
	
    mov byte [bgl_collision_flag],0
	
	cmp byte [bgl_collision_debug],0
	je .main
	call bgl_collision_debug_draw_1
	call bgl_collision_debug_draw_2b
		
	; x2 and y2 are for the point (w2 and h2 are unused here)
	
.main:
	mov ax,[bgl_collision_x1]
	cmp word [bgl_collision_x2],ax
	jl .skip
	
	mov ax,[bgl_collision_x1]
	add ax,[bgl_collision_w1]
	cmp word [bgl_collision_x2],ax
	jg .skip
	
	mov ax,[bgl_collision_y1]
	cmp word [bgl_collision_y2],ax
	jl .skip
	
	mov ax,[bgl_collision_y1]
	add ax,[bgl_collision_h1]
	cmp word [bgl_collision_y2],ax
	jg .skip
	
	mov byte [bgl_collision_flag],1
.skip:
	pop ax
	ret
%endif

%ifndef bgl_no_keys
bgl_key_handler:
	push ax
	push bx
	
	in al,60h ; get keyboard stuff
	xor ah,ah
	mov bx,ax
	and bx,127 ; last 7 bits (bx): scan code
	shl ax,1 ; first bit (ah): press/release
	xor ah,1
	mov [bgl_key_states+bx],ah ; move press/release state to the appropriate index
	mov al,20h
	out 20h,al
	
	pop bx
	pop ax
	iret
	
bgl_get_orig_key_handler:
	push bx
	push es
	push ax
	mov ax,3509h ; get address of original key handler
	int 21h
	mov [bgl_key_handler_orig],bx ; offset
	mov [bgl_key_handler_orig+2],es	; segment
	pop ax
	pop es
	pop bx
	ret
	
bgl_restore_orig_key_handler:
	push dx
	push ds
	push ax
	mov dx,[bgl_key_handler_orig]
	mov ds,[bgl_key_handler_orig+2]
	mov ax,2509h
	int 21h
	pop ax
	pop ds
	pop dx
	ret

bgl_replace_key_handler:
	push dx
	push ax
	call bgl_get_orig_key_handler
	mov dx,bgl_key_handler ; replace the default key handler with our own
	mov ax,2509h
	int 21h
	pop ax
	pop dx
	ret
%endif
	
bgl_wait_retrace:
	push ax
	push dx
	
.wait_for:
	mov dx,3dah ; FREEDAH!!
	in al,dx
	test al,8
	je .wait_for
	
.wait_after:
	in al,dx
	test al,8
	jne .wait_after
	
	pop dx
	pop ax
	ret
	
bgl_init_first:
    mov al,13h ; graphics mode: 13h (256 colour vga)
    xor ah,ah ; function number
    int 10h
	
	mov ax,0a000h
	mov fs,ax ; fs Should(tm) always contain the vga memory address
	ret
	
bgl_init_last:
	xor al,al ; clear buffer
	call bgl_flood_fill_full
	
%ifndef bgl_no_keys
	call bgl_replace_key_handler
%ifndef bgl_no_palette
	call bgl_get_orig_palette
%endif
%endif
	ret
	
bgl_init: ; yeah mate, its bgl init bruv
	push ax
	call bgl_init_first
	call bgl_allocate_com
	call bgl_init_last
	pop ax
	ret
	
bgl_init_seg: ; yeaaah init seg?!
	push ax
	call bgl_init_first
	call bgl_allocate_seg
	call bgl_init_last
	pop ax
	ret
	
bgl_allocate_com:
	mov ax,word [2] ; psp: segment of first byte beyond program (word)
	sub ax,64000/16 ; amount of memory we want, in "segments" (16 bytes)
	mov es,ax ; es is the temporary graphics buffer
	ret
	
bgl_allocate_seg:
	mov ah,4ah ; resize memory block
	mov bx,64000/16
	int 21h
	jc bgl_error
	
	mov ah,48h ; allocate memory
	mov bx,64000/16
	int 21h
	jc bgl_error
	mov es,ax
	ret
	
bgl_write_buffer_fast:
	push ax
	push cx
	push si
	push di
	push ds
	push es

	mov ax,es
	mov ds,ax ; ds = es (bgl)
	mov ax,fs
	mov es,ax ; es = fs (vga)
	xor si,si
	xor di,di
	
	mov cx,64000/4
	rep movsd ; ultimate speed: FOUR BYTES AT A TIME.
	
	pop es
	pop ds
	pop di
	pop si
	pop cx
	pop ax
	ret	
	
bgl_write_buffer:
	push eax
	push di

	mov di,0
.loop:
	mov eax,[es:di]
	mov dword [fs:di],eax ; weird way of doing it, but it works, and it does the same as write_buffer_fast, but without the keyboard weirdness, rep movsd is weird
	stosd
	cmp di,64000
	jb .loop
	
	pop di
	pop eax
	ret
	
bgl_flood_fill_full:
	push di
	push cx
	mov ah,al
	xor di,di
	push ax
	shl eax,16
	pop ax
	mov cx,64000/4
	rep stosd
	pop cx
	pop di
	ret
	
bgl_flood_fill:
.loop:
	mov byte [es:di],al
	inc di
	cmp di,cx
	jne .loop
	ret
	
bgl_flood_fill_fast: ; di: start, cx: end
	push ax
	
	mov ah,al
	rep stosw
	
	pop ax
	ret
	
bgl_flood_fill2: ; di: start, cx: amount of pixels
	push ax
	
	mov ah,al
	add cx,di
.loop:
	stosw
	cmp di,cx
	jb .loop
	
	pop ax
	ret
	
%ifndef bgl_no_palette
bgl_restore_orig_palette:
	push ax
	push dx
	push si
	
	mov si,64000
	
	mov dx,3c8h
	xor al,al
	out dx,al
	
	mov dx,3c9h
.loop:
	mov al,[fs:si]
	out dx,al
	inc si
	cmp si,64000+768
	jne .loop
	
	pop si
	pop dx
	pop ax
	ret
	
bgl_get_orig_palette:
	; puts default vga colours into the extra space after the graphics memory
	push ax
	push bx
	push dx
	push di
	
	xor cx,cx ; colour index
	mov di,64000
	
	xor al,al
	mov dx,3c7h ; read register (write register is 3c8h)
	out dx,al
.loop:
	mov dx,3c9h
	in al,dx ; r
	mov byte [fs:di],al ; fs is the vga address...
	inc di
	in al,dx ; g
	mov byte [fs:di],al
	inc di
	in al,dx ; b
	mov byte [fs:di],al
	inc di
	
	inc cx ; go to next index
	cmp cx,255 ; reached last index?
	jb .loop ; if not, keep getting those colours
	
	pop di
	pop dx
	pop bx
	pop ax
	ret
	
bgl_temp_palette resw 768 ; resw, because for the fade in, we use negative values (super janky)
	
bgl_fill_temp_palette:
	push ax
	push si
	push di
	
	mov si,64000
	xor di,di
.loop:
	movzx ax,[fs:si]
	mov word [bgl_temp_palette+di],ax
	inc si
	add di,2
	cmp di,768*2
	jne .loop
	
	pop di
	pop si
	pop ax
	ret
	
bgl_clear_temp_palette:
	push bx
	
	xor bx,bx
.loop:
	mov word [bgl_temp_palette+bx],0
	add bx,2
	cmp bx,768*2
	jne .loop
	
	pop bx
	ret
	
bgl_fade_out:
	push ax
	push bx
	push cx
	push dx

	; implemented based on pseudocode from:
	; http://qzx.com/pc-gpe/vgaregs.txt
	
	call bgl_fill_temp_palette
	mov cl,64 ; fade steps
	
.step_loop:
	xor bx,bx ; byte counter
	
	mov dx,3c8h ; write address - entry
	xor al,al ; entry 0
	out dx,al
	mov dx,3c9h ; data
.byte_loop:
	mov ax,[bgl_temp_palette+bx]
	cmp ax,0 ; this byte 0?
	je .byte_skip ; if so, keep it 0
	dec ax ; if not, decrease it
	mov word [bgl_temp_palette+bx],ax
.byte_skip:
	out dx,al
	add bx,2 ; increase byte counter
	cmp bx,768*2 ; reached final byte?
	jne .byte_loop ; if not, continue bything
	
	call bgl_wait_retrace
	
	dec cl
	cmp cl,0 ; last fade step?
	jne .step_loop ; do it again

	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bgl_fade_in:
	push ax
	push bx
	push cx
	push dx
	push si
	
	call bgl_fill_temp_palette
	mov cl,64 ; fade steps
	
.step_loop:
	xor bx,bx ; byte counter
	mov si,64000
	
	mov dx,3c8h ; write address - entry
	xor al,al ; entry 0
	out dx,al
	mov dx,3c9h ; data
.byte_loop:
	mov ax,[bgl_temp_palette+bx]
	push dx
	movzx dx,[fs:si]
	add dx,255
	cmp ax,dx ; is this byte matching?
	pop dx
	je .byte_skip
	inc ax
	mov word [bgl_temp_palette+bx],ax
.byte_skip:
	sub ax,64
	cmp ax,0
	jg .zero_skip
	xor ax,ax
.zero_skip:
	out dx,al
	inc si
	add bx,2 ; increase byte counter
	cmp bx,768*2 ; reached final byte?
	jne .byte_loop ; if not, continue bything
	
	call bgl_wait_retrace
	
	dec cl
	cmp cl,0 ; last fade step?
	jne .step_loop ; do it again

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
%endif
	
%ifndef bgl_no_keys
bgl_escape_exit:
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .skip
	call bgl_reset
	mov ah,4ch ; return to command line
	int 21h
.skip:
	ret
	
%ifndef bgl_no_palette
bgl_escape_exit_fade:
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .skip
	call bgl_fade_out
	call bgl_reset
	mov ah,4ch ; return to command line
	int 21h
.skip:
	ret
%endif
%endif
	
bgl_error:

	push dx
	push cx
	push bx
	push ax

	mov ax,3 ; restore graphics mode
	int 10h
	
	mov ah,9
	mov dx,bgl_error_message
	int 21h
	
	xor cl,cl
	
.register_loop:
	mov ah,2
	mov dl,"A"
	add dl,cl
	int 21h
	mov dl,"X"
	int 21h
	mov dl,":"
	int 21h
	pop ax ; get last pushed register into ax
	mov dl,ah
	call bgl_write_hex_byte
	mov dl,al
	call bgl_write_hex_byte
	mov ah,2
	mov dl," "
	int 21h
	cmp cl,3
	je .register_skip
	inc cl
	jmp .register_loop
	
.register_skip:
	
	mov ah,9
	mov dx,cr_lf
	int 21h
	
	mov ah,4ch ; return to command line
	int 21h
	ret
	
bgl_write_hex_byte:
	push ax
	push dx
	
	shr dl,4
	call bgl_write_hex_digit
	pop dx
	
	call bgl_write_hex_digit
	pop ax
	ret
	
bgl_write_hex_digit: ; dl: value between 0-15 (if above, it'll get the last digit, so 14 will return 4)
	push dx
	push ax
	
	mov al,dl
	and al,15
	
	mov ah,2
	mov dl,al
	cmp dl,10 ; is dl (same as al for now) greater than 10?
	jb .write ; if not, write the digit
	add dl,7
.write:
	add dl,"0"
	mov ah,2
	int 21h
	
	pop ax
	pop dx
	ret
	
%ifndef bgl_no_font
bgl_draw_font_number:
	; eax = number
	; cx = digits
	push bx
	push cx
	push dx
	
	push eax
	mov ax,cx ; get start x
	dec ax
	movzx bx,[bgl_font_spacing]
	xor dx,dx
	mul bx ; digits * font spacing
	add word [bgl_x_pos],ax
	pop eax
	
	push eax ;
.loop:
	mov bx,10
	pop eax ;
	xor edx,edx
	div ebx ; dx will contain the remainder...
	push eax ; the value to multiply again
	
	mov eax,edx
	add eax,15 ; numbers start here!
	
	push eax
	movzx eax,byte [bgl_font_size]
	mov ebx,eax ; font size*font size
	xor edx,edx
	mul ebx
	add eax,2 ; width/height
	mov ebx,eax
	pop eax
	mul ebx
	
	mov bx,ax ; using multiplied number as offset...
	mov ax,[bgl_font_offset]
	mov word [bgl_buffer_offset],ax
	add word [bgl_buffer_offset],bx
	call bgl_draw_gfx_fast
	movzx ax,[bgl_font_spacing]
	sub word [bgl_x_pos],ax
	
	loop .loop
	
	pop eax ; ...eeeeEEEEEEAAAAAAAAAAXXXX
	pop dx
	pop cx
	pop bx
	ret
	
bgl_draw_font_string:
	push ax
	push bx
	push dx
	push si
	mov ax,[bgl_x_pos]
	push ax

	xor ax,ax
	mov si,[bgl_font_string_offset]
.loop:
	mov al,[si] ; get character at position bx into al
	cmp al,0
	je .end
	sub al,33
	jmp .get_offset

.get_offset:
	push bx ; offset
	cmp al," "-33
	je .skip
	push ax ; character number
	xor ax,ax
	xor bx,bx
	mov al,[bgl_font_size] ; size in bytes
	mov bl,al
	xor dx,dx
	mul bx ; ax=size*size
	mov bx,ax
	add ax,2 ; width/height header
	pop bx ; multiply that by the character value...
	mul bx
	
	mov bx,ax ; put result into bx so we can offset
	
	mov ax,[bgl_font_offset]
	add ax,bx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	
.skip:
	xor ax,ax
	mov al,[bgl_font_spacing]
	add word [bgl_x_pos],ax
	pop bx
	inc si
	jmp .loop
.end:

	pop word [bgl_x_pos]
	pop si
	pop dx
	pop bx
	pop ax
	ret
%endif
	
bgl_reset:
	push ax
%ifndef bgl_no_keys
	call bgl_restore_orig_key_handler
%endif
	mov ax,3 ; restore graphics mode
	int 10h
	pop ax
	ret
	
bgl_error_message: db "oops something bad has bappened",13,10,"$"
cr_lf: db 13,10,"$"

%ifndef bgl_no_wave
wave_table_deg:
	dw 0,6,12,18,25,31,37,43,50,56,62,68,74,80,87,93,99,105,111,117,123,129,134,140,146,152,157,163,169,174,179,185,190,196,201,206,211,216,221,226,231,236,240,245,250
	dw 254,258,263,267,271,275,279,283,287,291,294,298,301,305,308,311,314,317,320,323,326,328,331,333,336,338,340,342,344,346,347,349,350,352,353,354,355,356,357,358,358,359,359,359,359
	dw 359,359,359,359,359,358,358,357,356,355,354,353,352,350,349,347,346,344,342,340,338,336,333,331,328,326,323,320,317,314,311,308,305,301,298,294,291,287,283,279,275,271,267,263,258
	dw 254,250,245,240,236,231,226,221,216,211,206,201,196,190,185,180,174,169,163,157,152,146,140,134,129,123,117,111,105,99,93,87,80,74,68,62,56,50,43,37,31,25,18,12,6
	dw 0,-7,-13,-19,-26,-32,-38,-44,-51,-57,-63,-69,-75,-81,-88,-94,-100,-106,-112,-118,-124,-130,-135,-141,-147,-153,-158,-164,-170,-175,-180,-186,-191,-197,-202,-207,-212,-217,-222,-227,-232,-237,-241,-246,-251
	dw -255,-259,-264,-268,-272,-276,-280,-284,-288,-292,-295,-299,-302,-306,-309,-312,-315,-318,-321,-324,-327,-329,-332,-334,-337,-339,-341,-343,-345,-347,-348,-350,-351,-353,-354,-355,-356,-357,-358,-359,-359,-360,-360,-360,-360
	dw -360,-360,-360,-360,-360,-359,-359,-358,-357,-356,-355,-354,-353,-351,-350,-348,-347,-345,-343,-341,-339,-337,-334,-332,-329,-327,-324,-321,-318,-315,-312,-309,-306,-302,-299,-295,-292,-288,-284,-280,-276,-272,-268,-264,-259
	dw -255,-251,-246,-241,-237,-232,-227,-222,-217,-212,-207,-202,-197,-191,-186,-181,-175,-170,-164,-158,-153,-147,-141,-135,-130,-124,-118,-112,-106,-100,-94,-88,-81,-75,-69,-63,-57,-51,-44,-38,-32,-26,-19,-13,-7
	dw  -1
	
wave_table_255:
	db 0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46,49,51,54,57,60,63,65,68,71,73,76,78,81,83,85,88,90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116,117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127,127,127,127,127,126,126,126,125,125,124,123,122,122,121,120,118,117,116,115,113,112,111,109,107,106,104,102,100,98,96,94,92,90,88,85,83,81,78,76,73,71,68,65,63,60,57,54,51,49,46,43,40,37,34,31,28,25,22,19,16,12,9,6,3,0,-3,-6,-9,-12,-16,-19,-22,-25,-28,-31,-34,-37,-40,-43,-46,-49,-51,-54,-57,-60,-63,-65,-68,-71,-73,-76,-78,-81,-83,-85,-88,-90,-92,-94,-96,-98,-100,-102,-104,-106,-107,-109,-111,-112,-113,-115,-116,-117,-118,-120,-121,-122,-122,-123,-124,-125,-125,-126,-126,-126,-127,-127,-127,-127,-127,-127,-127,-126,-126,-126,-125,-125,-124,-123,-122,-122,-121,-120,-118,-117,-116,-115,-113,-112,-111,-109,-107,-106,-104,-102,-100,-98,-96,-94,-92,-90,-88,-85,-83,-81,-78,-76,-73,-71,-68,-65,-63,-60,-57,-54,-51,-49,-46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3
%endif
	
bgl_end: