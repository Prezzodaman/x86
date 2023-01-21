## beep_play_sfx
Plays a sound effect at the offset specified by **si**. Sound effects are stored as an "array" of words, with 0 denoting the end of a sound effect, and 1 denoting a loop, useful for "music tracks". To simulate note cuts, use a value such as 2 or 3, as they're high enough to be nearly inaudible.
## beep_play_sample
Plays a 1-bit PWM encoded sound through the PC speaker. **si** should contain the offset for the file, **dx** should contain the length of the file, and **cx** decides how fast the sound should play, with higher values resulting in slower playback. This will lock up the program temporarily as the CPU needs to dedicate all its time to playing the sound, so there are no stutters! To encode a sound, use "pcm2pwm.py" with an unsigned 8-bit wave file as the input.

Please refer to "pwm.asm" for an example of this subroutine is used!
## beep_handler
Handles playback of sound effects. Put this in your main loop!
## beep_on
Connects the PC speaker to timer 2, ready to start beeping.
## beep_off
Disconnects the PC speaker from timer 2, effectively turning it off (unless you write bits directly to it).
## beep_change
If the PC speaker is turned on, this changes the frequency at which it beeps.
