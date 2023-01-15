	
	org 100h

	mov dx,key_handler ; replace the default key handler with our own
	mov ax,2509h
	int 21h

    mov al,13h ; graphics mode: 13h (256 colour vga)
    mov ah,0 ; function number
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
	
flood_fill:	
	; flood fill (background colour is iffy, so we're doing it manually)
	mov di,64000 ; vga ram size
	mov al,[background_colour]

.loop:
	mov byte [fs:di],al
	dec di
	cmp di,0
	jne .loop
	
main:

	; REMEMBER: with brackets refers to the data inside, without brackets refers to the offset
	
	;;
	
	mov ah,3dh ; open file
	mov al,0 ; read
	mov dx,bumper_pres_gfx ; load OFFSET of gfx
	int 21h
	push ax
	
	mov ah,3fh ; read from file
	pop bx
	mov cx,602h
	mov dx,bumper_pres_gfx_buffer
	int 21h
	push bx
	
	mov ah,3eh ; close the file to free up the handle
	pop bx
	int 21h
	
	;;
	
	mov ah,3dh ; open file
	mov al,0 ; read
	mov dx,bumper_cool_gfx ; load OFFSET of gfx
	int 21h
	push ax
	
	mov ah,3fh ; read from file
	pop bx
	mov cx,602h
	mov dx,bumper_other_gfx_buffer
	int 21h
	push bx
	
	mov ah,3eh ; close the file to free up the handle
	pop bx
	int 21h
	
.loop:
	
	; draw sprites
	
	push 0
	push bumper_other_gfx_buffer
	push word [background_colour]
	push word [other_x_pos]
	push word [other_y_pos]
	call bgl_draw_gfx
	
	push 0
	push bumper_pres_gfx_buffer
	push word [background_colour]
	push word [pres_x_pos]
	push word [pres_y_pos]
	call bgl_draw_gfx
	
.skip:
	
	; write the buffer to the screen BEFORE erasing...
	
	mov si,0
	
.write_buffer_loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .write_buffer_loop
	
	; erase sprites
	
	push 1
	push bumper_other_gfx_buffer
	push word [background_colour]
	push word [other_x_pos]
	push word [other_y_pos]
	call bgl_draw_gfx
	
	push 1
	push bumper_pres_gfx_buffer
	push word [background_colour]
	push word [pres_x_pos]
	push word [pres_y_pos]
	call bgl_draw_gfx
	
	
	xor dx,dx
	mov dl,[pres_speed]
	
	; detect key presses
	
	inc word [other_x_pos]
	
	cmp byte [key_states+50h],0 ; down pressed?
	je .key_check_up ; if not, skip
	mov ax,200-32
	cmp word [pres_y_pos],ax ; have we reached the bottom?
	jae .key_check_up ; if so, skip
	add word [pres_y_pos],dx ; otherwise, move
.key_check_up:
	cmp byte [key_states+48h],0 ; up pressed?
	je .key_check_left ; if not, skip
	cmp word [pres_y_pos],0 ; have we reached the top?
	jle .key_check_left ; if so, skip
	sub word [pres_y_pos],dx ; otherwise, move
.key_check_left:
	cmp byte [key_states+4bh],0 ; left pressed?
	je .key_check_right ; if not, skip
	cmp word [pres_x_pos],0 ; have we reached the left?
	jle .key_check_right ; if so, skip
	sub word [pres_x_pos],dx ; otherwise, move
.key_check_right:
	cmp byte [key_states+4dh],0 ; right pressed?
	je .key_check_end ; if not, skip
	mov ax,320-48
	cmp word [pres_x_pos],ax ; have we reached the right?
	jae .key_check_end ; if so, skip
	add word [pres_x_pos],dx ; otherwise, move
.key_check_end:
	
	
	;mov ah,4ch
	;int 21h
	
	jmp .loop
	
key_handler:
	push ax
	push bx
	
	in al,60h ; get keyboard stuff
	mov ah,0
	mov bx,ax
	and bx,127 ; last 7 bits (bx): scan code
	shl ax,1 ; first bit (ah): press/release
	xor ah,1
	mov [key_states+bx],ah ; move press/release state to the appropriate index
	mov al,20h
	out 20h,al
	
	pop bx
	pop ax
	iret
	
sprite_buffer_segment dw 0
key_states times 128 db 0

background_colour db 1 ; colour index for all "sprites"

pres_x_pos dw 0
pres_y_pos dw 0
other_x_pos dw 20h
other_y_pos dw 10h
pres_speed db 2

bumper_pres_gfx: db "bumper_pres.gfx",0
bumper_cool_gfx: db "bumper_cool.gfx",0
bumper_cool_2_gfx: db "bumper_cool_2.gfx",0
bumper_dog_gfx: db "bumper_dog.gfx",0
bumper_woah_gfx: db "bumper_woah.gfx",0
bumper_rye_gfx: db "bumper_rye.gfx",0

bumper_pres_gfx_buffer: times 602h db 0
bumper_other_gfx_buffer: times 602h db 0
msg: db "oops something bad has bappened",13,10,"$" ; have you seen my floury baps? my floury baps are floury. greggs.
	
%include "..\bgl.asm"
