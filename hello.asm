	
	org 100h

main:
	mov dx,msg
	mov ah,9
	int 21h

	mov dx,input_buffer
	mov ah,10 ; get input
	int 21h

	movzx bx,[input_buffer+1] ; number of characters actually read
	mov byte [input_buffer+bx+2],"$" ; add a dollar at the end

	mov dx,msg2 ; "the thing you said was:"
	mov ah,9
	int 21h
	
	mov dx,input_buffer+2 ; show the message you entered
	mov ah,9
	int 21h
	
	mov dx,crlf ; carriage return
	mov ah,9
	int 21h

	mov si,input_buffer+2 ; compare strings
	mov di,compare
	movzx cx,[input_buffer+1]
.check:
	mov al,[si]
	mov ah,[di]
	cmp al,ah
	jne .end ; strings aren't equal, go to end
	inc si ; strings are equal so far, continue checking
	inc di
	loop .check
	
.snark: ; strings are equal, show a very serious message
	mov dx,msg3
	mov ah,9
	int 21h
	
.end:
	mov ah,4ch
	int 21h

msg db "Hello world!",13,10,"$"
msg2 db "The thing you said was:",13,10,"$"
msg3 db "That's a bit stupid isn't it?",13,10,"$"
compare db "yes",13,10
crlf db 13,10,"$"
input_buffer
	db 10,0
	resb 11 ; 10 + 1 for the eof character