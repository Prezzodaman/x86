org 100h

gfx_width dw 0
gfx_height dw 0
gfx_transparent dw 0 ; the index used for transparency
gfx_x_pos dw 0
gfx_y_pos dw 0

main:
    mov al,13h ; graphics mode: 13h (256 colour vga)
    mov ah,0 ; function number
    int 10h
	
	; REMEMBER: with brackets refers to the data inside, without brackets refers to the offset
	mov ah,3dh ; open file
	mov al,0 ; read
	mov dx,bloke_gfx ; load OFFSET of bloke_gfx
	int 21h
	mov word [file_handle],ax ; for future usage
	
	mov ah,3fh ; read from file
	mov bx,[file_handle] ; load VALUE OF file_handle into bx
	mov cx,242h
	mov dx,gfx_buffer
	int 21h
	
	call draw_gfx
	
	add word [gfx_x_pos],32
	add word [gfx_y_pos],32
	call draw_gfx
	
	add word [gfx_x_pos],8
	add word [gfx_y_pos],8
	call draw_gfx
	
	;mov ah,4ch
	;int 21h
	
.loop:
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
    mov ah,0ch ; otherwise, draw that bad boy
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
bloke_gfx: db "bloke.gfx",0
yup: db "yup.yup",0
gfx_buffer: times 1024 db 0
msg: db "oops something bad has bappened",13,10,"$"