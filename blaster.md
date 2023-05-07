# User-Friendly Functions

## blaster_init
Initializes the Sound Blaster by resetting the DSP, turning on the speaker, replacing the interrupt service routine and programming the DMA.

## blaster_deinit
Deinitializes the Sound Blaster by turning off the speaker, restoring the interrupt service routine, and freeing any opened files.

## blaster_play_sound
Plays a sample through the Sound Blaster, with **si** containing the offset to the sound, and **cx** containing the length.

## blaster_mix_retrace
Performs all the mixing calculations for 4 voice 11025Hz playback, plays it back, and waits for the vertical retrace. This is important, because the buffer size is linked directly to the retrace period. To just perform the calculations and nothing else, use **blaster_mix_calculate**.

## blaster_mix_play_sample
Plays a sample using the mix buffer, where **al** is the voice number (0-3), **ah** decides whether the sample is looping (strictly 0 or 1!), **si** points to the sample, and **ecx** defines the length. To stream a sample, set **bx** to 1, and make **si** point to a zero-terminated filename. An error will occur if the filename's invalid. Streaming samples means that you can use a sample up to 4gb long!

## blaster_mix_stop_sample
Stops voice number **al** from playing in the mix buffer.

## blaster_set_sample_rate
A *macro* that sets the sample rate of the Sound Blaster. If using 4 voice playback, this has to be 11025Hz. To use it, simply put ```blaster_set_sample_rate <rate>```

## blaster_buffer_size
A *constant* that specifies the size of the Sound Blaster's buffer in bytes. Be sure to put this above the %include! It's used as follows:
```
%include "blaster.asm"
blaster_buffer_size equ 14000
```
If using 4 voice playback, set it to **blaster_mix_buffer_size** instead.

# Nitty Gritty Functions

## blaster_read_dsp
Reads data from the Sound Blaster's DSP and stores it in **al**.

## blaster_write_dsp
Writes data specified in **bl** to the Sound Blaster's DSP.

## blaster_reset_dsp
Resets the Sound Blaster's DSP.

## blaster_fill_buffer
Fills the Sound Blaster's buffer with sample data at **si**, with length **cx**.

## blaster_start_playback
Starts 8-bit single cycle playback.

## blaster_program_dma
Programs the Sound Blaster's DMA to use channel 1, single cycle mode.

# Caveats
Using the mix buffer relies on the vertical retrace running at the full speed. This means that if your main code slows down, you'll get stuttering. I can't think of any other way of approaching it, so that'll have to be left for now!

The Sound Blaster's settings are fixed to I/O port 220h, DMA channel 1, and IRQ 7. One day, I might make a program that lets you change these settings!
