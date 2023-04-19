%include "ball.asm"
%include "bats.asm"

game:
	not byte [bat_hit_sound]
	not byte [table_hit_sound]

	call bats_handler
	call game_init
	mov byte [game_started],0
	mov word [table_y_offset],table_height

.loop:
	call ball_serve_handler
	call bats_handler
	call ball_handler
	
	mov al,[bgl_background_colour]
	call bgl_flood_fill_full
	call stars_draw
	
	cmp byte [game_started],0
	je .table_only ; game hasn't started yet, only draw table
	mov byte [bgl_no_bounds],1
	call bat_2_draw
	cmp byte [bat_batting],0
	jne .ball_front
	cmp byte [ball_out],0
	je .ball_front
	call ball_draw
	call table_draw
	jmp .skip
.ball_front:
	call table_draw
	call ball_draw
	
	jmp .skip
.table_only:
	call table_draw
	call game_text_draw ; so the label's technically a lie :P
	sub word [table_y_offset],2
	inc word [star_y_offset]
	cmp word [table_y_offset],0
	jg .skip
	mov byte [game_started],1
	
.skip:
	cmp byte [game_started],0
	je .skip_2
	call bat_1_draw
.skip_2:
	call ending_text_draw
	call ending_cursor
	call game_text_draw
	
	call bgl_wait_retrace
	;call beep_pcm_handler
	call bgl_write_buffer
	call bgl_escape_exit_fade
	call beep_handler
	
	jmp .loop
	
	; stuff
	
again_button_x equ 84
again_button_y equ 120
again_button_width equ 68
again_button_height equ 28
again_button_clicked db 0

exit_button_x equ again_button_x+90
exit_button_y equ again_button_y
exit_button_width equ 54
exit_button_height equ again_button_height
	
table_sound_effect:
	not byte [bat_hit_sound]
	cmp byte [table_hit_sound],0
	jne .sound_2
	mov si,table1_pcm
	mov cx,table1_pcm_length
	jmp .end
.sound_2:
	mov si,table2_pcm
	mov cx,table2_pcm_length
.end:
	call blaster_play_sound
	ret
	
ending_buttons_draw:
	push bx
	push cx ; in case i affect them...
	push dx
	; called from within ending_cursor, so the mouse x and y are passed across in cx and dx respectively
	cmp word [ending_text_scale],0
	jne .end
	cmp byte [again_button_clicked],0
	jne .end
	
	mov byte [bgl_tint],0
	mov word [bgl_x_pos],again_button_x
	mov word [bgl_y_pos],again_button_y
	mov word [bgl_buffer_offset],again_button_rle
	
	mov word [bgl_collision_x1],again_button_x
	mov word [bgl_collision_y1],again_button_y
	mov word [bgl_collision_w1],again_button_width
	mov word [bgl_collision_h1],again_button_height
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],0
	je .again_button_skip
	mov al,[bgl_collision_flag]
	shl al,2
	mov byte [bgl_tint],al
	cmp bx,1 ; left button clicked?
	jne .again_button_skip
	dec word [ending_text_scale]
	mov byte [again_button_clicked],1
	; insert behaviour here
.again_button_skip:
	call bgl_draw_gfx_rle_fast
	
.exit_button:
	mov byte [bgl_tint],0
	
	add word [bgl_x_pos],90
	mov word [bgl_buffer_offset],exit_button_rle
	
	mov word [bgl_collision_x1],exit_button_x
	mov word [bgl_collision_y1],exit_button_y
	mov word [bgl_collision_w1],exit_button_width
	mov word [bgl_collision_h1],exit_button_height
	call bgl_point_collision_check
	cmp byte [bgl_collision_flag],0
	je .exit_button_skip
	mov al,[bgl_collision_flag]
	shl al,2
	mov byte [bgl_tint],al
	cmp bx,1 ; left button clicked?
	jne .exit_button_skip
	call bgl_fade_out
	call bgl_reset
	mov ah,4ch ; return to command line
	int 21h
	
.exit_button_skip:
	call bgl_draw_gfx_rle_fast
.end:

	mov byte [bgl_tint],0
	pop dx
	pop cx
	pop bx
	ret
	
ending_cursor:
	cmp word [ending_text_scale],0
	jne .end
	mov ax,3
	int 33h
	shr cx,1
	dec cx
	inc cx
	mov word [bgl_collision_x2],cx
	dec cx
	mov word [bgl_collision_y2],dx
	call ending_buttons_draw
	mov word [bgl_buffer_offset],cursor_gfx
	mov word [bgl_x_pos],cx
	mov word [bgl_y_pos],dx
	call bgl_draw_gfx_fast
.end:
	ret
	
ending_text_draw:
	cmp byte [game_over],0
	je .end
	mov byte [bgl_no_bounds],0
	mov ax,[ending_text_x_pos]
	push bx
	mov bx,[ending_text_scale]
	sar bx,1
	add ax,bx
	pop bx
	mov word [bgl_x_pos],ax
	mov ax,[ending_text_y_pos]
	sar ax,1 ; this...
	mov word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],you_gfx
	cmp word [ending_text_scale],0
	je .non_scale
	call bgl_draw_gfx_scale
	jmp .scale_skip
.non_scale:
	call bgl_draw_gfx_fast
.scale_skip:
	add word [bgl_x_pos],32
	push bx
	mov bx,[ending_text_scale]
	sub bx,ending_text_scale_initial
	sar bx,1 ; ...and this are unrelated
	sub word [bgl_x_pos],bx
	pop bx
	cmp byte [game_winner],0
	je .win
	mov word [bgl_buffer_offset],lose_gfx
	jmp .skip
.win:
	mov word [bgl_buffer_offset],win_gfx
.skip:
	cmp byte [again_button_clicked],0 ; playing again?
	je .skip_2 ; if not, zoom in
	dec word [ending_text_y_pos] ; if so, zoom out
	inc word [ending_text_scale]
	cmp word [ending_text_scale],ending_text_scale_initial
	jl .skip_3
	call game_init
	jmp .skip_3
.skip_2:
	cmp word [ending_text_scale],0
	je .non_scale_2
	inc word [ending_text_y_pos]
	dec word [ending_text_scale]
.skip_3:
	movzx eax,word [ending_text_scale]
	mov dword [bgl_scale_x],eax
	mov dword [bgl_scale_y],eax
	call bgl_draw_gfx_scale
	jmp .end
	
.non_scale_2:
	call bgl_draw_gfx_fast
	
	cmp byte [game_winner],0
	je .win_2
	mov word [bgl_x_pos],32
	mov word [bgl_y_pos],64
	mov word [bgl_font_string_offset],game_over_message_2
	call bgl_draw_font_string
	mov word [bgl_x_pos],36
	add word [bgl_y_pos],10
	mov word [bgl_font_string_offset],game_over_message_2b
	call bgl_draw_font_string
	jmp .end
.win_2:
	mov word [bgl_x_pos],26
	mov word [bgl_y_pos],64
	mov word [bgl_font_string_offset],game_over_message_1
	call bgl_draw_font_string
	mov word [bgl_x_pos],46
	add word [bgl_y_pos],10
	mov word [bgl_font_string_offset],game_over_message_1b
	call bgl_draw_font_string
	mov word [bgl_x_pos],80
	add word [bgl_y_pos],10
	mov word [bgl_font_string_offset],game_over_message_1c
	call bgl_draw_font_string
.end:
	ret
	
