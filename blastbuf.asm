
blaster_buffer_size equ blaster_mix_buffer_size
%include "blaster.asm"
%include "bgl.asm"

	org 100h
	
	call bgl_init
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov word [bgl_rotate_angle],0
	mov word [bgl_buffer_offset],yems

	call blaster_init
	blaster_set_sample_rate 11025
	
	mov si,sound
	mov cx,sound_size
	mov al,0
	mov ah,1
	call blaster_mix_play_sample
	
	mov si,sound2
	mov cx,sound2_size
	mov al,1
	mov ah,1
	call blaster_mix_play_sample
	
	mov si,sound3
	mov cx,sound3_size
	mov al,2
	mov ah,0
	call blaster_mix_play_sample
	
yess:
	mov al,3
	call bgl_flood_fill_full
	sub word [bgl_rotate_angle],10
	call bgl_draw_gfx_rotate
	
	call bgl_wait_retrace
	call bgl_write_buffer
	call blaster_mix_calculate
	call blaster_program_dma
	call blaster_start_playback
	
	cmp byte [bgl_key_states+2],0
	je .1
	mov si,sound
	mov cx,sound_size
	mov al,0
	mov ah,0
	call blaster_mix_play_sample
	jmp .end
.1:
	cmp byte [bgl_key_states+3],0
	je .2
	mov si,sound2
	mov cx,sound2_size
	mov al,1
	mov ah,0
	call blaster_mix_play_sample
	jmp .end
.2:
	cmp byte [bgl_key_states+4],0
	je .end
	mov si,sound3
	mov cx,sound3_size
	mov al,2
	mov ah,0
	call blaster_mix_play_sample
	jmp .end
.end:
	jmp yess
	
	call blaster_deinit
	
	mov ah,4ch
	int 21h

sound: incbin "extreme.raw"
sound_size equ $-sound
sound2: incbin "bester.raw"
sound2_size equ $-sound2
sound3: incbin "lgr.raw"
sound3_size equ $-sound3

yems: incbin "engineer.gfx"