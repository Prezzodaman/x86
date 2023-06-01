## mod_play

Plays a module at offset **si** through the Sound Blaster. **mod_playing** is set to 1. Blastlib needs to be in 4-voice or 8-voice mode for this to work!

The following memory locations are affected during playback: (4 of each)
- **mod_play_sample** - Sample number currently on this channel (byte)
- **mod_play_period** - Period value of the sample that's playing (word)
- **mod_play_effect** - Effect number on this channel (byte)
- **mod_play_params** - Parameters for the effect on this channel (byte)
- **mod_play_volume** - Volume of the channel, set by either the sample or effect **Cxx** (byte)
- **mod_play_line** - Number of the current pattern line (byte)
- **mod_play_pattern** - Number of the currently playing pattern (byte)
- **mod_play_order** - Current order position (byte)
- **mod_play_ticks** - Ticks per row (byte)
- **mod_play_timer** - Counts down from the tick value, processes a line once it reaches 0, and resets (byte)

## mod_stop

Stops a module from playing.

## mod_set_speed

Sets the timer speed and buffer size based on the BPM value in **al**. Word **mod_buffer_end** and byte **mod_play_bpm** are affected. This is also used internally whenever effect **Fxx** is encountered.

## mod_open

Reads all data from a module specified at offset **si**. Once read, the data can be accessed from the following memory locations:

## mod_debug

%define this at the beginning of your code to draw the module data in text mode. (rhymes on a dime)

## mod_buffer_override

To save some space, %define this, and then use constant **blaster_mix_buffer_base_length** to specify a new buffer length. That way, if you know your song won't be below a certain BPM, you can save some extra bytes!

### Module Info
- **mod_name** - Title of the module (bytes, length 20)
- **mod_patterns** - Amount of patterns in the module (byte)
- **mod_order_list** - List of patterns to be played (bytes, length 128)
- **mod_order_length** - Length of the order list (byte)
- **mod_pattern_list** - List of pointers to each pattern (words)
- **mod_sample_list** - List of pointers to each sample's data (words)
### Sample Info (31 of each!)
- **mod_sample_name** - Name of each sample (bytes, length 22)
- **mod_sample_length** - Length of each sample (words)
- **mod_sample_finetune** - Finetune of each sample (bytes)
- **mod_sample_volume** - Volume of each sample (bytes)
- **mod_sample_loop_start** - Start of the loop for this sample / 2 (words)
- **mod_sample_loop_length** - Length of the loop for this sample / 2 (words)

Note that sample data is stored in signed format instead of unsigned. To convert to unsigned, simply add 128 to each sample byte.

## mod_interrupt

The main timer interrupt that does all the parsing and playback! Once the routine finishes, Blastlib's mixing routine is called, and playback starts.

# Support

The following effects are supported:

- **1xx** - Pitch slide up
- **2xx** - Pitch slide down
- **3xx** - Tone portamento (+ memory)
- **9xx** - Set offset (+ memory)
- **Axy** - Volume slide up/down
- **Bxx** - Position break
- **Cxx** - Set volume
- **Dxx** - Line break
- **ECx** - Note cut
- **Fxx** - Set speed/ticks

Isolated sample numbers and notes are also supported! I'll probably never add arpeggio, vibrato or tremolo, as I rarely use them, and I only made this player for my own use :P

# Caveats

Unfortunately, certain tempos give very clicky results, and I haven't figured out why, and probably won't for a while. This is likely because the timer rate doesn't quite line up with the buffer size (Blastlib is single-buffered). I haven't found a pattern of values that's consistently clicky, but I will report back if I do! In the meantime, use the word **mod_buffer_end_offset** to add or subtract a value from the buffer length. 9 times out of 10, this fixes the issue, but finding the value can be hit or miss (it's usually very small)

Also, there's a module that makes the player crash entirely (**amiga broken.mod**), even though it's a duplicate of another module. It crashes immediately, and I traced it back to the part where it fills the buffer with empty bytes (???). I cannot for the life of me figure out why it crashes.

Obviously, Blastlib and the timer library are required for this to work (**blaster.asm** and **timer.asm** respectively). Check out **modplay.asm** for an example of how the library is used!