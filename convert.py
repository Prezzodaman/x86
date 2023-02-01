import sys
import os
from PIL import Image

rle=False
if len(sys.argv)>2:
    if "--rle" in sys.argv:
        rle=True
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        vga_colours=[]
        with Image.open("vga.png") as image:
            for x in range(0,image.size[0]):
                vga_colours.append(image.getpixel((x,0)))
        with Image.open(file_name) as image:
            image_size=[image.size[0],image.size[1]]
            if image.size[0]>255:
                image_size[0]=255
                size_warning=True
            if image.size[1]>255:
                image_size[1]=255
                size_warning=True
            file_finished=[image_size[0],image_size[1]]
            colour_index_last=None
            rle_counter=0
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
                    if rle:
                        if colour_index_last==colour_index:
                            rle_counter+=1
                        else:
                            if colour_index_last!=None:
                                file_finished.append(colour_index_last)
                                file_finished.append(rle_counter)
                            rle_counter=1
                            colour_index_last=colour_index
                    else:
                        file_finished.append(colour_index)
                if rle: # reset the counter on every line to make it easier to draw, with a small sacrifice on file size
                    file_finished.append(colour_index_last)
                    file_finished.append(rle_counter)
                    rle_counter=0
            if rle:
                file_finished.append(colour_index_last)
                file_finished.append(rle_counter)
        with open(output_file,"bw") as file:
            file.write(bytearray(file_finished))
        print("Converted size: " + str(len(file_finished)) + " (" + hex(len(file_finished)) + ")")
        if image.size[0]>255:
            print("WARNING: Width is greater than 255!")
        if image.size[1]>255:
            print("WARNING: Height is greater than 255!")
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")