title_screen:
	mov word [title_ball_angle],0
	mov word [title_ball_x_vel],3
	mov word [title_ball_x_pos],18
	mov word [title_ball_y_vel],0
	mov word [title_ball_y_pos],-13
	mov byte [title_ball_active],1
	
	mov word [logo_word_x_pos],40+10
	mov word [logo_word_x_pos+2],140+10
	mov word [logo_word_x_pos+4],210+10
	mov ax,logo_word_start_y
	mov word [logo_word_y_pos],ax
	mov word [logo_word_y_pos+2],ax
	mov word [logo_word_y_pos+4],ax
	
	mov ax,-32
	mov word [select_box_x_pos],ax
	mov word [select_box_x_pos+2],ax
	mov word [select_box_x_pos+4],ax
	mov word [select_box_y_pos],select_box_start_y
	mov word [select_box_y_pos+2],select_box_start_y+32+4
	mov word [select_box_y_pos+4],select_box_start_y+32+4+32+4 ; laziness
	mov byte [select_box_delay],0
	mov byte [select_box_current],0
	mov byte [select_box_rollover],3
	
	mov word [star_y_offset],0
.loop:
	mov al,[bgl_background_colour]
	call bgl_flood_fill_full

	call title_logo_draw
	call stars_draw
	call title_ball_draw
	call title_select_draw
	call title_start_button
	call title_blerb_draw
	
	call title_ball_handler
	call title_logo_handler
	call title_select_handler
	;call beep_handler

	call title_cursor
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	call bgl_escape_exit_fade
	
	cmp byte [faded],0
	jne .end
	mov byte [faded],1
	call bgl_fade_in
.end:
	jmp .loop

title_blerb_draw:
	cmp byte [intro_section],2 ; comin on strong
	jne .end
	mov word [bgl_font_offset],font_gfx
	mov word [bgl_x_pos],96
	mov word [bgl_y_pos],select_box_start_y
	mov byte [bgl_font_size],8
	mov byte [bgl_font_spacing],8
	cmp byte [select_box_rollover],0
	je .dew
	cmp byte [select_box_rollover],1
	je .doong
	cmp byte [select_box_rollover],2
	je .pres
	jmp .chooz
.dew:
	mov word [bgl_font_string_offset],blurb_dew_1
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_2
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_3
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_4
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_5
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_6
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_7
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_dew_8
	call bgl_draw_font_string
	jmp .end
.doong:
	mov word [bgl_font_string_offset],blurb_doong_1
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_2
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_3
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_4
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_5
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_6
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_doong_7
	call bgl_draw_font_string
	jmp .end
.pres:
	mov word [bgl_font_string_offset],blurb_pres_1
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_pres_2
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_pres_3
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_pres_4
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_pres_5
	call bgl_draw_font_string
	jmp .end
.chooz:
	sub word [bgl_x_pos],10
	add word [bgl_y_pos],20
	mov word [bgl_font_string_offset],blurb_chooz_1
	call bgl_draw_font_string
	add word [bgl_y_pos],12
	mov word [bgl_font_string_offset],blurb_chooz_2
	call bgl_draw_font_string
.end:
	ret

title_start_button:
	cmp byte [intro_section],2
	jne .end
	
	mov al,[start_button_rollover]
	shl al,2
	mov byte [bgl_tint],al
	mov word [bgl_buffer_offset],start_button_rle
	mov word [bgl_x_pos],start_button_x_pos
	mov word [bgl_y_pos],start_button_y_pos
	call bgl_draw_gfx_rle
	mov byte [bgl_tint],0
.end:
	ret

title_select_handler:
	mov ax,3
	cmp byte [intro_section],1
	je .fly_in
	cmp byte [intro_section],3
	je .fly_out
	jmp .end
.fly_in:
	cmp byte [select_box_current],3
	je .end
	mov bl,[select_box_current]
	shl bl,1
	add word [select_box_x_pos+bx],ax
	inc byte [select_box_delay]
	cmp byte [select_box_delay],25
	jb .end
	mov byte [select_box_delay],0
	inc byte [select_box_current]
	cmp byte [select_box_current],3
	jb .sound
	mov byte [intro_section],2
	jmp .end
