; IMPORTANT: Because of the order files are included, modlib must be defined at the beginning of your source code.
; blaster.asm needs to be included before this file, so if you define modlib in this file, it'll be ignored. It uses that definition so it sends the right buffer size to the Sound Blaster. Otherwise, horrible clicking occurs.

; See modplay.asm for an example on how this library is used!

; %define mod_debug if you want to see the module information drawn in text mode. general.asm is required for this!
; timer.asm is also required for the interrupts

; NOTE: certain bpms give *very* clicky results. I have no idea why this is, and I can't figure out how to prevent it, so just change the bpm :P

; wow there's a lot of notes, it's almost like this player's held together with string

%ifndef mod_buffer_override
	blaster_mix_buffer_base_length equ 1400 ; this is the longest the buffer will ever be, to accomodate different speeds
%endif

	jmp mod_end

mod_channels equ 4
mod_patterns_max equ 256 ; how many maximum patterns in a .mod file. instead of storing the pattern data, we'll store pointers to each pattern to save space
mod_rows_per_channel equ 4
mod_lines equ 64

mod_name_length equ 20
mod_name resb mod_name_length
mod_patterns db 0 ; how many patterns in this module?
mod_order_length db 0
mod_order_list resb 128

mod_sample_name_length equ 22
mod_samples equ 31
mod_sample_name resb mod_sample_name_length*mod_samples
mod_sample_length resw mod_samples
mod_sample_finetune resb mod_samples
mod_sample_volume resb mod_samples
mod_sample_loop_start resw mod_samples
mod_sample_loop_length resw mod_samples
mod_sample_list resw mod_samples

mod_pattern_list resw mod_patterns_max
	
mod_play_ticks db 6
mod_play_timer db 0 ; tick timer, counts down until it's zero, then resets and processes next line
mod_play_bpm db 0

mod_play_sample resb mod_channels
mod_play_period resw mod_channels
mod_play_effect resb mod_channels
mod_play_params resb mod_channels
mod_play_volume resb mod_channels
mod_play_note resw mod_channels ; used for finding the finetune
mod_play_line db 0 ; which line are we currently on?
mod_play_pattern db 0 ; which pattern are we currently on?
mod_play_order db 0 ; order position
mod_playing db 0
mod_stupid_flag resb mod_channels ; this is set if there's a sample, but no note. i spent an entire day trying to figure out how to check, but i've restored to making this stupid flag
mod_play_last_period resw mod_channels ; this contains the same as play_period, but is only set if the period is non-zero
mod_play_previous_period resw mod_channels ; the period before this one - also used for tone portamento to get the... previous period
mod_play_last_sample resb mod_channels

mod_port_memory resb mod_channels ; the last value used with effect 3 (tone portamento), port up and down (1 and 2) have no memory
mod_port_up resb mod_channels ; if true, the tone portamento will slide up. used to prevent repeat checks, it's only checked once on the line the effect's encountered
mod_port_from resw mod_channels
mod_port_to resw mod_channels
mod_port_sliding resb mod_channels
mod_offset_memory resb mod_channels ; sample offset (as stored in the effect)
mod_vibrato_memory resb mod_channels
mod_note_cut_ticks resb mod_channels
mod_note_delay resb mod_channels

mod_buffer_end dw 0 ; the sound blaster's buffer is of a fixed size, but the mod player only uses a certain amount of that buffer, depending on the module's speed. remember the module's speed also affects the timer's speed!!
mod_buffer_end_offset dw 0 ; this value must be manually adjusted, it's a very dodgy workaround to the "clicky sound with certain bpms" issue

mod_get_note: ; input: ax = period, result: ax = note
	push bx ;;
	push dx ;;
	
	xor bx,bx
.loop:
	mov dx,[mod_period_table+bx]
	cmp ax,dx ; is the current period a match?
	je .end ; if so, set the note value
	add bx,2
	cmp bx,36*2
	jne .loop
.end:
	mov ax,bx
	shr ax,1
	
	pop dx ;;
	pop bx ;;
	ret

