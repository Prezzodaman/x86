%include "ball.asm"
%include "bats.asm"

game:
	call bats_handler
	
	; it's so important to initialize here!
	mov byte [game_started],0
	mov word [table_y_offset],table_height
	mov word [bat_2_x_pos],bat_2_x_centre
	mov word [bat_2_y_pos],90
	mov byte [bat_2_x_timer],-2 ; MWAHAHAHAHAAAAA
	
	call ball_reset

.loop:
	call ball_serve_handler
	call ball_handler
	call bats_handler
	
	mov al,[bgl_background_colour]
	call bgl_flood_fill_full
	
	cmp byte [game_started],0
	je .table_only ; game hasn't started yet, only draw table
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
	cmp word [table_y_offset],0
	jg .skip
	mov byte [game_started],1
	
.skip:
	cmp byte [game_started],0
	je .skip_2
	call bat_1_draw
.skip_2:
	call game_text_draw
	
	call bgl_wait_retrace
	;call beep_pcm_handler
	call bgl_write_buffer_fast
	call bgl_escape_exit
	call beep_handler
	
	jmp .loop
	
	; stuff
	
game_text_draw:
	cmp byte [ball_served],1
	je .served_skip
	cmp byte [game_started],0
	je .served_skip
	mov byte [bgl_flip],0
	mov word [bgl_font_offset],font_gfx
	mov word [bgl_x_pos],96
	mov word [bgl_y_pos],40
	mov byte [bgl_font_size],8
	mov byte [bgl_font_spacing],8
	mov word [bgl_font_string_offset],serve_message
	call bgl_draw_font_string
.served_skip:
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov word [bgl_buffer_offset],bgl_get_font_offset("P")
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("1")
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":")
	call bgl_draw_gfx_fast
	
	movzx ax,[bat_1_points]
	mov bx,font_gfx
	call bgl_get_font_number_offset
	mov word [bgl_buffer_offset],ax
	add word [bgl_x_pos],8
	call bgl_draw_gfx_fast
	
	mov word [bgl_x_pos],320-(8*4)
	mov word [bgl_buffer_offset],bgl_get_font_offset("P")
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset("2")
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	mov word [bgl_buffer_offset],bgl_get_font_offset(":")
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
	mov byte [bgl_flip],0
	mov al,[game_started]
	mov byte [bgl_no_bounds],al
	call bgl_draw_gfx_rle
	add word [bgl_x_pos],table_width-1
	mov byte [bgl_flip],1
	call bgl_draw_gfx_rle
	ret
	
game_started db 0 ; used for the Fancy Intro Scroll-Up
	
table_rle: incbin "table.rle"
table_top_edge equ 58
table_x equ 40
table_y equ 200-table_height
table_width equ 112
table_height equ 78

table_y_offset dw 0 ; used for intro

serve_message: db "CLICK TO SERVE...",0

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