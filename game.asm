org 100h

sprite_buffer_segment dw 0
key_states times 128 db 0

pres_x_pos dw 0
pres_y_pos dw 0
pres_speed db 2

gfx_erase db 0
gfx_background_colour db 1 ; colour index for all "sprites"
gfx_width db 0 ; using dw because it makes comparisons easier, probably a better way but i'm not known for that
gfx_height db 0
gfx_transparent db 0 ; the index used for transparency
gfx_x_pos dw 0
gfx_y_pos dw 0

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
	shl ax,5 ; shift by 32
	mov fs,ax ; fs is the temporary graphics buffer
;yeee:
;	jmp yeee
	
flood_fill:	
	; flood fill (background colour is iffy, so we're going it manually)
	mov di,64000 ; vga ram size
	mov al,[gfx_background_colour]

.loop:
	mov byte [fs:di],al
	dec di
	cmp di,0
	jne .loop
	
main:

	; REMEMBER: with brackets refers to the data inside, without brackets refers to the offset
	mov ah,3dh ; open file
	mov al,0 ; read
	mov dx,bloke_gfx ; load OFFSET of bloke_gfx
	int 21h
	mov word [file_handle],ax ; for future usage
	
	mov ah,3fh ; read from file
	mov bx,[file_handle] ; load VALUE OF file_handle into bx
	mov cx,902h
	mov dx,gfx_buffer
	int 21h
	
.loop:
	
	; draw sprites
	
	mov byte [gfx_erase],0
	
	mov ax,[pres_x_pos]
	mov word [gfx_x_pos],ax
	mov ax,[pres_y_pos]
	mov word [gfx_y_pos],ax
	call draw_gfx
	
.skip:
	
;    mov ecx,22000
;.delay:
;    nop
;    loop .delay
	
	; write the buffer to the screen BEFORE erasing...
	
	mov di,0
	
.write_buffer_loop:
	mov al,[fs:di] ; get value from buffer
	mov byte [es:di],al ; write this value to the video memory
	inc di
	cmp di,64000
	jne .write_buffer_loop
	
	; erase sprites
	
	mov byte [gfx_erase],1
	
	mov ax,[pres_x_pos]
	mov word [gfx_x_pos],ax
	mov ax,[pres_y_pos]
	mov word [gfx_y_pos],ax
	call draw_gfx
	
	; detect key presses
	
	xor dx,dx
	mov dl,[pres_speed]
	mov ax,0
	cmp [key_states+50h],ax
	je .key_check_up
	add word [pres_y_pos],dx
.key_check_up:
	cmp [key_states+48h],ax
	je .key_check_left
	sub word [pres_y_pos],dx
.key_check_left:
	cmp [key_states+4bh],ax
	je .key_check_right
	sub word [pres_x_pos],dx
.key_check_right:
	cmp [key_states+4dh],ax
	je .key_check_end
	add word [pres_x_pos],dx
.key_check_end:
	
	
	;mov ah,4ch
	;int 21h
	
	jmp .loop
	
draw_gfx:
	
	; graphics are stored x first, then y
	
	mov ax,[gfx_buffer] ; first byte should contain the width
	mov byte [gfx_width],al
	mov ax,[gfx_buffer+1] ; second byte should contain the height
	mov byte [gfx_height],al
	mov ax,[gfx_buffer+2] ; top left pixel is assumed transparent
	mov byte [gfx_transparent],al
	mov si,2 ; beginning of actual graphic data
    mov cx,[gfx_x_pos] ; x
    mov dx,[gfx_y_pos] ; y

.loop:
	
    mov al,[gfx_buffer+si] ; pixel colour
	cmp al,[gfx_transparent]
	je .skip ; if the pixel is "transparent", skip drawing
	
	cmp byte [gfx_erase],0 ; otherwise, check if we're erasing so we use the right colour
	je .erase_skip ; if not, use the proper colour as set earlier
	mov al,[gfx_background_colour] ; otherwise, use background colour
.erase_skip:
	; es = vga video buffer, fs = temporary buffer
	; draw that bad boy. at this point al contains the colour
	push dx ; y is being modified, so aaah sssh push it, pu-pu-push it push it
	; formula: (y<<8)+(y<<6)+x
	shl dx,6
	mov di,dx ; di: y<<6
	shl dx,2 ; dx: y<<8
	add di,dx
	add di,cx ; di: y<<6+y<<8+x
    pop dx
	;mov byte [es:di],al ; the pixel
	mov byte [fs:di],al
	
.skip:
	inc si ; next byte
	inc cx ; increase x
	
	mov ax,cx
	sub al,[gfx_x_pos] ; new x - original x
	cmp al,[gfx_width] ; reached the end of the line?
	jb .loop ; if not, go to next horizontal pixel
	mov cx,[gfx_x_pos] ; we've reached the end of the line, so reset x and increase y
	inc dx
	
	mov ax,dx
	sub al,[gfx_y_pos] ; new y - original y
	cmp al,[gfx_height] ; reached the bottom of the graphic?
	jb .loop ; if not, go to next line
	
	ret
	
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
	
file_handle: db 0
bloke_gfx: db "bumper.gfx",0
yup: db "yup.yup",0
gfx_buffer: db ?
msg: db "oops something bad has bappened",13,10,"$"