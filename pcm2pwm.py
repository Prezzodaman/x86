import sys
import os

if len(sys.argv)==4:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    threshold=sys.argv[3]
    if os.path.exists(file_name):
        if threshold.isdigit():
            threshold=int(threshold)
            if threshold>=0 and threshold<=255:
                with open(file_name,"rb") as file:
                    file_orig=file.read()
                    
                file_quantized=[]
                byte_high=False
                byte_low_value=threshold
                byte_high_value=255-byte_low_value
                counter=8
                binary_value=255

                for byte in file_orig:
                    if byte>byte_high_value:
                        byte_high=True
                    if byte<byte_low_value:
                        byte_high=False
                    counter-=1
                    if not byte_high:
                        binary_value=binary_value&~(1<<counter)
                    if counter==0:
                        file_quantized.append(binary_value)
                        counter=8
                        binary_value=255
                    
                with open(output_file,"wb") as file:
                    file.write(bytearray(file_quantized))
            else:
                print("Threshold must be between 0 and 255!")
        else:
            print("Threshold must be a number!")
    else:
        print("Input file doesn't exist!")
else:
    print("Input name, output name and threshold required!")