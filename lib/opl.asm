
%define opl

	call opl_reset ; auto-init ;)
	jmp opl_end

opl_reset:
	push bx
	xor bx,bx
.loop:
	call opl_write
	inc bl
	cmp bl,0f6h
	jne .loop
	pop bx
	ret
	
opl_write: ; bl = register, bh = value
	push ax
	push cx
	push dx

	mov dx,388h
	mov al,bl
	out dx,al
	
	mov dx,389h ; wait
	mov cx,6
.wait:
	in al,dx
	loop .wait
	
	mov al,bh
	out dx,al
	
	mov cx,35
.wait_2:
	in al,dx
	loop .wait_2
	
	pop dx
	pop cx
	pop ax
	ret
	
opl_note_on: ; al = channel, bl = note
	push ax
	push bx
	push dx
	
	xor bh,bh
	cmp bx,opl_midi_table_length/3
	ja .end
	
	push bx ;;
	xor bh,bh
	shl bx,1
	mov dx,[opl_midi_table+bx] ; get frequency based on this note
	pop bx ;;
	
	mov bl,0a0h ; register: write low value
	add bl,al ; + channel number
	mov bh,dl ; value: note frequency (low)
	call opl_write
	
	mov bl,0b0h ; register: write high value
	add bl,al ; + channel number
	mov bh,34h
	or bh,dh ; + note frequency (high)
	call opl_write
	
.end:
	pop dx
	pop bx
	pop ax
	ret
	
opl_note_off: ; al = channel
	push bx
	mov bl,0b0h
	add bl,al
	mov bh,0
	call opl_write
	pop bx
	ret
	
opl_all_notes_off:
	push ax
	xor al,al
.loop:
	call opl_note_off
	inc al
	cmp al,9
	jne .loop
	pop ax
	ret
	
opl_setup_instrument: ; al = channel, si = instrument
	push bx
	push cx
	
	xor bx,bx
	mov cl,al
.loop:
	mov al,[opl_instrument_registers+bx] ; register
	add al,cl ; + channel
	mov ah,[si+bx] ; value
	push bx ;
	mov bx,ax
	call opl_write
	pop bx ;
	inc bx
	cmp bx,opl_instrument_registers_len
	jne .loop
	
	pop cx
	pop bx
	ret
	
opl_percussion_mode:
	push bx
	mov	bl,63h
	mov	bh,0f0h
	call opl_write
	pop bx
	ret
	
opl_instrument_registers db 20h,40h,60h,80h,0e0h,0c0h,23h,43h,63h,83h,0e3h
opl_instrument_registers_len equ $-opl_instrument_registers

opl_instrument_piano db 033h,05ah,0b2h,050h,000h,000h,031h,000h,0b1h,0f5h,000h
opl_instrument_honktonk db 034h,09bh,0f3h,063h,001h,001h,011h,000h,092h,0f5h,001h
opl_instrument_ep1 db 027h,028h,0f8h,0b7h,001h,002h,091h,000h,0f1h,0f9h,000h
opl_instrument_ep2 db 01ah,02dh,0f3h,0eeh,001h,001h,011h,000h,0f1h,0f5h,000h
opl_instrument_harpsic db 035h,095h,0f2h,058h,00fh,001h,032h,002h,081h,0f6h,001h
opl_instrument_clavic db 031h,085h,0c9h,040h,001h,000h,035h,000h,0c2h,0b9h,001h
opl_instrument_celesta db 009h,015h,0c7h,064h,008h,000h,001h,005h,0b2h,035h,000h
opl_instrument_glock db 006h,003h,0f4h,044h,000h,001h,001h,01bh,0f2h,034h,000h
opl_instrument_musicbox db 004h,006h,0a9h,024h,00ah,001h,001h,001h,0f5h,074h,000h
opl_instrument_vibes db 0d4h,000h,0f6h,033h,000h,000h,0f1h,000h,061h,0e3h,000h
opl_instrument_marimba db 0d4h,000h,0f7h,0e8h,004h,000h,0d1h,000h,0a4h,064h,000h
opl_instrument_xylo db 036h,016h,0f7h,0f7h,001h,000h,031h,007h,0b5h,0f5h,000h
opl_instrument_tubebell db 003h,01bh,0a2h,043h,00bh,000h,000h,000h,0f3h,074h,000h
opl_instrument_santur db 0c3h,08eh,0f8h,035h,001h,001h,011h,000h,0c3h,094h,001h
opl_instrument_organ1 db 0e2h,007h,0f4h,01bh,006h,001h,0e0h,000h,0f4h,00dh,001h
opl_instrument_organ2 db 0f2h,000h,0f6h,02ch,004h,000h,0f0h,000h,0f5h,00bh,001h
opl_instrument_organ3 db 0f1h,006h,0b6h,015h,00ah,000h,0f0h,000h,0bfh,007h,000h
opl_instrument_pipeorg db 022h,003h,079h,016h,008h,001h,0e0h,000h,06dh,008h,001h
opl_instrument_reedorg db 031h,027h,063h,006h,001h,000h,072h,000h,051h,017h,001h
opl_instrument_acordian db 0b4h,01dh,053h,016h,00fh,001h,071h,000h,051h,017h,001h
opl_instrument_harmonic db 025h,029h,097h,015h,001h,000h,032h,000h,053h,008h,001h
opl_instrument_bandneon db 024h,09eh,067h,015h,00fh,000h,031h,000h,053h,006h,001h
opl_instrument_nylongt db 013h,027h,0a3h,0b4h,005h,001h,031h,000h,0d2h,0f8h,000h
opl_instrument_steelgt db 017h,0a3h,0f3h,032h,001h,000h,011h,000h,0e2h,0c7h,001h
opl_instrument_jazzgt db 033h,024h,0d2h,0c1h,00fh,001h,031h,000h,0f1h,09ch,000h
opl_instrument_cleangt db 031h,005h,0f8h,044h,001h,000h,032h,002h,0f2h,0c9h,001h
opl_instrument_mutegt db 021h,009h,09ch,07bh,007h,000h,002h,003h,095h,0fbh,000h
opl_instrument_overdgt db 021h,084h,081h,098h,007h,001h,021h,004h,0a1h,059h,000h
opl_instrument_distgt db 0b1h,00ch,078h,043h,001h,000h,022h,003h,091h,0fch,003h
opl_instrument_gtharms db 000h,00ah,082h,08ch,009h,000h,008h,002h,0b4h,0ech,000h
opl_instrument_acoubass db 021h,013h,0abh,046h,001h,000h,021h,000h,093h,0f7h,000h
opl_instrument_fingbass db 001h,00ah,0f9h,032h,001h,000h,022h,004h,0c1h,058h,000h
opl_instrument_pickbass db 021h,007h,0fah,077h,00bh,000h,022h,002h,0c3h,06ah,000h
opl_instrument_fretless db 021h,017h,071h,057h,00bh,000h,021h,000h,062h,087h,000h
opl_instrument_slapbas1 db 025h,001h,0fah,078h,007h,001h,012h,000h,0f3h,097h,000h
opl_instrument_slapbas2 db 021h,003h,0fah,088h,00dh,000h,013h,000h,0b3h,097h,000h
opl_instrument_synbass1 db 021h,009h,0f5h,07fh,009h,001h,023h,004h,0f3h,0cch,000h
opl_instrument_synbass2 db 001h,010h,0a3h,09bh,009h,000h,001h,000h,093h,0aah,000h
opl_instrument_violin db 0e2h,019h,0f6h,029h,00dh,001h,0e1h,000h,078h,008h,001h
opl_instrument_viola db 0e2h,01ch,0f6h,029h,00dh,001h,0e1h,000h,078h,008h,001h
opl_instrument_cello db 061h,019h,069h,016h,00bh,001h,061h,000h,054h,027h,001h
opl_instrument_contrab db 071h,018h,082h,031h,00dh,001h,032h,000h,061h,056h,000h
opl_instrument_tremstr db 0e2h,023h,070h,006h,00dh,001h,0e1h,000h,075h,016h,001h
opl_instrument_pizz db 002h,000h,088h,0e6h,008h,000h,061h,000h,0f5h,0f6h,001h
opl_instrument_harp db 012h,020h,0f6h,0d5h,00fh,001h,011h,080h,0f3h,0e3h,000h
opl_instrument_timpani db 061h,00eh,0f4h,0f4h,001h,001h,000h,000h,0b5h,0f5h,000h
opl_instrument_strings db 061h,01eh,09ch,004h,00fh,001h,021h,080h,071h,016h,000h
opl_instrument_slowstr db 0a2h,02ah,0c0h,0d6h,00fh,002h,021h,000h,030h,055h,001h
opl_instrument_synstr1 db 061h,021h,072h,035h,00fh,001h,061h,000h,062h,036h,001h
opl_instrument_synstr2 db 021h,01ah,072h,023h,00fh,001h,021h,002h,051h,007h,000h
opl_instrument_choir db 0e1h,016h,097h,031h,009h,000h,061h,000h,062h,039h,000h
opl_instrument_oohs db 022h,0c3h,079h,045h,001h,000h,021h,000h,066h,027h,000h
opl_instrument_synvox db 021h,0deh,063h,055h,001h,001h,021h,000h,073h,046h,000h
opl_instrument_orchit db 042h,005h,086h,0f7h,00ah,000h,050h,000h,074h,076h,001h
opl_instrument_trumpet db 031h,01ch,061h,002h,00fh,000h,061h,081h,092h,038h,000h
opl_instrument_trombone db 071h,01eh,052h,023h,00fh,000h,061h,002h,071h,019h,000h
opl_instrument_tuba db 021h,01ah,076h,016h,00fh,000h,021h,001h,081h,009h,000h
opl_instrument_mutetrp db 025h,028h,089h,02ch,007h,002h,020h,000h,083h,04bh,002h
opl_instrument_frhorn db 021h,01fh,079h,016h,009h,000h,0a2h,005h,071h,059h,000h
opl_instrument_brass1 db 021h,019h,087h,016h,00fh,000h,021h,003h,082h,039h,000h
opl_instrument_synbras1 db 021h,017h,075h,035h,00fh,000h,022h,082h,084h,017h,000h
opl_instrument_synbras2 db 021h,022h,062h,058h,00fh,000h,021h,002h,072h,016h,000h
opl_instrument_sopsax db 0b1h,01bh,059h,007h,001h,001h,0a1h,000h,07bh,00ah,000h
opl_instrument_altosax db 021h,016h,09fh,004h,00bh,000h,021h,000h,085h,00ch,001h
opl_instrument_tensax db 021h,00fh,0a8h,020h,00dh,000h,023h,000h,07bh,00ah,001h
opl_instrument_barisax db 021h,00fh,088h,004h,009h,000h,026h,000h,079h,018h,001h
opl_instrument_oboe db 031h,018h,08fh,005h,001h,000h,032h,001h,073h,008h,000h
opl_instrument_englhorn db 0a1h,00ah,08ch,037h,001h,001h,024h,004h,077h,00ah,000h
opl_instrument_bassoon db 031h,004h,0a8h,067h,00bh,000h,075h,000h,051h,019h,000h
opl_instrument_clarinet db 0a2h,01fh,077h,026h,001h,001h,021h,001h,074h,009h,000h
opl_instrument_piccolo db 0e1h,007h,0b8h,094h,001h,001h,021h,001h,063h,028h,000h
opl_instrument_flute1 db 0a1h,093h,087h,059h,001h,000h,0e1h,000h,065h,00ah,000h
opl_instrument_recorder db 022h,010h,09fh,038h,001h,000h,061h,000h,067h,029h,000h
opl_instrument_panflute db 0e2h,00dh,088h,09ah,001h,001h,021h,000h,067h,009h,000h
opl_instrument_bottleb db 0a2h,010h,098h,094h,00fh,000h,021h,001h,06ah,028h,000h
opl_instrument_shaku db 0f1h,01ch,086h,026h,00fh,000h,0f1h,000h,055h,027h,000h
opl_instrument_whistle db 0e1h,03fh,09fh,009h,000h,000h,0e1h,000h,06fh,008h,000h
opl_instrument_ocarina db 0e2h,03bh,0f7h,019h,001h,000h,021h,000h,07ah,007h,000h
opl_instrument_squarwav db 022h,01eh,092h,00ch,00fh,000h,061h,006h,0a2h,00dh,000h
opl_instrument_sawwav db 021h,015h,0f4h,022h,00fh,001h,021h,000h,0a3h,05fh,000h
opl_instrument_syncalli db 0f2h,020h,047h,066h,003h,001h,0f1h,000h,042h,027h,000h
opl_instrument_chiflead db 061h,019h,088h,028h,00fh,000h,061h,005h,0b2h,049h,000h
opl_instrument_charang db 021h,016h,082h,01bh,001h,000h,023h,000h,0b2h,079h,001h
opl_instrument_solovox db 021h,000h,0cah,093h,001h,000h,022h,000h,07ah,01ah,000h
opl_instrument_fifthsaw db 023h,000h,092h,0c9h,008h,001h,022h,000h,082h,028h,001h
opl_instrument_basslead db 021h,01dh,0f3h,07bh,00fh,000h,022h,002h,0c3h,05fh,000h
opl_instrument_fantasia db 0e1h,000h,081h,025h,000h,001h,0a6h,086h,0c4h,095h,001h
opl_instrument_warmpad db 021h,027h,031h,001h,00fh,000h,021h,000h,044h,015h,000h
opl_instrument_polysyn db 060h,014h,083h,035h,00dh,002h,061h,000h,0d1h,006h,000h
opl_instrument_spacevox db 0e1h,05ch,0d3h,001h,001h,001h,062h,000h,082h,037h,000h
opl_instrument_bowedgls db 028h,038h,034h,086h,001h,002h,021h,000h,041h,035h,000h
opl_instrument_metalpad db 024h,012h,052h,0f3h,005h,001h,023h,002h,032h,0f5h,001h
opl_instrument_halopad db 061h,01dh,062h,0a6h,00bh,000h,0a1h,000h,061h,026h,000h
opl_instrument_sweeppad db 022h,00fh,022h,0d5h,00bh,001h,021h,084h,03fh,005h,001h
opl_instrument_icerain db 0e3h,01fh,0f9h,024h,001h,000h,031h,001h,0d1h,0f6h,000h
opl_instrument_soundtrk db 063h,000h,041h,055h,006h,001h,0a2h,000h,041h,005h,001h
opl_instrument_crystal db 0c7h,025h,0a7h,065h,001h,001h,0c1h,005h,0f3h,0e4h,000h
opl_instrument_atmosph db 0e3h,019h,0f7h,0b7h,001h,001h,061h,000h,092h,0f5h,001h
opl_instrument_bright db 066h,09bh,0a8h,044h,00fh,000h,041h,004h,0f2h,0e4h,001h
opl_instrument_goblin db 061h,020h,022h,075h,00dh,000h,061h,000h,045h,025h,000h
opl_instrument_echodrop db 0e1h,021h,0f6h,084h,00fh,000h,0e1h,001h,0a3h,036h,000h
opl_instrument_starthem db 0e2h,014h,073h,064h,00bh,001h,0e1h,001h,098h,005h,001h
opl_instrument_sitar db 021h,00bh,072h,034h,009h,000h,024h,002h,0a3h,0f6h,001h
opl_instrument_banjo db 021h,016h,0f4h,053h,00dh,000h,004h,000h,0f6h,0f8h,000h
opl_instrument_shamisen db 021h,018h,0dah,002h,00dh,000h,035h,000h,0f3h,0f5h,000h
opl_instrument_koto db 025h,00fh,0fah,063h,009h,000h,002h,000h,094h,0e5h,001h
opl_instrument_kalimba db 032h,007h,0f9h,096h,001h,000h,011h,000h,084h,044h,000h
opl_instrument_bagpipe db 020h,00eh,097h,018h,009h,002h,025h,003h,083h,018h,001h
opl_instrument_fiddle db 061h,018h,0f6h,029h,001h,000h,062h,001h,078h,008h,001h
opl_instrument_shannai db 0e6h,021h,076h,019h,00bh,000h,061h,003h,08eh,008h,001h
opl_instrument_tinklbel db 027h,023h,0f0h,0d4h,001h,000h,005h,009h,0f2h,046h,000h
opl_instrument_agogo db 01ch,00ch,0f9h,031h,00fh,001h,015h,000h,096h,0e8h,001h
opl_instrument_steeldrm db 002h,000h,075h,016h,006h,002h,001h,000h,0f6h,0f6h,001h
opl_instrument_woodblok db 025h,01bh,0fah,0f2h,001h,000h,012h,000h,0f6h,09ah,000h
opl_instrument_taiko db 002h,01dh,0f5h,093h,001h,000h,000h,000h,0c6h,045h,000h
opl_instrument_melotom db 011h,015h,0f5h,032h,005h,000h,010h,000h,0f4h,0b4h,000h
opl_instrument_syndrum db 022h,006h,0fah,099h,009h,000h,001h,000h,0d5h,025h,000h
opl_instrument_revrscym db 02eh,000h,0ffh,000h,00fh,002h,00eh,00eh,021h,02dh,000h
opl_instrument_fretnois db 030h,00bh,056h,0e4h,001h,001h,017h,000h,055h,087h,002h
opl_instrument_brthnois db 024h,000h,0ffh,003h,00dh,000h,005h,008h,098h,087h,001h
opl_instrument_seashore db 00eh,000h,0f0h,000h,00fh,002h,00ah,004h,017h,004h,003h
opl_instrument_birds db 020h,008h,0f6h,0f7h,001h,000h,00eh,005h,077h,0f9h,002h
opl_instrument_telephon db 020h,014h,0f1h,008h,001h,000h,02eh,002h,0f4h,008h,000h
opl_instrument_helicopt db 020h,004h,0f2h,000h,003h,001h,023h,000h,036h,005h,001h
opl_instrument_applause db 02eh,000h,0ffh,002h,00fh,000h,02ah,005h,032h,055h,003h

opl_midi_table:
	db 005h, 000h, 005h, 000h, 006h, 000h, 006h, 000h, 006h, 000h, 007h, 000h, 007h, 000h, 008h, 000h
	db 008h, 000h, 009h, 000h, 009h, 000h, 00ah, 000h, 00ah, 000h, 00bh, 000h, 00ch, 000h, 00ch, 000h
	db 00dh, 000h, 00eh, 000h, 00fh, 000h, 010h, 000h, 011h, 000h, 012h, 000h, 013h, 000h, 014h, 000h
	db 015h, 000h, 016h, 000h, 018h, 000h, 019h, 000h, 01bh, 000h, 01ch, 000h, 01eh, 000h, 020h, 000h
	db 022h, 000h, 024h, 000h, 026h, 000h, 028h, 000h, 02bh, 000h, 02dh, 000h, 030h, 000h, 033h, 000h
	db 036h, 000h, 039h, 000h, 03ch, 000h, 040h, 000h, 044h, 000h, 048h, 000h, 04ch, 000h, 051h, 000h
	db 056h, 000h, 05bh, 000h, 060h, 000h, 066h, 000h, 06ch, 000h, 073h, 000h, 079h, 000h, 081h, 000h
	db 088h, 000h, 091h, 000h, 099h, 000h, 0a2h, 000h, 0ach, 000h, 0b6h, 000h, 0c1h, 000h, 0cdh, 000h
	db 0d9h, 000h, 0e6h, 000h, 0f3h, 000h, 002h, 001h, 011h, 001h, 022h, 001h, 033h, 001h, 045h, 001h
	db 058h, 001h, 06dh, 001h, 083h, 001h, 09ah, 001h, 0b2h, 001h, 0cch, 001h, 0e7h, 001h, 004h, 002h
	db 023h, 002h, 044h, 002h, 066h, 002h, 08bh, 002h, 0b1h, 002h, 0dah, 002h, 006h, 003h, 034h, 003h
	db 065h, 003h, 098h, 003h, 0cfh, 003h, 009h, 004h, 046h, 004h, 088h, 004h, 0cdh, 004h, 016h, 005h
	db 063h, 005h, 0b5h, 005h, 00ch, 006h, 068h, 006h, 0cah, 006h, 031h, 007h, 09eh, 007h, 012h, 008h
	db 08dh, 008h, 010h, 009h, 09ah, 009h, 02ch, 00ah, 0c7h, 00ah, 06bh, 00bh, 018h, 00ch, 0d1h, 00ch
	db 094h, 00dh, 062h, 00eh, 03dh, 00fh, 025h, 010h, 01bh, 011h, 020h, 012h, 034h, 013h, 058h, 014h
	db 08eh, 015h, 0d6h, 016h, 031h, 018h, 0a2h, 019h, 028h, 01bh, 0c5h, 01ch, 07bh, 01eh, 04bh, 020h
opl_midi_table_length equ $-opl_midi_table

opl_end: