
%define blaster_mix_rate_22050
%define blaster_buffer_size_custom
%define blaster_mix_1_voice

%define bgl_no_rotate
%define bgl_no_scale
%define bgl_no_rle
%define bgl_no_palette
%define bgl_no_wave
%define bgl_no_keys

%include "blaster.asm"
%include "bgl.asm"
%include "timer.asm"

	; warning: this code is extremely Ugly and I Know It (by LMFAO)

	org 100h
	
	cmp byte [80h],0
	je uhoh
	movzx bx,[80h]
	mov cx,bx
	mov byte [bx+81h],0
	xor di,di
	xor bx,bx
psp:
	mov al,[bx+82h]
	mov byte [filename+di],al
	inc bx
	inc di
	loop psp
	jmp main
uhoh:
	mov ah,9
	mov dx,uhoh_msg
	int 21h
	mov ah,4ch
	int 21h
	
main:
	mov word [bgl_font_offset],font_gfx-(66*15)
	mov word [bgl_font_size],8
	mov word [bgl_font_spacing],8
	
	blaster_mix_buffer_base_length equ blaster_mix_18hz-30
	call blaster_init
	call bgl_init
	
	mov al,0
	mov ah,1
	mov bx,1
	mov dx,[s]
	mov si,filename
	call blaster_mix_play_sample
	
	mov ax,inty
	call timer_interrupt
	
hi:
	mov al,0
	mov di,0
	mov cx,64000/2
	call bgl_flood_fill_fast
	
	mov ax,3
	call bgl_blaster_visualize
	
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov cx,5
	xor ax,ax
.l:
	mov word [bgl_buffer_offset],font_gfx_rate
	add word [bgl_buffer_offset],ax
	call bgl_draw_gfx_fast
	add word [bgl_x_pos],8
	add ax,66
	loop .l
	
	mov word [bgl_x_pos],5*8
	movzx eax,word [s]
	mov cx,5
	call bgl_draw_font_number
	
	call bgl_wait_retrace
	call bgl_write_buffer
	
	mov ax,3
	int 33h
	cmp bx,0
	je .end
	cmp bx,1
	jne .right
	add word [s],60
.right:
	cmp bx,2
	jne .skip
	sub word [s],60
.skip:
	push bx
	mov ax,[s]
	xor bx,bx
	call blaster_get_scale
	pop bx
.end:
	
	mov ah,1
	int 16h
	jz .ender
	call bgl_reset
	call timer_reset
	mov ah,4ch
	int 21h
.ender:
	jmp hi
	
inty:
	call blaster_mix_calculate
	call blaster_program_dma
	call blaster_start_playback
	iret
	
filename resb 64
s dw 22050

rate_str db "RATE:",0

font_gfx:
	incbin "bgl/c64_0.gfx"
	incbin "bgl/c64_1.gfx"
	incbin "bgl/c64_2.gfx"
	incbin "bgl/c64_3.gfx"
	incbin "bgl/c64_4.gfx"
	incbin "bgl/c64_5.gfx"
	incbin "bgl/c64_6.gfx"
	incbin "bgl/c64_7.gfx"
	incbin "bgl/c64_8.gfx"
	incbin "bgl/c64_9.gfx"
font_gfx_rate:
	incbin "bgl/c64_r.gfx"
	incbin "bgl/c64_a.gfx"
	incbin "bgl/c64_t.gfx"
	incbin "bgl/c64_e.gfx"
	incbin "bgl/c64_58.gfx"
uhoh_msg db "No file specified!",13,10,"$"