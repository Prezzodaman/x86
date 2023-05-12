
	org 100h
	
%include "midi.asm"
%include "timer.asm"

	mov ax,midi_interrupt
	call timer_interrupt
	mov ax,timer_30hz
	call timer_speed

	mov byte [midi_looping],1
	mov byte [midi_speed],4
	
	mov al,0
	mov ah,80
	call midi_channel_change
	mov al,1
	mov ah,81
	call midi_channel_change
	mov al,2
	mov ah,96
	call midi_channel_change
	mov al,3
	mov ah,8
	call midi_channel_change
	
	call testmid_play
	;mov byte [midi_playing],0
	
	mov ah,0
	mov al,3
	int 10h
	
	mov ah,1
	mov cx,2607h
	int 10h
	
	mov word [midi_tracks_playing],0000000000110001b
	
q:
	
	xor cx,cx
.track_loop:
	mov ah,2
	mov bh,0
	mov dh,1
	mov dl,3
	
	push ax
	push bx
	push cx
	push dx
	mov al,cl
	mov bl,11
	xor dx,dx
	mul bl
	pop dx
	add dl,al
	pop cx
	pop bx
	pop ax
	int 10h
	
	push dx
	
	mov ah,9
	mov dx,head_track
	int 21h
	
	mov ah,2
	mov dl,"1"
	add dl,cl
	int 21h
	
	pop dx
	mov ah,2
	mov bh,0
	add dh,1
	add dl,2
	int 10h
	
	mov ah,9
	bt word [midi_tracks_playing],cx
	jc .on
	mov dx,head_off
	jmp .on_off_skip
.on:
	mov dx,head_on
.on_off_skip:
	int 21h

	inc cl
	cmp cl,[midi_tracks]
	jne .track_loop
	
	cmp byte [midi_playing],0
	je .head_playing_skip
	
	mov ah,2
	mov bh,0
	mov dh,4
	mov dl,35
	int 10h
	
	mov ah,9
	mov dx,head_playing
	int 21h
.head_playing_skip:

	mov ah,7
	int 21h
	sub al,"1"
	xor ah,ah
	btc word [midi_tracks_playing],ax
	call midi_all_notes_off_channel
	jmp q
	
%include "test_mid_c.asm"
head_track db "Track $"
head_on db "ON $" ; apply directly to the forehead
head_off db "OFF$"
head_playing db "Playing...$"