mod_get_finetune_period: ; di = sample number*2, bx = channel number*2
	push bx
	push dx
	push di
	
	shr di,1
	shr bx,1
	movzx ax,[mod_sample_finetune+di]
	shl di,1
	shl bx,1
	cmp al,7fh ; nothing?
	je .end ; if so, skip
	
	push bx ; times finetune by 36 (length of each period table)
	mov bx,36 ; finetune is in ax
	xor dx,dx
	mul bx ; offset index
	pop bx
	push bx
	
	add ax,[mod_play_note+bx] ; add current note to offset
	shl ax,1 ; * words
	mov bx,ax
	mov ax,[mod_period_table+bx]
	pop bx
.end:

	pop di
	pop dx
	pop bx
	ret

mod_stop: ; in case I need to add anything else :)
	mov byte [mod_playing],0
	ret
	
mod_set_speed: ; bpm in al, returns nothing!
	push eax
	push ebx
	push edx
	
	; check if ticks
	cmp al,32 ; 32 is the minimum bpm
	jb .ticks ; if we're setting ticks, keep bpm as is, only change ticks
	add al,2 ; for some reason it's slightly off
	mov byte [mod_play_bpm],al
	jmp .bpm
.ticks:
	mov byte [mod_play_ticks],al
	mov byte [mod_play_timer],al
.bpm:
	; convert bpm to hz
	movzx eax,byte [mod_play_bpm]
	push eax ; push bpm for later
	xor edx,edx
	shl eax,1 ; bpm*2
	mov ebx,5
	div ebx ; (bpm*2)/5
	
	; convert hz to timer rate
	xor edx,edx
	mov ebx,eax
	mov eax,1193180 ; timer's clock speed
	div ebx ; divide that by our frequency
	call timer_speed
	
	; set buffer "size"
	xor edx,edx
	mov eax,blaster_mix_rate
	mov ebx,10
	mul ebx ; mix rate*10
	
	xor edx,edx
	pop ebx ; get back bpm, into bx
	div ebx ; (mix rate*10)/bpm
	shr eax,2
	
	mov word [mod_buffer_end],ax
	mov ax,[mod_buffer_end_offset]
	add word [mod_buffer_end],ax
	
	pop edx
	pop ebx
	pop eax
	ret

mod_get_frequency: ; period in ax, frequency in ax
	push ebx
	push edx
	
	and eax,0ffffh ; clear top bits
	shl eax,1 ; frequency*2
	mov ebx,eax
	mov eax,7159091
	xor edx,edx
	div ebx
	
	pop edx
	pop ebx
	ret

mod_effects_check: ; line-based effects (apart from Cxx), takes bx as the channel number (0,1,2,3)
	push ax
	push bx
	push dx
	
	cmp byte [mod_play_effect+bx],0eh ; extended?
	jne .speed
	mov al,[mod_play_params+bx]
	shr al,4 ; get upper nibble
	cmp al,0ch ; note cut?
	jne .delay ; check for note delay
	mov al,[mod_play_params+bx]
	and al,0fh ; get lower nibble (cut ticks)
	mov byte [mod_note_cut_ticks+bx],al
	jmp .end
.delay:
	cmp al,0dh ; note delay?
	jne .end ; if not, skip to end (no more extended effects)
	mov al,[mod_play_params+bx]
	and al,0fh ; get lower nibble
	mov byte [mod_note_delay+bx],al
	jmp .end
.speed:
	cmp byte [mod_play_effect+bx],0fh ; speed change
	jne .position
	mov al,[mod_play_params+bx]
	call mod_set_speed
	jmp .end
.position:
	cmp byte [mod_play_effect+bx],0bh ; position change
	jne .line
	mov al,[mod_play_params+bx]
	mov byte [mod_play_order],al
	mov byte [mod_play_line],0
