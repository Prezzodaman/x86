import sys
import os

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        with open(file_name,"rb") as file:
            file_orig=file.read()
            
        file_finished=[]
        byte_high=False

        for byte in file_orig:
            byte_bin=bin(byte)[2:]
            if len(byte_bin)<8:
                zeroes=""
                for a in range(0,8-len(byte_bin)):
                    zeroes+="0"
                byte_bin=zeroes+byte_bin
            for bit in byte_bin:
                file_finished.append(int(bit)*255)
            
        with open(output_file,"wb") as file:
            file.write(bytearray(file_finished))
    else:
        print("Input file doesn't exist!")
else:
    print("Input name and output name required!")