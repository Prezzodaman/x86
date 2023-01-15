
	org 100h
	
	mov dx,4000 ; frequency
	call beep_on
	mov ah,7
	int 21h
	call beep_off
	
	mov ah,4ch
	int 21h
	
beep_on:
	mov al,182
	out 43h,al

	mov ax,dx
	out 42h,al ; low byte...
	mov al,ah
	out 42h,al ; high byte...
	in al,61h

	or al,00000011b ; connect speaker to timer 2
	out 61h,al
	ret
	
beep_off:
	and al,11111100b ; disconnect speaker from timer 2
	out 61h,al
	ret