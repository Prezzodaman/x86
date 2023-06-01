
	org 100h
	
	call opl_reset
	xor al,al
	mov si,opl_instrument_musicbox
	call opl_setup_instrument
	
	mov si,cscale
.a:
	mov ah,2
	mov dl,"."
	int 21h

	xor al,al
	mov bl,[si]
	call opl_note_on
	
	mov ah,7
	int 21h
	
	xor al,al
	call opl_note_off
	inc si
	cmp si,cscale+8
	jne .s
	mov si,cscale
.s:
	
	jmp .a
	
%include "lib/opl.asm"

cscale db 48,50,52,53,55,57,59,60