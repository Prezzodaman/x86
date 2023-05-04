
blaster_buffer_size equ blaster_mix_buffer_size

%include "blaster.asm"

blaster_set_sample_rate 11025

	org 100h
	
	call blaster_init
	
	mov ah,9
	mov dx,message
	int 21h
	
	mov al,0
	mov ah,1
	mov bx,1
	mov si,filename
	mov ecx,342381
	call blaster_mix_play_sample
	
hi:
	call blaster_mix_retrace
	jmp hi
	
filename db "reallylong.raw",0
message db "That's jazzy!$"