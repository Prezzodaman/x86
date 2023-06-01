
%define blaster_buffer_size_custom
%define blaster_mix_rate_22050

%define modlib
%define mod_debug
;%define mod_buffer_override

;	blaster_mix_buffer_base_length equ 770

	org 100h
	
	call blaster_init
	mov ax,mod_interrupt
	call timer_interrupt
	
	mov si,module
	call mod_play
	
hang:
	jmp hang

module: incbin "mods/pungi.mod"
	
%include "lib/blaster.asm"
%include "lib/mod.asm"
%include "lib/timer.asm"
%include "lib/general.asm"