; BGL (best graphics library)
; by: me

; references:
;	http://www.brackeen.com/vga/index.html
; 	https://stackoverflow.com/questions/6560343/double-buffer-video-in-assembler

bgl_rle_word dw 0
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

bgl_font_offset dw 0
bgl_font_size db 0
bgl_font_spacing db 0
bgl_font_string_offset dw 0

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
	call bgl_get_x_y_offset
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
	
bgl_draw_full_gfx: ; WARNING: this is untested because a full image uses up all available space in a .com file
	mov bx,[bgl_buffer_offset] ; starting from 2 to avoid the width/height - they're not necessary here
	add bx,2 ; henceforth
	mov si,0 ; "source" index (graphics/buffer offset, same in this situation)
.loop:
	mov al,[bx+si] ; get source pixel
	mov byte [fs:si],al ; move to temporary graphics buffer
	inc si
	cmp si,64000
	jb .loop
	ret
	
bgl_draw_full_gfx_rle:
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov bx,[bgl_buffer_offset]
	mov si,2
	mov cx,0
	mov dx,0
.loop:
	mov ax,[bx+si] ; get the word
	mov word [bgl_rle_word],ax
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word]
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah
	mov word [bgl_rle_word],ax
	
	call bgl_get_x_y_offset ; get offset based off cx/dx and put it into di
	
	mov byte [fs:di],al
	
	inc cx ; increase x position
	cmp cx,320 ; reached end of the line?
	jne .draw_loop ; if not, continue drawing
	inc dx ; reached end of line, increase y and reset x
	mov cx,0
	cmp dx,200 ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end:
	add si,2 ; x and y are still in bounds, go to next byte
	jmp .loop
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret

bgl_draw_gfx_rle: ; "draw graphics... really?"
	push ax
	push bx
	push cx
	push dx
	push si
	
.init: ; bruv
	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	mov si,2 ; increased by 2 each time to get each byte and its repeats as a word
	mov cx,[bgl_x_pos]
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .init_skip ; if not, skip
	xor ah,ah
	mov al,[bgl_width]
	add cx,ax ; if drawing flipped, start from the right side
.init_skip:
	mov dx,[bgl_y_pos]
