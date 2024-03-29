# Graphics
## bgl_draw_gfx
Draws a graphics file to the BGL's graphics buffer. The maximum width and height of a graphic is 255. Parameters are passed using the following memory locations:

- **bgl_x_pos** - X position to draw the graphic at (word)
- **bgl_y_pos** - Y position to draw the graphic at (word)
- **bgl_buffer_offset** - The memory location where the graphic is stored (word)
- **bgl_erase** - Whether to "erase" the graphic or not, replacing all colour with the background colour while retaining transparency, useful for a "silhouette" effect (byte)
- **bgl_background_colour** - When **bgl_erase** is set, this is the colour to fill the graphic in with (byte)
- **bgl_opaque** - If set, the graphic will draw without transparency (byte)
- **bgl_flip** - If set, the graphic will be flipped horizontally (byte)
- **bgl_no_bounds** - If set, edge clipping will be disabled, speeding up drawing (byte)
- **bgl_tint** - Adds or subtracts from the colour index of each pixel, leaving transparency unchanged. A value of 0 will have no effect. (byte)
- **bgl_mask** - If set, the pixels of the graphic and everything behind it are added together, creating a translucent/masking effect (byte)

To convert an image to a .gfx file compatible with the BGL, run **convert.py**, specifying the input file and output file. Only 24-bit PNGs are supported right now. It's best to use RLE instead, unless your graphic has lots of unique pixels, or needs to be scaled or rotated.

## bgl_draw_gfx_fast
Identical to **bgl_draw_gfx**, but optimized for speed. Because of this, **bgl_flip** isn't supported, and there's no edge clipping, so graphics will still be visible if drawn outside the screen. However, it's at least 2x faster than **bgl_draw_gfx**!

## bgl_draw_gfx_scale
Draws a *scaled* graphic to the BGL's buffer!! It uses all the same parameters as **bgl_draw_gfx**, with the addition of the following parameters:

- **bgl_scale_x** - The horizontal scale (dword)
- **bgl_scale_y** - The vertical scale (dword)
- **bgl_scale_centre** - If set, this scales from the centre point instead of the top-left corner (byte)
- **bgl_scale_square** - If set, scaling will be linear (byte)

Higher scale values make the graphic smaller, and negative scale values make it bigger. The largest positive scale value is 32. 32-bit values are required so the graphic can be scaled to extremely small sizes!

## bgl_draw_gfx_rotate
Draws a *rotated* graphic to the BGL's buffer!! It uses all the same parameters as **bgl_draw_gfx**, with the addition of the following parameters:

- **bgl_rotate_angle** - The angle of rotation, in degrees (word)
- **bgl_rotate_bounds** - If set, this allows for custom rotation boundaries, so everything outside the graphic is visible (byte)
- **bgl_rotate_width** - If **bgl_rotate_bounds** is set, this specifies the width of the bounding box (byte)
- **bgl_rotate_height** - If **bgl_rotate_bounds** is set, this specifies the height of the bounding box (byte)

It's also possible to scale and rotate a graphic at the same time, by setting **bgl_rotate_scale**! Then you can use the dword **bgl_scale_x** to change the scale. Both the horizontal and vertical scales are affected.

All other regular parameters are supported apart from **bgl_flip**. If the angle value is -1, it results in a little jitter, due to 360 not being a power of 2. If that's the case, simply constrain the value to 360 and you're all good.

## bgl_draw_gfx_rotate_fast
Identical to **bgl_draw_gfx_rotate**, but uses 8-bit values and bit shifting, for a significant increase in speed. All the boundary checks are also skipped, as well as scaling, but custom boundaries are still supported. Because it uses 8-bit values, angles range from 0-255 instead of 0-360.

## bgl_draw_gfx_rle
Draws an RLE encoded graphics file to the BGL's graphics buffer. Usage is identical to **bgl_draw_gfx**. To convert an image to RLE, use **convert.py** the same way as before, but use the option **--rle**. It's advisable to use a different file extension (such as .rle) to make it easier to identify an RLE encoded file. Using RLE offers a significant reduction in file size, but can be slower to draw.

## bgl_draw_gfx_rle_fast
Identical to **bgl_draw_gfx_rle**, but removes **bgl_flip** and skips all the edge checks to increase speed. It draws graphics... rle fast.

## bgl_draw_full_gfx
Draws a full-screen graphics file to the BGL's graphics buffer. The only required parameter is **bgl_buffer_offset**. This command is unsuitable for .com files because a full-screen graphic uses up 64kb, which spans the entire memory. Therefore, it hasn't been tested, but should work just fine.

## bgl_draw_full_gfx_rle
Draws an RLE encoded full-screen graphics file to the BGL's graphics buffer. Usage is identical to **bgl_draw_full_gfx**, only this time, you can actually fit backgrounds in a .com file, making this the preferred option for drawing backgrounds.

## bgl_draw_full_gfx_pal
Draws an RLE encoded full-screen graphics file to the BGL's graphics buffer, using a different format that contains its own palette. This replaces the existing palette, but as a result, provides a much higher colour depth.

## bgl_flood_fill
Fills the entirety of the BGL's graphics buffer with a colour specified by **al**. Useful as a "clear screen" command for clearing up previously drawn graphics. Specify the start offset using **di**, and the end offset using **cx**.

## bgl_flood_fill2
Fills a portion of the BGL's graphics buffer with a colour specified by **al**, where **di** is the start offset \* 2, and **cx** is the amount of pixels \* 2.

## bgl_flood_fill_fast
Identical to **bgl_flood_fill**, but writes 2 bytes at a time instead. This is the safest bet, as it's a good balance between speed and stability.

## bgl_flood_fill_full
Fills the entire graphics buffer with a single colour, specified by **al**. This writes 4 bytes at a time, so it's extremely fast, but can interfere with other functions.

## bgl_draw_box
Draws a rectangle to the graphics buffer, with **al** specifying the colour. Parameters are passed using the following memory locations:

- **bgl_x_pos** - X position to draw the box (word)
- **bgl_y_pos** - Y position to draw the box (word)
- **bgl_width** - The width of the box (byte)
- **bgl_height** - The height of the box (byte)

## bgl_draw_chunky_pixel
Draws a 2x2 block on the screen at offset **di**, using colour **al**. Used internally for the collision debugging feature, but could be useful on its own!

## bgl_draw_box_fast
Identical to **bgl_draw_box**, but skips all boundary checks, and treats the width and height as multiples of 4 (for example, 0-3 will draw 4 pixels, 4-7 will draw 8, etc). Support for **bgl_mask** is also removed.

## bgl_blaster_visualize
If you're using the Sound Blaster library, this draws a visualization of the sound to the BGL's buffer, similar to an oscilloscope. The library is automatically detected, as is the sample rate. The colour to use is specified by **al**.

# Fonts

## bgl_draw_font_string
Draws a string to the BGL's graphics buffer using a custom graphics font. The graphic for each letter/number must be the exact same size, and have the same width and height. The graphics start from ASCII character 33, so they *must* be in order. See "font.asm" for an example, and check out an ASCII table chart for more details.

- **bgl_font_string_offset** - The offset of the zero terminated string to draw. All letters must be uppercase. (word)
- **bgl_font_offset** - The offset of the font graphics. (word)
- **bgl_font_size** - The width/height of each character. (byte)
-	**bgl_font_spacing** - How many pixels between each character. (byte)

Because this subroutine uses **bgl_draw_gfx**, all the same parameters apply. For example, to set the drawing position of a string, set **bgl_x_pos** and **bgl_y_pos**. If you're running out of space, it's possible to remove characters starting from the beginning by defining a constant value, using this formula:

```(character width*character height+2)*characters to remove```

Then, subtract this from any instance of **bgl_font_offset**, **bgl_get_font_offset** and **bgl_get_font_number_offset**.

## bgl_draw_font_number
Draws a number specified in **eax** to the BGL's graphic buffer using a custom graphics font, with leading zeroes. Use **cx** to specify how many digits to draw. It uses all the same parameters as **bgl_draw_font_string**, apart from **bgl_font_string_offset**.

## bgl_get_font_number_offset
A quick and easy function for getting the font offset of a single digit. Put the digit in **ax**, and the font label in **bx**, and it'll return the offset back in **ax**. This is also available for use as a macro, used similarly to **bgl_get_font_offset** - this function just exists if you want to use registers!
## bgl_get_font_offset(a,b)
A *macro* for getting the font offset of a single letter, substituting **a** with the required letter (uppercase or lowercase), and **b** with the label offset of the font.

# Buffer/Pixels

## bgl_write_buffer
Writes the contents of the BGL's graphics buffer to the screen, 4 bytes at a time.

## bgl_write_buffer_fast
Same as **bgl_write_buffer**, but uses a different method that significantly improves performance. However, it can interfere with the BGL's key handler, amongst other things.

## bgl_pseudo_fade
Slowly reveals the contents of the BGL's graphics buffer in vertical strips, going from left to right, back to the left again. Use this before **bgl_write_buffer** so the screen doesn't contain the same as the buffer!

## bgl_get_gfx_pixel
Gets the value of a graphic's pixel at location **cx**, **dx**, and puts the result into **al**. The graphic offset is decided by **bgl_buffer_offset**.

## bgl_get_buffer_pixel
Identical to **bgl_get_gfx_pixel**, but grabs a pixel from the graphics buffer instead. **bgl_buffer_offset** isn't required here.

# Palette
## bgl_fade_in
Fades the palette in from black.
## bgl_fade_out
Fades the palette out to black.
## bgl_get_orig_palette
Puts the current VGA colour palette into the VGA's temporary storage. This is required for all palette-related functions!
## bgl_restore_orig_palette
Restores the colours from the VGA's temporary storage back into the current palette.
## bgl_fill_temp_palette
Copies the contents of the VGA's temporary storage to the BGL's own buffer.
## bgl_clear_temp_palette
Clears the contents of the BGL's palette buffer.

# Collision
## bgl_collision_check
Performs a simple box check between two sprites. Parameters are passed using the following memory locations:
- **bgl_collision_x1** - X position of the first sprite (word)
- **bgl_collision_y1** - Y position of the first sprite (word)
- **bgl_collision_w1** - Width of the first sprite (word)
- **bgl_collision_h1** - Height of the first sprite (word)
- **bgl_collision_x2** - X position of the second sprite (word)
- **bgl_collision_y2** - Y position of the second sprite (word)
- **bgl_collision_w2** - Width of the second sprite (word)
- **bgl_collision_h2** - Height of the second sprite (word)
- **bgl_collision_debug** - If set, this will draw points representing each of the collision boxes (byte)
- **bgl_collision_c1** - The colour of the first collision box (byte)
- **bgl_collision_c2** - The colour of the second collision box (byte)

If the two boxes intersect, the byte **bgl_collision_flag** will be set to 1, otherwise it'll be set to 0.

## bgl_point_collision_check
Checks if a single point is inside a sprite, useful for checking against the mouse position. Parameters are passed using the following memory locations:
- **bgl_collision_x1** - X position of the sprite (word)
- **bgl_collision_y1** - Y position of the sprite (word)
- **bgl_collision_w1** - Width of the sprite (word)
- **bgl_collision_h1** - Height of the sprite (word)
- **bgl_collision_x2** - X position of the point (word)
- **bgl_collision_y2** - Y position of the point (word)
- **bgl_collision_w2** - Unused
- **bgl_collision_h2** - Unused
- **bgl_collision_debug** - If set, this will draw points representing the collision box and the collision point (byte)
- **bgl_collision_c1** - The colour of the collision box (byte)
- **bgl_collision_c2** - The colour of the collision point (byte)

If the point is anywhere inside the sprite, the byte **bgl_collision_flag** will be set to 1, otherwise it'll be set to 0.

# Keys
## bgl_get_orig_key_handler
Gets the location of the default key handler for later retrieval.
## bgl_restore_orig_key_handler
Restores the default key handler. **bgl_get_orig_key_handler** must be used before this.
## bgl_replace_key_handler
Replaces the default key handler with the BGL's custom one, while getting the original key handler for later retrieval. The BGL's key handler allows for multiple key presses to be detected at once, and gives each key its own on/off state. To get the state of a key, offset **bgl_key_states** by the scan code value of the key you want to check.
## bgl_escape_exit
Checks if the escape key is pressed, and if so, exits the program. Only functional if **bgl_replace_key_handler** is used prior.
## bgl_escape_exit_fade
Identical to **bgl_escape_exit**, but it fades out before exiting.

# Utility
## bgl_wait_retrace
Wait for the graphical retrace period to finish. Put this before **bgl_write_buffer** or else tearing will occur!
## bgl_init
Gets the BGL's graphical capabilities ready for use by setting the graphics mode, "allocating" memory for the graphics buffer, pointing **fs** to the VGA buffer, pointing **es** to the BGL's graphics buffer, replacing the key handler, and clearing the contents of the BGL's buffer. If you want to draw directly to the VGA buffer, point **es** to **fs**.
## bgl_init_seg
Identical to **bgl_init**, but allocates memory using BIOS functions instead, for use in .exe files.
## bgl_error
If something bad has bappened, call this function, and it'll halt the program and show the states of registers **ax**-**dx**.
## bgl_write_hex_byte/bgl_write_hex_digit
Writes a hex value in text mode. Used in the error handler.
## bgl_joypad_handler
Put this in your main loop to add 2-player joypad support to your program. The joypad states for each player are held in memory locations **bgl_joypad_states_1** and **bgl_joypad_states_2** as single bytes containing binary states. Use bit testing to get the state of a certain button. Bits 0-3 are up, down, left and right, and bits 4 and 5 are buttons 1 and 2 respectively. The last 2 are unused. Please note that support for the second joypad is very buggy!

# Maths
## bgl_get_sine
Finds the sine of value **ax** using a lookup table, and puts the result into **ax**.
## bgl_get_cosine
Finds the cosine of value **ax** using a lookup table, and puts the result into **ax**.
## bgl_square
Finds the square of value **eax**, and puts the result into **eax**. Used internally for **bgl_draw_gfx_scale**, but can be used elsewhere!
## bgl_spread_8_16/bgl_spread_16_32/bgl_spread_8_32
"Spreads" a value across register **al**, **ax** or **eax**. For example, if **bgl_spread_8_16** is used and **al** contains 12h, **ax** will contain 1212h. If **bgl_spread_16_32** and **ax** contains 1234h, **eax** will contain 12341234h. This is used for drawing multiple of the same index using different word lengths.
## bgl_extend_8_16/bgl_extend_16_32/bgl_extend_8_32
Sign extends a value in register **al**, **ax** or **eax**. For example, this can be used when you have a negative 8-bit value, and need to use it with a 16-bit register. In this case **al** will contain the original value, and **ax** wil contain the result.

# Miscellaneous
## bgl_intro
Draws a full-screen RLE-encoded graphic to the buffer, fades in, waits for a few frames, and fades out again. This can be used as an "intro" to your game or program. Specify the offset for the graphic using **bgl_buffer_offset**. BGL has its own funny intro graphic (bgl_intro.rle) which can be used!

# %defines
Certain features of the BGL can be disabled to save space. To do so, define one of these at the beginning of your code:
* bgl_no_rle
* bgl_no_font
* bgl_no_collision
* bgl_no_keys
* bgl_no_scale
* bgl_no_rotate
* bgl_no_wave
* bgl_no_palette
* bgl_no_joypad
