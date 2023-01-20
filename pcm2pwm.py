import sys
import os

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        with open(file_name,"rb") as file:
            file_orig=file.read()
            
        file_quantized=[]
        byte_high=False
        byte_low_value=120
        byte_high_value=255-byte_low_value
        counter=8
        binary_value=0b10000000

        for byte in file_orig:
            if byte>byte_high_value or byte<byte_low_value:
                if byte>byte_high_value:
                    byte_high=True
                if byte<byte_low_value:
                    byte_high=False
            counter-=1
            if byte_high:
                binary_value=binary_value|(1<<counter)
            else:
                binary_value=binary_value&~(1<<counter)
            if counter==0:
                file_quantized.append(binary_value)
                counter=8
                binary_value=0
                binary_mask=0b10000000
            
        with open(output_file,"wb") as file:
            file.write(bytearray(file_quantized))