.loop:
	mov ax,[bx+si] ; get the word - low byte is colour index, high byte is amount of repeats
	mov word [bgl_rle_word],ax ; we'll need to affect ax later, and the stack can't be used in this situation
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word] ; -- equivalent to "pop ax" if the stack wasn't wacky here, this restores the affected word
	
	; \/ the positioning of this code is very very important!!! \/
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah ; decadecAhhh, decah decAhhh BUM. BUM. oooOOOoOoohhHYYyeEEaaAAHhhh.
	mov word [bgl_rle_word],ax ; -- (oh yeah store it as well, that's improtant. this is the push of the figurative pop)
	
	; /\ the positioning of this code is very very important!!! /\
	
	cmp al,[bgl_transparent] ; if the pixel about to be drawn is transparent, don't even draw it, just skip
	je .draw_loop_skip
	cmp cx,0 ; check if x and y are within boundaries
	jl .draw_loop_skip
	cmp cx,320
	jge .draw_loop_skip
	cmp dx,0
	jl .draw_loop_skip
	cmp dx,200
	jge .draw_loop_skip
	call bgl_get_x_y_offset ; if it's not transparent AND it's within boundaries, get offset based off cx/dx and put it into di
	
	cmp byte [bgl_erase],0 ; erasing?
	je .draw_loop_main ; if not, continue as normal
	mov al,[bgl_background_colour] ; otherwise, replace pixel colour with the background colour
	
.draw_loop_main:
	mov byte [fs:di],al ; ax still contains the word at this point, now we can do all the funky stuff
.draw_loop_skip: ; a transparent pixel was encountered
	inc cx ; increase "internal" x position
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip2 ; if not, continue as normal
	sub cx,2 ; decrease x instead (cx + 1 - 2 = cx - 1)
.draw_loop_skip2:
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip3 ; if not, continue as normal
	cmp cx,[bgl_x_pos] ; if drawing flipped, simply compare the new x with the original x
	jne .draw_loop ; haven't reached the end of the line, so continue drawing
	jmp .draw_loop_skip4 ; reached end of line
.draw_loop_skip3:
	mov ax,cx
	sub ax,[bgl_x_pos] ; new x - original x
	cmp al,[bgl_width] ; reached end of the line?
	jne .draw_loop ; if not, continue drawing
.draw_loop_skip4:
	inc dx ; reached end of line, increase y and reset x
	mov cx,[bgl_x_pos]
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip5 ; if not, continue as normal
	xor ah,ah
	mov al,[bgl_width]
	add cx,ax ; if drawing flipped, start from original x + width
.draw_loop_skip5:
	mov ax,dx
	sub ax,[bgl_y_pos] ; new y - original y
	cmp al,[bgl_height] ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end: ; get next word
	add si,2
	jmp .loop ; very complicated piece of code
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bgl_get_x_y_offset: ; result: offset in di - requires: cx to contain x, dx to contain y
	push cx
	push dx
	
	; formula: (y<<8)+(y<<6)+x
	shl dx,6
	mov di,dx ; di: y<<6
	shl dx,2 ; dx: y<<8
	add di,dx
	add di,cx ; di: y<<6+y<<8+x
	
	pop dx
    pop cx
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
	
bgl_init: ; yeah mate, its bgl init bruv
	push ax
	push bx
	
    mov al,13h ; graphics mode: 13h (256 colour vga)
    xor ah,ah ; function number
    int 10h
	
	mov ax,0a000h
	mov es,ax ; es Should(tm) always contain the vga memory address
	
	mov ax, word [2] ; psp: segment of first byte beyond program (word)
	sub ax,64000/16 ; amount of memory we want, in "segments" (16 bytes)
	;add ax,130
	mov fs,ax ; fs is the temporary graphics buffer
	
	mov al,0 ; clear buffer
	mov di,0
	mov cx,64000
	call bgl_flood_fill
	
	call bgl_get_orig_key_handler
	
	pop bx
	pop ax
	ret
	
bgl_write_buffer:
	push ax
	push si

	mov si,0
.loop:
	mov ax,[fs:si] ; get value from buffer
	mov word [es:si],ax ; write this value to the video memory, two bytes at a time for SPEEEEEED
	add si,2
	cmp si,64000
	jne .loop
	
	pop si
	pop ax
	ret
	
bgl_flood_fill: ; di: start, cx: end
	push ax
	push di
	push cx
	mov ah,al
.loop:
	mov word [fs:di],ax
	add di,2
	cmp di,cx
	jb .loop
	pop cx
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
	call bgl_reset
	mov ah,4ch ; return to command line
	int 21h
.skip:
	ret
	
bgl_error:

	push dx
	push cx
	push bx
	push ax

	mov al,2 ; restore graphics mode
	xor ah,ah
	int 10h
	
	mov ah,9
	mov dx,bgl_error_message
	int 21h
	
	mov cl,0
	
.register_loop:
	mov ah,2
	mov dl,"A"
	add dl,cl
	int 21h
	mov dl,"X"
	int 21h
	mov dl,":"
	int 21h
	pop ax ; get last pushed register into ax
	mov dl,ah
	call bgl_write_hex_byte
	mov dl,al
	call bgl_write_hex_byte
	mov ah,2
	mov dl," "
	int 21h
	cmp cl,3
	je .register_skip
	inc cl
	jmp .register_loop
	
.register_skip:
	
	mov ah,9
	mov dx,cr_lf
	int 21h
	
	mov ah,4ch ; return to command line
	int 21h
	ret
	
bgl_write_hex_byte:
	push ax
	push dx
	
	shr dl,4
	call bgl_write_hex_digit
	pop dx
	
	call bgl_write_hex_digit
	pop ax
	ret
	
bgl_write_hex_digit: ; dl: value between 0-15 (if above, it'll get the last digit, so 14 will return 4)
	push dx
	
	mov al,dl
	and al,15
	
	mov ah,2
	mov dl,al
	cmp dl,10 ; is dl (same as al for now) greater than 10?
	jb .write ; if not, write the digit
	add dl,7
.write:
	add dl,"0"
	mov ah,2
	int 21h
	
	pop dx
	ret
	
bgl_draw_font_string:
	push ax
	push bx
	mov ax,[bgl_x_pos]
	push ax

	xor bx,bx
	xor ax,ax
	mov si,[bgl_font_string_offset]
.loop:
	mov al,[si+bx] ; get character at position bx into al
	cmp al,0
	je .end
	cmp al,"A"
	jge .letter
	sub al,"0" ; not greater? character is assumed to be a number
	jmp .get_offset
.letter:
	sub al,55 ; start from 0, plus the 10 digits (otherwise it'll print a number)

.get_offset:
	push bx ; offset
	cmp al,0f0h
	je .skip
	push ax ; character number
	xor ax,ax
	xor bx,bx
	mov al,[bgl_font_size] ; size in bytes
	mov bl,al
	mul bx ; ax=size*size
	mov bx,ax
	add ax,2 ; width/height header
	pop bx ; multiply that by the character value...
	mul bx
	
	mov bx,ax ; put result into bx so we can offset
	
	mov ax,[bgl_font_offset]
	add ax,bx
	mov word [bgl_buffer_offset],ax
	call bgl_draw_gfx
	
.skip:
	xor ax,ax
	mov al,[bgl_font_spacing]
	add word [bgl_x_pos],ax
	pop bx
	inc bx
	jmp .loop
.end:

	pop word [bgl_x_pos]
	pop bx
	pop ax
	ret
	
bgl_reset:
	call bgl_restore_orig_key_handler
	mov al,2 ; restore graphics mode
	xor ah,ah
	int 10h
	ret
	
bgl_error_message: db "oops something bad has bappened",13,10,"$"
cr_lf: db 13,10,"$"