.fly_out:
	sub word [select_box_x_pos],ax
	sub word [select_box_x_pos+2],ax
	sub word [select_box_x_pos+4],ax
	inc byte [select_box_delay]
	cmp byte [select_box_delay],25
	jb .end
	mov byte [select_box_delay],0
	mov byte [intro_section],4
	jmp .end
.sound:
	mov si,swoosh_pcm
	mov cx,swoosh_pcm_length
	call blaster_play_sound
.end:
	ret

title_select_draw:
	cmp byte [intro_section],0 ; draw select boxes for every section above 0
	je .end
	
	xor bx,bx
.loop:
	cmp bx,0
	je .dew
	cmp bx,2
	je .doong
	jmp .pres
.dew:
	mov word [bgl_buffer_offset],select_dew_rle
	jmp .draw
.doong:
	mov word [bgl_buffer_offset],select_doong_rle
	jmp .draw
.pres:
	mov word [bgl_buffer_offset],select_pres_rle
.draw:
	mov ax,[select_box_y_pos+bx]
	mov word [bgl_y_pos],ax
	
	mov ax,[select_box_x_pos+bx]
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx_rle
	;
	neg ax
	add ax,320-32
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx_rle

	cmp bx,4
	je .arrow
	add bx,2
	jmp .loop
.arrow:
	inc byte [select_arrow_flash]
	and byte [select_arrow_flash],7
	cmp byte [intro_section],2
	jne .end
	cmp byte [select_arrow_flash],3
	ja .end
	mov byte [bgl_flip],0
	mov word [bgl_buffer_offset],select_arrow_rle
	mov ax,[select_box_x_pos]
	sub ax,32
	mov word [bgl_x_pos],ax
	movzx ax,[bat_1_type]
	mov bx,32+4
	xor dx,dx
	mul bx
	add ax,select_box_start_y+3
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	
	mov byte [bgl_flip],1
	mov ax,[select_box_x_pos]
	neg ax
	add ax,(320-32)+32+12+4
	mov word [bgl_x_pos],ax
	movzx ax,[bat_2_type]
	mov bx,32+4
	xor dx,dx
	mul bx
	add ax,select_box_start_y+3
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	
	mov byte [bgl_flip],0
.end:
	ret

title_cursor:
	cmp byte [intro_section],2
	jne .end
	
	mov ax,3
	int 33h
	shr cx,1
	dec cx
	mov word [bgl_x_pos],cx
	mov word [bgl_y_pos],dx
	mov word [bgl_buffer_offset],cursor_gfx
	call bgl_draw_gfx_fast
	
	; start button rollover
	
	inc cx
	mov word [bgl_collision_x2],cx
	mov word [bgl_collision_y2],dx
	
	mov word [bgl_collision_x1],start_button_x_pos
	mov word [bgl_collision_y1],start_button_y_pos
	mov word [bgl_collision_w1],68
	mov word [bgl_collision_h1],28
	
	call bgl_point_collision_check
	mov al,[bgl_collision_flag]
	mov byte [start_button_rollover],al
	
	mov byte [select_box_rollover],3
	cmp bx,1 ; left button clicked?
	jne .select_boxes
	
.select_boxes:
	; select boxes
	
	mov ax,[select_box_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[select_box_y_pos]
	mov word [bgl_collision_y1],ax
	mov word [bgl_collision_w1],32
	mov word [bgl_collision_h1],32
	
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_1_dew ; not the best way, but there's only 3 so we can get away with it
	
	mov ax,[select_box_x_pos]
	neg ax
	add ax,320-32
	mov word [bgl_collision_x1],ax
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_2_dew
	
	;;;
	
	mov ax,[select_box_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[select_box_y_pos+2]
	mov word [bgl_collision_y1],ax
	
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_1_doong
	
	mov ax,[select_box_x_pos]
	neg ax
	add ax,320-32
	mov word [bgl_collision_x1],ax
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_2_doong
	
	;;;
	
	mov ax,[select_box_x_pos]
	mov word [bgl_collision_x1],ax
	mov ax,[select_box_y_pos+4]
	mov word [bgl_collision_y1],ax
	
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_1_pres
	
	mov ax,[select_box_x_pos]
	neg ax
	add ax,320-32
	mov word [bgl_collision_x1],ax
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .select_2_pres
	
	;; start button clicked
	
	cmp bx,1
	jne .end
	mov word [bgl_collision_x1],start_button_x_pos
	mov word [bgl_collision_y1],start_button_y_pos
	mov word [bgl_collision_w1],68
	mov word [bgl_collision_h1],28
	
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],1
	je .start
	
	jmp .end
	
.start:
	mov byte [intro_section],3
	mov byte [select_box_delay],0
	jmp .end
	
.select_1_dew:
	mov byte [select_box_rollover],0
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_1_type],0
	jmp .end
