c_0 equ 12
c_sharp_0 equ 13
d_0 equ 14
d_sharp_0 equ 15
e_0 equ 16
f_0 equ 17
f_sharp_0 equ 18
g_0 equ 19
g_sharp_0 equ 20
a_0 equ 21
a_sharp_0 equ 22
b_0 equ 23
c_1 equ 24
c_sharp_1 equ 25
d_1 equ 26
d_sharp_1 equ 27
e_1 equ 28
f_1 equ 29
f_sharp_1 equ 30
g_1 equ 31
g_sharp_1 equ 32
a_1 equ 33
a_sharp_1 equ 34
b_1 equ 35
c_2 equ 36
c_sharp_2 equ 37
d_2 equ 38
d_sharp_2 equ 39
e_2 equ 40
f_2 equ 41
f_sharp_2 equ 42
g_2 equ 43
g_sharp_2 equ 44
a_2 equ 45
a_sharp_2 equ 46
b_2 equ 47
c_3 equ 48
c_sharp_3 equ 49
d_3 equ 50
d_sharp_3 equ 51
e_3 equ 52
f_3 equ 53
f_sharp_3 equ 54
g_3 equ 55
g_sharp_3 equ 56
a_3 equ 57
a_sharp_3 equ 58
b_3 equ 59
c_4 equ 60
c_sharp_4 equ 61
d_4 equ 62
d_sharp_4 equ 63
e_4 equ 64
f_4 equ 65
f_sharp_4 equ 66
g_4 equ 67
g_sharp_4 equ 68
a_4 equ 69
a_sharp_4 equ 70
b_4 equ 71
c_5 equ 72
c_sharp_5 equ 73
d_5 equ 74
d_sharp_5 equ 75
e_5 equ 76
f_5 equ 77
f_sharp_5 equ 78
g_5 equ 79
g_sharp_5 equ 80
a_5 equ 81
a_sharp_5 equ 82
b_5 equ 83
c_6 equ 84
c_sharp_6 equ 85
d_6 equ 86
d_sharp_6 equ 87
e_6 equ 88
f_6 equ 89
f_sharp_6 equ 90
g_6 equ 91
g_sharp_6 equ 92
a_6 equ 93
a_sharp_6 equ 94
b_6 equ 95
c_7 equ 96
c_sharp_7 equ 97
d_7 equ 98
d_sharp_7 equ 99
e_7 equ 100
f_7 equ 101
f_sharp_7 equ 102
g_7 equ 103
g_sharp_7 equ 104
a_7 equ 105
a_sharp_7 equ 106
b_7 equ 107
c_8 equ 108
c_sharp_8 equ 109
d_8 equ 110
d_sharp_8 equ 111
e_8 equ 112
f_8 equ 113
f_sharp_8 equ 114
g_8 equ 115
g_sharp_8 equ 116
a_8 equ 117
a_sharp_8 equ 118
b_8 equ 119

drum_laser equ 27
drum_whip equ 28
drum_scratch_push equ 29
drum_scratch_pull equ 30
drum_stick_click equ 31
drum_metro_click equ 32
drum_metro_bell equ 34 ; there is no 33 ;)
drum_bass equ 35
drum_kick equ 36 ; there is a difference!
drum_snare_stick equ 37
drum_snare equ 38
drum_clap equ 39
drum_electric_snare equ 40
drum_tom_2 equ 41
drum_hat_closed equ 42
drum_tom_1 equ 43
drum_hat_pedal equ 44
drum_tom_3 equ 45
drum_hat_open equ 46
drum_tom_4 equ 47
drum_tom_5 equ 48
drum_crash equ 49
drum_tom_6 equ 50
drum_ride equ 51
drum_china equ 52
drum_ride_bell equ 53
drum_tambourine equ 54
drum_splash equ 55
drum_cowbell equ 56 ; i've got a fever
drum_crash_2 equ 57
drum_vibraslap equ 58
drum_ride_2 equ 59
drum_bongo_high equ 60
drum_bongo_low equ 61
drum_conga_dead equ 62
drum_conga equ 63
drum_tumba equ 64
drum_timbale_high equ 65
drum_timbale_low equ 66
drum_agogo_high equ 67
drum_agogo_low equ 68
drum_cabasa equ 69 ; nice
drum_maracas equ 70
drum_whistle_short equ 71
drum_whistle_long equ 72
drum_guiro_short equ 73
drum_guiro_long equ 74
drum_claves equ 75
drum_wood_high equ 76
drum_wood_low equ 77
drum_cuica_high equ 78
drum_cuica_low equ 79
drum_triangle_mute equ 80
drum_triangle_open equ 81
drum_shaker equ 82
drum_sleigh_bell equ 83
drum_bell_tree equ 84
drum_surdu_dead equ 86
drum_surdu equ 87
drum_snare_rod equ 91
drum_ocean equ 92
drum_snare_brush equ 93

