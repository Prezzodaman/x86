org 100h

vga equ 0xa000
gfx_erase db 0
gfx_background_colour db 1 ; colour index for all "sprites"
gfx_width dw 0 ; using dw because it makes comparisons easier, probably a better way but i'm not known for that
gfx_height dw 0
gfx_transparent db 0 ; the index used for transparency
gfx_x_pos dw 0
gfx_y_pos dw 0
yes db 0

    mov al,13h ; graphics mode: 13h (256 colour vga)
    mov ah,0 ; function number
    int 10h

flood_fill:	
	; flood fill (background colour is iffy, so we're going it manually)
	mov cx,0
	mov dx,0
	mov al,[gfx_background_colour]
	mov ah,0ch

.loop:
	int 10h
	inc cx
	cmp cx,320
	jne .loop
	mov cx,0
	inc dx
	cmp dx,200
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
	mov byte [gfx_erase],0
	
	call draw_gfx
	
	add word [gfx_x_pos],50
	add word [gfx_y_pos],50
	call draw_gfx
	sub word [gfx_x_pos],50
	sub word [gfx_y_pos],50
	
    mov ecx,62000
.delay:
    nop
    loop .delay
	
	mov byte [gfx_erase],1
	
	call draw_gfx
	
	add word [gfx_x_pos],50
	add word [gfx_y_pos],50
	call draw_gfx
	sub word [gfx_x_pos],50
	sub word [gfx_y_pos],50
	
	inc word [gfx_x_pos]
	inc word [gfx_y_pos]
	
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
    mov ah,0ch ; draw that bad boy
    int 10h
.skip:
	inc si ; next byte
	inc cx ; increase x
	
	mov ax,cx
	sub ax,[gfx_x_pos] ; new x - original x
	cmp ax,[gfx_width] ; reached the end of the line?
	jb .loop ; if not, go to next horizontal pixel
	mov cx,[gfx_x_pos] ; we've reached the end of the line, so reset x and increase y
	inc dx
	
	mov ax,dx
	sub ax,[gfx_y_pos] ; new y - original y
	cmp ax,[gfx_height] ; reached the bottom of the graphic?
	jb .loop ; if not, go to next line
	
	ret
	
file_handle: db 0
bloke_gfx: db "birz.gfx",0
yup: db "yup.yup",0
gfx_buffer: db ?
msg: db "oops something bad has bappened",13,10,"$"