.select_2_dew:
	mov byte [select_box_rollover],0
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_2_type],0
	jmp .end
.select_1_doong:
	mov byte [select_box_rollover],1
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_1_type],1
	jmp .end
.select_2_doong:
	mov byte [select_box_rollover],1
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_2_type],1
	jmp .end
.select_1_pres:
	mov byte [select_box_rollover],2
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_1_type],2
	jmp .end
.select_2_pres:
	mov byte [select_box_rollover],2
	cmp bx,1 ; left button clicked?
	jne .end
	mov byte [bat_2_type],2
	jmp .end
	
.end:
	ret

title_logo_handler:
	cmp byte [intro_section],1
	je .end
	cmp byte [intro_section],2
	je .end
	cmp byte [intro_section],3
	je .end
	cmp byte [title_ball_active],0
	je .rise_all ; if ball's inactive, rise all letters
	cmp byte [logo_rising],0
	je .end ; if logo isn't rising yet, do nothing
	cmp byte [logo_rising_delay],20 ; only rise to a certain point
	ja .end
	mov bl,[logo_word_rising]
	dec bl ; because of how it works; increasing on every bounce, but only moving if logo_rising is set
	shl bl,1
	mov ax,3
	sub word [logo_word_y_pos+bx],ax
	inc byte [logo_rising_delay]
	jmp .end
.rise_all:
	inc byte [logo_rising_delay]
	cmp byte [logo_rising_delay],30
	jb .end
	mov ax,2
	sub word [logo_word_y_pos],ax
	sub word [logo_word_y_pos+2],ax
	sub word [logo_word_y_pos+4],ax
	cmp byte [intro_section],0
	je .first_check
	cmp word [logo_word_y_pos],-80
	jg .end
	jmp game
.first_check:
	cmp word [logo_word_y_pos],20
	jg .end
	mov byte [intro_section],1
	mov si,swoosh_pcm
	mov cx,swoosh_pcm_length
	call blaster_play_sound
.end:
	ret
	
title_logo_draw:
	xor bx,bx
.loop:
	cmp bx,0
	je .word_1
	cmp bx,2
	je .word_2
	cmp bx,4
	je .word_3
.word_1:
	mov word [bgl_buffer_offset],logo_1_rle
	jmp .word_skip
.word_2:
	mov word [bgl_buffer_offset],logo_2_rle
	jmp .word_skip
.word_3:
	mov word [bgl_buffer_offset],logo_3_rle

.word_skip:
	mov ax,[logo_word_x_pos+bx]
	mov word [bgl_x_pos],ax
	mov ax,[logo_word_y_pos+bx]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle

	cmp bx,4
	je .cover
	add bx,2
	jmp .loop
.cover:
	cmp byte [intro_section],0
	jne .end
	; cover up the logo text...
	mov al,[bgl_background_colour]
	mov di,(320*logo_word_start_y)
	mov cx,(320*30)
	call bgl_flood_fill_fast
.end:
	ret

