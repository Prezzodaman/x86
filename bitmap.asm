org 100h

main:
	mov dx,msg
	mov ah,9
	int 21h
	
	mov ah,4ch
	int 21h
	
msg db "Hello world",13,10,"$"
    