.line:
	cmp byte [mod_play_effect+bx],0dh ; line break
	jne .offset ; for some reason, the line break effect stores the value as DECIMAL, not hex. WHY... is the mod format so weird
	xor dx,dx
	push bx ;
	movzx ax,[mod_play_params+bx]
	and ax,0f0h ; get top nibble
	shr ax,4 ; put into lower
	mov bx,10
	mul bx
	pop bx ;
	movzx dx,[mod_play_params+bx]
	and dx,0fh ; get low nibble
	add al,dl
	mov byte [mod_play_line],al
	jmp .end
.offset:
	cmp byte [mod_play_effect+bx],9 ; offset
	jne .tone
	cmp byte [mod_play_params+bx],0 ; use previous offset?
	je .end ; if so, leave offset unaffected
	mov al,[mod_play_params+bx] ; change offset
	mov byte [mod_offset_memory+bx],al
	jmp .end
.tone:
	cmp byte [mod_play_effect+bx],3 ; tone portamento?
	jne .end
	push bx
	shl bx,1
	cmp word [mod_play_period+bx],0 ; a note playing?
	pop bx
	je .end ; if not, skip
	mov byte [mod_port_up+bx],0 ; slide down by default
	mov al,[mod_play_params+bx] ; slide speed
	cmp al,0
	je .tone_skip
	mov byte [mod_port_memory+bx],al
.tone_skip:
	mov byte [mod_port_sliding+bx],1
	push bx
	
	shl bx,1
	mov ax,[mod_play_last_period+bx]
	call mod_get_finetune_period
	mov word [mod_port_to+bx],ax
	mov ax,[mod_play_previous_period+bx]
	mov word [mod_port_from+bx],ax
	mov word [mod_play_last_period+bx],ax
	mov ax,[mod_port_to+bx]
	cmp word [mod_port_from+bx],ax
	pop bx
	jb .end
	mov byte [mod_port_up+bx],1
.end:
	pop dx
	pop bx
	pop ax
	ret

mod_portamento:
	push ax
	push bx
	push dx
	push si
	
	mov si,bx ; si=bx*2 (to make life easier)
	shl si,1
	
	cmp word [mod_play_last_period+si],0
	je .end
	
	movzx ax,[mod_play_params+bx]
	cmp byte [mod_play_effect+bx],1 ; slide up?
	je .up
	cmp byte [mod_play_effect+bx],2 ; slide down?
	je .down
	cmp byte [mod_play_effect+bx],3 ; tone?
	je .tone
	jmp .end ; none of the above
.up:
	sub word [mod_play_last_period+si],ax
	jmp .skip
.down:
	add word [mod_play_last_period+si],ax
	jmp .skip
.tone:
	cmp byte [mod_port_sliding+bx],0
	je .skip
	movzx dx,[mod_port_memory+bx]
	mov ax,[mod_port_to+si]
	cmp byte [mod_port_up+bx],0 ; sliding up?
	je .tone_down ; if not... slide down
	push ax
	add ax,dx ; to prevent it from overshooting
	cmp word [mod_play_last_period+si],ax ; reached note?
	pop ax
	jb .tone_end
	sub word [mod_play_last_period+si],dx
	jmp .skip
.tone_down:
	push ax
	sub ax,dx
	cmp word [mod_play_last_period+si],ax ; reached note?
	pop ax
	ja .tone_end
	add word [mod_play_last_period+si],dx
	jmp .skip
.tone_end:
	mov word [mod_play_last_period+si],ax
	mov byte [mod_port_sliding+bx],0
.skip:
	mov ax,[mod_play_last_period+si]
	call mod_get_frequency
	call blaster_get_scale
.end:
	pop si
	pop dx
	pop bx
	pop ax
	ret
	
mod_note_cut:
	cmp byte [mod_play_effect+bx],0eh ; extended?
	jne .end
	mov al,[mod_play_params+bx]
	shr al,4 ; get upper nibble
	cmp al,0ch ; note cut?
	jne .end
	dec byte [mod_note_cut_ticks+bx]
	jnz .end
	mov al,bl
	call blaster_mix_stop_sample
.end:
	ret

mod_volume_slide:
	push ax
	push dx
	cmp byte [mod_play_effect+bx],0ah ; check if it's a volume slide effect
	jne .end ; if not, skip
	mov al,[mod_play_volume+bx]
	mov dl,[mod_play_params+bx] ; get volume change
	cmp dl,10h ; sliding up?
	jae .up ; if so... slide up
	sub al,dl ; current vol - slide amount
	js .low_clip ; result is signed, clip to 0
	jmp .skip
.up:
	shr dl,4 ; get top nibble into lower
	add al,dl ; current vol + slide amount
	and al,64
	jz .high_clip
	jmp .skip
.low_clip:
	mov al,0
	jmp .skip
.high_clip:
	mov al,64
	jmp .skip
.skip:
	mov byte [mod_play_volume+bx],al ; store it back for next time
	call mod_convert_volume
	mov byte [blaster_mix_sample_volume+bx],al
.end:
	pop dx
	pop ax
	ret

mod_convert_volume:	; mod volume in al, result in al (from 0-255)
	xor ah,ah
	shl ax,2
	cmp ax,100h
	jne .shoddy_skip
	mov al,255 ; god this code is awful
.shoddy_skip:
	ret

mod_play:
	call mod_open
	mov byte [mod_playing],1
	mov al,[mod_play_ticks]
	mov byte [mod_play_timer],al
	ret
	
mod_get_pattern_offset:
	; input: al = pattern, ah = line
	; output: ax = offset
	push bx
	
	push ax
	mov bx,mod_channels*4*mod_lines
	xor ah,ah ; clear high byte to get pattern number in ax
	xor dx,dx
	mul bx ; patter number * pattern constant
	mov bx,ax ; put result in bx
	pop ax
	
	shr ax,8 ; high byte into al
	shl ax,4
	add ax,[mod_pattern_list]
	add ax,bx ; add pattern offset to line offset
	
	pop bx
	ret
	
mod_interrupt:
	pushad
	
	cmp byte [mod_playing],0
	je .end
	
	; each note is 4 bytes long, and is laid out as follows:
	
	; byte 0    byte 1    byte 2    byte 3
	; aaaaBBBB  CCCCCCCC  DDDDeeee  FFFFFFFF
	
	; aaaaDDDD = sample number
	; BBBBCCCCCCCC = period value
	; eeee = effect
	; FFFFFFFF = effect parameters
	
	; just eh... sssffff.. uggggWHYYYY?????

	call blaster_mix_calculate
	call blaster_program_dma
	call blaster_start_playback
	
	dec byte [mod_play_timer]
	jnz .effects ; only update tick-based effects if the timer's not finished
	mov al,[mod_play_ticks]
	mov byte [mod_play_timer],al
	
%ifdef mod_debug
	mov ah,2
	mov dl,13
	int 21h
	mov dl,10
	int 21h
	mov dl,"P"
	int 21h
	mov dl,[mod_play_pattern]
	call print_hex_byte
	mov dl,","
	int 21h
	mov dl,"O"
	int 21h
	mov dl,[mod_play_order]
	call print_hex_byte
	mov dl,","
	int 21h
	mov dl,"L"
	int 21h
	mov dl,[mod_play_line]
	call print_hex_byte
	mov dl,":"
	int 21h
	mov dl," "
	int 21h
%endif
	
	cmp byte [mod_play_line],mod_lines ; reached end of pattern?
	jne .play_line_skip ; if not, get pattern offset, increase line
	mov byte [mod_play_line],0 ; otherwise, go back to beginning
	inc byte [mod_play_order] ; increase order position
	mov al,[mod_order_length]
	cmp byte [mod_play_order],al
	jne .play_line_skip
	mov byte [mod_play_order],0
.play_line_skip:
	movzx bx,[mod_play_order]
	mov al,[mod_order_list+bx] ; fetch next pattern number from order list
	mov byte [mod_play_pattern],al
	mov al,[mod_play_pattern]
	mov ah,[mod_play_line]
	call mod_get_pattern_offset
	inc byte [mod_play_line]
	jmp .read_line
	
.read_line:
	mov si,ax
	xor bx,bx ; channels
.channel_loop:

	mov byte [mod_stupid_flag+bx],0
	
	; sample number
	mov al,[si]
	and al,11110000b
	mov ah,[si+2]
	shr ah,4
	add al,ah
	xor ah,ah
	mov di,ax ; di will contain the sample number as an offset
	dec di
	shl di,1
	mov byte [mod_play_sample+bx],al
	cmp al,0
	je .sample_skip
	mov byte [mod_play_last_sample+bx],al
.sample_skip:
%ifdef mod_debug
	mov dl,al
	call print_hex_byte
	
	mov ah,2
	mov dl,","
	int 21h
%endif
	
	push bx
	; period
	shl bx,1
	
	mov ax,[mod_play_last_period+bx]
	mov word [mod_play_previous_period+bx],ax
	
	mov al,[si]
	and al,00001111b
	shl ax,8
	mov al,[si+1]
	
	mov word [mod_play_period+bx],ax
	cmp ax,0
	je .period_skip
	mov word [mod_play_last_period+bx],ax
.period_skip:
	
	push bx
	shr bx,1
	cmp byte [mod_play_sample+bx],0 ; no sample?
	pop bx
	je .flag_skip ; skip flag check
	cmp ax,0 ; there's a sample, but is there any period?
	jne .flag_skip ; if there is, leave flag unchanged
	shr bx,1
	mov byte [mod_stupid_flag+bx],1
	shl bx,1
	
.flag_skip:
	; find note for finetune
	cmp ax,0
	je .note_skip
	call mod_get_note
	mov word [mod_play_note+bx],ax
.note_skip:
	
%ifdef mod_debug
	mov dx,[mod_play_note+bx]
	call print_hex_byte
	
	mov ah,2
	mov dl,","
	int 21h
%endif
	
	pop bx
	; effect number
	mov al,[si+2]
	and al,00001111b
	mov byte [mod_play_effect+bx],al
	
%ifdef mod_debug
	mov dl,al
	call print_hex_byte
	
	mov ah,2
	mov dl,","
	int 21h
%endif
	
	; effect parameter
	mov al,[si+3]
	mov byte [mod_play_params+bx],al
	
%ifdef mod_debug
	mov dl,al
	call print_hex_byte
	
	mov ah,2
	mov dl,","
	int 21h
	
	mov ah,2
	mov dl," "
	int 21h
%endif
	
	; channel finished!
	
	pushad ;;;
	
	call mod_effects_check
	
	cmp byte [mod_play_effect+bx],3 ; tone portamento?
	jne .tone_portamento_skip ; if not, skip
	push bx
	shl bx,1
	cmp word [mod_port_from+bx],0 ; anything to slide from?
	pop bx
	je .tone_portamento_skip ; if not, play sample
	jmp .offset_skip
.tone_portamento_skip:
	mov al,[mod_play_sample+bx]
	cmp byte [mod_play_sample+bx],0 ; a sample playing?
	jne .no_sample ; a sample playing, skip
	push bx
	shl bx,1
	cmp word [mod_play_period+bx],0 ; no sample playing, check if there's a note
	pop bx
	je .play_sample_effects ; no sample or note, skip
	movzx ax,[mod_play_last_sample+bx]
	mov byte [mod_play_sample+bx],al
	mov di,ax
	shl di,1
	
.no_sample:
	shr di,1
	mov al,[mod_sample_volume+di]
	shl di,1
	; volume has to be checked separately here (seriously, i've tried putting it in the effect checking function, all the registers are the same, code is the same, but it doesn't work, SSCCCCHH WHY???????)
	cmp byte [mod_play_effect+bx],0ch ; volume command?
	jne .volume_skip ; if not, use default volume
	mov al,[mod_play_params+bx]
.volume_skip:
	mov byte [mod_play_volume+bx],al
	
	shl bx,1
	
	push ebx ;;;
	
	call mod_get_finetune_period
	mov word [mod_play_period+bx],ax
	mov ax,[mod_play_period+bx]
	call mod_get_frequency
	
	pop ebx ;;; get channel number
	shr bx,1
	call blaster_get_scale
	
	cmp byte [mod_stupid_flag+bx],0 ; sample but no period?
	jne .play_sample_effects ; if so, skip sample playback
	
	push bx
	mov dx,ax ; frequency
	mov ah,0 ; looping
	cmp byte [mod_sample_loop_length+di],1
	je .not_looping
	mov ah,1 ; looping
.not_looping:
	mov al,bl ; voice
	mov si,[mod_sample_list+di] ; sample location
	mov cx,[mod_sample_length+di] ; sample length
	shl cx,1
	xor bl,bl ; streaming
	mov bh,1 ; signed
	call blaster_mix_play_sample
	
	pop bx
	cmp word [mod_sample_loop_length+di],1
	je .play_sample_skip
	push ebx ;
	shl bx,2
	movzx eax,word [mod_sample_loop_start+di]
	shl eax,1
	mov dword [blaster_mix_sample_loop_start+bx],eax
	movzx eax,word [mod_sample_loop_length+di]
	add ax,[mod_sample_loop_start+di]
	shl eax,1
	mov dword [blaster_mix_sample_loop_end+bx],eax
	pop ebx ;
	
	shr di,1
	
.play_sample_effects:
	cmp byte [mod_stupid_flag+bx],0
	je .play_sample_effects_skip
	shl bx,1
	mov ax,[mod_play_last_period+bx] ; this is used for sample number, no period
	call mod_get_finetune_period
	mov word [mod_play_period+bx],ax
	call mod_get_frequency
	shr bx,1
	call blaster_get_scale
.play_sample_effects_skip:
	cmp byte [mod_play_effect+bx],0ch ; volume command?
	jne .play_sample_skip ; if not, skip, keep default volume
	mov al,[mod_play_params+bx] ; change volume
	mov byte [mod_play_volume+bx],al
	
.play_sample_skip:
	mov al,[mod_play_volume+bx]
	call mod_convert_volume	
	mov byte [blaster_mix_sample_volume+bx],al
	
	cmp byte [mod_play_effect+bx],9
	jne .offset_skip
	movzx eax,byte [mod_offset_memory+bx]
	shl eax,8
	shl bx,2
	
	mov dword [blaster_mix_sample_position+bx],eax
	shr bx,1
	
.offset_skip:
	popad ;;;
	
	;;;;;
	
	add si,4
	inc bx
	cmp bx,mod_channels
	jne .channel_loop
	
	jmp .end ; ignore tick-based effects on tick 0

.effects:
	xor bx,bx
.effect_loop: ; update tick-based effects
	call mod_volume_slide
	call mod_note_cut
	call mod_portamento
	inc bx
	cmp bx,mod_channels
	jne .effect_loop
	
.end:
	popad
	iret
	
mod_open:
	; opens a module at offset si, and does the following:
	; * reads all the sample information for all 31 samples
	;   * sample name
	;   * fine tune
	;   * volume
	;   * loop start
	;   * loop end
	;   * length
	; * reads the order list (mod_order_list, byte)
	; * gets the amount of patterns in the module (mod_patterns, byte)
	; * stores the offsets to each of the sample's data (mod_sample_list, word)
	; * stores the offsets to each pattern (mod_pattern_list, word)
	; * sets default speed (125bpm), and default ticks per row (6)
	; * resets buffer offset (janky workaround)
	pushad
	mov eax,[si+438h] ; the "magic" "number": M.K.
	cmp eax,2e4b2e4dh ; valid 4 channel mod?
	jne .error
	
%ifdef mod_debug
	mov ah,9 ; gibb
	mov dx,mod_msg_name ; gibb
	int 21h ; gibb
%endif
	
	xor bx,bx
