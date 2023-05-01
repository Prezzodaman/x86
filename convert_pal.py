import sys
import os
from PIL import Image

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        with Image.open(file_name) as image:
            image_size=[image.size[0],image.size[1]]
            palette=[]
            palette_reduced=[]
            palette_reduced_tuple=[]
            file_finished=[]
            for y in range(0,image.size[1]):
                for x in range(0,image.size[0]):
                    pixel=image.getpixel((x,y))
                    palette.append([pixel[0],pixel[1],pixel[2]])
            palette.sort()
            for a in range(0,len(palette),252):
                palette_reduced.append(palette[a][0])
                file_finished.append(palette[a][0]>>2)
                palette_reduced.append(palette[a][1])
                file_finished.append(palette[a][1]>>2)
                palette_reduced.append(palette[a][2])
                file_finished.append(palette[a][2]>>2)
                palette_reduced_tuple.append((palette[a][0],palette[a][1],palette[a][2]))
            for a in range(0,2):
                file_finished.append(255)
                file_finished.append(255)
                file_finished.append(255)
            palette_image=Image.new("P",(1,1))
            palette_image.putpalette(palette_reduced)
            image=image.quantize(palette=palette_image,dither=Image.Dither.NONE)
            image=image.convert("RGB")
            colour_index_last=None
            rle_counter=0
            for y in range(0,image.size[1]):
                for x in range(0,image.size[0]):
                    closest_diff=1000000
                    colour_index=0
                    orig_pixel=image.getpixel((x,y))
                    for counter,colour in enumerate(palette_reduced_tuple):
                        red_diff=orig_pixel[0]-colour[0]
                        green_diff=orig_pixel[1]-colour[1]
                        blue_diff=orig_pixel[2]-colour[2]
                        overall_diff=red_diff*red_diff+green_diff*green_diff+blue_diff*blue_diff
                        if closest_diff>overall_diff:
                            closest_diff=overall_diff
                            colour_index=counter
                    if colour_index_last==colour_index:
                        rle_counter+=1
                        if rle_counter==255:
                            file_finished.append(colour_index_last)
                            file_finished.append(rle_counter)
                            rle_counter=0
                    else:
                        if colour_index_last!=None:
                            file_finished.append(colour_index_last)
                            file_finished.append(rle_counter)
                        rle_counter=1
                        colour_index_last=colour_index
            file_finished.append(colour_index_last)
            file_finished.append(rle_counter)
        with open(output_file,"bw") as file:
            file.write(bytearray(file_finished))
        print("Converted file \"" + file_name + "\"! Size: " + str(len(file_finished)) + " (" + hex(len(file_finished)) + ")")
        if len(file_finished)>64000:
            print("WARNING: File is too big to fit into a .com file!")
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")