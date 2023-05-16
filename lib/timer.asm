timer_60hz equ 4daeh
timer_30hz equ 965ch
timer_20hz equ 0e90bh
timer_18hz equ 0ffffh

	jmp timer_end

timer_reset:
	push ax
	mov ax,timer_18hz
	call timer_speed
	pop ax
	ret
	
timer_speed:
	push ax
	push dx
	mov dx,ax
	mov al,3ch
	out 43h,al
	mov al,dl
	out 40h,al
	mov al,dh
	out 40h,al
	pop dx
	pop ax
	ret
	
timer_interrupt:
	push ax
	push dx
	mov dx,ax
	mov ah,25h
	mov al,1ch
	int 21h
	pop dx
	pop ax
	ret
	
timer_end: