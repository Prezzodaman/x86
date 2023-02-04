intro:
	mov si,intro_song
	mov cx,beep_11025
	mov dx,[intro_song_length]

	call beep_play_pcm_sample
	call beep_play_pcm_sample
	call beep_play_pcm_sample
	call beep_play_pcm_sample
	call beep_play_pcm_sample
	call beep_play_pcm_sample
	
	jmp game
	
intro_song: incbin "fatoby.raw"
intro_song_length: dw $-intro_song

logo_1_gfx: incbin "logo_1.rle"
logo_2_gfx: incbin "logo_2.rle"