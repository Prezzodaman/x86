
	org 100h
	
	call bgl_init
	
	mov dx,3c8h
	xor al,al
	out dx,al
	mov dx,3c9h
	
	mov cx,768
palette:
	mov ax,cx
	dec ax
	shr ax,2
	push ax
	xor al,al
	out dx,al
	pop ax
	out dx,al
	out dx,al
	loop palette
	
draw:
	xor cx,cx
	xor dx,dx
	xor di,di
.loop:
	mov ax,cx
	shr ax,1
	add ax,[frame_counter]
	call bgl_get_sine
	add word [colour],ax
	
	mov ax,dx
	add ax,[frame_counter]
	call bgl_get_sine
	add word [colour],ax
	
	mov ax,cx
	shl ax,1
	mov bx,dx
	add bx,[frame_counter]
	add bx,[frame_counter]
	add ax,bx
	call bgl_get_sine
	add ax,[frame_counter]
	shr ax,1
	add word [colour],ax
	
	mov ax,[colour]
	shr ax,2
	
	mov ah,al
	push ax
	shl eax,16
	pop ax
	mov dword [es:di],eax
	
	push di
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,320
	mov dword [es:di],eax
	add di,4
	mov dword [es:di],eax
	pop di
	
	add di,4

	;;;
	
	mov word [colour],0
	inc cx
	inc cx
	inc cx
	inc cx
	cmp cx,320
	jne .loop_skip
	add di,320
	add di,320
	add di,320
	xor cx,cx
	inc dx
	inc dx
	inc dx
	inc dx
	cmp dx,200
	jne .loop_skip
	jmp .loop_end
.loop_skip:
	cmp di,64000
	jne .loop
.loop_end:
	call bgl_wait_retrace
	call bgl_write_buffer_fast
	add word [frame_counter],1
	jmp draw
	
%include "bgl.asm"
%include "general.asm"

frame_counter dw 0
colour dw 0