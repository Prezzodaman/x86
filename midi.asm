
	org 100h
	
	mov si,sawng
	mov dx,haggidyhoogidy
	mov ah,25h
	mov al,1ch
	int 21h
	
a:
	jmp a
	
haggidyhoogidy:
	inc bx
	cmp bx,4
	jne .boogidybiggidy
	xor bx,bx
	
	mov ah,2
	mov dl,"."
	int 21h
	
	push bx
	
	mov al,0
	mov ah,0
	call midi_channel_change
	
	cmp si,sawng+sawng_length
	je .endy
	cmp byte [si],0
	je .skip
	mov al,0
	mov ah,127
	mov bl,[si]
	call midi_note_on
.skip:
	inc si
	
	call midi_note_off
	
.endy:
	pop bx
	
.boogidybiggidy:
	iret
	
sawng:
	db 48,50,52,53,55,55,55,55
	db 48,50,52,53,55,0,55,0
	db 48,50,52,53,55,55,55,55
	db 55,53,52,50,48,0,48,0
sawng_length equ $-sawng
	
midi_setup:
	push ax
	mov dx,331h ; gets it into uart mode
	mov al,3fh
	out dx,al
	
	mov dx,330h
	pop ax
	ret

midi_channel_change: ; al = channel, ah = instrument
	push ax
	push dx
	call midi_setup
	add al,0c0h ; change instrument
	out dx,al
	mov al,ah ; instrument number
	out dx,al
	pop dx
	pop ax
	ret
	
midi_note_off: ; al = channel, bl = note
	push ax
	call midi_setup
	add al,80h
	out dx,al
	mov al,bl ; note to turn off
	out dx,al
	mov al,63
	out dx,al ; note off velocity
	pop ax
	ret
	
midi_note_on: ; al = channel, ah = velocity, bl = note
	push ax
	push dx
	call midi_setup
	add al,90h ; note on
	out dx,al
	mov al,bl ; note to play
	out dx,al
	mov al,ah ; velocity
	out dx,al
	pop dx
	pop ax
	ret