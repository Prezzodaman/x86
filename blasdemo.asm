
%include "blaster.asm"

	org 100h

	call blaster_init
	blaster_set_sample_rate 16000
	
yess:
	mov si,sound
	mov cx,sound_size
	call blaster_play_sound
	xor ah,ah
	int 16h
	
	mov si,sound_2
	mov cx,sound_2_size
	call blaster_play_sound
	xor ah,ah
	int 16h
	
	jmp yess
	
	call blaster_deinit
	
	mov ah,4ch
	int 21h

sound: incbin "organ1.raw"
sound_size equ $-sound
sound_2: incbin "organ2.raw"
sound_2_size equ $-sound_2