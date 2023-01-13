org 100h

pixel_amount equ 6
pixel_move times pixel_amount dw 0101b ; up, down, left, right
pixel_x times pixel_amount dw 0
pixel_y times pixel_amount dw 0
pixel_colour times pixel_amount dw 1
pixel_speed times pixel_amount dw 1
pixel_size times pixel_amount dw 6
pixel_colour_current dw 0
yes db 0

main:
    ; set graphics mode

    mov al,13h ; graphics mode: 13h (256 colour vga)
    mov ah,0 ; function number
    int 10h
	
	mov word [pixel_colour+2],2
	mov word [pixel_colour+4],6
	mov word [pixel_colour+6],4
	mov word [pixel_colour+8],5
	mov word [pixel_colour+10],9

	mov si,2
	
	mov ax,[pixel_x+si]
	add ax,34
	mov word [pixel_x+si],ax
	mov ax,[pixel_y+si]
	add ax,20
	mov word [pixel_y+si],ax
	
	add si,2
	mov ax,[pixel_x+si]
	add ax,90
	mov word [pixel_x+si],ax
	mov ax,[pixel_y+si]
	add ax,70
	mov word [pixel_y+si],ax
	
	add si,2
	mov ax,[pixel_x+si]
	add ax,140
	mov word [pixel_x+si],ax
	mov ax,[pixel_y+si]
	add ax,6
	mov word [pixel_y+si],ax
	
	add si,2
	mov ax,[pixel_x+si]
	add ax,250
	mov word [pixel_x+si],ax
	mov ax,[pixel_y+si]
	add ax,140
	mov word [pixel_y+si],ax
	
	add si,2
	mov ax,[pixel_x+si]
	add ax,80
	mov word [pixel_x+si],ax
	mov ax,[pixel_y+si]
	add ax,50
	mov word [pixel_y+si],ax
    
loop:
	mov si,0 ; reset index of current pixel
    
.pixel:
	mov ax,[pixel_colour+si]
	mov word [pixel_colour_current],ax
	call pixel_draw
    
	add si,2 ; next pixel
	mov ax,pixel_amount
	add ax,ax ; cheeky way of multiplying by 2
	cmp si,ax ; are we on the last pixel index?
    jne .pixel ; if not, draw the next pixel!
	
	mov si,0 ; finished drawing, so reset index of current pixel
	mov word [pixel_colour_current],0
	
	; delay...
    mov ecx,12000
.delay:
    nop
    loop .delay
	
.pixel_remove:
	call pixel_draw
    call pixel_movement
    
	add si,2
	mov ax,pixel_amount
	add ax,ax
	cmp si,ax
    jne .pixel_remove ; we haven't reached the last pixel yet!
    
	;mov ah,0x4c
	;int 21h
	jmp loop

pixel_movement:
    mov cx,[pixel_speed+si]
    mov dx,[pixel_move+si]
    test dx,1000b ; moving up?
    jz .down_skip ; if not, skip
    sub word [pixel_y+si],cx ; otherwise, move it up
.down_skip:
    test dx,0100b ; moving down?
    jz .left_skip ; if not, skip
    add word [pixel_y+si],cx ; otherwise, move it down
.left_skip:
    test dx,0010b ; moving left?
    jz .right_skip ; if not, skip
    sub word [pixel_x+si],cx ; otherwise, move it left 
.right_skip:
    test dx,0001b ; moving right?
    jz .end_skip ; if not, skip
    add word [pixel_x+si],cx ; otherwise, move it right
.end_skip:
    
pixel_hit_check:
    mov dx,[pixel_x+si]
    mov cx,320
    sub cx,[pixel_speed+si]
	sub cx,[pixel_size+si]
    cmp dx,cx
    jb .left_skip ; if not, skip
    xor byte [pixel_move+si],0011b ; if so, stop moving right
    call pixel_colour_change
.left_skip:
    mov cx,[pixel_speed+si]
    cmp dx,cx
    jae .top_skip ; if not, skip
    xor byte [pixel_move+si],0011b ; if so, stop moving left
    call pixel_colour_change
.top_skip:
    mov dx,[pixel_y+si]
    cmp dx,cx
    jae .bottom_skip ; if not, skip
    xor byte [pixel_move+si],1100b ; if so, stop moving up
    call pixel_colour_change
.bottom_skip:
    mov cx,200
    sub cx,[pixel_speed+si]
	sub cx,[pixel_size+si]
    cmp dx,cx
    jb .end_skip ; if not, skip
    xor byte [pixel_move+si],1100b ; if so, stop moving down
    call pixel_colour_change
.end_skip:
    ret

pixel_colour_change:
    inc byte [pixel_colour+si]
    mov dx,[pixel_colour+si]
    cmp dx,15
    jb .skip
    mov word [pixel_colour+si],1
.skip:
    ret
    
pixel_draw:
    mov cx,[pixel_x+si] ; x
    mov dx,[pixel_y+si] ; y
.horiz_loop:
	mov al,[pixel_colour_current]
    mov ah,0ch ; function number
	int 10h
	inc cx
	
	mov ax,cx ; copy modified pixel x to ax
	sub ax,[pixel_x+si] ; difference between modified pixel x and original pixel x
	cmp ax,[pixel_size+si] ; have we reached the end of the line yet? (well it's aaaaaaalright)
	jng .horiz_loop ; if not, keep bustin.
	
	inc dx ; otherwise, we've reached the end of the line, increase y and reset x
	mov cx,[pixel_x+si]
	
	mov ax,dx
	sub ax,[pixel_y+si] ; difference between modified/original again...
	cmp ax,[pixel_size+si] ; are we there yet?
	jng .horiz_loop ; if not, keep drawing horizontally
	
	ret