note_on equ 90h
note_off equ 80h

%ifdef opl
	call opl_percussion_mode
%endif

	jmp midi_end

; there is no correlation between tracks and channels - each track contains note ons and offs for its own channel
midi_track_offset resw 16 ; labels where each track is stored
midi_track_offset_i resw 16 ; initial offset
midi_tracks_playing dw 0 ; bit states
midi_length dw 0
midi_position dw 0 ; overall
midi_speed db 0 ; specified by the user
midi_speed_counter db 0 ; used internally for keeping time
midi_tracks db 0 ; how many are there in the current song? (counting from 0)
midi_track_event dw 0 ; bit states, for the programmer's use
midi_track_wait resb 16 ; how many ticks to wait before playing the note?
midi_last_command resw 16
midi_playing db 0
midi_looping db 0

midi_play_song:
	push ax
	push bx
	push cx

	inc byte [midi_tracks]
	
	; get initial track offsets...
	xor bx,bx
.offset_loop:
	push bx
	shl bx,1
	mov ax,[midi_track_offset+bx]
	mov word [midi_track_offset_i+bx],ax
	pop bx
	mov byte [midi_track_wait+bx],0
	inc bx
	cmp bl,[midi_tracks]
	jne .offset_loop
	
	; only enable the tracks that are actually playing...
	mov word [midi_tracks_playing],0
	movzx ax,[midi_tracks]
.track_loop:
	bts word [midi_tracks_playing],ax
	cmp ax,0
	je .track_loop_skip
	dec ax
	jmp .track_loop
.track_loop_skip:
	mov al,[midi_speed]
	mov byte [midi_speed_counter],al
	mov byte [midi_playing],1
	
	pop cx
	pop bx
	pop ax
	ret

midi_interrupt:
	push ax
	push bx
	push cx
	push dx
	push si
	
	cmp byte [midi_playing],0
	je .end
	
	dec byte [midi_speed_counter]
	cmp byte [midi_speed_counter],0
	jne .end
	mov al,[midi_speed]
	mov byte [midi_speed_counter],al
	
	mov word [midi_track_event],0
	xor bx,bx
	; go through each track!
.track_loop:
	push bx
	shl bx,1
	
	xor cl,cl ; drum flag (for note offs)
	mov si,[midi_track_offset+bx] ; one byte at a time
	mov al,[si] ; note on/off
	cmp al,0 ; null byte?
	je .track_loop_end ; if so, skip everything
	cmp al,254 ; end command?
	je .track_loop_end_skip ; if so, do nothing
	cmp al,255 ; wait command?
	jne .no_wait ; if not, continue as normal
	push bx
	shr bx,1
	inc si ; get wait ticks
	mov al,[si]
	mov byte [midi_track_wait+bx],al ; how long to wait
	pop bx
	jmp .track_loop_end_wait
	
.no_wait:
	push bx
	shr bx,1
	cmp byte [midi_track_wait+bx],0 ; no ticks to wait?
	pop bx
	je .no_wait_skip ; if not, play note
	push bx
	shr bx,1
	dec byte [midi_track_wait+bx] ; otherwise, decrease
	pop bx
	jmp .track_loop_end_skip
.no_wait_skip:
	cmp al,note_on ; it's a valid command, is it a note off already?
	jb .track_loop_note_off_skip ; if so, continue as normal
	mov ax,[midi_last_command+bx] ; note off the last played note
	cmp ax,0
	je .track_loop_note_off_skip
	cmp al,note_on
	jb .track_loop_note_off_skip
	
%ifdef opl
	push ax
	sub al,90h ; get channel number on its own
	call opl_note_off ; no note required
	pop ax
%else
	call midi_setup
	sub al,10h ; change note on to note off
	out dx,al
	mov al,ah ; note number
	out dx,al
	mov al,63 ; velocity
	out dx,al
%endif
	
.track_loop_note_off_skip:
%ifndef opl
	call midi_setup
