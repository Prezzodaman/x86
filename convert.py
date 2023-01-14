import sys
import os
from PIL import Image

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        vga_colours=[]
        with Image.open("vga.png") as image:
            for x in range(0,image.size[0]):
                vga_colours.append(image.getpixel((x,0)))
        with Image.open(file_name) as image:
            file_finished=[image.size[0],image.size[1]]
            for y in range(0,image.size[1]):
                for x in range(0,image.size[0]):
                    closest_diff=1000000
                    colour_index=0
                    orig_pixel=image.getpixel((x,y))
                    for counter,colour in enumerate(vga_colours):
                        red_diff=orig_pixel[0]-colour[0]
                        green_diff=orig_pixel[1]-colour[1]
                        blue_diff=orig_pixel[2]-colour[2]
                        overall_diff=red_diff*red_diff+green_diff*green_diff+blue_diff*blue_diff
                        if closest_diff>overall_diff:
                            closest_diff=overall_diff
                            colour_index=counter
                    file_finished.append(colour_index)
        with open(output_file,"bw") as file:
            file.write(bytearray(file_finished))
        print("Converted size: " + str(len(file_finished)) + " (" + hex(len(file_finished)) + ")")
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")