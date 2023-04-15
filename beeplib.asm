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

	cmp dx,2
	je .beep_off
	mov ax,dx
	out 42h,al ; low byte...
	mov al,ah
	out 42h,al ; high byte...
	in al,61h

	mov al,00000011b ; connect speaker to timer 2
	out 61h,al
	jmp .end
.beep_off:
	call beep_off
.end:
	pop dx
	pop ax
	ret
	
beep_off:
	push ax
	mov al,11111100b ; disconnect speaker from timer 2
	out 61h,al
	pop ax
	ret
	
beep_sfx_state dw 0
beep_sfx_offset dw 0
beep_sfx_playing db 0
beep_sfx_add dw 0
	
beep_play_sfx:
	mov word [beep_sfx_offset],si
	mov word [beep_sfx_state],0
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
	mov	bx,[beep_sfx_state]
	shl bx,1 ; each beep is a word, so multiply by 2
	mov dx,[si+bx] ; beep the appropriate beep
	cmp dx,0 ; check that the beep value is non zero before beeping
	je .stop ; if it's zero, stop playing the sound effect
	cmp dx,1 ; otherwise, check that the value is 1 (loop)
	je .rewind ; if so, rewind
	cmp dx,3 ; is the value a note cut?
	jne .skip ; if not, proceed as usual
	call beep_off ; cut note, skip past beep_change as that turns on the beeper
	jmp .skip_2
.rewind:
	mov word [beep_sfx_state],0
	mov si,[beep_sfx_offset]
	mov bx,0
	mov dx,[si+bx]
.skip:
	add dx,[beep_sfx_add]
	call beep_change ; if it's non zero, beep!
.skip_2:
	inc word [beep_sfx_state] ; once beeped, go to next beep
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

	; references:
	; 	https://www.youtube.com/watch?v=4SBUrv7fXqI
	;	https://wiki.osdev.org/Programmable_Interval_Timer

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
	xor bx,bx
	mov es,bx
	mov bx,[es:46ch]
.wait:
	cmp bx,[es:46ch]
	je .wait
	pop bx
	pop es
	
	; play the byte
	
	mov al,10010000b ; 001 = hardware re-triggerable one-shot
	out 43h,al ; mode/command register
	mov al,[si+bx] ; frequency (current sample byte)
	shr al,1
	inc al ; reduce distortion
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
	
beep_play_pcm_sample2: ; using 32 bit registers, no audible carrier signal - compatibility issues on older computers

	push ax
	push bx
	push cx
	push dx
	
	add cx,16
	shr cx,1
	shl edx,1
	
	sub cl,16
	mov al,16h ; speed up timer
	out 43h,al
	mov al,cl
	out 40h,al
	
	call beep_on
	
	mov ebx,0 ; data pointer
	
.loop:
	push es ; wait...
	push ebx
	xor bx,bx
	mov es,bx
	mov bx,[es:46ch]
.wait:
	cmp bx,[es:46ch]
	je .wait
	pop ebx
	pop es
	
	; play the byte
	
	push ebx
	shr ebx,1
	mov al,10010000b ; 001 = hardware re-triggerable one-shot
	out 43h,al ; mode/command register
	mov al,[si+bx] ; frequency (current sample byte)
	shr al,2
	inc al ; reduce distortion
	out 42h,al
	pop ebx
	
	inc ebx ; go to next byte
	
	cmp ebx,edx ; reached end of file?
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
	
beep_pcm_offset dw 0
beep_pcm_length dw 0
beep_pcm_position dw 0
beep_pcm_speed db 0
beep_pcm_loops dw 0
	
beep_pcm_on:
	push cx
	push ax
	mov cl,[beep_pcm_speed]
	sub cl,24
	mov al,16h ; speed up timer
	out 43h,al
	mov al,cl
	out 40h,al
	pop ax
	pop cx
	ret
	
beep_pcm_off:
	push ax
	mov al,16h ; slow timer down
	out 43h,al
	mov al,0
	out 40h,al
	pop ax
	ret
	
beep_pcm_handler:
	push cx
	mov cx,[beep_pcm_loops]
.loop:
	call beep_pcm_handler_sub
	loop .loop
	pop cx
	ret
	
beep_pcm_handler_sub:
	push ax
	push bx
	push dx
	
	call beep_pcm_on
	
	mov si,[beep_pcm_offset]
	mov bx,[beep_pcm_position]
	mov dx,[beep_pcm_length]
	
	push es ; wait...
	push bx
	xor bx,bx
	mov es,bx
	mov bx,[es:46ch]
.wait:
	cmp bx,[es:46ch]
	je .wait
	pop bx
	pop es
	
	; play the byte
	
	mov al,10010000b ; 001 = hardware re-triggerable one-shot
	out 43h,al ; mode/command register
	mov al,[si+bx] ; frequency (current sample byte)
	shr al,1
	inc al ; reduce distortion
	out 42h,al
	
	cmp bx,0 ; at beginning of file?
	je .beep_on ; if so, turn ON beeper
	cmp bx,dx ; reached end of file?
	je .beep_off ; if so, turn off beeper
	jmp .next_byte ; otherwise, go to next byte
	
.beep_off:
	call beep_off
	jmp .end
.beep_on:
	call beep_on
.next_byte:
	inc word [beep_pcm_position]
.end:
	
	call beep_pcm_off
	pop dx
	pop bx
	pop ax
	ret

beep_22050 equ 62
beep_22050_pwm equ beep_22050+30
beep_11025 equ beep_22050*2
beep_16000 equ 83
beep_8000 equ beep_16000*2

beep_c1 equ 478bh
beep_c_sharp_1 equ 4494h
beep_d1 equ 4034h
beep_d_sharp_1 equ 3ca9h
beep_e1 equ 38dah
beep_f1 equ 3613h
beep_f_sharp_1 equ 334ah
beep_g1 equ 2fc0h
beep_g_sharp_1 equ 3db3h
beep_a1 equ 2b46h
beep_a_sharp_1 equ 284bh
beep_b1 equ 2606h
beep_c2 equ 23d0h
beep_c_sharp_2 equ 218dh
beep_d2 equ 1fc4h
beep_d_sharp_2 equ 1e20h
beep_e2 equ 1c8bh
beep_f2 equ 1aadh
beep_f_sharp_2 equ 193dh
beep_g2 equ 17b0h
beep_g_sharp_2 equ 1674h
beep_a2 equ 154ah
beep_a_sharp_2 equ 13ffh
beep_b2 equ 130dh
beep_c3 equ 11c7h
beep_c_sharp_3 equ 10b9h
beep_d3 equ 1000h
beep_d_sharp_3 equ 0f14h
beep_e3 equ 0e4fh
beep_f3 equ 0d6ah
beep_f_sharp_3 equ 0cb3h
beep_g3 equ 0bedh
beep_g_sharp_3 equ 0b5bh
beep_a3 equ 0a90h
beep_a_sharp_3 equ 0a00h
beep_b3 equ 990h
beep_c4 equ 904h
beep_c_sharp_4 equ 877h
beep_d4 equ 7f0h
beep_d_sharp_4 equ 792h
beep_e4 equ 719h
beep_f4 equ 6aeh
beep_f_sharp_4 equ 65dh
beep_g4 equ 600h
beep_g_sharp_4 equ 5a9h
beep_a4 equ 549h
beep_a_sharp_4 equ 50ah
beep_b4 equ 4beh
beep_c5 equ 46eh