
	org 100h
	
	mov al,2
	mov ah,0
	int 10h
	mov dx,message
	mov ah,9
	int 21h
	
	call bgl_get_orig_key_handler
	call bgl_replace_key_handler
	
	call beep_on
	mov dx,0
	
main_loop:
	cmp word [bgl_key_states+4bh],0 ; left
	je .skip
	dec dx
	jmp .end
.skip:
	cmp word [bgl_key_states+4dh],0 ; right
	je .end
	inc dx
.end:
	call beep_change
	mov cx,6000
.delay:
	nop
	dec cx
	cmp cx,0
	jne .delay
	jmp main_loop

message: db "Press left/right to decrease/increase beep frequency",13,10,"$"

%include "beeplib.asm"
%include "bgl.asm"