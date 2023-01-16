	
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

.flood_fill:	
	; flood fill (background colour is iffy, so we're doing it manually)
	mov di,64000 ; vga ram size
	mov al,[background_colour]

.flood_fill_loop:
	mov byte [fs:di],al
	dec di
	cmp di,0
	jne .flood_fill_loop
	
	call bumper_collisions
	call bumper_other_draw
	call bumper_pres_draw

	call bumper_pres_movement
	call bumper_other_movement
	
	mov si,0
	
.write_buffer_loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .write_buffer_loop
	
	jmp main ; jump back to the main loop

	
sprite_buffer_segment dw 0
background_colour db 1 ; colour index for all "sprites"
collision_flag db 0

msg: db "oops something bad has bappened",13,10,"$" ; have you seen my floury baps? my floury baps are floury. greggs.
col_msg: db "CRITTICKAL HIT!!!$"
	
%include "..\bgl.asm"
%include "bumper.asm"