title_ball_draw:
	cmp byte [title_ball_active],0
	je .end
	
	mov word [bgl_buffer_offset],ball_1_gfx
	mov ax,[title_ball_x_pos]
	mov word [bgl_x_pos],ax
	mov ax,[title_ball_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,[title_ball_angle]
	mov word [bgl_rotate_angle],ax
	call bgl_draw_gfx_rotate
.end:
	ret

title_ball_handler:
	cmp byte [intro_section],0
	jne .end
	cmp byte [title_ball_active],0
	je .end

	mov ax,[title_ball_x_vel]
	add word [title_ball_x_pos],ax

	mov ax,[title_ball_y_vel]
	sar ax,1
	add word [title_ball_y_pos],ax
	inc word [title_ball_y_vel]
	cmp word [title_ball_y_pos],logo_word_start_y-13 ; reached text y?
	jl .y_skip
	mov si,table1_pcm
	mov cx,table1_pcm_length
	call blaster_play_sound
	mov word [title_ball_y_vel],-18 ; bounce da ball
	mov byte [logo_rising],1
	inc byte [logo_word_rising]
	mov byte [logo_rising_delay],0
	mov word [title_ball_x_vel],2
	cmp byte [logo_word_rising],3 ; on last word?
	jne .y_skip
	inc word [title_ball_x_vel] ; help it along
.y_skip:
	sub word [title_ball_angle],8
	
	cmp word [title_ball_x_pos],320 ; reached right side of screen?
	jl .end
	mov byte [title_ball_active],0 ; make the ball inactive if so
	mov byte [logo_rising_delay],0
.end:
	ret

faded db 0
intro_section db 0 ; 0: ball bouncing, words rising, all that good stuff, 1: players fly in from the sides, 2: you decide who's playin', 3: players fly out, 4: logo goes up
title_ball_angle dw 0
title_ball_y_vel dw 0
title_ball_x_pos dw 0
title_ball_y_pos dw 0
title_ball_x_vel dw 0
title_ball_active db 0

logo_rising db 0 ; rising at all?
logo_word_rising db 0 ; the word that's currently rising
logo_rising_delay db 0
logo_word_x_pos dw 0,0,0
logo_word_y_pos dw 0,0,0
logo_word_start_y equ 120

select_box_x_pos dw 0,0,0 ; 3 on both sides (using neg for the other side)
select_box_y_pos dw 0,0,0 ; 3 on both sides
select_box_delay db 0
select_box_current db 0
select_box_start_y equ 60
select_arrow_flash db 0

logo_1_rle: incbin "logo_1.rle"
logo_2_rle: incbin "logo_2.rle"
logo_3_rle: incbin "logo_3.rle" ; logo 3, rle, three little munkys up a coconut tree
select_arrow_rle: incbin "select_arrow.rle"
select_dew_rle: incbin "select_dew.rle"
select_doong_rle: incbin "select_doong.rle"
select_pres_rle: incbin "select_pres.rle"
select_box_rollover db 0 ; which type is rolled over on either side?

start_button_rle: incbin "start_button.rle"
start_button_x_pos equ (320/2)-(68/2)
start_button_y_pos equ 160
start_button_rollover db 0

;voice_1_pcm: incbin "voice_1_bin.raw"
;voice_1_pcm_length equ $-voice_1_pcm
;voice_2_pcm: incbin "voice_2_bin.raw"
;voice_2_pcm_length equ $-voice_2_pcm
;voice_3_pcm: incbin "voice_3_bin.raw"
;voice_3_pcm_length equ $-voice_3_pcm

bat_1_type db 0 ; used for selections, that's why it's here
bat_2_type db 2

blurb_dew_1:   db "PAC-DEW: THE ONE",0
blurb_dew_2:   db "DEW OF THEM ALL.",0
blurb_dew_3:   db "ORIGINATING IN A",0
blurb_dew_4:   db "MOUNTAIN DEW AND",0
blurb_dew_5:   db "PAC-MAN ADVERT,",0
blurb_dew_6:   db "HE PACKS HIGH",0
blurb_dew_7:   db "SKILL AND LOTS",0
blurb_dew_8:   db "OF AGILITY",0
blurb_doong_1: db "THE MAIN MAN",0
blurb_doong_2: db "OF THE POPULAR",0
blurb_doong_3: db "KIDS FRANCHISE",0
blurb_doong_4: db "WUTTY PRONG",0
blurb_doong_5: db "DOONG, HE EATS A",0
blurb_doong_6: db "LOT AND ALWAYS",0
blurb_doong_7: db "SAYS ",34,"REAH!",34,0
blurb_pres_1:  db "CAREFUL WITH HIM",0
blurb_pres_2:  db "HE WANTS YOU TO",0
blurb_pres_3:  db "KEEP YOUR HANDS",0
blurb_pres_4:  db "CLEAN AT ALL",0
blurb_pres_5:  db "TIMES, BEWARE...",0
blurb_chooz_1: db " CHOOSE CHARACTER",0
blurb_chooz_2: db "FOR PLAYER 1 AND 2",0