game_init:
	mov byte [game_over],0 ; no need to initialize game_winner, it'll be changed anyway
	mov word [table_y_offset],0
	mov byte [ball_served],0
	mov word [bat_2_x_pos],bat_2_x_centre
	mov word [bat_2_y_pos],90
	mov byte [bat_2_x_timer],-2 ; MWAHAHAHAHAAAAA
	mov word [bgl_font_offset],font_gfx
	mov byte [bgl_font_size],8
	mov byte [bgl_font_spacing],8
	mov byte [again_button_clicked],0
	mov byte [bat_1_points],0
	mov byte [bat_2_points],0
	
	mov word [ending_text_x_pos],90
	mov word [ending_text_y_pos],-16<<1
	mov word [ending_text_scale],ending_text_scale_initial
	call ball_reset
	ret
	
game_text_draw:
	cmp byte [ball_served],1
	je .served_skip
	cmp byte [game_started],0
	je .served_skip
	cmp byte [game_over],0
	jne .served_skip
	mov byte [bgl_flip],0
	mov word [bgl_x_pos],96
	mov word [bgl_y_pos],40
	mov word [bgl_font_string_offset],serve_message
	call bgl_draw_font_string
.served_skip:
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],bgl_get_font_offset("P",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("1",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":",font_gfx)
	call bgl_draw_gfx_fast
	
	movzx ax,[bat_1_points]
	mov bx,font_gfx
	call bgl_get_font_number_offset
	mov word [bgl_buffer_offset],ax
	add word [bgl_x_pos],8
	call bgl_draw_gfx_fast
	
	mov word [bgl_x_pos],320-(8*4)
	mov word [bgl_buffer_offset],bgl_get_font_offset("P",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("2",font_gfx)
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":",font_gfx)
	call bgl_draw_gfx_fast
	
	movzx ax,[bat_2_points]
	mov bx,font_gfx
	call bgl_get_font_number_offset
	mov word [bgl_buffer_offset],ax
	add word [bgl_x_pos],8
	call bgl_draw_gfx_fast
	
	ret
	
table_draw:
	mov word [bgl_buffer_offset],table_rle
	mov word [bgl_x_pos],table_x
	mov ax,table_y
	add ax,[table_y_offset]
	mov word [bgl_y_pos],ax
	;mov byte [bgl_flip],0
	;mov al,[game_started]
	;mov byte [bgl_no_bounds],al
	cmp byte [game_started],0
	jne .fast
	call bgl_draw_gfx_rle
	jmp .end
.fast:
	call bgl_draw_gfx_rle_fast
	;add word [bgl_x_pos],table_width-1
	;mov byte [bgl_flip],1
	;call bgl_draw_gfx_rle
.end:
	ret
	
game_started db 0 ; used for the Fancy Intro Scroll-Up
game_over db 0 ; use for you win/try again
game_winner db 0 ; 0 is me, 1 is you (me you you me)

you_gfx: incbin "you.gfx"
win_gfx: incbin "win.gfx"
lose_gfx: incbin "lose.gfx"
ending_text_x_pos dw 0
ending_text_y_pos dw 0
ending_text_scale dw 0
ending_text_scale_initial equ 64

table_rle: incbin "table.rle"
table_top_edge equ 58
table_x equ 40
table_y equ 200-table_height
table_width equ 112
table_height equ 78

bat_hit_sound db 0
table_hit_sound db 0

table_y_offset dw 0 ; used for intro

again_button_rle: incbin "again_button.rle"
exit_button_rle: incbin "exit_button.rle"

serve_message: db "CLICK TO SERVE...",0
game_over_message_1: db "YOU ARE NOW THE PING-PONG CHAMPION",0
game_over_message_1b: db "OF OUTER SPACE... EVEN THOUGH",0
game_over_message_1c: db "YOU'RE THE ONLY ONE",0
game_over_message_2: db "OH WELL... BETTER LUCK NEXT TIME",0
game_over_message_2b: db "KID. YOU'LL GET THERE, PROBABLY",0

table_sfx: dw 12000,18000,23000,0
bat_1_sfx: dw 400,0
bat_2_sfx: dw 800,0
out_sfx:
%assign b 0
%rep 6
	%assign a 10000
	%rep 10
		dw a-b
		%assign a a-300
	%endrep
	%assign b b+1200
%endrep
dw 0