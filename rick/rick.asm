
	org 100h
	
	call bgl_get_orig_key_handler
	call bgl_replace_key_handler
	call bgl_init
	
	mov si,song
	call beep_play_sfx
	
main:
	mov al,15
	call bgl_flood_fill_full
	
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	
	mov word [bgl_y_pos],10
	mov word [bgl_x_pos],10
	mov ax,text_1_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	mov word [bgl_x_pos],230
	mov ax,text_2_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	
	mov word [bgl_x_pos],90
	mov word [bgl_y_pos],200-111
	mov ax,rick_body_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	
	xor bx,bx
	mov bl,[wave_table_x_index]
	mov ax,[wave_table+bx]
	sar ax,4
	add ax,110
	add byte [wave_table_x_index],4
	cmp byte [wave_table_x_index],62*2
	jb .skip
	mov byte [wave_table_x_index],0
.skip:
	mov word [bgl_x_pos],ax
	mov bl,[wave_table_y_index]
	mov ax,[wave_table+bx]
	sar ax,4
	add ax,44
	add byte [wave_table_y_index],2
	cmp byte [wave_table_y_index],62*2
	jb .skip2
	mov byte [wave_table_y_index],0
.skip2:
	mov word [bgl_y_pos],ax
	mov ax,rick_head_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	
	cmp byte [song_delay],8
	jb .skip3
	call beep_handler
	mov byte [song_delay],0
.skip3:
	inc byte [song_delay]
	
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .end
	jmp exit
	
.end:
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	jmp main

exit:
	call bgl_restore_orig_key_handler
	call beep_off
	
	mov al,2 ; restore graphics mode
	mov ah,0
	int 10h
	
%include "..\bgl.asm"
%include "..\beeplib.asm"
%include "rickroll_song.asm"

rick_body_gfx: incbin "rick_body.gfx"
rick_head_gfx: incbin "rick_head.gfx"
rick_head_x_pos dw 0
rick_head_y_pos dw 0
wave_table_x_index db 0
wave_table_y_index db 0

text_1_gfx: incbin "text_1.gfx"
text_2_gfx: incbin "text_2.gfx"
song_delay db -1