.read_name: ; name is 20 bytes long
	mov al,[si+bx] ; get current byte
	mov byte [mod_name+bx],al ; store it!
	
%ifdef mod_debug
	mov ah,2 ; gibb
	mov dl,al ; gibb
	int 21h ; gibb
%endif
	
	inc bx
	cmp bx,mod_name_length
	jne .read_name
	
%ifdef mod_debug
	mov ah,2 ; gibb
	mov dl,13 ; gibb
	int 21h ; gibb
	mov dl,10 ; gibb
	int 21h ; gibb
%endif
	
	add si,20 ; base offset
	mov cx,31 ; sample number
	xor di,di ; for sample name and sample info
	
.get_sample_info:
	xor bx,bx ; offset starting from 0
	
.get_sample_info_name:
	mov al,[si+bx]
	mov byte [mod_sample_name+di],al
	inc di
	inc bx ; bx is our counter here, as well as the offset to read data from
	cmp bx,mod_sample_name_length ; reached end of name?
	jne .get_sample_info_name ; read next byte
	
	push di ; push sample name counter
	mov di,cx
	neg di ; make di start from 0 and count up to 31, instead of counting down
	add di,31
	shl di,1 ; *2 for word length
	
	mov ax,[si+bx] ; bx is at offset 22
	ror ax,8 ; big endian to little endian
	mov word [mod_sample_length+di],ax
	add bx,2
	
	shr di,1 ;;
	mov al,[si+bx] ; offset 24
	mov byte [mod_sample_finetune+di],al
	inc bx
	
	mov al,[si+bx] ; offset 25
	mov byte [mod_sample_volume+di],al
	inc bx
	shl di,1 ;;
	
	mov ax,[si+bx] ; offset 26
	ror ax,8
	mov word [mod_sample_loop_start+di],ax
	add bx,2
	
	mov ax,[si+bx] ; offset 28
	ror ax,8
	mov word [mod_sample_loop_length+di],ax
	add bx,2
	
	add si,30 ; header length
	pop di ; pop sample name counter
	loop .get_sample_info
	
.get_order_info:
	xor bx,bx
	mov al,[si+bx]
	mov byte [mod_order_length],al
	add bx,2 ; song length + unused byte
	
%ifdef mod_debug
	mov ah,9
	mov dx,mod_msg_orders
	int 21h
%endif
	
	mov byte [mod_patterns],0
	mov cx,128
	xor di,di
.get_order_info_loop:
	mov al,[si+bx]
	
%ifdef mod_debug
	mov dl,al
	call print_hex_byte
	push ax
	mov ah,2 ; gibb
	mov dl,"," ; gibb
	int 21h ; gibb
	pop ax
%endif
	
	cmp al,[mod_patterns]
	jb .get_order_info_loop_skip
	mov byte [mod_patterns],al
.get_order_info_loop_skip:
	mov byte [mod_order_list+di],al
	inc bx
	inc di
	loop .get_order_info_loop
	
	add si,134 ; plus the order length/unused byte, plus the "M.K." signature
	
	; the module is assumed to be 4 channels, so we'll use a fixed value to offset the pattern... offset
	; remember, we're getting the POINTERS to each pattern, not the data itself
	; once we have the pointers, we can freely access any part of any pattern!
	movzx cx,[mod_patterns] ; loop for x amount of patterns
	inc cx ; mod_patterns counts from 0
	xor bx,bx ; offset to the pattern pointer array
	
.get_pattern_loop:
	mov word [mod_pattern_list+bx],si
	add si,mod_channels*4*mod_lines
	add bx,2
	loop .get_pattern_loop
	
	; we've now reached the sample data, and of course, it's going to be huge, so we'll use pointers like we did with the patterns. no need to store the samples again if they're already included into the file!
	mov cx,mod_samples
	xor bx,bx
.get_sample_loop:
	mov word [mod_sample_list+bx],si
	mov ax,[mod_sample_length+bx]
	shl ax,1
	add si,ax
	add bx,2
	loop .get_sample_loop
	
	mov al,125 ; set default speed (this will immediately be overridden if there's a speed command on the first line)
	mov byte [mod_play_bpm],al
	call mod_set_speed
	mov byte [mod_play_ticks],6 ; default ticks per row
	
	mov word [mod_buffer_end_offset],0
	
	jmp .end
.error:
	mov ah,9
	mov dx,err
	int 21h
	mov ah,4ch
	int 21h
	jmp .endyes
.end:
%ifdef mod_debug
	mov ah,9
	mov dx,mod_msg
	int 21h
%endif
.endyes:
	popad
	ret
	
mod_print_song_name: ; no argue-ments required
	push ax
	push bx
	push cx
	push dx
	
	mov cx,mod_name_length
	xor bx,bx
.loop:
	mov ah,2
	mov dl,[mod_name+bx]
	int 21h
	inc bx
	loop .loop
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
mod_print_sample_name: ; al = sample number (0-30)
	push ax
	push bx
	push cx
	push dx

	mov bx,mod_sample_name_length
	xor dx,dx
	mul bx
	mov bx,ax
	mov cx,mod_sample_name_length
	
.loop:
	mov dl,[mod_sample_name+bx]
	mov ah,2
	int 21h
	inc bx
	loop .loop
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
mod_period_table:
; Tuning 0, Normal
	dw 856,808,762,720,678,640,604,570,538,508,480,453
	dw 428,404,381,360,339,320,302,285,269,254,240,226
	dw 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dw 850,802,757,715,674,637,601,567,535,505,477,450
	dw 425,401,379,357,337,318,300,284,268,253,239,225
	dw 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dw 844,796,752,709,670,632,597,563,532,502,474,447
	dw 422,398,376,355,335,316,298,282,266,251,237,224
	dw 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dw 838,791,746,704,665,628,592,559,528,498,470,444
	dw 419,395,373,352,332,314,296,280,264,249,235,222
	dw 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dw 832,785,741,699,660,623,588,555,524,495,467,441
	dw 416,392,370,350,330,312,294,278,262,247,233,220
	dw 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dw 826,779,736,694,655,619,584,551,520,491,463,437
	dw 413,390,368,347,328,309,292,276,260,245,232,219
	dw 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dw 820,774,730,689,651,614,580,547,516,487,460,434
	dw 410,387,365,345,325,307,290,274,258,244,230,217
	dw 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dw 814,768,725,684,646,610,575,543,513,484,457,431
	dw 407,384,363,342,323,305,288,272,256,242,228,216
	dw 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dw 907,856,808,762,720,678,640,604,570,538,508,480
	dw 453,428,404,381,360,339,320,302,285,269,254,240
	dw 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dw 900,850,802,757,715,675,636,601,567,535,505,477
	dw 450,425,401,379,357,337,318,300,284,268,253,238
	dw 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dw 894,844,796,752,709,670,632,597,563,532,502,474
	dw 447,422,398,376,355,335,316,298,282,266,251,237
	dw 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dw 887,838,791,746,704,665,628,592,559,528,498,470
	dw 444,419,395,373,352,332,314,296,280,264,249,235
	dw 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dw 881,832,785,741,699,660,623,588,555,524,494,467
	dw 441,416,392,370,350,330,312,294,278,262,247,233
	dw 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dw 875,826,779,736,694,655,619,584,551,520,491,463
	dw 437,413,390,368,347,328,309,292,276,260,245,232
	dw 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dw 868,820,774,730,689,651,614,580,547,516,487,460
	dw 434,410,387,365,345,325,307,290,274,258,244,230
	dw 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dw 862,814,768,725,684,646,610,575,543,513,484,457
	dw 431,407,384,363,342,323,305,288,272,256,242,228
	dw 216,203,192,181,171,161,152,144,136,128,121,114
	
mod_msg_name db "Module name: $"
mod_msg_orders db "Orders: $"
mod_msg db "Done!$"
err db "Invalid 4 channel module!$"
	
mod_end: