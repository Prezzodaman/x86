	
	org 100h
	
	call bgl_get_orig_key_handler

	mov dx,bgl_key_handler ; replace the default key handler with our own
	mov ax,2509h
	int 21h

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
	
	mov ax,[bumper_other_speed]
	mov word [bumper_other_x_vel],ax
	
main:

.flood_fill_top:	
	; flood fill (background colour is iffy, so we're doing it manually)
	mov di,0
	mov al,15

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
	
.background:
	mov ax,[background_x]
	sub ax,126
	mov cx,0
.background_loop:
	mov byte [bgl_opaque],1
	push cx
	and cx,1
	mov byte [bgl_flip],cl
	pop cx
	mov byte [bgl_erase],0
	push ax
	mov ax,background_chunk_gfx
	mov word [bgl_buffer_offset],ax
	pop ax
	mov word [bgl_x_pos],ax
	mov word [bgl_y_pos],14
	call bgl_draw_gfx
	add ax,62
	inc cx
	cmp cx,9
	jl .background_loop

.background_arrows:
	mov ax,[background_arrow_x]
	sub ax,38
	mov cx,0
.background_arrows_loop:
	mov byte [bgl_opaque],1
	mov byte [bgl_flip],0
	mov byte [bgl_erase],0
	push ax
	mov ax,background_arrow_gfx
	mov word [bgl_buffer_offset],ax
	pop ax
	mov word [bgl_x_pos],ax
	mov word [bgl_y_pos],56
	call bgl_draw_gfx
	add ax,32
	inc cx
	cmp cx,12
	jl .background_arrows_loop

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
	
	call bumper_pres_movement
	call bumper_other_movement
	
	mov ax,126
	mov bx,[bumper_pres_x_vel]
	shr bx,1
	sub ax,bx
	cmp word [background_x],ax
	jle .background_skip
	mov word [background_x],0
	jmp .background_skip2
	
.background_skip:
	cmp word [background_x],0
	jge .background_skip2
	mov word [background_x],ax

.background_skip2:

	cmp word [background_arrow_x],8
	jge .background_arrow_skip
	mov word [background_arrow_x],38
	
.background_arrow_skip:
	cmp word [background_arrow_x],38
	jle .background_arrow_skip2
	mov word [background_arrow_x],8
.background_arrow_skip2:

.draw_score:
	; draw score above everything
	
	mov cx,0 ; counter
	mov bx,0 ; offset
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	mov byte [bgl_erase],0
	mov ax,text_score_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[text_score_y]
	mov word [bgl_y_pos],ax
	mov ax,[text_score_x_start] ; doing this after, so we can have some fun with ax
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	mov ax,[game_score]
	mov word [game_score_divisor],ax
	mov ax,[text_score_x]
	mov word [text_score_x_start],ax
	add ax,38 ; end of score display
	add ax,10*5

.draw_score_loop:
	push ax ;;
	mov ax,[game_score_divisor]
	mov bx,10
	div bx ; game_score/10 - the one digit will be in dx
	mov word [game_score_divisor],ax
	
	mov ax,dx ; move remainder into ax so we can multiply (mul acts on ax)
	mov bx,66 ; 66 = size of one number
	mul bx ; ax*=66
	push ax ; push remainder to stack
	
	xor dx,dx ; clear remainder
	
	pop bx ; get remainder from stack
	mov ax,text_score_numbers_gfx
	add ax,bx ; offset the... offset
	mov word [bgl_buffer_offset],ax

	cmp cx,5 ; reached the last digit?
	je .draw_score_done ; if so, finish drawing
	inc cx ; otherwise, continue
	
	pop ax ;;
	sub ax,9 ; spacing between numbers
	mov word [bgl_x_pos],ax
	
	call bgl_draw_gfx
	jmp .draw_score_loop
	
.draw_score_done:
	inc word [game_score]
	mov si,0
	
.write_buffer_loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .write_buffer_loop
	
	cmp word [bgl_key_states+1],0
	je .exit_skip
	jmp .end_of
	
.exit_skip:
	jmp main ; jump back to the main loop

.end_of:
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

background_road_gfx: incbin "background_road.gfx"
background_chunk_gfx: incbin "background_chunk.gfx"
background_arrow_gfx: incbin "background_arrow.gfx"
background_draw_x dw 0
background_x dw 0
background_arrow_x dw 38
road_start_y dw 70

game_score dw 0
game_score_divisor dw 0
text_score_gfx: incbin "text_score.gfx"
text_score_numbers_gfx:
	incbin "text_score_0.gfx"
	incbin "text_score_1.gfx"
	incbin "text_score_2.gfx"
	incbin "text_score_3.gfx"
	incbin "text_score_4.gfx"
	incbin "text_score_5.gfx"
	incbin "text_score_6.gfx"
	incbin "text_score_7.gfx"
	incbin "text_score_8.gfx"
	incbin "text_score_9.gfx"
text_score_x dw 10
text_score_x_start dw 10
text_score_y dw 180