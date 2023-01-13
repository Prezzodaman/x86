; this entire code worked PERFECTLY first try, god i'm getting good

org 100h

pixel_colour dw 0

main:
    mov al,13h ; 256 colour vga
    mov ah,0
    int 10h
	
    mov cx,0
    mov dx,0
loop:
	mov al,[pixel_colour]
    mov ah,0ch ; function number
	int 10h
	inc dx ; increase y
	cmp dx,199 ; reached bottom of screen?
	jne loop ; if not, keep increasing y
	inc cx ; otherwise, increase x and reset y
	mov dx,0
	inc byte [pixel_colour]
	cmp cx,255 ; reached right of screen?
	jne loop ; if not, keep increasing y
	mov ah,0x4c ; if so, give us access to the command line again
	int 21h