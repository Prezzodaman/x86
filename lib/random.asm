
	jmp random_end

randomize:
	push ax ; ax through dx are all affected by the "get system time" function
	push bx
	push cx
	push dx
	mov ah,2ch ; get system time
	int 21h
	add word [global_randomizer],dx ; dl = 100th of a second, dh = whole second
	add word [global_randomizer],54789 ; there's no reasoning behind this number :P
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
random: ; gets a random number between 0-65535, puts it into ax, randomizes "seed"
	mov ax,[global_randomizer]
	add word [global_randomizer],2649 ; yet another meaningless number
	ret
	
random_range: ; gets a random number in range 0 to ax-1, the result is in ax
	push bx
	push dx
	
	push ax ; top range
	call random
	pop bx ; pop top range into bx
	xor dx,dx
	div bx ; ax (random number) divided by bx (top range)
	mov ax,dx ; here's the result!
	
	pop dx
	pop bx
	ret

global_randomizer dw 0 ; name of my next album

random_end: