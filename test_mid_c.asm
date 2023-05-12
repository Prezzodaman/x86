testmid_play:
	mov byte [midi_tracks],6
	mov word [midi_track_offset],testmid_track_1
	mov word [midi_track_offset+2],testmid_track_2
	mov word [midi_track_offset+4],testmid_track_3
	mov word [midi_track_offset+6],testmid_track_4
	mov word [midi_track_offset+8],testmid_track_5
	mov word [midi_track_offset+10],testmid_track_6
	mov word [midi_track_offset+12],testmid_track_7
	mov word [midi_length],testmid_length

	mov byte [midi_looping],1
	mov byte [midi_speed],4
	
	mov al,0
	mov ah,80
	call midi_channel_change
	mov al,1
	mov ah,81
	call midi_channel_change
	mov al,2
	mov ah,96
	call midi_channel_change
	mov al,3
	mov ah,8
	call midi_channel_change
	
	call midi_play_song
	ret

testmid_length equ 128
testmid_track_1: db 144,c_2,127,128,c_2,0,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,144,c_2,127,128,c_2,0,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,144,e_2,127,128,e_2,0,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,144,e_2,127,128,e_2,0,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,144,c_2,127,128,c_2,0,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,144,c_2,127,128,c_2,0,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,255,1,144,d_2,127,128,d_2,0,144,e_2,127,128,e_2,0,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,144,e_2,127,128,e_2,0,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0,255,1,144,f_2,127,128,f_2,0
testmid_track_2: db 145,c_3,127,145,d_3,127,129,d_3,0,145,d_3,127,145,d_3,127,129,d_3,0,255,2,145,d_3,127,129,d_3,0,145,d_3,127,145,d_3,127,129,d_3,0,255,1,145,d_3,127,145,e_3,127,129,e_3,0,145,e_3,127,145,e_3,127,129,e_3,0,255,2,145,e_3,127,129,e_3,0,145,e_3,127,145,e_3,127,129,e_3,0,255,1,145,e_3,127,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,2,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,1,145,e_3,127,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,2,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,1,145,c_3,127,145,d_3,127,129,d_3,0,145,d_3,127,145,d_3,127,129,d_3,0,255,2,145,d_3,127,129,d_3,0,145,d_3,127,145,d_3,127,129,d_3,0,255,1,145,d_3,127,145,e_3,127,129,e_3,0,145,e_3,127,145,e_3,127,129,e_3,0,255,2,145,e_3,127,129,e_3,0,145,e_3,127,145,e_3,127,129,e_3,0,255,1,145,e_3,127,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,2,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,1,145,e_3,127,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,255,2,145,f_3,127,129,f_3,0,145,f_3,127,145,f_3,127,129,f_3,0,254
testmid_track_3: db 146,g_4,127,255,4,146,f_sharp_4,127,255,20,146,g_4,127,255,2,146,f_sharp_4,127,255,4,146,a_4,127,255,4,146,c_4,127,255,18,146,g_4,127,255,4,146,f_sharp_4,127,255,20,146,g_4,127,255,2,146,f_sharp_4,127,255,4,146,a_4,127,255,4,146,f_4,127,254
testmid_track_4: db 255,9,147,a_4,127,255,0,147,b_4,127,255,0,147,c_5,127,255,26,147,a_4,127,255,0,147,b_4,127,255,0,147,c_5,127,255,4,147,d_5,127,255,20,147,a_4,127,255,0,147,b_4,127,255,0,147,c_5,127,255,26,147,a_4,127,255,0,147,b_4,127,255,0,147,f_4,127,254
testmid_track_5: db 153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,255,2,153,c_2,127,254
testmid_track_6: db 255,3,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,255,6,153,d_2,127,254
testmid_track_7: db 153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,255,0,153,f_3,127,255,1,153,f_3,127,255,1,153,f_3,127,255,2,153,f_3,127,255,2,153,f_3,127,254
