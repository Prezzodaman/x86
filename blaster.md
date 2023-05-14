# User-Friendly Functions

## blaster_init
Initializes the Sound Blaster by resetting the DSP, turning on the speaker, replacing the interrupt service routine and programming the DMA.

## blaster_deinit
Deinitializes the Sound Blaster by turning off the speaker, restoring the interrupt service routine, and freeing any opened files.

## blaster_play_sound
Plays a sample through the Sound Blaster, with **si** containing the offset to the sound, and **cx** containing the length. The buffer size has to be set to a fixed value; see **blaster_buffer_size** for more information.

## blaster_mix_retrace
Performs all the mixing calculations for multi-voice playback, plays it back, and waits for the vertical retrace. This is important, because the buffer size is linked directly to the retrace period. To perform the calculations without waiting for the retrace, use **blaster_mix_calculate** instead.

## blaster_mix_play_sample
Plays a sample using the mix buffer, where **al** is the voice number (0-3), **ah** decides whether the sample is looping (strictly 0 or 1!), **si** points to the sample, and **ecx** defines the length. To stream a sample, set **bx** to 1, and make **si** point to a zero-terminated filename. An error will occur if the filename's invalid. Streaming samples means that you can use a sample up to 4gb long!

## blaster_mix_stop_sample
Stops voice number **al** from playing in the mix buffer.

## blaster_set_sample_rate
A *macro* that sets the sample rate of the Sound Blaster. To use it, simply put ```blaster_set_sample_rate <rate>```

## blaster_buffer_size
A *constant* that specifies the size of the Sound Blaster's buffer in bytes. Be sure to put this above the %include! It's used as follows:
```
%define blaster_buffer_size_custom
%include "blaster.asm"
blaster_buffer_size equ 14000
```
This is only really neccessary for single sample playback. If you're using 4-voice playback macros, this doesn't need to be set, unless you're using the system timer.

## blaster_interrupt_handler
If you wish to use the system timer, replace the interrupt with this, and put ```%define blaster_buffer_size_custom``` above the %include.

## blaster_mix_buffer_base_length
A *constant* that defines how big the mix buffer is. This doesn't need to be changed unless you're using the system timer, in which case, a set of constants are available:
* blaster_mix_75hz
* blaster_mix_60hz
* blaster_mix_30hz
* blaster_mix_20hz
* blaster_mix_18hz

A timer library is available (timer.asm) which contains the appropriate speeds, and allows you to change the speed and replace the interrupt. Using the default timer speed (18.2Hz) will give the cleanest sounding results.

# %defines
* **blaster_mix_rate_11025** - Sets the mixing sample rate to 11025Hz.
* **blaster_mix_rate_22050** - Sets the mixing sample rate to 22050Hz.
* **blaster_mix_rate_44100** - Sets the mixing sample rate to 44100Hz.
* **blaster_buffer_size_custom** - Allows you to set a custom buffer size. Define this if you're using the system timer for the mix buffer, or playing back single samples (using **blaster_play_sound**). Then, set the constant **blaster_mix_buffer_base_length** to the desired value. See above for more information!
* **blaster_mix_1_voice** - Uses a single voice for multi-voice mixing. This is great for streaming single sounds, as you get the full bit depth!
* **blaster_mix_2_voices** - Uses 2 voices for multi-voice mixing.
* **blaster_mix_8_voices** - Uses 8 voices for multi-voice mixing. This significantly reduces the volume!

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
The Sound Blaster's settings are fixed to I/O port 220h, DMA channel 1, and IRQ 7. One day, I might make a program that lets you change these settings!
