
	org 100h
	
start:
	mov si,module
	mov eax,[si+438h] ; the "magic" "number": M.K.
	cmp eax,2e4b2e4dh ; valid 4 channel mod?
	jne .error
	
	mov ah,9
	mov dx,msg_name
	int 21h
	
	xor bx,bx
.read_name: ; name is 20 bytes long
	mov al,[si+bx] ; get current byte
	mov byte [mod_name+bx],al ; store it!
	
	mov ah,2 ; gibb
	mov dl,al ; gibb
	int 21h ; gibb
	
	inc bx
	cmp bx,20
	jne .read_name
	
	mov ah,2 ; gibb
	mov dl,13 ; gibb
	int 21h ; gibb
	mov dl,10 ; gibb
	int 21h ; gibb
	
	add si,20 ; base offset
	mov cx,31 ; sample number
.get_sample_info:
	xor bx,bx ; offset starting from 0
	
.get_sample_info_name:
	mov al,[si+bx]
	
	push bx
	xor dx,dx ; current index*name length
	mov ax,bx
	mov bx,22
	mul bx
	mov bx,ax
	mov byte [mod_sample_name+bx],al
	pop bx
	
	inc bx
	cmp bx,22 ; reached end of name?
	jne .get_sample_info_name ; read next byte
	
	mov al,[si+bx] ; bx is at offset 22
	mov byte [mod_sample_length+bx],al
	inc bx
	mov al,[si+bx] ; offset 23
	mov byte [mod_sample_length+bx],al
	inc bx
	
	mov al,[si+bx] ; offset 24
	mov byte [mod_sample_finetune+bx],al
	inc bx
	
	mov al,[si+bx] ; offset 25
	mov byte [mod_sample_volume+bx],al
	inc bx
	
	mov al,[si+bx] ; offset 26
	mov byte [mod_sample_loop_start+bx],al
	inc bx
	mov al,[si+bx] ; offset 27
	mov byte [mod_sample_loop_start+bx],al
	inc bx
	
	mov al,[si+bx] ; offset 28
	mov byte [mod_sample_loop_length+bx],al
	inc bx
	mov al,[si+bx] ; offset 29
	mov byte [mod_sample_loop_length+bx],al
	inc bx
	
	add si,30 ; header length
	loop .get_sample_info
	
.get_order_info:
	xor bx,bx
	mov al,[si+bx]
	mov byte [mod_order_length],al
	inc bx
	inc bx ; unused byte...
	
	mov byte [mod_patterns],0
	mov cx,128
.get_order_info_loop:
	mov al,[si+bx]
	cmp al,[mod_patterns]
	jb .get_order_info_loop_skip
	mov byte [mod_patterns],al
.get_order_info_loop_skip:
	mov byte [mod_order_list+bx],al
	inc bx
	loop .get_order_info_loop
	
	add si,130 ; plus the order length/unused byte
	mov eax,[si]

	jmp .end
	
.error:
	mov ah,9
	mov dx,err
	int 21h
	jmp .endyes
.end:
	mov ah,9
	mov dx,msg
	int 21h
.endyes:
	jmp .endyes
	
msg_name db "Module name: $"
msg db "Done!$"
err db "Invalid 4 channel module!$"
	
module: incbin "test.mod"

mod_name resb 21
mod_channels db 0
mod_patterns db 0
mod_order_length db 0
mod_order_list resb 128

mod_samples equ 31
mod_sample_name times mod_samples resb 22
mod_sample_length times mod_samples dw 0
mod_sample_finetune times mod_samples db 0
mod_sample_volume times mod_samples db 0
mod_sample_loop_start times mod_samples dw 0
mod_sample_loop_length times mod_samples dw 0