
	org 100h
	
	call bgl_init
	
	mov si,intro_song
	call beep_play_sfx
	
main:
	push cx
	mov al,15
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	pop cx

	mov byte [bgl_erase],0
	mov word [bgl_buffer_offset],cursor_gfx
	cmp byte [cursor_falling],0
	jne .start_skip
	mov word [cursor_x_old],cx
	mov ax,3
	int 33h
	mov word [cursor_y_pos],dx
	shr cx,1
	sub cx,12
	mov word [cursor_x_pos],cx
	mov ax,[cursor_angle]
	sar ax,3
	sub word [cursor_x_pos],ax
	cmp bx,1
	jne .start_skip
	mov byte [game_started],1
	mov word [seconds],0
.start_skip:
	mov ax,[cursor_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[cursor_y_pos]
	mov word [bgl_y_pos],ax
	
	cmp byte [game_started],0
	jne .start_skip2 ; if game started, draw the cursor rotated
	call bgl_draw_gfx ; if not, draw the cursor normally
	
	call draw_seconds
	call draw_intro_text
	mov word [text_y_pos],8
	jmp .skip

.start_skip2:
	call draw_seconds
	cmp word [text_y_pos],-32
	jl .start_skip3
	dec word [text_y_pos]
	dec word [text_y_pos]
	call draw_intro_text

.start_skip3:
	
	cmp byte [cursor_falling],0
	jne .start_skip4
	mov ax,[cursor_x_old] ; x distance
	sub ax,cx
	sal ax,2 ; mouse angling sensitivity
.start_skip4:
	push ax ;-
	
	mov ax,[bgl_rotate_angle]
	xor dx,dx
	mov bx,360+2
	div bx
	mov word [bgl_rotate_angle],dx
	
	mov byte [bgl_erase],0
	mov word [bgl_buffer_offset],cursor_gfx
	call bgl_draw_gfx_rotate
	
	; slowly increase/decrease the cursor's rotation
	mov ax,[cursor_angle_addness]
	sar ax,5
	add word [cursor_angle],ax
	cmp word [cursor_angle],0 ; is the cursor angle positive?
	jge .cursor_angle_increase ; if so, increase angle
	dec word [cursor_angle_addness] ; if it's negative, decrease angle
	jmp .cursor_skip
.cursor_angle_increase:
	inc word [cursor_angle_addness]
.cursor_skip:
	cmp byte [cursor_falling],0
	jne .cursor_skip2 ; if cursor is falling, do the fally stuff
	cmp word [cursor_angle],64
	jg .cursor_fall ; rotated too far to the left or right, fall
	cmp word [cursor_angle],-64
	jl .cursor_fall
	jmp .cursor_end
.cursor_fall:
	mov byte [cursor_falling],1
	mov byte [beep_sfx_playing],0
	call beep_on

.cursor_skip2:
	cmp byte [cursor_falling],0 ; only execute the falling sets once
	je .cursor_end
	
	movzx dx,[cursor_fall_vel]
	shl dx,7
	add dx,800
	call beep_change
	mov ax,[cursor_angle_addness]
	sar ax,5
	add word [cursor_angle],ax
	sar ax,1
	sub word [cursor_x_pos],ax
	movzx ax,[cursor_fall_vel]
	shr ax,2
	add word [cursor_y_pos],ax
	inc byte [cursor_fall_vel]
	cmp word [cursor_y_pos],200-32 ; reached bottom of the screen?
	jl .cursor_end
	call beep_off
	mov byte [cursor_falling],0
	mov word [cursor_fall_vel],0
	mov word [cursor_angle],0
	mov word [cursor_angle_addness],0
	mov byte [game_started],0
	mov byte [seconds_delay],0

.cursor_end:
	pop bx ;-
	
	inc byte [seconds_delay]
	cmp byte [seconds_delay],70
	jb .seconds_skip
	mov byte [seconds_delay],0
	inc word [seconds]
	
.seconds_skip:
	mov ax,[cursor_angle]
	sub ax,bx
	add word [cursor_angle_addness],bx
	mov word [bgl_rotate_angle],ax
	
	; find absolute value of addness
	; formula: (x xor y) - y
	; where y = x>>15
	mov ax,[cursor_angle_addness] ; x
	mov bx,ax ; y
	shr bx,15
	xor ax,bx ; x xor y
	sub ax,bx ; - y
	shr ax,2 ; reduce overall value
	mov bx,ax ; bx = abs(x)
	
	cmp byte [cursor_falling],0
	jne .skip
	inc byte [heartbeat_timer]
	
	mov ax,80
	sub ax,bx ; base value - absolute value of addness
	cmp byte [heartbeat_timer],al
	jb .skip
	mov byte [heartbeat_timer],0
	mov si,heartbeat_sfx
	call beep_play_sfx

.skip:
	call bgl_wait_retrace
	call bgl_write_buffer
	
	cmp byte [game_started],0
	je .beep_handler_slow ; if game NOT started, slow down handler
	call beep_handler ; if game started, handle as normal
	
.beep_handler_slow:
	inc byte [beep_delay]
	cmp byte [beep_delay],3
	jb .end
	mov byte [beep_delay],0
	call beep_handler

.end:
	call bgl_escape_exit
	jmp main
	

draw_intro_text:
	push word [bgl_x_pos]
	push word [bgl_y_pos]
	
	; intro text
	mov byte [bgl_erase],1
	mov byte [bgl_background_colour],0
	mov word [bgl_font_offset],font_gfx-stupid_constant-stupid_constant_2-stupid_constant_3
	mov byte [bgl_font_size],8
	mov byte [bgl_font_spacing],8
	mov word [bgl_x_pos],8*10
	mov ax,[text_y_pos]
	mov word [bgl_y_pos],ax
	mov word [bgl_font_string_offset],beginning_message
	call bgl_draw_font_string
	add word [bgl_y_pos],16
	sub word [bgl_x_pos],4*2
	mov word [bgl_font_string_offset],beginning_message_2
	call bgl_draw_font_string
	
	pop word [bgl_y_pos]
	pop word [bgl_x_pos]
	ret

draw_seconds:
	push word [bgl_x_pos]
	push word [bgl_y_pos]
	push cx
	
	; seconds counter
	mov byte [bgl_erase],1
	mov byte [bgl_background_colour],0
	mov word [bgl_font_offset],font_gfx-stupid_constant-stupid_constant_2-stupid_constant_3
	mov byte [bgl_font_size],8
	mov byte [bgl_font_spacing],8
	mov word [bgl_x_pos],2
	mov word [bgl_y_pos],200-8
	mov word [bgl_font_string_offset],seconds_message
	call bgl_draw_font_string
	
	mov ax,[seconds]
	mov cx,3
	mov word [bgl_x_pos],138+(8*2)
.loop:
	push ax
	pop ax
	mov bx,10
	xor dx,dx
	div bx ; divide by 10: dx will contain the remainder, the last digit
	mov word [bgl_buffer_offset],font_gfx
	; calculate the offset...
	mov bx,(8*8)+2 ; size of each number + header
	push ax ;- ax contains the remainder, but we need the divisor...
	push dx ;-- dx contains our remainder and will have an effect on mul
	mov ax,dx
	xor dx,dx
	mul bx
	add word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	sub word [bgl_x_pos],8
	pop dx ;--
	pop ax ;-
	loop .loop
	
	pop cx
	pop word [bgl_y_pos]
	pop word [bgl_x_pos]
	ret

stupid_constant equ 99*14 ; why these numbers, just... eh.. ssfff... WHYYYYY??!?!
stupid_constant_2 equ 2*25
stupid_constant_3 equ 16
stupid_letter_constant equ stupid_constant-stupid_constant_2-stupid_constant_3
	
cursor_gfx: incbin "cursor.gfx"
%include "../bgl.asm"
%include "../beeplib.asm"

beginning_message:
	db "POSITION THE CURSOR",0
beginning_message_2:
	db "THEN CLICK WHEN READY",0
seconds_message:
	db "SECONDS SURVIVED",0

game_started db 0
cursor_x_old dw 0
cursor_angle dw 0
cursor_angle_addness dw 0
cursor_falling db 0
cursor_fall_vel db 0
cursor_x_pos dw 0
cursor_y_pos dw 0
text_y_pos dw 0

seconds dw 0
seconds_delay db 0

heartbeat_sfx:
	dw 10000,12000,18000,22000,2,2,2,2,2,2,2,2,2,2,2,2,10000,12000,18000,22000,0
heartbeat_timer db -2
beep_delay db -2

intro_song:
	dw beep_f_sharp_3,2,beep_f_sharp_3,2,beep_g_sharp_3,2,beep_a_sharp_3,2
	dw beep_a_sharp_3,2,beep_f_sharp_4,2,beep_g_sharp_4,2,beep_a_sharp_4,2
	dw beep_g_sharp_4,2,beep_f_sharp_4,2,beep_a_sharp_3,2,beep_a_sharp_3,2
	dw beep_g_sharp_3,2,beep_f_sharp_3,2,beep_a_sharp_2,2,beep_f_sharp_3
	dw 0

font_gfx:
	incbin "../bgl/c64_0.gfx"
	incbin "../bgl/c64_1.gfx"
	incbin "../bgl/c64_2.gfx"
	incbin "../bgl/c64_3.gfx"
	incbin "../bgl/c64_4.gfx"
	incbin "../bgl/c64_5.gfx"
	incbin "../bgl/c64_6.gfx"
	incbin "../bgl/c64_7.gfx"
	incbin "../bgl/c64_8.gfx"
	incbin "../bgl/c64_9.gfx"
	incbin "../bgl/c64_a.gfx"
	incbin "../bgl/c64_b.gfx"
	incbin "../bgl/c64_c.gfx"
	incbin "../bgl/c64_d.gfx"
	incbin "../bgl/c64_e.gfx"
	incbin "../bgl/c64_f.gfx"
	incbin "../bgl/c64_g.gfx"
	incbin "../bgl/c64_h.gfx"
	incbin "../bgl/c64_i.gfx"
	incbin "../bgl/c64_j.gfx"
	incbin "../bgl/c64_k.gfx"
	incbin "../bgl/c64_l.gfx"
	incbin "../bgl/c64_m.gfx"
	incbin "../bgl/c64_n.gfx"
	incbin "../bgl/c64_o.gfx"
	incbin "../bgl/c64_p.gfx"
	incbin "../bgl/c64_q.gfx"
	incbin "../bgl/c64_r.gfx"
	incbin "../bgl/c64_s.gfx"
	incbin "../bgl/c64_t.gfx"
	incbin "../bgl/c64_u.gfx"
	incbin "../bgl/c64_v.gfx"
	incbin "../bgl/c64_w.gfx"
	incbin "../bgl/c64_x.gfx"
	incbin "../bgl/c64_y.gfx"
	incbin "../bgl/c64_z.gfx"