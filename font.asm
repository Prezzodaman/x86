
	org 100h
	
	call bgl_init
	;call bgl_restore_orig_key_handler
	
loop:
	mov al,0
	mov di,0
	mov cx,64000
	call bgl_flood_fill

	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov ax,font_gfx
	mov word [bgl_font_offset],ax
	mov byte [bgl_font_size],24
	mov byte [bgl_font_spacing],24
	
	mov ax,stringy
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	add word [bgl_y_pos],24
	mov ax,stringy2
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	add word [bgl_y_pos],24
	mov ax,stringy3
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	call bgl_write_buffer
	
	mov ah,7
	int 21h
	call bgl_reset
	
%include "bgl.asm"
stringy: db "HELLO THERE!?",0
stringy2: db "PUNCTUATION.",0
stringy3: db "COLONS:EQUAL=",0

font_gfx:
	incbin "bgl/font_33.gfx"
	incbin "bgl/font_34.gfx"
	incbin "bgl/font_35.gfx"
	incbin "bgl/font_36.gfx"
	incbin "bgl/font_37.gfx"
	incbin "bgl/font_38.gfx"
	incbin "bgl/font_39.gfx"
	incbin "bgl/font_40.gfx"
	incbin "bgl/font_41.gfx"
	incbin "bgl/font_42.gfx"
	incbin "bgl/font_43.gfx"
	incbin "bgl/font_44.gfx"
	incbin "bgl/font_45.gfx"
	incbin "bgl/font_46.gfx"
	incbin "bgl/font_47.gfx"
	incbin "bgl/font_0.gfx"
	incbin "bgl/font_1.gfx"
	incbin "bgl/font_2.gfx"
	incbin "bgl/font_3.gfx"
	incbin "bgl/font_4.gfx"
	incbin "bgl/font_5.gfx"
	incbin "bgl/font_6.gfx"
	incbin "bgl/font_7.gfx"
	incbin "bgl/font_8.gfx"
	incbin "bgl/font_9.gfx"
	incbin "bgl/font_58.gfx"
	incbin "bgl/font_59.gfx"
	incbin "bgl/font_60.gfx"
	incbin "bgl/font_61.gfx"
	incbin "bgl/font_62.gfx"
	incbin "bgl/font_63.gfx"
	incbin "bgl/font_64.gfx"
	incbin "bgl/font_a.gfx"
	incbin "bgl/font_b.gfx"
	incbin "bgl/font_c.gfx"
	incbin "bgl/font_d.gfx"
	incbin "bgl/font_e.gfx"
	incbin "bgl/font_f.gfx"
	incbin "bgl/font_g.gfx"
	incbin "bgl/font_h.gfx"
	incbin "bgl/font_i.gfx"
	incbin "bgl/font_j.gfx"
	incbin "bgl/font_k.gfx"
	incbin "bgl/font_l.gfx"
	incbin "bgl/font_m.gfx"
	incbin "bgl/font_n.gfx"
	incbin "bgl/font_o.gfx"
	incbin "bgl/font_p.gfx"
	incbin "bgl/font_q.gfx"
	incbin "bgl/font_r.gfx"
	incbin "bgl/font_s.gfx"
	incbin "bgl/font_t.gfx"
	incbin "bgl/font_u.gfx"
	incbin "bgl/font_v.gfx"
	incbin "bgl/font_w.gfx"
	incbin "bgl/font_x.gfx"
	incbin "bgl/font_y.gfx"
	incbin "bgl/font_z.gfx"