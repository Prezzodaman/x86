
	org 100h
	
	call bgl_init
	
	;jmp intro
	jmp game
	
end_of:
	call bgl_reset
	
	mov dx,end_string
	mov ah,9
	int 21h
	
	mov ah,4ch
	int 21h

;%include "intro.asm"
%include "game.asm"
%include "../bgl.asm"
%include "../beeplib.asm"

end_string: 
	db "Thank you for playing!",13,10,13,10
	db "This game is open-source, and was developed using self-made libraries.",13,10
	db "Check it out at:",13,10
	db "https://github.com/Prezzodaman/x86",13,10,13,10
	db "Do what you like with it! (if you understand x86 assembly)",13,10
	db "...but will your ideas be as abstract as mine happen to be?",13,10,13,10
	db "$"