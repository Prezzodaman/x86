	
	org 100h

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
	jb .background_loop

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
	jb .background_arrows_loop

	; draw sprites
	
	call bumper_collisions ; collisions first!
	
	; sprite ordering
	mov ax,[bumper_other_y_pos]
	sub ax,[bumper_pres_y_pos] ; difference between the two
	cmp ax,0 ; am i above the other car?
	jl .bumper_other_draw_above ; if so, draw above
	call bumper_pres_draw ; otherwise, learn english you can figure it out
	call bumper_other_draw
	jmp .ordering_skip

.bumper_other_draw_above:
	call bumper_other_draw
	call bumper_pres_draw

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

	mov si,0
	
.write_buffer_loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .write_buffer_loop
	
	jmp main ; jump back to the main loop

	
sprite_buffer_segment dw 0
background_colour db 7 ; colour index for all "sprites"
collision_flag db 0

msg: db "oops something bad has bappened",13,10,"$" ; have you seen my floury baps? my floury baps are floury. greggs.
col_msg: db "CRITTICKAL HIT!!!$"
	
%include "..\bgl.asm"
%include "bumper.asm"

background_road_gfx: incbin "background_road.gfx"
background_chunk_gfx: incbin "background_chunk.gfx"
background_arrow_gfx: incbin "background_arrow.gfx"
background_draw_x dw 0
background_x dw 0
background_arrow_x dw 38
road_start_y dw 70