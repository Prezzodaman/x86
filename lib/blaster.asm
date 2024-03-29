; huge thanks to Leo Ono for supplying a tutorial to work from! you're a legend!
; https://www.youtube.com/watch?v=KY57fXij51M
; https://pdos.csail.mit.edu/6.828/2008/readings/hardware/SoundBlaster.pdf

; important: sounds must be included at the bottom of your file. your program will act weird otherwise!
; also, this file must be included at the top of the file, so the macros can be used
; put your buffer size above the %include for this file, then blaster_set_sample_rate below the %include
; if you don't set the sample rate, it'll sound very flatulent
	
	jmp blaster_end

%define blaster

%define blaster_get_time_constant(a) (65536-(256000000/a))>>8

%macro blaster_set_sample_rate 1
	push bx
	
	mov bl,40h ; dsp command 40h: set time constant
	call blaster_write_dsp
	mov bl,blaster_get_time_constant(%1) ; the sample rate...
	call blaster_write_dsp
	
	pop bx
%endmacro

blaster_error db "Blastlib error:",13,10,"$"
blaster_error_stream db "File $"
blaster_error_stream_2 db " doesn't exist, or already open!",13,10,"$"
blaster_error_stream_3 db "Invalid filename!",13,10,"$"
blaster_error_access db "File access error!",13,10,"$"

blaster_io equ 220h
blaster_dma equ 1
blaster_irq equ 7
blaster_interrupt equ 8+blaster_irq

blaster_old_interrupt_offset dw 0
blaster_old_interrupt_segment dw 0
blaster_sound_offset dw 0
blaster_sound_length dw 0
blaster_sound_looping db 0

blaster_dma_page dw 0
blaster_dma_offset dw 0

; multi-voice sample mixing (default 4)

blaster_mix_70hz equ 624 ; still trying to find a formula!
blaster_mix_60hz equ 731
blaster_mix_30hz equ 1420
blaster_mix_20hz equ 2203
blaster_mix_18hz equ 2414
%ifndef blaster_buffer_size_custom
	blaster_mix_buffer_base_length equ blaster_mix_70hz
%endif
%ifdef blaster_mix_1_voice
	%define blaster_mix_custom_voices
	blaster_mix_voices_shift equ 0 ; one voice, no need to shift
%endif
%ifdef blaster_mix_2_voices
	%define blaster_mix_custom_voices
	blaster_mix_voices_shift equ 1 ; = 1<<1=2 voices
%endif
%ifdef blaster_mix_8_voices
	%define blaster_mix_custom_voices
	blaster_mix_voices_shift equ 3 ; = 1<<3=8 voices
%endif
%ifndef blaster_mix_custom_voices
	blaster_mix_voices_shift equ 2 ; = 1<<2=4 voices
%endif
blaster_mix_voices equ 1<<blaster_mix_voices_shift
blaster_mix_buffer_size_base equ (blaster_mix_buffer_base_length/4)+1
%ifdef blaster_mix_rate_11025
	%define blaster_mix_rate 11025
	blaster_mix_buffer_size equ blaster_mix_buffer_size_base
%endif
%ifdef blaster_mix_rate_22050
	%define blaster_mix_rate 22050
	blaster_mix_buffer_size equ blaster_mix_buffer_size_base*2
%endif
%ifdef blaster_mix_rate_44100
	%define blaster_mix_rate 44100
	blaster_mix_buffer_size equ blaster_mix_buffer_size_base*4
%endif
%ifdef blaster_mix_rate
	blaster_buffer_size equ blaster_mix_buffer_size
%else ; backwards compatibility
	blaster_mix_buffer_size equ blaster_mix_buffer_size_base+1
	; for single sample playback, specify the buffer size yourself!
