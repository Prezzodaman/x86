
blaster_buffer_size equ blaster_mix_buffer_size
%include "../blaster.asm"
%include "../beeplib.asm"
%include "../bgl.asm"
%include "../random.asm"

	org 100h
	
	call blaster_init
	blaster_set_sample_rate 11025
	call bgl_init
	mov word [bgl_font_offset],font_gfx
	mov word [bgl_font_size],8
	mov word [bgl_font_spacing],8
	call stars_init
	
	jmp title_screen
	;jmp game

%include "title.asm"
%include "game.asm"
%include "stars.asm"

font_gfx:
	incbin "../bgl/c64_33.gfx"
	incbin "../bgl/c64_34.gfx"
	incbin "../bgl/c64_35.gfx"
	incbin "../bgl/c64_36.gfx"
	incbin "../bgl/c64_37.gfx"
	incbin "../bgl/c64_38.gfx"
	incbin "../bgl/c64_39.gfx"
	incbin "../bgl/c64_40.gfx"
	incbin "../bgl/c64_41.gfx"
	incbin "../bgl/c64_42.gfx"
	incbin "../bgl/c64_43.gfx"
	incbin "../bgl/c64_44.gfx"
	incbin "../bgl/c64_45.gfx"
	incbin "../bgl/c64_46.gfx"
	incbin "../bgl/c64_47.gfx"
	incbin "../bgl/c64_0.gfx"
	incbin "../bgl/c64_1.gfx"
	incbin "../bgl/c64_2.gfx"
	incbin "../bgl/c64_3.gfx"
	incbin "../bgl/c64_4.gfx"
	incbin "../bgl/c64_5.gfx"
	incbin "../bgl/c64_6.gfx"
	incbin "../bgl/c64_7.gfx"
	incbin "../bgl/c64_8.gfx"
	incbin "../bgl/c64_9.gfx"
	incbin "../bgl/c64_58.gfx"
	incbin "../bgl/c64_59.gfx"
	incbin "../bgl/c64_60.gfx"
	incbin "../bgl/c64_61.gfx"
	incbin "../bgl/c64_62.gfx"
	incbin "../bgl/c64_63.gfx"
	incbin "../bgl/c64_64.gfx"
	incbin "../bgl/c64_a.gfx"
	incbin "../bgl/c64_b.gfx"
	incbin "../bgl/c64_c.gfx"
	incbin "../bgl/c64_d.gfx"
	incbin "../bgl/c64_e.gfx"
	incbin "../bgl/c64_f.gfx"
	incbin "../bgl/c64_g.gfx"
	incbin "../bgl/c64_h.gfx"
	incbin "../bgl/c64_i.gfx"
	incbin "../bgl/c64_j.gfx"
	incbin "../bgl/c64_k.gfx"
	incbin "../bgl/c64_l.gfx"
	incbin "../bgl/c64_m.gfx"
	incbin "../bgl/c64_n.gfx"
	incbin "../bgl/c64_o.gfx"
	incbin "../bgl/c64_p.gfx"
	incbin "../bgl/c64_q.gfx"
	incbin "../bgl/c64_r.gfx"
	incbin "../bgl/c64_s.gfx"
	incbin "../bgl/c64_t.gfx"
	incbin "../bgl/c64_u.gfx"
	incbin "../bgl/c64_v.gfx"
	incbin "../bgl/c64_w.gfx"
	incbin "../bgl/c64_x.gfx"
	incbin "../bgl/c64_y.gfx"
	incbin "../bgl/c64_z.gfx"