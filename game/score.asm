score_draw:
	mov cx,0 ; counter
	mov bx,0 ; offset
	mov byte [bgl_opaque],0
	mov byte [bgl_flip],0
	mov byte [bgl_erase],0
	mov ax,text_score_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[text_score_y]
	mov word [bgl_y_pos],ax
	mov ax,[text_score_x_start] ; doing this after, so we can have some fun with ax
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	mov ax,[game_score]
	mov word [game_score_divisor],ax
	mov ax,[text_score_x]
	mov word [text_score_x_start],ax
	add ax,38 ; end of score display
	add ax,10*5

.loop:
	push ax ;;
	mov ax,[game_score_divisor]
	mov bx,10
	xor dx,dx ; clear remainder
	div bx ; game_score/10 - the one digit will be in dx
	mov word [game_score_divisor],ax
	
	mov ax,dx ; move remainder into ax so we can multiply (mul acts on ax)
	mov bx,66 ; 66 = size of one number
	mul bx ; ax*=66
	push ax ; push remainder to stack
	
	
	pop bx ; get remainder from stack
	mov ax,text_score_numbers_gfx
	add ax,bx ; offset the... offset
	mov word [bgl_buffer_offset],ax

	cmp cx,5 ; reached the last digit?
	je .men ; if so, finish drawing
	inc cx ; otherwise, continue
	
	pop ax ;;
	sub ax,9 ; spacing between numbers
	mov word [bgl_x_pos],ax
	
	call bgl_draw_gfx
	jmp .loop
	
.men: ; best label name 2023
	pop ax
	mov ax,text_men_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[text_score_y]
	mov word [bgl_y_pos],ax
	mov word [bgl_x_pos],232
	call bgl_draw_gfx
	
	xor cx,cx
	mov cl,[bumper_pres_men] ; men to draw
	cmp cx,0 ; no men?
	je .end
	
	mov ax,man_icon_gfx
	mov word [bgl_buffer_offset],ax
	mov ax,[text_score_y]
	sub ax,2 ; cuz
	mov word [bgl_y_pos],ax
	mov ax,264 ; x men: the last stand
.men_loop:
	mov word [bgl_x_pos],ax
	call bgl_draw_gfx
	dec cx
	cmp cx,0 ; no more men left?
	je .end ; if not, finish drawing
	add ax,16 ; otherwise, man up
	jmp .men_loop
	
.end:
	ret

game_score dw 0
game_score_divisor dw 0
text_score_gfx: incbin "text_score.gfx"
text_score_numbers_gfx:
	incbin "text_score_0.gfx"
	incbin "text_score_1.gfx"
	incbin "text_score_2.gfx"
	incbin "text_score_3.gfx"
	incbin "text_score_4.gfx"
	incbin "text_score_5.gfx"
	incbin "text_score_6.gfx"
	incbin "text_score_7.gfx"
	incbin "text_score_8.gfx"
	incbin "text_score_9.gfx"
text_score_x dw 10
text_score_x_start dw 10
text_score_y dw 180
text_men_gfx: incbin "text_men.gfx"
man_icon_gfx: incbin "man_icon.gfx"