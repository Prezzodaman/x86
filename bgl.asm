; BGL (best graphics library)
; by: me
;
; fs MUST contain offset of video buffer!!

bgl_erase db 0
bgl_width db 0
bgl_height db 0
bgl_transparent db 0 ; the index used for transparency
bgl_x_pos dw 0
bgl_y_pos dw 0
bgl_buffer_offset dw 0
bgl_background_colour db 0
bgl_stack dw 0

bgl_draw_gfx:
	; the reason we're not just popping is because when calling a function, the topmost index will contain the return address
	pop word [bgl_stack]
	
	mov ax,[esp]
	mov word [bgl_y_pos],ax
	
	mov ax,[esp+2]
	mov word [bgl_x_pos],ax
	
	mov ax,[esp+4]
	mov byte [bgl_background_colour],al
	
	mov ax,[esp+6] ; graphics offset
	mov bx,ax
	xor ax,ax ; bx is now the offset from which to read
	
	mov ax,[esp+8]
	mov byte [bgl_erase],al
	
	
	; clean up the stack
	
	pop ax
	pop ax
	pop ax
	pop ax
	pop ax
	
	push si
	
	; graphics are stored x first, then y
	
	mov al,[bx] ; first byte should contain the width
	mov byte [bgl_width],al
	mov al,[bx+1] ; second byte should contain the height
	mov byte [bgl_height],al
	mov al,[bx+2] ; top left pixel is assumed transparent
	mov byte [bgl_transparent],al
	mov si,2 ; beginning of actual graphic data
    mov cx,[bgl_x_pos] ; x
    mov dx,[bgl_y_pos] ; y

.loop:
	
    mov al,[bx+si] ; pixel colour
	cmp al,[bgl_transparent]
	je .skip ; if the pixel is "transparent", skip drawing
	cmp cx,320
	jae .skip ; if the pixel has exceeded the horizontal boundaries, skip
	cmp cx,0
	jb .skip ; -'-
	cmp dx,200
	jae .skip ; if the pixel has exceeded the vertical boundaries, skip
	cmp dx,0
	jb .skip ; -'-
	
	cmp byte [bgl_erase],0 ; otherwise, check if we're erasing so we use the right colour
	je .erase_skip ; if not, use the proper colour as set earlier
	mov al,[bgl_background_colour] ; otherwise, use background colour
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
	mov byte [fs:di],al
	
.skip:
	inc si ; next byte
	inc cx ; increase x
	
	mov ax,cx
	sub al,[bgl_x_pos] ; new x - original x
	cmp al,[bgl_width] ; reached the end of the line?
	jb .loop ; if not, go to next horizontal pixel
	mov cx,[bgl_x_pos] ; we've reached the end of the line, so reset x and increase y
	inc dx
	
	mov ax,dx
	sub al,[bgl_y_pos] ; new y - original y
	cmp al,[bgl_height] ; reached the bottom of the graphic?
	jb .loop ; if not, go to next line
	
	pop si
	push word [bgl_stack]
	
	ret