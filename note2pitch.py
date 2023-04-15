import sys
import os

# example usage:
# note2pitch tank1.txt tanksong.asm --twine tank2.txt

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    double=1
    twine=1
    twine_check=True
    if len(sys.argv)>3:
        if sys.argv[3]=="--double":
            double=2
        elif sys.argv[3]=="--twine":
            if len(sys.argv)<4:
                print("Other file not specified!")
                twine_check=False
            else:
                file_name_2=sys.argv[4]
                twine=2
    if twine_check:
        file_finished="song: dw "
        file_pitch_values=[]
        if os.path.exists(file_name):
            with open(file_name,"r") as file:
                notes=file.read().replace("\n"," ").split(" ")
            if twine==2:
                with open(file_name_2,"r") as file:
                    notes_2=file.read().replace("\n"," ").split(" ")
            for a in range(0,len(notes)):
                note=notes[a]
                note_2="off"
                if twine==2:
                    if a<len(notes_2):
                        note_2=notes_2[a]
                for b in range(0,double):
                    for c in range(0,twine):
                        note_current=note
                        if c==1:
                            note_current=note_2
                        if note_current=="off":
                            file_pitch_values.append("3")
                        elif note_current=="end":
                            file_pitch_values.append("0")
                        elif note_current=="loop":
                            file_pitch_values.append("1")
                        else:
                            note_current=note_current.replace("#","_sharp_")
                            file_pitch_values.append("beep_"+note_current)
            file_finished+=",".join(file_pitch_values)
            with open(output_file,"w") as file:
                file.write(file_finished)
        else:
            print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")