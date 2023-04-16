## beep_play_sfx
Plays a sound effect at the offset specified by **si**. Sound effects are stored as an "array" of words, with 0 denoting the end of a sound effect, and 1 denoting a loop, useful for "music" tracks. To simulate note cuts, use the value 3.
## beep_play_sample
Plays a 1-bit sound through the PC speaker. **si** contains the offset for the file, **dx** should contain the length of the file, and **cx** decides how fast the sound should play, with higher values resulting in slower playback. This will lock up the program temporarily as the CPU needs to dedicate all its time to playing the sound, so there are no stutters! To encode a sound, use **pcm2pwm.py** with an unsigned 8-bit wave file as the input.

Please refer to **pwm.asm** for an example of how this subroutine is used!
## beep_play_pcm_sample
Plays an 8-bit unsigned PCM sound through the PC speaker. Usage of this command is identical to **beep_play_sample**.
## beep_play_pcm_sample2
Identical to **beep_play_pcm_sample**, but without the audible carrier signal. This results in much better sound quality, but there are compatibility issues on some older computers.
## beep_handler
Handles playback of sound effects/music. Put this in your main loop! A fun little addition is the word **beep_sfx_add** which alters the pitch by adding/subtracting from it!
## beep_pcm_handler
An awful implementation of asynchronous 8-bit sample playback. It works by playing a tiny chunk of the sample alongside the main loop. The start of the sample goes into **beep_pcm_offset**, and its length into **beep_pcm_length**. The speed of the sample is set using the byte **beep_pcm_speed**, and the length of each "chunk" is set using **beep_pcm_loops**. It's as awful as it sounds!
## beep_on
Connects the PC speaker to timer 2, ready to start beeping.
## beep_off
Disconnects the PC speaker from timer 2, effectively turning it off (unless you write bits directly to it).
## beep_change
If the PC speaker is turned on, this changes the frequency at which it beeps. If the value of 2 is used, the beeper is turned off (used for note cuts).

## Constants for sample playback:
* beep_22050
* beep_22050_pwm
* beep_11025
* beep_16000
* beep_8000

## Constants for chromatic notes:
* beep_c1
* beep_c_sharp_1
* beep_d1
* beep_d_sharp_1
* beep_e1
* beep_f1
* beep_f_sharp_1
* beep_g1
* beep_g_sharp_1
* beep_a1
* beep_a_sharp_1
* beep_b1

(all the way through to beep_c5)
