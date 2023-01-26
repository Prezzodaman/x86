import sys
import os

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    file_finished="song: dw "
    file_pitch_values=[]
    if os.path.exists(file_name):
        with open(file_name,"r") as file:
            notes=file.readline().split(" ")
        for note in notes:
            if note=="off":
                file_pitch_values.append("3")
            elif note=="end":
                file_pitch_values.append("0")
            elif note=="loop":
                file_pitch_values.append("1")
            else:
                note=note.replace("#","_sharp_")
                file_pitch_values.append("beep_"+note)
        file_finished+=",".join(file_pitch_values)
        with open(output_file,"w") as file:
            file.write(file_finished)
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")