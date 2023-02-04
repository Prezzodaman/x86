fen_draw:
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	
	mov ax,[fen_x_pos]
	mov word [bgl_x_pos],ax
	
	mov ax,[fen_y_pos]
	mov word [bgl_y_pos],ax
	mov ax,fen_head_gfx
	cmp byte [fen_hurt],0
	je .hurt_skip
	mov ax,fen_head_ouch_gfx
.hurt_skip:
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx_rle
	
	mov ax,fen_legs_gfx
	mov word [bgl_buffer_offset],ax
	sub word [bgl_x_pos],2
	add byte [bgl_y_pos],50
	call bgl_draw_gfx_rle
	
	mov ax,fen_trolley_gfx
	mov word [bgl_buffer_offset],ax
	add word [bgl_x_pos],24
	sub word [bgl_y_pos],16
	call bgl_draw_gfx_rle
	
	mov ax,fen_body_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[fen_x_pos]
	dec ax
	dec ax
	mov word [bgl_x_pos],ax
	mov ax,[fen_y_pos]
	add ax,24
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_rle
	ret
	
fen_move:
	cmp byte [fen_controllable],0
	je .controllable

	xor ax,ax ; because the speed is a byte..
	mov al,[fen_speed] ; make sure ax always contains the speed throughout all key checks!
	
	cmp byte [bgl_key_states+4dh],0 ; right pressed?
	je .left ; if not, skip
	cmp word [fen_x_pos],150 ; reached right bounds?
	jge .left
	add word [fen_x_pos],ax
.left:
	cmp byte [bgl_key_states+4bh],0 ; left pressed?
	je .up
	cmp word [fen_x_pos],0
	jle .up
	sub word [fen_x_pos],ax
.up:
	cmp byte [bgl_key_states+48h],0 ; up pressed?
	je .down
	cmp word [fen_y_pos],0
	jle .down
	sub word [fen_y_pos],ax
.down:
	cmp byte [bgl_key_states+50h],0 ; down pressed?
	je .controllable
	cmp word [fen_y_pos],118
	jge .controllable
	add word [fen_y_pos],ax
.controllable:
	call ape_move ; keep the ape's movements synchronized
	cmp byte [bgl_key_states+10h],0 ; q pressed?
	je .uncontrollable
	call ape_jump_in
.uncontrollable:
	cmp byte [bgl_key_states+12h],0 ; e pressed?
	je .end
	call ape_jump_out
.end:
	ret
	
fen_do_hurt: ; cuz variable names
	mov byte [fen_hurt],1
	mov byte [bgl_erase],0
	call game_gfx_draw
	call bgl_write_buffer
	mov si,ow_pwm
	mov cx,beep_11025
	mov dx,[ow_pwm_length]
	call beep_play_sample
	mov byte [fen_hurt],0
	ret

fen_x_pos dw 10
fen_y_pos dw 10
fen_speed db 2
fen_controllable db 1
fen_hurt db 0

fen_body_gfx: incbin "fen_body.rle"
fen_head_gfx: incbin "fen_head.rle"
fen_head_ouch_gfx: incbin "fen_head_ouch.rle"
fen_legs_gfx:
	incbin "fen_legs_1.rle"
fen_trolley_gfx: incbin "fen_trolley.rle"

ow_pwm: incbin "ow_bin.raw"
ow_pwm_length: dw $-ow_pwm

yems: db "Okay smarty pants, but why hack this game when the source is available to everyone?"