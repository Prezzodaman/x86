
blaster_buffer_size equ blaster_mix_buffer_size
%include "../blaster.asm"
%include "../bgl.asm"
%include "../random.asm"

	org 100h
	
	call bgl_init
	
game:
.loop:
	xor al,al
	call bgl_flood_fill_full
	
	call ship_draw
	call ship_bullet_draw
	
	call ship_handler
	call ship_bullet_handler
	
	call bgl_wait_retrace
	call bgl_write_buffer
	jmp .loop
	
ship_bullet_draw:
	xor bx,bx
.loop:
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	je .loop_end ; if not, do nothing
	mov ax,[ship_bullet_x+bx]
	mov word [bgl_x_pos],ax
	mov ax,[ship_bullet_y+bx]
	mov word [bgl_y_pos],ax
	mov word [bgl_buffer_offset],ship_bullet_gfx
	call bgl_draw_gfx
.loop_end:
	add bx,2
	cmp bx,ship_bullet_amount*2 ; reached last bullet?
	jne .loop ; if not, draw next bullet
	ret
	
ship_bullet_handler:
	xor bx,bx
.loop:
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	je .loop_end ; if not, do nothing
	cmp word [ship_bullet_y+bx],-16 ; bullet reached top of screen?
	jg .top_skip ; if not, continue as normal
	mov byte [ship_bullet_moving+bx],0 ; reset bullet
	jmp .loop_end
.top_skip:
	mov ax,ship_bullet_speed ; move bullet up
	sub word [ship_bullet_y+bx],ax
.loop_end:
	add bx,2
	cmp bx,ship_bullet_amount*2 ; reached last bullet?
	jne .loop ; if not, handle next bullet
	ret
	
ship_handler:
.left:
	cmp byte [bgl_key_states+4bh],0 ; left key pressed?
	je .right ; if not, check for right key
	sub word [ship_x],ship_speed
	cmp word [ship_x],0 ; reached left bounds
	jg .right ; if not, skip
	mov word [ship_x],0 ; clip to left bounds
.right:
	cmp byte [bgl_key_states+4dh],0 ; right key pressed?
	je .shoot ; if not, skip
	add word [ship_x],ship_speed
	cmp word [ship_x],320-ship_width ; reached right bounds?
	jl .shoot ; if not, skip
	mov word [ship_x],320-ship_width ; clip to right bounds
.shoot:
	cmp byte [bgl_key_states+39h],0 ; space pressed?
	je .shoot_shot ; if not, reset ship shot flag
	cmp byte [ship_shot],0 ; has the ship shot a bullet?
	jne .end ; if so, skip
	inc byte [ship_bullet_current]
	cmp byte [ship_bullet_current],ship_bullet_amount ; not shot yet, check that current bullet is in range
	jb .shoot_skip ; if it's in range, continue as normal
	mov byte [ship_bullet_current],0 ; reset current bullet
.shoot_skip:
	movzx bx,[ship_bullet_current]
	shl bx,1
	cmp byte [ship_bullet_moving+bx],0 ; current bullet moving?
	jne .end ; if so, skip
	mov byte [ship_bullet_moving+bx],1 ; bullet isn't moving... make it
	mov byte [ship_shot],1
	mov ax,[ship_x]
	add ax,(ship_width/2)-1
	mov word [ship_bullet_x+bx],ax
	mov ax,[ship_y]
	mov word [ship_bullet_y+bx],ax
	jmp .end
.shoot_shot: ; best l'bale name
	mov byte [ship_shot],0
.end:
	ret
	
ship_draw:
	mov word [bgl_buffer_offset],ship_gfx
	mov ax,[ship_x]
	mov word [bgl_x_pos],ax
	mov ax,[ship_y]
	mov word [bgl_y_pos],ax
	call bgl_draw_gfx_fast
	ret
	
ship_gfx: incbin "ship.gfx"
ship_width equ 30
ship_height equ 29
ship_speed equ 3

ship_x dw (320/2)-(ship_width/2)
ship_y dw 200-ship_height-16
ship_shot db 0

ship_bullet_gfx: incbin "ship_bullet.gfx"
ship_bullet_amount equ 6 ; how many on-screen at a given time
ship_bullet_speed equ 5

ship_bullet_x times ship_bullet_amount dw 0
ship_bullet_y times ship_bullet_amount dw 0
ship_bullet_moving times ship_bullet_amount dw 0
ship_bullet_current db 0