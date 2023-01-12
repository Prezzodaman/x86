org 100h

pixel_move db 0101b ; up, down, left, right
pixel_x dw 0
pixel_y dw 0
pixel_colour dw 1
pixel_speed dw 1
pixel_size dw 8

main:
    ; set graphics mode

    mov al,13h ; graphics mode: 13h (256 colour vga)
    mov ah,0 ; function number
    int 10h
    
    ; do the stuff
    
loop:
    
	call pixel_draw
	
    mov ecx,12000
.delay:
    nop
    loop .delay
    
    mov bx,[pixel_colour]
	mov word [pixel_colour],0
	call pixel_draw
	mov word [pixel_colour],bx
	
    call pixel_movement
    
    jmp loop
    
	;mov ah,0x4c
	;int 21h

pixel_movement:
    mov cx,[pixel_speed]
    mov dx,[pixel_move]
    test dx,1000b ; moving up?
    jz .down_skip ; if not, skip
    sub word [pixel_y],cx ; otherwise, move it up
.down_skip:
    test dx,0100b ; moving down?
    jz .left_skip ; if not, skip
    add word [pixel_y],cx ; otherwise, move it down
.left_skip:
    test dx,0010b ; moving left?
    jz .right_skip ; if not, skip
    sub word [pixel_x],cx ; otherwise, move it left 
.right_skip:
    test dx,0001b ; moving right?
    jz .end_skip ; if not, skip
    add word [pixel_x],cx ; otherwise, move it right
.end_skip:
    
pixel_hit_check:
    mov dx,[pixel_x]
    mov cx,320
    sub cx,[pixel_speed]
	sub cx,[pixel_size]
    cmp dx,cx
    jb .left_skip ; if not, skip
    xor byte [pixel_move],0011b ; if so, stop moving right
    call pixel_colour_change
.left_skip:
    mov cx,[pixel_speed]
    cmp dx,cx
    jae .top_skip ; if not, skip
    xor byte [pixel_move],0011b ; if so, stop moving left
    call pixel_colour_change
.top_skip:
    mov dx,[pixel_y]
    cmp dx,cx
    jae .bottom_skip ; if not, skip
    xor byte [pixel_move],1100b ; if so, stop moving up
    call pixel_colour_change
.bottom_skip:
    mov cx,200
    sub cx,[pixel_speed]
	sub cx,[pixel_size]
    cmp dx,cx
    jb .end_skip ; if not, skip
    xor byte [pixel_move],1100b ; if so, stop moving down
    call pixel_colour_change
.end_skip:
    ret

pixel_colour_change:
    inc byte [pixel_colour]
    mov dx,[pixel_colour]
    cmp dx,15
    jb .skip
    mov word [pixel_colour],1
.skip:
    ret
    
pixel_draw:
    mov cx,[pixel_x] ; x
    mov dx,[pixel_y] ; y
.horiz_loop:
    mov al,[pixel_colour]
    mov ah,0ch ; function number
	int 10h
	inc cx
	
	mov ax,cx ; copy modified pixel x to ax
	sub ax,[pixel_x] ; difference between modified pixel x and original pixel x
	cmp ax,[pixel_size] ; have we reached the end of the line yet? (well it's aaaaaaalright)
	jng .horiz_loop ; if not, keep bustin.
	
	inc dx ; otherwise, we've reached the end of the line, increase y and reset x
	mov cx,[pixel_x]
	
	mov ax,dx
	sub ax,[pixel_y] ; difference between modified/original again...
	cmp ax,[pixel_size] ; are we there yet?
	jng .horiz_loop ; if not, keep drawing horizontally
	
	ret