	
	org 100h
	
	call bgl_get_orig_key_handler
	call bgl_replace_key_handler
	call bgl_init
	
	jmp intro
	
game:
	call bumper_other_spawn_next
	mov word [bumper_other_x_pos],255-48
	mov ax,[road_start_y]
	mov word [bumper_other_y_pos],ax
	
	call bumper_pres_init ; m8
	
.loop:

.flood_fill_top:	
	; flood fill (background colour is iffy, so we're doing it manually)
	mov di,0
	mov al,1

.flood_fill_top_loop:
	mov byte [fs:di],al
	add di,320*41
	mov byte [fs:di],al
	sub di,320*41
	
	inc di
	cmp di,320*15
	jne .flood_fill_top_loop
	
.flood_fill_bottom:	
	mov ax,[road_start_y]
	mov bx,320
	mul bx ; ax*=bx
	mov di,ax
	mov al,[background_colour]

.flood_fill_bottom_loop:
	mov byte [fs:di],al
	inc di
	cmp di,64000
	jne .flood_fill_bottom_loop
	
	; draw back-round
	
	call background_draw

	; draw sprites
	
	call bumper_collisions ; collisions first!
	
	; sprite ordering
	mov ax,[bumper_pres_y_pos]
	sub ax,[bumper_other_y_pos] ; difference between the two
	cmp ax,0 ; am i above the other car?
	jl .bumper_other_draw_below ; if so, draw above
	call bumper_other_draw ; otherwise, learn english you can figure it out
	call bumper_pres_draw
	jmp .ordering_skip

.bumper_other_draw_below:
	call bumper_pres_draw
	call bumper_other_draw

.ordering_skip:
	
	call explosion_draw ; explosions above all
	call bumper_pres_movement
	call bumper_other_movement
	call background_scroll
	
	cmp byte [game_over_timer],40 ; game overed?
	jb .game_over_timer_inc ; if not, continue increasing
	
	cmp word [bgl_key_states+39h],0 ; space pressed?
	je .game_over_draw ; if not, skip
	call bumper_pres_init ; otherwise, respawn me
	mov byte [game_over],0
	mov byte [game_over_timer],0
	mov word [game_score],0
	
	mov ax,[bumper_pres_x_pos]
	sub ax,4
	mov word [explosion_x_pos],ax
	mov ax,[bumper_pres_y_pos]
	sub ax,12
	mov word [explosion_y_pos],ax
	call explosion_spawn
	mov si,explosion_sfx
	call beep_play_sfx
	
.game_over_draw:
	
	mov byte [bgl_erase],0
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	
	mov word [bgl_x_pos],60
	mov word [bgl_y_pos],65
	mov ax,game_over_1_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx
	
	mov word [bgl_x_pos],150
	mov word [bgl_y_pos],85
	mov ax,game_over_2_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx
	
	mov word [bgl_x_pos],72
	mov word [bgl_y_pos],125
	mov ax,text_try_again_gfx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx
	jmp .game_over_skip ; we know we're game overed, so no need to continue increasing!
	
.game_over_timer_inc:
	cmp byte [game_over],0
	je .game_over_skip
	inc byte [game_over_timer]

.game_over_skip:
	call score_draw
	
	call beep_handler
	
	call bgl_write_buffer
	
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .exit_skip
	jmp end_of ; exit game
	
.exit_skip:
	call bgl_wait_retrace
	jmp .loop ; jump back to the main loop

end_of:
	call bgl_restore_orig_key_handler
	
	mov al,2 ; restore graphics mode
	mov ah,0
	int 10h
	
	mov dx,end_message ; say a nice little message :)
	mov ah,9
	int 21h
	
	mov si,thanks_pwm
	mov cx,62
	mov dx,[thanks_pwm_length]
	call beep_play_sample
	
	mov ah,4ch ; back to command line
	int 21h
	
background_colour db 7 ; colour index for all "sprites"
collision_flag db 0

msg: db "oops something bad has bappened",13,10,"$" ; have you seen my floury baps? my floury baps are floury. greggs.
end_message: db "Thank you for playing!",13,10,"$"
	
%include "..\bgl.asm"
%include "..\beeplib.asm"
%include "bumper.asm"
%include "background.asm"
%include "explosion.asm"
%include "score.asm"
%include "intro.asm"

pres_hit_sfx dw 8000,9000,12000,16000,30000,0
other_hit_sfx dw 5000,4000,3600,4600,8000,17000,28000,0
bound_hit_sfx dw 8000,15000,20000,0
explosion_sfx dw 14000,3000,13000,8000,12000,9000,8300,0
skid_sfx dw 330,400,2,2,330,400,330,400,330,400,330,400,0

game_over_1_gfx: incbin "game_over_1.gfx"
game_over_2_gfx: incbin "game_over_2.gfx"
text_try_again_gfx: incbin "text_try_again.gfx"
game_over_timer db 0
game_over db 0

thanks_pwm: incbin "thanks_bin.raw"
thanks_pwm_length: dw $-thanks_pwm