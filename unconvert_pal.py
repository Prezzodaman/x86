import sys
from PIL import Image

if len(sys.argv)>2:
    input=sys.argv[1]
    output=sys.argv[2]
    
    input_data=bytearray()
    palette=[]
    with open(input,"br") as file:
        input_data=file.read()
    for a in range(0,768):
        palette.append(input_data[a]<<2)
    converted_image=Image.new("P",(320,200))
    converted_image.putpalette(palette)
    
    x=0
    y=0
    rle_byte=0
    rle_amount=0
    for a in range(768,len(input_data),2):
        rle_byte=input_data[a]
        rle_amount=input_data[a+1]
        for a in range(0,rle_amount):
            converted_image.putpixel((x,y),rle_byte)
            x+=1
            if x==320:
                x=0
                y+=1
    converted_image.save(output)