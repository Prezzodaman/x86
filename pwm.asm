
	org 100h
	
	mov si,pwm_file
	mov cx,620
	mov dx,[pwm_file_length]
	call beep_play_sample
	
	mov ah,4ch
	int 21h
	
%include "beeplib.asm"
pwm_file: incbin "highrate_bin.raw"
pwm_file_length: dw $-pwm_file