%endif
	mov si,[midi_track_offset+bx]
	mov al,[si]
	sub al,note_on ; get channel number
	cmp al,9 ; channel 10?
	jne .track_loop_skip ; if not, skip
	mov cl,1
.track_loop_skip:
	push bx
	shr bx,1
	bt word [midi_tracks_playing],bx ; current track playing?
	pop bx
	jnc .track_loop_end ; if not, skip
	
%ifdef opl
	push bx
	mov al,[si]
	cmp al,note_on ; is this a note on?
	jb .opl_note_off ; if not, handle note off
	sub al,note_on ; it's a note on
	inc si ; get note number
	mov bl,[si]
	call opl_note_on
	jmp .opl_skip
.opl_note_off:
	sub al,note_off
	call opl_note_off ; channel's all that's needed
.opl_skip:
	pop bx
%else
	mov al,[si] ; note on/off
	out dx,al
	inc si
	mov al,[si] ; note to play/cut
	out dx,al
	inc si
	mov al,[si] ; velocity
	out dx,al
%endif
	push bx
	shr bx,1
	bts word [midi_track_event],bx
	pop bx
	
	mov si,[midi_track_offset+bx]
	mov ax,[si]
	mov word [midi_last_command+bx],ax
	
	cmp cl,0 ; if this was a drum note, send a note off
	je .track_loop_end
	
.track_loop_end:
	add word [midi_track_offset+bx],3
	jmp .track_loop_end_skip
.track_loop_end_wait:
	add word [midi_track_offset+bx],2
.track_loop_end_skip:
	pop bx
	inc bx
	cmp bl,[midi_tracks]
	jne .track_loop
	
	inc word [midi_position]
	mov ax,[midi_length]
	cmp word [midi_position],ax ; reached end?
	jne .end ; if not, skip
	cmp byte [midi_looping],0
	je .stop
	mov word [midi_position],0
	xor bx,bx
.offset_loop: ; reset all track offsets
	push bx
	shl bx,1
	mov ax,[midi_track_offset_i+bx]
	mov word [midi_track_offset+bx],ax
	pop bx
	mov byte [midi_track_wait+bx],0
	inc bx
	cmp bl,[midi_tracks]
	jne .offset_loop
	jmp .end
.stop:
	cmp byte [midi_playing],0
	je .end
	mov byte [midi_playing],0
	call midi_all_notes_off
.end:

	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	iret

midi_all_notes_off:
%ifdef opl
	call opl_all_notes_off
%else
	push ax
	push bx

	xor al,al ; channel
.loop:
	call midi_all_notes_off_channel
	
	inc al
	cmp al,16
	jne .loop
	
	pop bx
	pop ax
%endif
	ret

midi_all_notes_off_channel: ; al = channel
%ifdef opl
	call opl_note_off
%else
	push bx
	xor bl,bl ; note
.note_loop:
	call midi_note_off
	inc bl
	cmp bl,127
	jne .note_loop
	pop ax
%endif
	ret

midi_setup:
%ifndef opl
	push ax
	mov dx,331h ; gets it into uart mode
	mov al,3fh
	out dx,al
	
	mov dx,330h
	pop ax
%endif
	ret

midi_channel_change: ; al = channel, ah = instrument
	; if using opl, si is the instrument, as it points to a series of values, not just one
%ifdef opl
	push si
	cmp si,opl_instrument_piano ; si can't be anything before the first instrument
	jae .opl_skip ; if it's a valid instrument, skip
	mov si,opl_instrument_piano ; otherwise, default to piano
.opl_skip:
	call opl_setup_instrument
	pop si
%else
	push ax
	push dx
	call midi_setup
	add al,0c0h ; change instrument
	out dx,al
	mov al,ah ; instrument number
	out dx,al
	pop dx
	pop ax
%endif
	ret
	
midi_note_off: ; al = channel, bl = note
%ifdef opl
	call opl_note_off
%else
	push ax
	call midi_setup
	add al,note_off
	out dx,al
	mov al,bl ; note to turn off
	out dx,al
	mov al,63
	out dx,al ; note off velocity
	pop ax
%endif
	ret
	
midi_note_on: ; al = channel, ah = velocity, bl = note
%ifdef opl
	call opl_note_on
%else
	push ax
	push dx
	call midi_setup
	add al,note_on ; note on
	out dx,al
	mov al,bl ; note to play
	out dx,al
	mov al,ah ; velocity
	out dx,al
	pop dx
	pop ax
%endif
	ret
	
midi_end: