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
bgl_y_clip db 0

bgl_scale_x dd 1
bgl_scale_y dd 1
bgl_scale_factor_width dd 0
bgl_scale_factor_height dd 0
bgl_scale_width dw 0
bgl_scale_height dw 0
bgl_scale_precision db 16
bgl_scale_centre db 0

bgl_rotate_angle dw 0
bgl_rotate_angle_sin dw 0
bgl_rotate_angle_cos dw 0
bgl_rotate_x_centre dw 0
bgl_rotate_y_centre dw 0
bgl_rotate_x_adjusted dw 0
bgl_rotate_y_adjusted dw 0

bgl_font_offset dw 0
bgl_font_size db 0
bgl_font_spacing db 0
bgl_font_string_offset dw 0
	
bgl_pseudo_fade:
	push di
	push cx
	push dx
	push ax
	xor di,di
	xor cx,cx
	xor dx,dx
.first_loop:
	mov al,[es:di]
	mov byte [fs:di],al
	add di,320
	inc dx
	cmp dx,200
	ja .first_loop_skip
	jmp .first_loop
.first_loop_skip:
	push cx
	and cx,2
	cmp cx,0
	pop cx
	je .first_loop_skip2
	call bgl_wait_retrace
.first_loop_skip2:
	add cx,2
	mov di,cx
	xor dx,dx
	cmp cx,320
	jbe .first_loop

	mov cx,319
	mov di,319
.second_loop:
	mov al,[es:di]
	mov byte [fs:di],al
	add di,320
	inc dx
	cmp dx,200
	je .second_loop_skip
	jmp .second_loop
.second_loop_skip:
	push cx
	and cx,2
	cmp cx,0
	pop cx
	je .second_loop_skip2
	call bgl_wait_retrace
.second_loop_skip2:
	sub cx,2
	mov di,cx
	xor dx,dx
	cmp cx,0
	jg .second_loop
.end:
	pop ax
	pop dx
	pop cx
	pop di
	ret
	
bgl_draw_gfx_rotate:
	; reference:
	; https://www.codingame.com/playgrounds/2524/basic-image-manipulation/transformation
	; test written in python, "converted over" to assembly by hand

	pusha

	; find sin of angle..
	mov ax,[bgl_rotate_angle]
	mov bx,360
	xor dx,dx
	div bx ; dx = angle % 360
	mov bx,dx
	
	shl bx,1 ; word length
	mov ax,[wave_table_deg+bx]
	mov word [bgl_rotate_angle_sin],ax
	
	; find cos of angle..
	add bx,90*2
	mov ax,bx
	mov bx,360*2
	xor dx,dx
	div bx ; dx = (angle+90) % 360
	mov bx,dx
	
	mov ax,[wave_table_deg+bx]
	mov word [bgl_rotate_angle_cos],ax

	;;;

	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	; get x and y centre points
	
	movzx ax,[bgl_width]
	shr ax,1
	mov word [bgl_rotate_x_centre],ax
	movzx ax,[bgl_height]
	shr ax,1
	mov word [bgl_rotate_y_centre],ax
	
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
	xor cx,cx
	xor dx,dx
.loop:
	push bx
	
	; x
	
	push cx
	push dx
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	xor dx,dx
	mul bx ; x*cos(angle)
	mov cx,ax ; cx = x*cos(angle)
	
	pop bx ; original y counter into bx
	push bx ;;
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; y*sin(angle)
	mov dx,ax ; dx = y*sin(angle)
	sub cx,dx
	
	push bx
	mov ax,[bgl_rotate_x_centre]
	mov bx,360
	mul bx
	add cx,ax
	pop bx
	
	mov word [bgl_rotate_x_adjusted],cx
	
	pop dx
	pop cx
	
	; y
	
	push cx
	push dx
	
	mov bx,cx
	sub bx,[bgl_rotate_x_centre]
	mov ax,[bgl_rotate_angle_sin] ; sin(angle)
	xor dx,dx
	mul bx ; x*sin(angle)
	mov cx,ax ; cx = x*sin(angle)
	
	pop bx ;; original y counter into bx
	push bx
	sub bx,[bgl_rotate_y_centre]
	mov ax,[bgl_rotate_angle_cos] ; cos(angle)
	xor dx,dx
	mul bx ; y*cos(angle)
	mov dx,ax ; dx = y*cos(angle)
	add cx,dx
	
	push bx
	mov ax,[bgl_rotate_y_centre]
	mov bx,360
	mul bx
	add cx,ax
	pop bx
	
	mov word [bgl_rotate_y_adjusted],cx
	
	mov ax,[bgl_rotate_x_adjusted]
	mov bx,360-1 ; maximum sine value, minus 1
	xor dx,dx
	div bx
	mov cx,ax
	
	mov ax,[bgl_rotate_y_adjusted]
	xor dx,dx
	div bx
	mov dx,ax
	
	call bgl_get_gfx_pixel
	
	movzx bx,[bgl_width]
	cmp cx,bx
	jl .width_skip
	mov al,[bgl_transparent]
.width_skip:
	movzx bx,[bgl_height]
	cmp dx,bx
	jl .height_skip
	mov al,[bgl_transparent]
.height_skip:
	
	pop dx
	pop cx
	
	;;;
	
	pop bx
	
	cmp byte [bgl_opaque],0
	jne .draw
	cmp al,[bgl_transparent]
	je .skip
	cmp byte [bgl_erase],0
	je .draw
	mov al,[bgl_background_colour]
	
.draw:
	stosb
	dec di
.skip:
	inc di
	inc cx
	cmp cl,[bgl_width]
	jb .loop_end
	push ax
	push bx
	mov ax,320
	movzx bx,[bgl_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	mov cx,0
	inc dx
	cmp dl,[bgl_height]
	jb .loop_end
	jmp .end
.loop_end:
	jmp .loop
.end:

	popa
	ret
	
bgl_draw_gfx_scale:

	; the simplest and most functional algorithm: (used as a reference)
	; https://www.researchgate.net/figure/Nearest-neighbour-image-scaling-algorithm_fig2_272092207

	pusha

	xor edx,edx ; when dividing 16/32 bit numbers, dx is used as the "high register"

	mov bx,[bgl_buffer_offset]
	mov al,[bx]
	mov byte [bgl_width],al
	mov al,[bx+1]
	mov byte [bgl_height],al
	mov al,[bx+2]
	mov byte [bgl_transparent],al
	
	push ebx ; ebx is our temporary register here
	
	; get scale factor based off the width
	mov eax,[bgl_scale_x]
	movzx ebx,byte [bgl_width]
	add eax,ebx ; scale amount + original width
	mov cl,[bgl_scale_precision]
	shl eax,cl
	movzx ebx,byte [bgl_width]
	div ebx ; new size/original size
	sub eax,ebx
	mov dword [bgl_scale_factor_width],eax
	
	mov eax,[bgl_scale_y]
	movzx ebx,byte [bgl_width]
	add eax,ebx ; scale amount + original width
	mov cl,[bgl_scale_precision]
	shl eax,cl
	movzx ebx,byte [bgl_width]
	xor edx,edx
	div ebx ; new size/original size
	sub eax,ebx
	mov dword [bgl_scale_factor_height],eax

	; get width and height
	xor ebx,ebx
	mov ebx,[bgl_scale_factor_width]
	movzx eax,byte [bgl_width]
	shl eax,cl
	xor edx,edx
	div ebx
	mov word [bgl_scale_width],ax
	movzx eax,byte [bgl_height]
	shl eax,cl
	xor edx,edx
	mov ebx,[bgl_scale_factor_height]
	div ebx
	mov word [bgl_scale_height],ax
	
	pop ebx

	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	cmp byte [bgl_scale_centre],0
	je .x_y_skip
	mov eax,[bgl_scale_x]
	shr eax,2
	add cx,ax
	mov eax,[bgl_scale_y]
	shr eax,2
	add dx,ax
	
.x_y_skip:
	call bgl_get_x_y_offset
	
	xor cx,cx
	xor dx,dx
.loop:
	push ebx
	push ecx
	push edx
	
	
	movzx eax,cx
	xor edx,edx
	mov ebx,[bgl_scale_factor_width]
	mul ebx
	mov cl,[bgl_scale_precision]
	shr eax,cl
	mov cx,ax
	
	pop edx
	push edx
	movzx eax,dx
	mov ebx,[bgl_scale_factor_height]
	mul ebx
	push ecx
	mov cl,[bgl_scale_precision]
	shr eax,cl
	mov dx,ax
	pop ecx
	
	call bgl_get_gfx_pixel
	
	pop edx
	pop ecx
	pop ebx
	
	cmp byte [bgl_opaque],0
	jne .draw
	cmp al,[bgl_transparent]
	je .skip
	cmp byte [bgl_erase],0
	je .draw
	mov al,[bgl_background_colour]
	
.draw:
	stosb
	dec di
.skip:
	inc di
	inc cx
	cmp cx,[bgl_scale_width]
	jb .loop_end
	push ax
	push bx
	mov ax,320
	movzx bx,[bgl_scale_width]
	sub ax,bx
	add di,ax
	pop bx
	pop ax
	mov cx,0
	inc dx
	cmp dl,[bgl_scale_height]
	jb .loop_end
	jmp .end
.loop_end:
	jmp .loop
.end:

	popa
	ret

bgl_get_gfx_pixel:
	push bx
	push cx
	push dx
	; input: cl, dl = x, y (of graphic, not the screen)
	; output: al = pixel
	; formula: (y*width)+x
	
	xor ah,ah
	mov al,dl ; y*width
	movzx bx,[bgl_width]
	mul bx
	
	mov bx,[bgl_buffer_offset]
	add bx,2 ; skip header
	
	xor ch,ch
	add ax,cx ; +x
	add bx,ax
	
	mov al,[bx]
	pop dx
	pop cx
	pop bx
	ret

bgl_draw_gfx_fast:
	push ax
	push bx
	push cx
	push dx
	push si

	; this exists as a challenge to see... just how FUAHST. i can do it.
	; there will be sacrifices, namely the lack of edge clipping
	; it'll draw based off a fixed offset instead of repeatedly calculating the x/y because that ate up tons of cycles
	
	mov si,[bgl_buffer_offset]
	mov al,[si]
	mov byte [bgl_width],al
	mov al,[si+1]
	mov byte [bgl_height],al
	mov al,[si+2]
	mov byte [bgl_transparent],al
	add si,2
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	mov cx,[bgl_x_pos]
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset ; get initial offset based off x and y
	
	xor cx,cx ; now we use cx and dx as x/y counters
	xor dx,dx
	
.draw:
	; per byte instead of words, in case the width/height isn't a multiple of 4 (i could reinforce that, but ueeEEeeaAauAHGHgh)
	mov al,[si]
	inc si
	cmp al,[bgl_transparent]
	je .draw_skip
	cmp byte [bgl_erase],0
	je .erase_skip
	mov al,[bgl_background_colour]
.erase_skip:
	stosb ; write the contents of al to es:di, increment di (faster than mov)
	dec di ; remove effect of auto increment because of the skip
.draw_skip:
	inc di
	inc cx
	cmp cl,[bgl_width] ; reached end of line?
	jne .draw_end ; if not, skip
	xor cx,cx ; reset x counter
	inc dx
	mov ax,320
	movzx bx,[bgl_width] ; bx only used as a temporary register here
	sub ax,bx
	add di,ax ; move down a line starting from current x
	mov al,[bgl_height]
	sub al,[bgl_y_clip]
	cmp dl,al ; reached baddum udda grafic?
	jne .draw_end ; if not, skip
	jmp .end ; if so, finished drawing graphic
.draw_end:
	jmp .draw
	
.end:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret

bgl_draw_gfx:
	push ax
	push bx
	push cx
	push dx
	push si
	
	; graphics are stored x first, then y
	
	mov si,[bgl_buffer_offset]
	
	mov al,[si] ; first byte should contain the width
	mov byte [bgl_width],al
	mov al,[si+1] ; second byte should contain the height
	mov byte [bgl_height],al
	
	mov al,[si+2] ; top left pixel is assumed transparent
	mov byte [bgl_transparent],al
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	add si,2 ; beginning of actual graphic data
    mov cx,[bgl_x_pos] ; x
    mov dx,[bgl_y_pos] ; y
	
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .loop ; if not, carry on as usual
	xor ax,ax
	mov al,[bgl_width]
	add cx,ax ; otherwise, start from the end

.loop:
	
    mov al,[si] ; pixel colour
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
	mov byte [es:di],al
	
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
	
bgl_draw_full_gfx: ; WARNING: this is STILL untested because a full image uses up all available space in a .com file
	push ax
	push bx
	push si
	push di
	
	mov si,[bgl_buffer_offset] ; starting from 2 to avoid the width/height - they're not necessary here
	add si,2 ; henceforth
	xor di,di
.loop:
	mov eax,[si] ; get source pixel
	mov dword [es:di],eax ; move to temporary graphics buffer
	add si,4
	cmp si,64000
	jb .loop
	
	pop di
	pop si
	pop bx
	pop ax
	ret
	
bgl_draw_full_gfx_rle:
	push ax
	push bx
	push si
	push di
	
	mov di,0
	mov si,[bgl_buffer_offset]
	add si,2
	mov cx,0
	mov dx,0
.loop:
	mov ax,[si] ; get the word
	mov word [bgl_rle_word],ax
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word]
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah
	mov word [bgl_rle_word],ax
	mov byte [es:di],al
	inc di
	
	cmp di,64000 ; reached bottom of graphic?
	jne .draw_loop ; if not, continue drawing
	jmp .end ; otherwise, stop drawing altogether
	
.draw_loop_end:
	add si,2 ; x and y are still in bounds, go to next byte
	jmp .loop
	
.end:
	pop di
	pop si
	pop bx
	pop ax
	ret

bgl_draw_gfx_rle: ; "draw graphics... really?"
	push ax
	push bx
	push cx
	push dx
	push si
	
	cmp word [bgl_x_pos],320 ; check if it's even in range before drawing
	jge .end
	cmp word [bgl_y_pos],200
	jge .end
	
	mov cx,[bgl_x_pos]
	cmp byte [bgl_flip],0
	je .flip_skip
	xor bh,bh
	mov bl,[bgl_width]
	add cx,bx
.flip_skip:
	mov dx,[bgl_y_pos]
	call bgl_get_x_y_offset
	
.init: ; bruv
	mov si,[bgl_buffer_offset]
	mov al,[si]
	mov byte [bgl_width],al
	mov al,[si+1]
	mov byte [bgl_height],al
	mov al,[si+2]
	mov byte [bgl_transparent],al
	
	cmp byte [bgl_opaque],0
	je .opaque_skip
	mov byte [bgl_transparent],255
	
.opaque_skip:
	xor cx,cx
	xor dx,dx
	
	add si,2 ; increased by 2 each time to get each byte and its repeats as a word
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .loop ; if not, skip
	mov cl,[bgl_width] ; if drawing flipped, start from the right side
.loop:
	mov ax,[si] ; get the word - low byte is colour index, high byte is amount of repeats
	mov word [bgl_rle_word],ax ; we'll need to affect ax later, and the stack can't be used in this situation
	
.draw_loop: ; drawing al for ah amount of times
	mov ax,[bgl_rle_word] ; -- equivalent to "pop ax" if the stack wasn't wacky here, this restores the affected word
	
	; \/ the positioning of this code is very very important!!! \/
	
	cmp ah,0 ; no more repeats?
	je .draw_loop_end ; if not, get next word
	dec ah ; decadecAhhh, decah decAhhh BUM. BUM. oooOOOoOoohhHYYyeEEaaAAHhhh.
	
	; /\ the positioning of this code is very very important!!! /\
	
	cmp al,[bgl_transparent] ; if the pixel about to be drawn is transparent, don't even draw it, just skip
	je .draw_loop_skip
	
	push ax
	mov ax,cx
	add ax,[bgl_x_pos]
	cmp ax,0 ; check if x and y are within boundaries
	pop ax
	jl .draw_loop_skip
	
	push ax
	mov ax,cx
	add ax,[bgl_x_pos]
	cmp ax,320
	pop ax
	jge .draw_loop_skip
	
	push ax
	mov ax,dx
	add ax,[bgl_y_pos]
	cmp ax,0
	pop ax
	jl .draw_loop_skip
	
	push ax
	mov ax,dx
	add ax,[bgl_y_pos]
	cmp ax,200
	pop ax
	jge .draw_loop_skip
	
	cmp byte [bgl_erase],0 ; erasing?
	je .draw_loop_main ; if not, continue as normal
	mov al,[bgl_background_colour] ; otherwise, replace pixel colour with the background colour
	
.draw_loop_main:
	stosb ; this is actually faster than moving the byte manually!
	dec di
.draw_loop_skip:
	mov word [bgl_rle_word],ax
	inc di
	inc cx ; increase "internal" x position
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip2 ; if not, continue as normal
	sub cx,2 ; decrease x instead (cx + 1 - 2 = cx - 1)
	sub di,2
.draw_loop_skip2:
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip3 ; if not, continue as normal
	cmp cx,0 ; if drawing flipped, simply compare the new x with the original x
	jne .draw_loop ; haven't reached the end of the line, so continue drawing
	jmp .draw_loop_skip4 ; reached end of line
.draw_loop_skip3:
	cmp cl,[bgl_width] ; reached end of the line?
	jne .draw_loop ; if not, continue drawing
.draw_loop_skip4:
	inc dx ; reached end of line, increase y and reset x
	xor cx,cx
	mov ax,320
	xor bh,bh
	mov bl,[bgl_width]
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_flip_skip ; if not, continue as normal
	add ax,bx
	jmp .draw_loop_flip_skip2
.draw_loop_flip_skip:
	sub ax,bx
.draw_loop_flip_skip2:
	add di,ax
	cmp byte [bgl_flip],0 ; drawing flipped?
	je .draw_loop_skip5 ; if not, continue as normal
	mov cl,[bgl_width]
.draw_loop_skip5:
	cmp dl,[bgl_height] ; reached bottom of graphic?
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
	mov fs,ax ; fs Should(tm) always contain the vga memory address
	
	mov ax, word [2] ; psp: segment of first byte beyond program (word)
	sub ax,64000/16 ; amount of memory we want, in "segments" (16 bytes)
	mov es,ax ; es is the temporary graphics buffer
	
	mov al,0 ; clear buffer
	mov di,0
	mov cx,64000
	call bgl_flood_fill
	
	call bgl_replace_key_handler
	
	pop bx
	pop ax
	ret
	
	
bgl_write_buffer_fast:
	; this is WAY faster, but causes some weird issues with key presses for some reason
	push ax
	push si
	push di
	push ds
	push es

	mov ax,es
	mov ds,ax
	mov ax,fs
	mov es,ax
	xor si,si
	xor di,di
	
	mov cx,64000/2
	rep movsd ; ultimate speed: FOUR BYTES AT A TIME.
	
	pop es
	pop ds
	pop di
	pop si
	pop ax
	ret	
	
bgl_write_buffer:
	push ax
	push si

	mov si,0
.loop:
	mov eax,[es:si]
	mov dword [fs:si],eax
	add si,4
	cmp si,64000
	jne .loop
	
	pop si
	pop ax
	ret
	
bgl_flood_fill:
	push ax
.loop:
	mov byte [es:di],al
	inc di
	cmp di,cx
	jne .loop
	pop ax
	ret
	
bgl_flood_fill_fast: ; di: start, cx: end
	push ax
	
	mov ah,al
	rep stosw
	
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

	xor ax,ax
	mov si,[bgl_font_string_offset]
.loop:
	mov al,[si] ; get character at position bx into al
	cmp al,0
	je .end
	sub al,33
	jmp .get_offset

.get_offset:
	push bx ; offset
	cmp al," "-33
	je .skip
	push ax ; character number
	xor ax,ax
	xor bx,bx
	mov al,[bgl_font_size] ; size in bytes
	mov bl,al
	xor dx,dx
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
	inc si
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

wave_table:
	dw 0,12,25,37,49,60,71,81,91,99,106,113,118,122,125,126,126,125,123,120,115,109,102,94,85,76,65,54,42,30,17,5,-7,-20,-32,-44,-56,-67,-77,-87,-96,-103,-110,-116,-120,-124,-126,-126,-126,-124,-121,-117,-112,-105,-98,-89,-80,-69,-59,-47,-35,-23,-10 ; length: 63

wave_table_deg:
	dw 0,6,12,18,25,31,37,43,50,56,62,68,74,80,87,93,99,105,111,117,123,129,134,140,146,152,157,163,169,174,179,185,190,196,201,206,211,216,221,226,231,236,240,245,250
	dw 254,258,263,267,271,275,279,283,287,291,294,298,301,305,308,311,314,317,320,323,326,328,331,333,336,338,340,342,344,346,347,349,350,352,353,354,355,356,357,358,358,359,359,359,359
	dw 359,359,359,359,359,358,358,357,356,355,354,353,352,350,349,347,346,344,342,340,338,336,333,331,328,326,323,320,317,314,311,308,305,301,298,294,291,287,283,279,275,271,267,263,258
	dw 254,250,245,240,236,231,226,221,216,211,206,201,196,190,185,180,174,169,163,157,152,146,140,134,129,123,117,111,105,99,93,87,80,74,68,62,56,50,43,37,31,25,18,12,6
	dw 0,-7,-13,-19,-26,-32,-38,-44,-51,-57,-63,-69,-75,-81,-88,-94,-100,-106,-112,-118,-124,-130,-135,-141,-147,-153,-158,-164,-170,-175,-180,-186,-191,-197,-202,-207,-212,-217,-222,-227,-232,-237,-241,-246,-251
	dw -255,-259,-264,-268,-272,-276,-280,-284,-288,-292,-295,-299,-302,-306,-309,-312,-315,-318,-321,-324,-327,-329,-332,-334,-337,-339,-341,-343,-345,-347,-348,-350,-351,-353,-354,-355,-356,-357,-358,-359,-359,-360,-360,-360,-360
	dw -360,-360,-360,-360,-360,-359,-359,-358,-357,-356,-355,-354,-353,-351,-350,-348,-347,-345,-343,-341,-339,-337,-334,-332,-329,-327,-324,-321,-318,-315,-312,-309,-306,-302,-299,-295,-292,-288,-284,-280,-276,-272,-268,-264,-259
	dw -255,-251,-246,-241,-237,-232,-227,-222,-217,-212,-207,-202,-197,-191,-186,-181,-175,-170,-164,-158,-153,-147,-141,-135,-130,-124,-118,-112,-106,-100,-94,-88,-81,-75,-69,-63,-57,-51,-44,-38,-32,-26,-19,-13,-7
	dw  -1