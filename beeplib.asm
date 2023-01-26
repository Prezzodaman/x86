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
	mov si,[beep_sfx_offset]
	mov bx,0
	mov dx,[si+bx]
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
	
beep_play_sample:

	push ax
	push bx
	push cx
	push dx
	
	mov ax,1
	out 42h,al ; low byte...
	mov al,ah
	out 42h,al ; high byte...
	in al,61h
	
	mov al,16h ; make the timer ultra fast y'all
	out 43h,al
	mov al,cl
	out 40h,al
	mov bx,0 ; offset (increased once all bits processed)
	mov cx,0 ; bit counter
	
.loop:
	mov al,[si+bx]
	inc bx
.loop_shift:
	push bx ;
	push es
	mov bx,0
	mov es,bx
	mov bx,[es:46ch]
.wait:
	cmp bx,[es:46ch]
	je .wait

	pop es
	pop bx ;

	shl al,1 ; get bit from the left
	jc .loop_beep_on ; if the bit's a 1, turn on the speaker
	call beep_off ; if the bit's a 0, turn off the speaker
	jmp .loop_skip
.loop_beep_on:
	call beep_on
.loop_skip:
	inc cx
	cmp cx,7 ; reached last bit?
	jne .loop_shift ; if not, keep shifting
	mov cx,0 ; otherwise, reset counter
	dec dx ; file length
	cmp dx,0 ; reached end of file?
	jne .loop ; if not, go to next bit
	
	mov al,16h ; slow timer down
	out 43h,al
	mov al,0
	out 40h,al
	
	call beep_off
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
beep_play_pcm_sample: ; si = source index, cx = speeeeeeeed, dx = length

	; reference:
	; 	https://www.youtube.com/watch?v=4SBUrv7fXqI
	; i understand all of it, apart from outing 90h to 43h - what does that do?

	push ax
	push bx
	push cx
	push dx
	
	sub cl,16
	mov al,16h ; speed up timer
	out 43h,al
	mov al,cl
	out 40h,al
	
	call beep_on
	
	mov bx,0 ; data pointer
	
.loop:
	push es ; wait...
	push bx
	mov bx,0
	mov es,bx
	mov bx,[es:46ch]
.wait:
	cmp bx,[es:46ch]
	je .wait
	pop bx
	pop es
	
	; play the byte
	
	mov al,90h ; "set up the speaker"
	out 43h,al
	mov al,[si+bx] ; frequency (current sample byte)
	shr al,1
	add al,8 ; reduce distortion
	out 42h,al
	
	inc bx ; go to next byte
	
	cmp bx,dx ; reached end of file?
	jne .loop ; if not, keep going
	
	mov al,16h ; slow timer down
	out 43h,al
	mov al,0
	out 40h,al
	
	call beep_off
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
beep_sfx_state db 0
beep_sfx_offset dw 0
beep_sfx_playing db 0

beep_22050 equ 62
beep_11025 equ 62*2