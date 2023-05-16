import sys
import os

if len(sys.argv)>1:
    file_name=sys.argv[1]
    if os.path.exists(file_name):
        input_lines=[]
        output_file=""
        with open(file_name,"r") as file:
            input_lines=file.readlines()
            
        for line in input_lines:
            if not "lib/" in line:
                line=line.replace("blaster.asm","lib/blaster.asm")
                line=line.replace("bgl.asm","lib/bgl.asm")
                line=line.replace("beeplib.asm","lib/beeplib.asm")
                line=line.replace("timer.asm","lib/timer.asm")
                line=line.replace("midi.asm","lib/midi.asm")
                line=line.replace("random.asm","lib/random.asm")
                line=line.replace("general.asm","lib/general.asm")
            output_file+=line
            
        with open("temp.asm","w") as file:
            file.write(output_file)
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Please specify input file!")