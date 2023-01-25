# 8086
Experiments with 8086 assembly for DOS. Hopefully this'll all culminate in a fully fledged game, but we'll have to see how that turns out! Starting off with the basics, and slowly moving up to more advanced things.

Compile these with NASM using the following command:
```nasm -f bin -o file.com file.asm```

These were developed with DOSBox running at roughly 50000 cycles, so please use that speed for the best results.

## The Premise
Make a game that involves a bald, emotionless version of myself riding in a bumper car, mindlessly bumping into other cars to gain points. It'll be possible to bump the same car multiple times for a bonus, eventually oblitterating the car entirely by way of spontaneous combustion. The whole thing will be in a .com file, and have a size of under 64k.

## BGL (Best Graphics Library)
It's the thing I've written for my game to draw graphics. It is the greatest graphics library to ever exist.

Okay, so it's a bit flawed; the background colour has to be solid because of how redrawing works, but it's surprisingly effective. It uses a custom file format which is extremely simple. The first 2 bytes consist of the width and height (of course, the maximum is 255), and the rest of the bytes consist of the different colour indexes that make up the graphic. In a way, it's better than using a pre-existing format, as I have all VGA colours at my disposal, and it's super quick to parse as it consists of raw data. Graphics are simply included as raw files, which can then be loaded from based off the offset value.

The program "convert.py" is a simple Python script that converts an image to the .gfx format. 32-bit PNGs seem to be a safe bet, as I've had issues with other bit depths. It's super rough and there's no checking, because I only wrote it for myself to get the job done. It requires the Pillow library for handling images.

With large objects, it can be quite slow, so try and keep the size of objects relatively small if possible. It supports flipping graphics, and "clearing" them based off a background colour. This was what I used before double-buffering, so it's almost redundant, although you can use it as a sort of "silhouette" effect. You can also choose whether to draw them transparent or not.

The BGL also handles all the keyboard controls, and has a bunch of functions that automate certain tasks, such as initializing the screen, replacing/restoring the key handler, and even a basic flood fill. So it's much more than a graphics library now!

## Graphics
The game uses double-buffering, which completely eliminates flicker. It works by allocating a chunk of memory that contains the entire video buffer, and doing all the drawing on that. Then, once it's finished drawing, we write the contents of the buffer to the display. This means you don't see any of the redrawing that's happening behind the scenes, which is what happened with a single-buffered display, and resulted in lots of flicker (demonstrated in bounce.asm and bitmap.asm). I was alright with that initially, but then I realized for any serious purpose it's much better to use 2 buffers. I also ended up writing directly to video memory instead of using the obscenely slow Int 10h/AH=0Ch BIOS calls, because that does a bunch of checks beforehand which slows it down massively.

Despite all this, in true Prezzo fashion, the BGL manages to slow it down anyway! Most notably, it slows down when drawing large objects. If you're drawing double-buffered without a background, the CPU speed must be at least 32000 cycles/ms (roughly equivalent to a 60mhz Pentium) which is pretty standard for most DOS games. If drawing a background however, it'll need to be at least 50000 cycles/ms (about the same as a 90mhz Pentium!). Things are still somewhat useable at the previously mentioned speed, but anything below that, and it's borderline unusable. So be careful! Also, chances are you're using an emulator, so you have full control over the speed. If not, a modern computer will run it insanely fast!

Ever since I implemented double buffering, I made a right silly doofus error. When allocating memory, it'll return an error code when something goes wrong, and store it in AX. I was assuming that it worked correctly, but after some degibbing (gibb), I found out that I was using the **error code** as the segment address, and somehow it was working! I'm now using the Program Segment Prefix (PSP), which at address 02h, gives me direct access to the first memory segment after the program. That's perfect for what I need, but there's probably some allocation weirdness that needs to be sorted out. We'll have to see, but For The Moment<sup>TM</sup> it seems to be working.

The bit that made me pull my hair out was figuring out how to write directly to VGA memory. There is tons of conflicting information on the internet, but I eventually figured out how to do it. I'm using the ES register instead of DS, because it won't interfere with other data reading functions. I can simply use an index register for the offset, and then write to memory like so:

```
mov ax,0a000h ; vga video offset
mov es,ax ; only have to set this once at the beginning of the code
mov di,0 ; destination index (used for the offset)
mov al,2 ; the colour index to write
mov byte [es:di],al ; write to offset di, starting from es
```

This is only for my reference, but hopefully someone else finds it useful.

## Sound
Sound is handled by Beeplib which I originally made to turn the beeper on and off. It has since expanded to play back sound effects, songs, and even *digital samples!!!* Sound effects are stored as "arrays" of word values, with a 0 denoting the end of a sound effect. You can also use 3 for a silent note (1 is more noisy) or 2 to loop playback, useful for music. Playing a sample locks up the program, but it's totally possible to do so while a game is running, you just need to nab the code from "beeplib.asm" and adjust it as you see fit. I may add asynchronous sample playback one day.

Sound support won't go beyond the PC speaker, because I'm trying to keep things standardized, and from what I've seen, the Sound Blaster is an absolute ballache to work with. I also love the PC speaker!
