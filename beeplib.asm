beep_on:
	push ax
	mov al,182
	out 43h,al

	mov al,00000011b ; connect speaker to timer 2
	out 61h,al
	pop ax
	ret
	
beep_change:
	push ax
	push dx

	mov ax,dx
	out 42h,al ; low byte...
	mov al,ah
	out 42h,al ; high byte...
	in al,61h

	mov al,00000011b ; connect speaker to timer 2
	out 61h,al
	pop dx
	pop ax
	ret
	
beep_off:
	push ax
	mov al,11111100b ; disconnect speaker from timer 2
	out 61h,al
	pop ax
	ret
	
beep_play_sfx:
	mov word [beep_sfx_offset],si
	mov byte [beep_sfx_state],0
	mov byte [beep_sfx_playing],1
	call beep_on
	ret
	
beep_handler:
	push dx
	push si
	push bx
	mov si,[beep_sfx_offset]
	cmp byte [beep_sfx_playing],0 ; playing a sound?
	je .end ; if not, do nothing
	xor bx,bx
	mov	bl,[beep_sfx_state]
	shl bx,1 ; each beep is a word, so multiply by 2
	mov dx,[si+bx] ; beep the appropriate beep
	cmp dx,0 ; check that the beep value is non zero before beeping
	je .stop ; if it's zero, stop beeping
	cmp dx,1 ; otherwise, check that the value is 1 (loop)
	je .rewind ; if so, rewind
	jmp .skip
.rewind:
	mov byte [beep_sfx_state],0
.skip:
	call beep_change ; if it's non zero, beep!
	inc byte [beep_sfx_state] ; once beeped, go to next beep
	jmp .end
.stop:
	call beep_off
	mov byte [beep_sfx_playing],0
.end:
	pop bx
	pop si
	pop dx
	ret
	
beep_sfx_state db 0
beep_sfx_offset dw 0
beep_sfx_playing db 0