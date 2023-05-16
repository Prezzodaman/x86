square: ; eax = number to square, output in eax
	push ebx
	push ecx
	push edx
	mov edx,eax
	mov ecx,eax
	xor eax,eax
.loop:
	add eax,edx
	loop .loop
	pop edx
	pop ecx
	pop ebx
	ret

print_hex_word:
	push dx
	mov dl,dh
	call print_hex_byte
	pop dx
	call print_hex_byte
	ret

print_hex_byte:
	push ax
	push dx
	
	shr dl,4
	call print_hex_digit
	pop dx
	
	call print_hex_digit
	pop ax
	ret
	
print_hex_digit: ; dl: value between 0-15 (if above, it'll get the last digit, so 14 will return 4)
	push dx
	push ax
	
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
	
	pop ax
	pop dx
	ret
	
clamp_value: ; ax = value, bx = maximum value, result in ax
	push dx
	
	xor dx,dx
	cmp bx,0
	je .end
	div bx
	mov ax,dx
.end:
	pop dx
	ret
	
word_to_dword: ; input: ax, output: eax
	push edx
	cwd
	shl edx,16
	add eax,edx
	pop edx
	ret