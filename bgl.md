## bgl_draw_gfx
Draws a graphics file to the BGL's graphics buffer. The maximum width and height of a graphic is 255. Parameters are passed using the following memory locations:

- **bgl_x_pos** - X position to draw the graphic at (word)
- **bgl_y_pos** - Y position to draw the graphic at (word)
- **bgl_erase** - Whether to "erase" the graphic or not, replacing all colour with the background colour while retaining transparency, useful for a "silhouette" effect (byte)
- **bgl_background_colour** - When bgl_erase is set, this is the colour to fill the graphic in with (byte)
- **bgl_opaque** - If set, the graphic will draw without transparency (byte)
- **bgl_flip** - If set, the graphic will be flipped horizontally (byte)

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

If the two sprites collide, **bgl_collision_flag** will be set to 1, otherwise it'll be set to 0. **bgl_collision_flag** is a byte.
## bgl_get_orig_key_handler
Gets the location of the default key handler for later retrieval.
## bgl_restore_orig_key_handler
Restores the default key handler. **bgl_get_orig_key_handler** must be used before this.
## bgl_replace_key_handler
Replaces the default key handler with the BGL's custom one. This allows for multiple key presses to be detected at once. To get the state of a key, offset **bgl_key_states** by the scan code value of the key you want to check.
## bgl_wait_retrace
Wait for the graphical retrace period to finish. Useful for regulating the speed.
## bgl_init
Gets the BGL's graphical capabilities ready for use by setting the graphics mode, allocating memory for the graphics buffer, and pointing **es** to the VGA buffer and **fs** to the BGL's graphics buffer.
## bgl_write_buffer
Writes the content of the BGL's graphics buffer to the screen.
## bgl_flood_fill
Fills the entirety of the BGL's graphics buffer with a colour specified by **al**. Useful as a "clear screen" command for clearing up previously drawn graphics.
