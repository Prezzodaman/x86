# x86
Experiments with x86 assembly for DOS. The fun began on the 12th of January 2023, and it continues!

Compile these with NASM using the following command:
```nasm -f bin -o file.com file.asm```

Everything was developed with DOSBox running at roughly 76000 cycles, so please use that speed for the best results.

## The Original Premise
Make a game that involves a bald, emotionless version of myself riding in a bumper car, mindlessly bumping into other cars to gain points. It'll be possible to bump the same car multiple times for a bonus, eventually oblitterating the car entirely by way of spontaneous combustion. The whole thing will be in a .com file, and have a size of under 64k.

## The Result
I managed to achieve my goal in just over a week! The resulting file size is 63k, which is a tight fit. I have no intentions to move away from .com files, because they're tons of fun, and it's a nice challenge seeing how much I can squeeze into 64k. Also, .exes are boring.

While developing my game, so many improvements and developments were made. Using my current knowledge, I could easily halve the file size now. I'll continue to develop more games as it's a great way of learning more about assembly and how I can optimize my code! I have so many ideas that I want to do, and as I get used to assembly, making them a reality becomes easier and easier.

## BGL (Best Graphics Library)
It's the thing I've written to draw graphics. It is the greatest graphics library to ever exist.

It uses an extremely simple custom file format. The first 2 bytes consist of the width and height (of course, the maximum is 255), and the rest of the bytes consist of the different colour indexes that make up the graphic. In a way, it's better than using a pre-existing format, as I have all (standard) VGA colours at my disposal. There's also support for RLE encoded graphics, which offers a significant reduction in file size, and draws slightly quicker as well! Unfotunately, it's very slow when drawing large objects, especially backgrounds. One day, I hope to figure out a faster method. But for smaller objects, it works quite well!

The BGL supports flipping graphics, and "clearing" them based off a background colour. This was what I used before double-buffering, so it's almost redundant, but it can still be used as a sort of "silhouette" effect. You can also choose whether to draw graphics transparent or not. It also handles all the keyboard controls, supports scaling and rotation (but not both!), and has a bunch of functions that automate certain tasks such as initializing the screen, replacing/restoring the key handler, and even a basic flood fill. So it's much more than a graphics library now!

The program **convert.py** is a simple Python script that converts an image to a compatible format. Use the option **--rle** to convert graphics to RLE instead. 24-bit PNGs seem to be the best bet, as I've had issues with other bit depths. I could alter the program, but I really can't be bothered as it works fine, and it's held together with string and tape. It requires the Pillow library for handling images.

## Graphics
The BGL uses double-buffering, which completely eliminates flicker. It works by allocating a chunk of memory that contains the entire video buffer, and doing all the drawing on that. Then, once it's finished drawing, the contents of the buffer are written to the active display. This means you don't see any of the redrawing that's happening behind the scenes, which is what happened with a single-buffered display, and resulted in lots of flicker (demonstrated in **bounce.asm** and **bitmap.asm*, my first graphics-related programs). I was alright with that initially, but then I realized for any serious purpose it's much better to use double-buffering. I also ended up writing directly to video memory instead of using the obscenely slow Int 10h/AH=0Ch BIOS call, because it does a bunch of checks beforehand that slow things down massively.

Ever since I implemented double-buffering, I made a right silly doofus error. When allocating memory, it'll return an error code when something goes wrong, and store it in **ax**. I was assuming that it worked correctly, but after some degibbing (gibb), I found out that I was using the **error code** as the segment address, and somehow it was working! I'm now using the Program Segment Prefix (PSP), which at address 02h, gives me direct access to the first memory segment after the program. That's perfect for what I need, but there's probably some allocation weirdness that needs to be sorted out. We'll have to see, but For The Moment™ it seems to be working.

The bit that made me pull my hair out was figuring out how to write directly to VGA memory. There is tons of conflicting information on the internet, but I eventually figured out how to do it. In this example, I'm using the **es** register instead of **ds**, because it won't interfere with other data reading/writing functions. I can simply use an index register for the offset (such as **bx**, **si** or **di**), and then write to memory like so:

```
mov ax,0a000h ; vga video offset
mov es,ax ; only have to set this once at the beginning of the code
mov di,0 ; destination index (used for the offset)
mov al,2 ; the colour index to write
mov byte [es:di],al ; write to offset di, starting from es
```

Also, a worthy note about the layout of mode 13h is that the video memory actually extends beyond the visible graphics. The graphics start at offset A000h, and last for 64000 bytes. But I recently discovered that after it (at offset A000h:FA00h) there are an additional 768 bytes, which perfectly fits an entire colour palette. It has no relation to the colours you actually see, but it can be used as temporary storage, which is especially useful if you're doing effects that require altering the default palette, such as colour fading. This useful feature is barely documented anywhere, so I'm putting it here for my reference and yours too!

## Sound
Sound is handled by Beeplib which I originally made to turn the beeper on and off, and nothing else. It has since expanded to play back sound effects, songs, and even *digital samples!!!* Sound effects are stored as "arrays" of word values, with a 0 denoting the end of a sound effect. You can also use 3 for note cuts or 2 to loop playback, useful for music. For "music", you can make a text file containing a bunch of notes, and convert it using **note2pitch.py**. Doing this allows for a much more readable syntax, before it gets converted into a bunch of macros. Regarding samples, it can play 1-bit samples, which are much smaller but have low sound quality, and 8-bit unsigned samples, which sound great but use up 8x more space. It plays 8-bit samples using a method called pulsewidth modulation, which can be pulled off by using the "retriggerable one shot" mode found in the PIT (Programmable Interval Timer) which turns the speaker on for a certain amount of time, before turning it off again. It's buried in the documentation somewhere, so it took a while to figure out! It's also technically 7-bit, because each sample has to be shifted over, otherwise clipping will occur. Playing a sample locks up the program, but I've started implementing asynchronous sample playback for 8-bit samples. It's pretty terrible though, and I'm still trying to figure out how to make it sound okay!

## Future Plans
The BGL has expanded massively since its inception, and as such, it compiles to a much bigger filesize now. As more features are added, it might be advisable to make it modular, having each set of features in its own source file (e.g. draw, rotate, scale, keyboard, etc.). The reason I've put it off for so long, is because I want to maintain backwards compatibility with all my older projects. Also, it may become an inconvenience having to include every individual file. I've considered the idea mainly as a concern of filesize! Also regarding the BGL, it's ridiculously slow when it comes to backgrounds, and I cannot for the life of me figure out a faster way. If anyone has an idea, please let me know!

An amazing feature would be asynchronous sample playback, potentially using the Sound Blaster. Apparently it's a pig to program, but it has some neat features such as direct mode, which lets you blast data directly to it, but that's similar to what I'm doing with the PC speaker. I'll try and get something sorted out. I hope to end up with .voc or .wav files in my games, instead of bleeps coming from the speaker!
