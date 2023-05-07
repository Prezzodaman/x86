## bgl_draw_gfx
Draws a graphics file to the BGL's graphics buffer. The maximum width and height of a graphic is 255. Parameters are passed using the following memory locations:

- **bgl_x_pos** - X position to draw the graphic at (word)
- **bgl_y_pos** - Y position to draw the graphic at (word)
- **bgl_erase** - Whether to "erase" the graphic or not, replacing all colour with the background colour while retaining transparency, useful for a "silhouette" effect (byte)
- **bgl_background_colour** - When bgl_erase is set, this is the colour to fill the graphic in with (byte)
- **bgl_opaque** - If set, the graphic will draw without transparency (byte)
- **bgl_flip** - If set, the graphic will be flipped horizontally (byte)
- **bgl_no_bounds** - If set, edge clipping will be disabled, speeding things up (byte)
- **bgl_tint** - Adds or subtracts from the colour index of each pixel, leaving the background unchanged (byte)

To convert an image to a .gfx file compatible with BGL, run **convert.py**, specifying the input file and output file. Only 24-bit PNGs are supported right now. It's best to use RLE instead, unless your graphic has lots of unique pixels, or needs to be scaled or rotated.

## bgl_draw_gfx_fast
Identical to **bgl_draw_gfx**, but optimized for speed. Because of this, **bgl_flip** isn't supported, and there's no edge clipping, so graphics will still be visible if drawn outside the screen. However, it's at least 2x faster than **bgl_draw_gfx**!

## bgl_draw_gfx_scale
Draws a *scaled* graphic to the BGL's buffer!! Uses all the same parameters as **bgl_draw_gfx**, with the addition of dwords **bgl_scale_x** and **bgl_scale_y** which allow you to scale the width and height independently. Higher values make the graphic smaller, and negative values make it bigger. The largest positive scale value is 32. To scale from the centre point instead of the top-left corner, set **bgl_scale_centre** to 1. To make the scaling linear, set **bgl_scale_square** to 1; this is optional to maintain backwards compatibility.

## bgl_draw_gfx_rotate
Draws a *rotated* graphic to the BGL's buffer!! Uses all the same parameters as **bgl_draw_gfx**, with the addition of the word **bgl_rotate_angle** which determines the rotation angle in degrees. It supports all parameters apart from **bgl_flip**. There's an odd behaviour where going from 0 to -1 results in a little jitter, but just offset your rotation value by a multiple of 360, and you're all good.

## bgl_draw_gfx_rle
Draws an RLE encoded graphics file to the BGL's graphics buffer. Usage is identical to **bgl_draw_gfx**. To convert an image to RLE, use **convert.py** the same way as before, but use the option **--rle**. It's advisable to use a different file extension (such as .rle) to make it easier to identify an RLE encoded file. Using RLE offers a significant reduction in file size, but can be slower to draw.

## bgl_draw_gfx_rle_fast
Identical to **bgl_draw_gfx_rle**, but removes **bgl_flip** and skips all the edge checks to increase speed. It draws graphics... rle fast.

## bgl_draw_full_gfx
Draws a full-screen graphics file to the BGL's graphics buffer. The only required parameter is **bgl_buffer_offset**. This command is unsuitable for .com files because a full-screen graphic uses up 64k, which spans the entire memory. Therefore, it hasn't been tested, but should work just fine.

## bgl_draw_full_gfx_rle
Draws an RLE encoded full-screen graphics file to the BGL's graphics buffer. Usage is identical to **bgl_draw_full_gfx**, only this time, you can actually fit backgrounds in a .com file, making this the preferred option for drawing backgrounds.

## bgl_draw_full_gfx_pal
Draws an RLE encoded full-screen graphics file to the BGL's graphics buffer, using a different format that contains its own palette. This replaces the existing palette, but as a result, provides a much higher colour depth.

## bgl_get_gfx_pixel
Gets the value of a graphic's pixel at location **cx**, **dx**, and puts the result into **al**. The graphic offset is decided by **bgl_buffer_offset**.

## bgl_get_buffer_pixel
Identical to **bgl_get_gfx_pixel**, but grabs a pixel from the graphics buffer instead. **bgl_buffer_offset** isn't required here.

## bgl_draw_font_string
Draws a string to the BGL's graphics buffer using a custom graphics font. The graphic for each letter/number must be the exact same size, and have the same width and height. The graphics start from ASCII character 33, so they *must* be in order. See "font.asm" for an example, and check out an ASCII table chart for more details.

- **bgl_font_string_offset** - The offset of the zero terminated string to draw. All letters must be uppercase. (word)
- **bgl_font_offset** - The offset of the font graphics. (word)
- **bgl_font_size** - The width/height of each character. (byte)
-	**bgl_font_spacing** - How many pixels between each character. (byte)

Because this subroutine uses **bgl_draw_gfx**, all the same parameters apply. For example, to set the drawing position of a string, set **bgl_x_pos** and **bgl_y_pos**.

## bgl_draw_font_number
Draws a number specified in **eax** to the BGL's graphic buffer using a custom graphics font, with leading zeroes. Use **cx** to specify how many digits to draw. It uses all the same parameters as **bgl_draw_font_string**, apart from **bgl_font_string_offset**.

## bgl_pseudo_fade
Slowly reveals the contents of the BGL's graphics buffer in vertical strips, going from left to right, back to the left again. Use this before **bgl_write_buffer** so the screen doesn't contain the same as the buffer!

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

If the point is anywhere inside the sprite, the byte **bgl_collision_flag** will be set to 1, otherwise it'll be set to 0.
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
## bgl_wait_retrace
Wait for the graphical retrace period to finish. Put this before **bgl_write_buffer** or else tearing will occur!
## bgl_init
Gets the BGL's graphical capabilities ready for use by setting the graphics mode, "allocating" memory for the graphics buffer, pointing **fs** to the VGA buffer, pointing **es** to the BGL's graphics buffer, replacing the key handler, and clearing the contents of the BGL's buffer. If you want to draw directly to the VGA buffer, point **es** to **fs**.
## bgl_write_buffer
Writes the content of the BGL's graphics buffer to the screen.
## bgl_write_buffer_fast
Same as **bgl_write_buffer**, but uses a different method that significantly improves performance. However, it can interfere with the BGL's key handler.
## bgl_flood_fill
Fills the entirety of the BGL's graphics buffer with a colour specified by **al**. Useful as a "clear screen" command for clearing up previously drawn graphics. Specify the start offset using **di**, and the end offset using **cx**.
## bgl_flood_fill_fast
Identical to **bgl_flood_fill**, but writes 2 bytes at a time instead.
## bgl_flood_fill_full
Fills the entire graphics buffer with a single colour, specified by **al**. This writes 4 bytes at a time, so it's extremely fast.
## bgl_error
If something bad has bappened, call this function, and it'll halt the program and show the states of registers **ax**-**dx**.
## bgl_get_font_number_offset
A quick and easy function for getting the font offset of a single digit. Put the digit in **ax**, and the font label in **bx**, and it'll return the offset back in **ax**. This is also available for use as a macro, used similarly to **bgl_get_font_offset** - this function just exists if you want to use registers!
## bgl_get_font_offset(a,b)
A *macro* for getting the font offset of a single letter, substituting **a** with the required letter (uppercase or lowercase), and **b** with the label offset of the font.
## bgl_joypad_handler
Put this in your main loop to add 2-player joypad support to your program. The joypad states for each player are held in memory locations **bgl_joypad_states_1** and **bgl_joypad_states_2** as single bytes containing binary states. Use bit testing to get the state of a certain button. Bits 0-3 are up, down, left and right, and bits 4 and 5 are buttons 1 and 2 respectively. The last 2 are unused. Please note that while a second joypad is supported, functionality hasn't been tested!
## bgl_fade_in
Fades the palette in from black. It looks a bit weird, but it probably won't get fixed because fading's here anyway!
## bgl_fade_out
Fades the palette out to black.
## bgl_get_orig_palette
Puts the current VGA colour palette into the VGA's temporary storage. This is required for all palette-related functions!
## bgl_restore_orig_palette
Restores the colours from the VGA's temporary storage back into the current palette.
## bgl_intro
Draws a full-screen RLE-encoded graphic to the buffer, fades in, waits for a few frames, and fades out again. This can be used as an "intro" to your game or program. Specify the offset for the graphic using **bgl_buffer_offset**. BGL has its own funny intro graphic which can be used!
## bgl_get_sine
Finds the sine of value **ax** using a lookup table, and puts the result into **ax**.
## bgl_get_cosine
Finds the cosine of value **ax** using a lookup table, and puts the result into **ax**.
## bgl_square
Finds the square of value **eax**, and puts the result into **eax**. Used internally for **bgl_draw_gfx_scale**, but can be used elsewhere!
