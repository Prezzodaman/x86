timer_60hz equ 4daeh
timer_30hz equ 965ch
timer_20hz equ 0e90bh
timer_18hz equ 0ffffh
timer_interrupt_old dd 0

	jmp timer_end

timer_reset:
	push ax
	push dx
	push ds
	mov ax,timer_18hz
	call timer_speed
	
	mov ax,[timer_interrupt_old]
	mov ds,ax
	mov dx,[timer_interrupt_old+2]
	call timer_interrupt
	pop ds
	pop dx
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
	push es
	push dx
	push ax
	
	mov ah,35h
	mov al,1ch
	int 21h
	mov word [timer_interrupt_old],es
	mov word [timer_interrupt_old+2],bx
	
	pop ax
	push ax
	mov dx,ax
	mov ah,25h
	mov al,1ch
	int 21h
	
	pop ax
	pop dx
	pop es
	ret
	
timer_end: