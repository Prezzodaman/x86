
	org 100h
	
	call bgl_init
	
	call canvas_clear
	call top_bottom_draw
	call canvas_open
	
loopy:
	mov ax,3
	int 33h
	shr cx,1
	mov word [brush_x],cx
	mov word [brush_y],dx
	
	call canvas_grab_brush_buffer ; get the current canvas
	
	cmp bx,0
	je .draw_skip
	cmp bx,1
	je .draw
	cmp bx,2
	je .save
	;cmp dx,top_height
	;jl .draw_skip
	;cmp dx,200-bottom_height
	;jg .draw_skip
.draw:
	call canvas_draw_pixel
	call top_bottom_draw
	jmp .end
.save:
	call canvas_save
	call bgl_reset
	mov ah,4ch
	int 21h
	
.draw_skip:
	call top_bottom_draw
.end:
	dec cx
	mov word [bgl_x_pos],cx
	mov word [bgl_y_pos],dx
	mov word [bgl_buffer_offset],pencil_rle
	call bgl_draw_gfx_rle
	
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	
	inc cx
	call canvas_draw_brush_buffer
	
	jmp loopy
	
top_bottom_draw:
	push ax
	push cx
	push di
	
	mov al,4
	mov di,0
	mov cx,(top_height*320)/2
	call bgl_flood_fill_fast
	
	mov al,4
	mov di,(200-(bottom_height))*320
	mov cx,(bottom_height*320)/2
	call bgl_flood_fill_fast
	
	pop di
	pop cx
	pop ax
	ret
	
canvas_draw_pixel: ; cx, dx = brush x and y, al = colour
	push ax
	push cx
	push dx
	push di

	movzx ax,[brush_size] ; movzx because we need to compare to 16-bit registers
	inc ax
	cmp al,0 ; drawing 1 pixel?
	je .one_pixel ; skip checks for speed
	push cx ;
	push dx ;;
	
	push ax
	dec ax
	shr ax,1
	sub cx,ax
	sub dx,ax
	call bgl_get_x_y_offset
	pop ax
	xor cx,cx ; reset x counter
	xor dx,dx ; reset y counter
.loop:
	push ax ; ax stores the brush size
	mov al,[brush_colour]
	mov byte [es:di],al
	pop ax ; restore brush size
.loop_skip:
	inc cx
	inc di
	cmp cl,al ; reached width?
	jne .loop ; if not, continue
	xor cx,cx ; reset x counter
	inc dx ; increase y counter
	sub di,ax ; move down a line
	add di,320
	cmp dx,ax ; reached height?
	jne .loop ; if not, continue
.loop_end:
	jmp .end ; done drawing, skip to end
.one_pixel:
	call bgl_get_x_y_offset
	mov al,[brush_colour]
	mov byte [es:di],al
.end:
	pop dx ;;
	pop cx ;
	call canvas_grab_brush_buffer ; get the canvas after being affected
	pop di
	pop dx
	pop cx
	pop ax
	ret
	
canvas_draw_brush_buffer: ; cx, dx = brush x and y
	push bx
	push cx
	push dx
	push di

	call bgl_get_x_y_offset ; get buffer location into di
	xor bx,bx ; brush buffer offset
	xor cx,cx ; clear x counter
	xor dx,dx ; clear y counter
.loop:
	mov al,[brush_buffer+bx]
	mov byte [es:di],al
	inc di
	inc bx ; increase brush buffer offset
	inc cx ; increase x counter
	cmp cx,brush_gfx_size+1 ; reached width?
	jne .loop ; if not, continue
	sub di,brush_gfx_size+1 ; otherwise, move down a line
	add di,320
	xor cx,cx ; reset x counter
	inc dx ; increase y counter
	cmp dx,brush_gfx_size ; reached height?
	jne .loop ; if not, continue looping
	
	pop di
	pop dx
	pop cx
	pop bx
	ret
	
canvas_grab_brush_buffer: ; cx, dx = brush x and y
	push bx
	push cx
	push dx

	call bgl_get_x_y_offset
	xor bx,bx ; brush buffer offset
	xor cx,cx ; clear x counter
	xor dx,dx ; clear y counter
.loop:
	mov al,[es:di]
	mov byte [brush_buffer+bx],al
	inc bx ; increase brush buffer offset
	inc cx ; increase x counter
	inc di
	cmp cx,brush_gfx_size+1 ; reached width?
	jne .loop ; if not, continue
	xor cx,cx ; reset x counter
	inc dx ; increase y counter
	sub di,brush_gfx_size+1
	add di,320
	cmp dx,brush_gfx_size ; reached height?
	jne .loop ; if not, continue looping
	
	pop dx
	pop cx
	pop bx
	ret

canvas_clear:
	push ax
	push cx
	push di
	
	mov al,15
	mov di,top_height*320
	mov cx,((200-(top_height+bottom_height))*320)/2
	call bgl_flood_fill_fast
	
	pop di
	pop cx
	pop ax
	ret

canvas_open:
	push eax
	push ebx
	push ecx
	push edx
	push edi

	mov ah,3dh ; open file
	mov al,0 ; read access
	mov dx,picture_filename
	int 21h ; file handle in ax
	jc .error
	
	mov bx,ax
	mov cx,4 ; one word at a time
	mov di,top_height*320
.loop: ; doing it per dword instead of the whole file, because we only have 64kb to work with, so we read it a bit at a time
	mov ah,3fh ; read bytes from file
	mov dx,canvas_read_buffer ; ...into this buffer!
	int 21h
	mov eax,[canvas_read_buffer]
	mov dword [es:di],eax
	add di,cx
	cmp di,(200-bottom_height)*320
	jne .loop
	jmp .end
.error:
	mov word [bgl_buffer_offset],error_rle
	mov word [bgl_x_pos],(320/2)-(121/2)
	mov word [bgl_y_pos],(200/2)-(41/2)
	call bgl_draw_gfx_rle_fast
	call bgl_write_buffer_fast
	mov cx,120 ; wait for so-and-so frames
.error_wait:
	call bgl_wait_retrace
	loop .error_wait
	call canvas_clear
.end:

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

canvas_save:
	push ax
	push bx
	push cx
	push dx
	push si

	mov ah,3dh ; open file
	mov al,2 ; read/write
	mov dx,picture_filename
	int 21h ; try to open file, if successful, file handle in ax
	jnc .exists ; carry set if file doesn't exist
	mov ah,3ch ; file doesn't exist, create file
	xor cx,cx ; attributes "read-only" even though you can write
	mov dx,picture_filename
	int 21h ; if successful, file handle in ax
	jc .error ; if for some reason the file can't be created
.exists:
	mov bx,ax ; the "write file" function requires the handle to be in bx
	mov si,top_height*320 ; canvas start
	push ds
	mov ax,es
	mov ds,ax
	mov dx,si ; bytes to write
	mov ah,40h ; write file
	mov cx,(200-bottom_height-top_height)*320 ; how many bytes
	int 21h
	pop ds
	jmp .end
.error:
.end:

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
%include "../bgl.asm"
picture_filename db "picture.pic",0
top_height equ 20
bottom_height equ 20

brush_x dw 0
brush_y dw 0
brush_size db 2 ; 0 is 1 pixel, 1 is 2, etc.
brush_colour db 0
brush_buffer resb (brush_gfx_size+1)*brush_gfx_size
brush_gfx_size equ 21 ; not in bytes, but in both width/height
pencil_rle: incbin "pencil.rle"

canvas_read_buffer dd 0

error_rle: incbin "error.rle"