beep_on:
	push ax
	push dx
	mov al,182
	out 43h,al

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