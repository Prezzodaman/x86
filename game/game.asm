	
	org 100h
	
	call bgl_get_orig_key_handler
	call bgl_replace_key_handler

    mov al,13h ; graphics mode: 13h (256 colour vga)
    xor ah,ah ; function number
    int 10h
	
	mov ax,0a000h
	mov es,ax ; es Should(tm) always contain the vga memory address
	
	mov ah,48h ; allocate memory for the vga buffer
	mov bx,64000 ; how many paragraphs to allocate
	; (we're doing it in bytes then converting to "paragraphs" because it's easier for me to read)
	shr bx,4 ; divide by 16
	int 21h
	mov word [sprite_buffer_segment],ax ; hoohohoho we got a little chunk of memory all to ourselves

	mov ax,sprite_buffer_segment
	shl ax,5 ; multiply by 32
	mov fs,ax ; fs is the temporary graphics buffer
	
	call bumper_other_spawn_next
	mov word [bumper_other_x_pos],255-48
	mov ax,[road_start_y]
	mov word [bumper_other_y_pos],ax
	
main:

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
	call score_draw
	
	call beep_handler
	
	mov si,0
	
.write_buffer_loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .write_buffer_loop
	
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .exit_skip
	jmp end_of ; exit game
	
.exit_skip:

.retrace_loop:
	; wait for retrace
	mov dx,3dah ; FREEDAH!!
	in al,dx
	test al,8
	je .retrace_loop
	
	jmp main ; jump back to the main loop

end_of:
	call bgl_restore_orig_key_handler
	
	mov al,2 ; restore graphics mode
	mov ah,0
	int 10h
	
	mov dx,end_message ; say a nice little message :)
	mov ah,9
	int 21h
	
	mov ah,4ch ; back to command line
	int 21h
	
sprite_buffer_segment dw 0
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

pres_hit_sfx dw 8000,9000,12000,16000,30000,0
other_hit_sfx dw 5000,4000,3600,4600,8000,17000,28000,0
bound_hit_sfx dw 8000,15000,20000,0
explosion_sfx dw 14000,3000,13000,8000,12000,9000,8300,0
skid_sfx dw 330,400,1,1,330,400,330,400,330,400,330,400,0