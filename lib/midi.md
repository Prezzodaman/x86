## midi_play_song

Plays a MIDI song using the proprietary format. Parameters are passed using the following memory locations:

- **midi_tracks** - How many tracks there are in your song, from 0 to 15 (byte)
- **midi_track_offset** - The memory location where the data for each track is located. Each track has its own offset, so offset this memory location by the track number\*2 to get/set the corresponding value (word)
- **midi_speed** - How many clock ticks to wait before playing the next part of the song (byte)
- **midi_length** - How long the song is, in ticks (word)
- **midi_looping** - Once the song reaches the end, it'll go back to the beginning if this is set (byte)

When this is called, **midi_playing** is set to 1, and once it finishes, it's set to 0 again.

MIDIs are stored in a (rather bizarre) proprietary format, and they start off as OpenMPT pattern data. In OpenMPT, copy a pattern by selecting some channels, making sure to cover every row of each channel. Then, paste it into a text file, and run **midiconv.py**, passing the input and output filenames as arguments. The result will be an assembly source file, which you can include into your project. It'll contain its own subroutine which plays the song, which you can simply call! See **testmid.txt** for an example of pattern data, and **test_mid.asm** for the converted result. (yes, the underscore bugs me too)

A useful note is that the instrument numbers correspond to MIDI channels, so you can spread polyphony on a single channel across multiple tracks. There can be a maximum of 16 tracks.

## midi_interrupt

The main MIDI playing routine! Hook this to the system timer.

## midi_all_notes_off

Sends a "note off" signal for all notes to every MIDI channel.

## midi_all_notes_off_channel

Identical to **midi_all_notes_off**, but per channel instead. Specify the MIDI channel using **al**.

## midi_channel_change

Changes the instrument of a MIDI channel, where **al** is the channel, and **ah** is the instrument number.

## midi_note_on

Sends a "note on" signal to a MIDI channel specified in **al**, where **ah** is the velocity and **bl** is the note number. There are a bunch of constant values to help find the correct note, ranging from C-0 to B-8, in the format **c_0**, **c_sharp_0**, **d_0**, etc.

## midi_note_off

Sends a "note off" signal to a MIDI channel specified in **al**, where **bl** is the note number.

# Bonus feature: OPL2 support!

If the OPL2 library (opl2.asm) is included alongside this library, MIDI notes will play through the OPL2 instead! Beware that polyphony isn't supported in this case, due to how multiple notes can share the same channel.