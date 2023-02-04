game:
	mov al,4
	mov byte [bgl_background_colour],al
	mov di,0
	mov cx,64000
	call bgl_flood_fill
	mov byte [bgl_erase],0
	;call background_draw ; shelves
	
	call employee_attacker_init
	call employee_attacker_spawn

.loop:
	inc word [global_randomizer] ; global randomizer, invader of the galaxies

	call fen_move ; ape_move is called from within fen_move
	call employees_move
	
	mov byte [bgl_erase],0
	call background_pattern_draw
	call game_gfx_draw
	call bgl_wait_retrace ; must go before to avoid tearing!
	call bgl_write_buffer
	mov byte [bgl_erase],1
	call game_gfx_draw
	
	call beep_handler
	
	cmp byte [bgl_key_states+1],0
	je .skip
	
	jmp end_of
	
.skip:
	jmp .loop
	
game_gfx_draw:
	call employee_attacker_draw
	call employee_defender_draw
	call fen_draw
	call ape_draw
	ret

global_randomizer dw 0 ; name of my next album

%include "fen.asm"
%include "ape.asm"
%include "background.asm"
%include "employees.asm"