%endif
blaster_mix_buffer resb blaster_mix_buffer_size
blaster_mix_sample_offset resd blaster_mix_voices
blaster_mix_sample_position resd blaster_mix_voices
blaster_mix_sample_loop_start resd blaster_mix_voices
blaster_mix_sample_loop_end resd blaster_mix_voices
blaster_mix_sample_length resd blaster_mix_voices
blaster_mix_sample_byte resb blaster_mix_voices ; the value of the current byte of each sample (for the programmer's use)
blaster_mix_voice_loops resd blaster_mix_voices ; how many times has a voice looped? (not used internally, but for the programmer's use)
blaster_mix_stream_file_pointer resd blaster_mix_voices
blaster_mix_stream_file_handle resd blaster_mix_voices
blaster_mix_stream_file_buffer db 0 ; that's a huge buffer
blaster_mix_sample_playing db 0 ; bunch of bit states. because it's a byte, it allows for up to 8 voices
blaster_mix_sample_looping db 0 ; same goes for this
blaster_mix_sample_streaming db 0 ; and this
blaster_mix_sample_signed db 0 ; and this
blaster_mix_sample_scale_frac resd blaster_mix_voices ; fractional part
blaster_mix_sample_scale_whole resd blaster_mix_voices ; whole part
blaster_mix_sample_scale_count resd blaster_mix_voices
blaster_mix_sample_volume times blaster_mix_voices db 255

blaster_buffer resb blaster_buffer_size

blaster_get_scale: ; ax = sample rate, bx = voice
	push eax
	push ebx
	push edx
	
	shl eax,16
	shr eax,16
	shl bx,2
	push bx ;
	xor edx,edx
	mov ebx,blaster_mix_rate
	div ebx ; sample rate / mix rate
	pop bx ;
	mov dword [blaster_mix_sample_scale_whole+bx],eax
	push bx ;
	mov eax,edx ; put remainder into eax
	shl eax,16
	mov ebx,blaster_mix_rate
	div ebx ; ((sample rate % mix rate)<<16)/mix rate
	pop bx ;
	mov dword [blaster_mix_sample_scale_frac+bx],eax
	
	pop edx
	pop ebx
	pop eax
	ret

blaster_interrupt_handler:
	call blaster_mix_calculate
	call blaster_program_dma
	call blaster_start_playback
	iret
	
blaster_mix_retrace:
	push ax
	push dx
	
.wait_for:
	mov dx,3dah
	in al,dx
	test al,8
	je .wait_for
	
.wait_after:
	in al,dx
	test al,8
	jne .wait_after
	
	call blaster_mix_calculate
	call blaster_program_dma
	call blaster_start_playback
	
	pop dx
	pop ax
	ret

blaster_mix_stop_sample: ; al = voice number
	push cx
	mov cl,al
	mov al,1
	shl al,cl
	xor al,11111111b
	and byte [blaster_mix_sample_playing],al
	pop cx
	ret

blaster_mix_play_sample: ; al = voice number, ah = looping (0 or 1), bl = streaming, bh = signed, si = sample/pointer to filename, cx = length, dx = sample rate
	push ax
	push bx
	xor bh,bh
	mov bl,al
	mov ax,dx
	call blaster_get_scale
	pop bx
	pop ax
	
	cmp dword [blaster_mix_sample_scale_frac+bx],0
	je .skip
	mov dx,blaster_mix_rate
.skip:
	push dx
	push bx ;
	cmp cx,65535 ; backwards compatibility - check if length is 16-bit
	jbe .start ; if so, continue as normal
	shl ecx,16 ; clear top word, in case it contains anything
	shr ecx,16
.start:
	movzx bx,al
	shl bx,2
	mov dx,bx ; dx is temporary storage for now...
	mov word [blaster_mix_sample_offset+bx],si
	mov dword [blaster_mix_sample_position+bx],0
	mov dword [blaster_mix_sample_length+bx],ecx
	mov dword [blaster_mix_sample_loop_end+bx],ecx
	mov dword [blaster_mix_sample_loop_start+bx],0
	mov word [blaster_mix_voice_loops+bx],0
	mov cl,al
	mov al,1
	shl al,cl
	pop bx ; get streaming/signed flag back
	or byte [blaster_mix_sample_playing],al
	
	mov al,1
	shl al,cl
	cmp ah,0 ; looping?
	jne .looping_skip ; if so, set bit
	xor al,11111111b ; clear bit
	and byte [blaster_mix_sample_looping],al
	jmp .signed
.looping_skip:
	or byte [blaster_mix_sample_looping],al
.signed:
	mov al,1
	shl al,cl
	cmp bh,0 ; signed?
	jne .signed_skip ; if so, set bit
	xor al,11111111b ; clear bit
	and byte [blaster_mix_sample_signed],al
	jmp .streaming
.signed_skip:
	or byte [blaster_mix_sample_signed],al
.streaming:
	mov al,1
	shl al,cl
	cmp bl,0 ; streaming?
	jne .streaming_skip ; if so, set bit
	xor al,11111111b ; clear bit
	and byte [blaster_mix_sample_streaming],al
	jmp .end
.streaming_skip:
	or byte [blaster_mix_sample_streaming],al
	
	push dx ;
	mov bx,dx
	mov ax,[blaster_mix_stream_file_handle+bx]
	mov ah,3eh
	int 21h
	
	mov ah,3dh ; open file
	xor al,al ; read
	mov dx,si
	int 21h
	jc .error
	pop bx ; pushed from dx, popped into bx to use as an offset
	mov word [blaster_mix_stream_file_handle+bx],ax
	xor cx,cx ; offset msb
	xor dx,dx ; offset lsb
	mov ah,42h ; move pointer to end of file
	mov al,2
	int 21h ; new pointer location in dx:ax
	shl edx,16 ; convert dx:ax to eax
	or eax,edx
	mov dword [blaster_mix_sample_length+bx],eax
	mov dword [blaster_mix_sample_loop_end+bx],eax
	jmp .end
.error:
	mov ax,3
	int 10h
	
	mov ah,9
	mov dx,blaster_error
	int 21h
	
	push si
	
.error_file_check_loop: ; check for non-ascii characters before printing
	mov al,[si]
	inc si
	cmp al,127
	ja .error_file_checked ; non-ascii character, print different error
	cmp al,0 ; reached end of file?
	jne .error_file_check_loop ; if not, continue checking
	mov dx,blaster_error_stream ; it's probably a valid string!
	int 21h
	
	pop si
	
	mov ah,2
	mov dl,34
	int 21h
.error_file_loop:
	mov dl,[si]
	inc si
	cmp dl,0
	je .error_file_loop_end
	int 21h
	jmp .error_file_loop
	
.error_file_loop_end:
	mov dl,34
	int 21h
	
	mov ah,9
	mov dx,blaster_error_stream_2
	int 21h
	
%ifdef bgl
%ifndef bgl_no_keys
	call bgl_restore_key_handler
%endif
%endif

	mov ah,4ch
	int 21h
	
.error_file_checked:
	mov dx,blaster_error_stream_3
	int 21h
	
%ifdef bgl
	call bgl_restore_key_handler
%endif

	mov ah,4ch
	int 21h
.end:
	;pop bx
	pop dx
	ret

blaster_mix_calculate:
	push ax
	push bx
	push ecx
	push dx
	push esi
	push di

	; using di as a counter instead of cx, because it needs to be used as an offset
	xor esi,esi ; the current sample index (source)
	xor di,di ; the buffer index (destination)
	
	; clear buffer first!
.clear_loop:
	mov byte [blaster_mix_buffer+di],0
	inc di
	cmp di,blaster_mix_buffer_size
	jb .clear_loop
	
	xor di,di
.buffer_loop:
	xor bx,bx ; voice
.voice_loop:
	mov cl,bl
	shr cl,2 ; dword to byte
	mov al,1
	shl al,cl ; al will contain 1, 2, 4, 8, etc...
	test byte [blaster_mix_sample_playing],al ; current sample playing at all?
	jz .null_byte ; if not, add a null byte
	mov esi,[blaster_mix_sample_offset+bx]
	test byte [blaster_mix_sample_streaming],al ; current sample streaming?
	jz .not_streaming ; if not, play sample normally
	
	push bx
	mov ax,[blaster_mix_stream_file_handle+bx]
	mov bx,ax
	mov ah,3fh ; read from file
	mov cx,1 ; one byte
	mov dx,blaster_mix_stream_file_buffer ; buffer that's a whopping 1 byte large
	int 21h
	pop bx
	
	push bx
	push cx
	mov eax,[blaster_mix_sample_position+bx]
	push eax ;;
	mov ax,[blaster_mix_stream_file_handle+bx] ; get file handle for this sample
	mov bx,ax ; file handle must be in bx
	mov ah,42h ; move file pointer
	xor al,al ; move it from start of the file
	pop ecx ;; ; offset msb
	mov edx,ecx ; offset lsb
	shr ecx,16
	int 21h
	jc .error
	
	mov ah,3fh ; read from file
	mov cx,1 ; one byte
	mov dx,blaster_mix_stream_file_buffer ; buffer that's a whopping 1 byte large
	int 21h
	pop cx
	pop bx
	
	mov al,[blaster_mix_stream_file_buffer]
	shr bx,2
	mov byte [blaster_mix_sample_byte+bx],al
	shl bx,2
	
	jmp .streaming_skip
.not_streaming:
	add esi,[blaster_mix_sample_position+bx] ; get offset of sample into si
	mov al,[esi] ; get sample value from offset si
	push ax
	mov cl,bl
	shr cl,2 ; dword to byte
	mov al,1
	shl al,cl ; al will contain 1, 2, 4, 8, etc...
	test byte [blaster_mix_sample_signed],al ; current sample signed?
	pop ax
	jz .signed_skip ; if not, continue
	add al,128
.signed_skip:
	
	shr bx,2
	mov byte [blaster_mix_sample_byte+bx],al
	shl bx,2
.streaming_skip:
	xor dx,dx
	shr bx,2
	mul byte [blaster_mix_sample_volume+bx] ; scale according to the volume
	mov al,ah
	mov ah,[blaster_mix_sample_volume+bx]
	shr ah,1
	add ah,128
	sub al,ah
	shl bx,2

	shr al,blaster_mix_voices_shift ; divide by the amount of voices
	add byte [blaster_mix_buffer+di],al
	
	mov eax,[blaster_mix_sample_scale_frac+bx] ; fractional sample stepping
	add dword [blaster_mix_sample_scale_count+bx],eax ; if the addition overflows, the carry will be set
	mov eax,[blaster_mix_sample_position+bx]
	adc eax,[blaster_mix_sample_scale_whole+bx] ; add WITH CARRY! so if the previous addition overflowed, this will add an extra one!
	mov dword [blaster_mix_sample_position+bx],eax ; go to next byte in the sample!
	mov eax,[blaster_mix_sample_loop_end+bx]
	cmp dword [blaster_mix_sample_position+bx],eax ; reached end of loop?
	jb .voice_end ; if not, skip
	; reached end of sample, but are we looping?
	
	mov cl,bl ; this has to be recalculated here!
	shr cl,2
	mov al,1
	shl al,cl
	test byte [blaster_mix_sample_looping],al ; this is sample set to loop?
	jz .not_looping
	mov eax,[blaster_mix_sample_loop_start+bx]
	mov dword [blaster_mix_sample_position+bx],eax ; sample is looping, get it back to the beginning!
	inc byte [blaster_mix_voice_loops+bx]
	jmp .voice_end
	
.not_looping: ; not looping, keep the sample at the end
	xor byte [blaster_mix_sample_playing],al ; al will contain the shifty bit value
	mov ax,[blaster_mix_sample_length+bx]
	dec ax
	mov word [blaster_mix_sample_position+bx],ax
	
	jmp .voice_end
.null_byte:
	add byte [blaster_mix_buffer+di],128>>blaster_mix_voices_shift
	shr bx,2
	mov byte [blaster_mix_sample_byte+bx],128
	shl bx,2
.voice_end:

	add bx,4 ; next voice (4 because dword)
	cmp bx,blaster_mix_voices*4
	jb .voice_loop ; haven't reached the last voice yet...
	inc di ; reached last voice, go to next byte in buffer
%ifdef modlib
	cmp byte [mod_playing],0 ; module playing?
	je .length_skip ; compare against blaster buffer's size
	cmp di,[mod_buffer_end]
	jmp .length_skip2
%endif
.length_skip:
	cmp di,blaster_mix_buffer_size
.length_skip2:
	jb .buffer_loop ; haven't reached end of buffer, reset voice value
	
	; reached end of buffer, all voices processed. now we need to copy to the sound blaster's actual buffer

	mov si,blaster_mix_buffer

%ifdef modlib
	cmp byte [mod_playing],0 ; module playing?
	je .length_skip3
	mov cx,[mod_buffer_end]
	jmp .length_skip4
%endif
.length_skip3:
	mov cx,blaster_mix_buffer_size
.length_skip4:
	call blaster_fill_buffer
	jmp .end
	
.error:
	mov ax,3
	int 10h
	
	mov ah,9
	mov dx,blaster_error
	int 21h
	mov dx,blaster_error_access
	int 21h
	
%ifdef bgl
%ifndef bgl_no_keys
	call bgl_restore_key_handler
%endif
%endif
	
	mov ah,4ch
	int 21h
.end:
	pop di
	pop esi
	pop dx
	pop ecx
	pop bx
	pop ax
	ret

blaster_init:
	push bx
	call blaster_reset_dsp
	
	mov bl,0d1h ; dsp command d1h: turn on speaker
	call blaster_write_dsp
	
	call blaster_replace_isr
	call blaster_enable_irq
	call blaster_get_buffer_offset
	call blaster_program_dma
	
	blaster_set_sample_rate blaster_mix_rate

	pop bx
	ret

blaster_play_sound: ; it's all led up to this moment...
	call blaster_program_dma
	call blaster_fill_buffer
	call blaster_start_playback
	ret

blaster_start_playback:
	push bx
	
	mov bl,14h ; dma command 14h: 8-bit single cycle output
	call blaster_write_dsp
%ifdef modlib
	cmp byte [mod_playing],0
	je .skip

	mov bx,[mod_buffer_end]
	dec bx
	xor bh,bh
	call blaster_write_dsp
	
	mov bx,[mod_buffer_end]
	dec bx
	shr bx,8
	call blaster_write_dsp
	jmp .end
%endif
.skip:
	mov bl,(blaster_buffer_size-1) & 0ffh ; low byte
	call blaster_write_dsp
	mov bl,(blaster_buffer_size-1)>>8 ; high byte
	call blaster_write_dsp
.end:
	
	pop bx
	ret

blaster_program_dma:
	push ax
	push dx
	
	mov dx,0ah ; write single mask register for dma 1
	; bit layout:
	; bits 7-3: unused
	; bit 2: disable channel (1 to disable, 0 to enable)
	; bits 1-0: select channel 1 or 2
	mov al,00000101b ; disable dma channel 1
	out dx,al
	
	mov dx,0ch ; "clear byte pointer flip-flop"
	xor al,al ; apparently this can be any value
	out dx,al
	
	mov dx,0bh ; write mode register for dma 1
	; bit layout:
	; bits 7-6: mode selection bits
	;   00: demand mode
	;   01: single mode
	;   10: block mode
	;   11: cascade mode
	; bit 5: address increment bit
	;   0: increment
	;   1: decrement
	; bit 4: auto-initialization enable bit
	;   0: single-cycle dma
	;   1: auto-initialized dma
	; bits 3-2: transfer bits
	;   00: verify transfer
	;   01: write transfer to memory
	;   10: read transfer from memory
	;   11: illegal (you'll be arrested if you use this)
	; bits 1-0: channel selection bits
	;   00: channel 0 (4)
	;   01: channel 1 (5)
	;   10: channel 2 (6)
	;   11: channel 3 (7)
	mov al,01001001b ; single mode, increment, single cycle, read from memory, channel 1
	out dx,al
	
	mov dx,03h ; channel 1 "count" (number of bytes)
	mov al,(blaster_buffer_size-1) & 0ffh
	out dx,al ; low byte...
	mov al,(blaster_buffer_size-1)>>8
	out dx,al ; high byte..
	
	mov dx,02h ; channel 1 buffer address
	mov al,[blaster_dma_offset]
	out dx,al ; low byte...
	mov al,[blaster_dma_offset+1]
	out dx,al ; high byte..
	
	mov dx,83h ; 8-bit dma channel 1 page (low)
	mov al,[blaster_dma_page]
	out dx,al ; low byte only
	
	mov dx,0ah ; enable dma
	; bit layout:
	; bits 7-3: unused
	; bit 2: disable channel (1 to disable, 0 to enable)
	; bits 1-0: select channel 1 or 2
	mov al,00000001b ; disable dma channel 1
	out dx,al
	
	pop dx
	pop ax
	ret

blaster_fill_buffer:
	; si = sound offset
	; cx = length of sound

	; using formulas:
	; segment=dma_page<<12
	; offset=dma_offset (wow)

	push ax
	push es
	push di
	
	mov ax,[blaster_dma_page]
	shl ax,12
	mov es,ax
	mov di,[blaster_dma_offset]
	
	push cx
	mov cx,blaster_buffer_size
.nothing:
	mov byte [es:di],127
	inc di
	loop .nothing
	pop cx
	cmp cx,blaster_buffer_size
	jle .size_skip
	mov cx,blaster_buffer_size
.size_skip:
	mov di,[blaster_dma_offset]
.sound:
	mov al,[ds:si]
	mov byte [es:di],al
	inc si
	inc di
	loop .sound
	
	pop di
	pop es
	pop ax
	ret

blaster_get_buffer_offset:
	; using formulas:
	; dma_offset=((segment<<4)+offset) & 0ffffh
	; dma_page=((segment<<4)+offset)>>16
	; if (0ffffh-dma_offset+1 < sound_size):
	;   dma_offset=0
	;   dma_page++

	push ax
	push bx
	push cx
	push dx
	
	mov ax,cs
	mov dx,ax
	shr dx,12
	shl ax,4
	add ax,blaster_buffer
	jnc .skip
	inc dx
.skip:
	mov cx,0ffffh
	sub cx,ax
	inc cx
	cmp cx,blaster_buffer_size
	jae .end
	xor ax,ax
	inc dx
.end:
	mov word [blaster_dma_page],dx
	mov word [blaster_dma_offset],ax
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
blaster_deinit:
	push ax
	push bx
	
	call blaster_disable_irq
	call blaster_restore_isr
	mov bl,0d3h ; dsp command d3h: turn off speaker
	call blaster_write_dsp
	
	; free all opened stream files
	mov cx,blaster_mix_voices
	mov ah,3eh
.loop:
	push bx
	mov bx,[blaster_mix_stream_file_handle+bx]
	pop bx
	cmp bx,0
	je .loop_skip
	int 21h
.loop_skip:
	add bx,4
	loop .loop
	
	pop bx
	pop ax
	ret

blaster_replace_isr:
	push ax
	push es
	cli
	xor ax,ax
	mov es,ax
	mov ax,[es:4*blaster_interrupt]
	mov [blaster_old_interrupt_offset],ax
	mov ax,[es:4*blaster_interrupt+2]
	mov [blaster_old_interrupt_segment],ax
	mov word [es:4*blaster_interrupt],blaster_irq_handler
	mov word [es:4*blaster_interrupt+2],cs
	sti
	pop es
	pop ax
	ret
	
blaster_restore_isr:
	push ax
	push es
	cli
	xor ax,ax
	mov es,ax
	mov ax,[blaster_old_interrupt_offset]
	mov [es:4*blaster_interrupt],ax
	mov ax,[blaster_old_interrupt_segment]
	mov [es:4*blaster_interrupt+2],ax
	sti
	pop es
	pop ax
	ret

blaster_irq_handler: ; this will be called by the sound blaster once the sample's finished playing
	pusha ; this is very important!
	
	mov dx,blaster_io+0eh ; 0eh = 8-bit dma i/o
	in al,dx
	
	mov al,20h ; end of interrupt
	out 20h,al ; master pic data port (base)
	
	popa
	iret

blaster_enable_irq:
	push ax
	in al,21h ; master pic data port (mask, connected to interrupts 0-7)
	and al,01111111b ; clear bit 7, enabling interrupt
	out 21h,al
	pop ax
	ret
	
blaster_disable_irq:
	push ax
	in al,21h
	or al,10000000b ; set bit 7, disabling interrupt
	out 21h,al
	pop ax
	ret

blaster_read_dsp:
	push dx
	mov dx,blaster_io+0eh ; dsp command 0eh: get read-buffer status
.busy:
	in al,dx ; check for data
	or al,al ; data available?
	jns .busy ; bit 7 clear, try again
	
	mov dx,blaster_io+0ah ; dsp command 0ah: access in-bound dsp data
	in al,dx ; read data
	pop dx
	ret

blaster_write_dsp: ; data = bl
	push ax
	push dx
	
	mov dx,blaster_io+0ch ; dsp command 0ch: write command/get write-buffer status
.busy:
	in al,dx ; get write-buffer status into al
	or al,al ; ready to write?
	js .busy ; if bit 7 is set, try again
	
	mov al,bl
	out dx,al
	
	pop dx
	pop ax
	ret

blaster_reset_dsp:
	push ax
	push cx
	push dx

	mov dx,blaster_io+6 ; dsp command 06: reset
	
	mov al,1
	out dx,al ; write 1 to dsp reset port
	
	xor al,al
.delay:
	dec al
	jne .delay ; wait for 255...
	out dx,al ; al wrapped back round to 0, write 0 to dsp reset port
	
	xor cx,cx
.empty:
	mov dx,blaster_io+0eh ; dsp command 0e: read-buffer status (any data to read?)
	
	in al,dx ; any data available?
	or al,al ; or'ing a register with itself will set the zero flag if the register is 0
	jns .try_again ; bit 7 clear, try again
	
	mov dx,blaster_io+0ah ; dsp command 0a: read dsp data port
	in al,dx ; get the data
	cmp al,0aah ; success?
	je .end ; if so, dsp is reset
	
.try_again:
	loop .empty
	
.end:
	pop dx
	pop cx
	pop ax
	ret
	
blaster_end: