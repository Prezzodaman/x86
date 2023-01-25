; BGL (best graphics library)
; by: me

; references:
;	http://www.brackeen.com/vga/index.html
; 	https://stackoverflow.com/questions/6560343/double-buffer-video-in-assembler

bgl_flip db 0
bgl_erase db 0
bgl_width db 0
bgl_height db 0
bgl_transparent db 0 ; the index used for transparency
bgl_x_pos dw 0
bgl_y_pos dw 0
bgl_buffer_offset dw 0
bgl_background_colour db 0
bgl_opaque db 0
bgl_collision_flag db 0
bgl_collision_x1 dw 0
bgl_collision_x2 dw 0
bgl_collision_y1 dw 0
bgl_collision_y2 dw 0
bgl_collision_w1 dw 0
bgl_collision_w2 dw 0
bgl_collision_h1 dw 0
bgl_collision_h2 dw 0
bgl_key_states times 128 db 0
bgl_key_handler_orig dw 0,0
bgl_palette_segment dw 0

bgl_draw_gfx:
	push ax
	push bx
	push cx
	push dx
	push si
	
	; graphics are stored x first, then y
	
	mov bx,[bgl_buffer_offset]
	
	mov al,[bx] ; first byte should contain the width
	mov byte [bgl_width],al
	mov al,[bx+1] ; second byte should contain the height
	mov byte [bgl_height],al
	
	mov al,[bx+2] ; top left pixel is assumed transparent
	mov byte [bgl_transparent],al
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	mov si,2 ; beginning of actual graphic data
    mov cx,[bgl_x_pos] ; x
    mov dx,[bgl_y_pos] ; y
	
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .loop ; if not, carry on as usual
	xor ax,ax
	mov al,[bgl_width]
	add cx,ax ; otherwise, start from the end

.loop:
	
    mov al,[bx+si] ; pixel colour
	cmp al,[bgl_transparent]
	je .skip ; if the pixel is "transparent", skip drawing
	cmp cx,320
	jge .skip ; if the pixel has exceeded the horizontal boundaries, skip
	cmp cx,0
	jl .skip ; -'-
	cmp dx,200
	jge .skip ; if the pixel has exceeded the vertical boundaries, skip
	cmp dx,0
	jl .skip ; -'-
	
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
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .skip2 ; if not, carry on as usual
	sub cx,2 ; otherwise, decrease x
.skip2:
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .skip3 ; if not, carry on as usual
	cmp cx,[bgl_x_pos] ; otherwise, compare the current x to the original x
	mov ax,[bgl_x_pos]
	jne .loop
	jmp .skip4 ; reached the end of this line
.skip3:
	mov ax,cx
	sub ax,[bgl_x_pos] ; new x - original x
	cmp al,[bgl_width] ; reached the end of the line?
	jb .loop ; if not, go to next horizontal pixel (using unsigned checks to support widths over 127)
	mov cx,[bgl_x_pos] ; we've reached the end of the line, so reset x and increase y
	jmp .skip5
.skip4:
	mov cx,[bgl_x_pos]
	push ax
	xor ax,ax
	mov al,[bgl_width]
	add cx,ax
	pop ax
.skip5:
	inc dx
	
	mov ax,dx
	sub ax,[bgl_y_pos] ; new y - original y
	cmp al,[bgl_height] ; reached the bottom of the graphic?
	jb .loop ; if not, go to next line (using unsigned checks to support heights over 127)
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bgl_collision_check:
	push ax
	
    mov byte [bgl_collision_flag],0
	
	; I have no clue why I had to use jl for all of these, I tried the "logical choice" and it just didn't work.
	; If I had to guess why, it's because the result of all these comparisons will be negative if false.
	
	mov ax,[bgl_collision_x2]
	add ax,[bgl_collision_w2]
	cmp ax,[bgl_collision_x1]
	jl .skip
	mov ax,[bgl_collision_x1]
	add ax,[bgl_collision_w1]
	cmp ax,[bgl_collision_x2]
	jl .skip
	mov ax,[bgl_collision_y2]
	add ax,[bgl_collision_h2]
	cmp ax,[bgl_collision_y1]
	jl .skip
	mov ax,[bgl_collision_y1]
	add ax,[bgl_collision_h1]
	cmp ax,[bgl_collision_y2]
	jl .skip
	
	mov byte [bgl_collision_flag],1
.skip:
	pop ax
	ret	

bgl_point_collision_check:
	push ax
	
    mov byte [bgl_collision_flag],0
	
	; x2 and y2 are for the point (w2 and h2 are unused here)
	
	mov ax,[bgl_collision_x1]
	cmp word [bgl_collision_x2],ax
	jl .skip
	
	mov ax,[bgl_collision_x1]
	add ax,[bgl_collision_w1]
	cmp word [bgl_collision_x2],ax
	jg .skip
	
	mov ax,[bgl_collision_y1]
	cmp word [bgl_collision_y2],ax
	jl .skip
	
	mov ax,[bgl_collision_y1]
	add ax,[bgl_collision_h1]
	cmp word [bgl_collision_y2],ax
	jg .skip
	
	mov byte [bgl_collision_flag],1
.skip:
	pop ax
	ret	

bgl_key_handler:
	push ax
	push bx
	
	in al,60h ; get keyboard stuff
	xor ah,ah
	mov bx,ax
	and bx,127 ; last 7 bits (bx): scan code
	shl ax,1 ; first bit (ah): press/release
	xor ah,1
	mov [bgl_key_states+bx],ah ; move press/release state to the appropriate index
	mov al,20h
	out 20h,al
	
	pop bx
	pop ax
	iret
	
bgl_get_orig_key_handler:
	push bx
	push es
	mov ax,3509h ; get address of original key handler
	int 21h
	mov [bgl_key_handler_orig],bx ; offset
	mov [bgl_key_handler_orig+2],es	; segment
	pop es
	pop bx
	ret
	
bgl_restore_orig_key_handler:
	push dx
	push ds
	mov dx,[bgl_key_handler_orig]
	mov ds,[bgl_key_handler_orig+2]
	mov ax,2509h
	int 21h
	pop ds
	pop dx
	ret

bgl_replace_key_handler:
	push dx
	push ax
	call bgl_get_orig_key_handler
	mov dx,bgl_key_handler ; replace the default key handler with our own
	mov ax,2509h
	int 21h
	pop ax
	pop dx
	ret
	
bgl_wait_retrace:
	push ax
	push dx
	
.wait_for:
	mov dx,3dah ; FREEDAH!!
	in al,dx
	test al,8
	je .wait_for
	
.wait_after:
	in al,dx
	test al,8
	jne .wait_after
	
	pop dx
	pop ax
	ret
	
bgl_init:
	push ax
	push bx
	
    mov al,13h ; graphics mode: 13h (256 colour vga)
    xor ah,ah ; function number
    int 10h
	
	mov ax,0a000h
	mov es,ax ; es Should(tm) always contain the vga memory address
	
	mov ax, word [2] ; psp: segment of first byte beyond program (word)
	sub ax,64000/16 ; amount of memory we want, in "segments" (16 bytes)
	mov fs,ax ; fs is the temporary graphics buffer
	
	pop bx
	pop ax
	ret
	
bgl_write_buffer:
	mov si,0
.loop:
	mov al,[fs:si] ; get value from buffer
	mov byte [es:si],al ; write this value to the video memory
	inc si
	cmp si,64000
	jne .loop
	ret
	
bgl_flood_fill:
	push ax
	push di
	mov di,0
.loop:
	mov byte [fs:di],al
	inc di
	cmp di,64000
	jne .loop
	pop di
	pop ax
	ret
	
bgl_get_orig_palette:
	push ax
	push bx
	push di
	
	;mov ah,48h ; allocate memory for the original vga palette
	;mov bx,255/16 ; how many paragraphs to allocate
	;int 21h ; ax will contain the address
	
	mov cx,0 ; colour index
	mov di,0 ; destination index
.loop:
	
	mov dx,3c9h
	in al,dx ; r
	mov byte [gs:di],al
	inc di
	in al,dx ; g
	mov byte [gs:di],al
	inc di
	in al,dx ; b
	mov byte [gs:di],al
	inc di
	
	inc cx ; go to next index
	cmp cx,255 ; reached last index?
	je .end ; if so, end
	jmp .loop ; otherwise, keep getting those colours
	
.end:

	pop di
	pop bx
	pop ax
	ret
	
bgl_fade_in:
;	mov al,[gs:0]
;.qw:
;	jmp .qw
	push cx
	push si
	push ax
	push bx
	push dx
	
	mov cx,0 ; colour index
	mov si,0 ; source index
	mov bx,1 ; fade intensity
.palette_loop:
	push bx
	
	xor ax,ax
	mov al,cl
	mov dx,3c8h ; colour index is in al
	out dx,al
	inc dx ; go to 3c9h, where you give it the rgb values
	
	mov al,[gs:si]
	push dx
	xor dx,dx
	div bx
	pop dx
	out dx,al ; r
	inc si
	
	mov al,[gs:si]
	push dx
	xor dx,dx
	div bx
	pop dx
	out dx,al ; g
	inc si
	
	mov al,[gs:si]
	push dx
	xor dx,dx
	div bx
	pop dx
	out dx,al ; b
	inc si
	
	pop bx
	
	inc cx ; next index
	cmp cx,255 ; reached last one?
	jne .palette_loop ; if not, update next index
	; otherwise, reduce intensity and start again
	
	;call bgl_wait_retrace
	;dec bx
	;cmp bx,2
	;je .end
	;mov cx,0
	;jmp .palette_loop
	
.end:
	pop dx
	pop bx
	pop ax
	pop si
	pop cx
	ret
	
bgl_escape_exit:
	cmp word [bgl_key_states+1],0 ; escape pressed?
	je .skip
	call bgl_restore_orig_key_handler
	mov al,3
	xor ah,ah
	int 10h
	mov ah,4ch
	int 21h
.skip:
	ret