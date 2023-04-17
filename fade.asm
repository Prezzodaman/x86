; these peoples try to fade me, c-c-c-call me on my selfoam (i get busy)

	org 100h
	
	call bgl_init
	call bgl_get_orig_palette

	xor al,al
	xor di,di
	xor cx,cx
	xor dx,dx
loop:
	mov byte [fs:di],al
	add di,320
	inc dx
	cmp dx,200
	jb .skip
	xor dx,dx
	xor di,di
	inc cx
	add di,cx
	inc al
	cmp cx,255
	jb .skip
	jmp hang
.skip:
	jmp loop
hang:
	call bgl_fade_in
	call bgl_fade_out
	jmp hang
	
;yems: incbin "engineer.gfx"
	
%include "bgl.asm"