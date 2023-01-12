org 100h

main:
	mov dx,msg
	mov ah,9
	int 21h

	mov dx,input_buffer
	mov ah,10 ; get input
	int 21h

	mov si,input_buffer ; compare strings
	mov di,compare
	cld
	repe cmpsb
	je equal
	mov byte [is_equal],0

equal:
	xor bx,bx ; clear register bx (not necessary for now)
	mov bl,input_buffer[1] ; move offset of buffer end into lower bits of bx
	mov byte input_buffer[bx+2],"$" ; add a dollar at the end
	; we use bx instead of bl because addresses must be 16-bit

	mov dx,msg2
	mov ah,9
	int 21h
	lea dx,[input_buffer+2] ; must use lea for offsets!
	mov ah,9
	int 21h
	
	mov dx,crlf
	mov ah,9
	int 21h
	
	mov ax,0
	mov bx,is_equal
	cmp ax,bx
	je end
	
	mov dx,msg3
	mov ah,9
	int 21h
	
end:
	mov ah,0x4c
	int 21h

msg db "Hello world!",13,10,"$"
msg2 db "The thing you said was:",13,10,"$"
msg3 db "That's a bit stupid isn't it?",13,10,"$"
compare db "yes",13,10
crlf db 13,10,"$"
input_buffer db 10,?,10 dup(" ")
is_equal db 1