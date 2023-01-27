
	org 100h
	
	call bgl_init
	
	mov word [bgl_x_pos],0
	mov word [bgl_y_pos],0
	mov ax,stringy
	mov word [bgl_font_string_offset],ax
	mov ax,font_gfx
	mov word [bgl_font_offset],ax
	mov byte [bgl_font_size],24
	mov byte [bgl_font_spacing],21
	call bgl_draw_font_string
	
	add word [bgl_y_pos],28
	mov ax,stringy2
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	add word [bgl_y_pos],28
	mov ax,stringy3
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	add word [bgl_y_pos],28
	mov ax,stringy4
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	add word [bgl_y_pos],28
	mov ax,stringy5
	mov word [bgl_font_string_offset],ax
	call bgl_draw_font_string
	
	call bgl_write_buffer
	
	mov ah,7
	int 21h
	
	call bgl_reset
	
%include "bgl.asm"
stringy: db "HELLO THERE",0
stringy2: db "0123456789",0
stringy3: db "YOU CAN USE ANY",0
stringy4: db "FONT",0
stringy5: db "THAT YOU WONT",0

font_gfx:
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