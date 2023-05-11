
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
	
q:
	jmp q
	
%include "test_mid.asm"