# 8086
Experiments with 8086 assembly for DOS. Hopefully this'll all culminate in a fully fledged game, but we'll have to see how that turns out! Starting off with the basics, and slowly moving up to more advanced things.

Compile these with NASM using the following command:
```nasm -f bin -o file.com file.asm```

## The Premise
Make a game that involves a bald, emotionless version of myself riding in a bumper car, mindlessly bumping into other cars to gain points. It'll be possible to bump the same car multiple times for a bonus, eventually oblitterating the car entirely by way of spontaneous combustion. The whole thing will be in a .com file, and have a size of under 64k.

## BGL (Best Graphics Library)
It's the thing I've written for my game to draw graphics, mainly sprites. It is the greatest graphics library to ever exist.

Okay, so it's a bit flawed; the background colour has to be solid because of how redrawing works, and it isn't in its own file (Yet™), but it's surprisingly effective. It uses a custom file format which is extremely simple. The first 2 bytes consist of the width and height (of course, the maximum is 255), and the rest of the bytes consist of the different colour indexes that make up the graphic. In a way, it's better than using a pre-existing format, as I have all VGA colours at my disposal, and it's super quick to parse as it consists of raw data.

Graphics have to be stored in a buffer of fixed size, which is probably where most of the game's filesize will come from. For instance, if your graphic is 1024 bytes large (including the "header"), make a buffer that consists of 1024 empty bytes. Then, the BIOS file loader will know exactly how many bytes to load. Luckily, most of the player graphics in my game are the exact same size, so I can get away with reusing the same buffer for all players.

The program "convert.py" is a simple Python script that converts an image to the .gfx format. 32-bit PNGs seem to be a safe bet, as I've had issues with other bit depths. It's super rough and there's no checking, because I only wrote it for myself to get the job done. It requires the Pillow library for handling images.

## Graphics
The game uses double-buffering, which completely eliminates flicker. It works by allocating a chunk of memory that contains the entire video buffer, and doing all the drawing on that. Then, once it's finished drawing, we write the contents of the buffer to the display. This means you don't see any of the redrawing that's happening behind the scenes, which is what happened with a single-buffered display, and resulted in lots of flicker (demonstrated in bounce.asm and bitmap.asm). I was alright with that initially, but then I realized for any serious purpose it's much better to use 2 buffers. I also ended up writing directly to video memory instead of using the obscenely slow Int 10h/AH=0Ch BIOS calls, because that does a bunch of checks beforehand which slows it down massively.

The bit that made me pull my hair out was figuring out how to write directly to VGA memory. There is tons of conflicting information on the internet, but I eventually figured out how to do it. I'm using the ES register instead of DS, because it won't interfere with other data reading functions. I can simply use an index register for the offset, and then write to memory like so:

```
mov ax,0a000h ; vga video offset
mov es,ax ; only have to set this once at the beginning of the code
mov di,0 ; destination index (used for the offset)
mov al,2 ; the colour index to write
mov byte [es:di],al ; write to offset di, starting from es
```

Calculating the video offset manually and writing to memory offers a significant speed increase. This is only for my reference, but hopefully someone else finds it useful.

## Sound
I haven't considered it yet, but apparently the PC speaker is a pain to deal with. I'll worry about it at a later date. If I ever implement sound, it won't go beyond the PC speaker.
