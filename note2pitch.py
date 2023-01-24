import sys
import os

# all pitches found by ear using "pitch.asm"
pitch_values=[
    ["c1", "478b"],
    ["c#1", "4494"],
    ["d1", "4034"],
    ["d#1", "3ca9"],
    ["e1", "38da"],
    ["f1", "3613"],
    ["f#1", "334a"],
    ["g1", "2fc0"],
    ["g#1", "3db3"],
    ["a1", "2b46"],
    ["a#1", "284b"],
    ["b1", "2606"],
    ["c2", "23d0"],
    ["c#2", "218d"],
    ["d2", "1fc4"],
    ["d#2", "1e20"],
    ["e2", "1c8b"],
    ["f2", "1aad"],
    ["f#2", "193d"],
    ["g2", "17b0"],
    ["g#2", "1674"],
    ["a2", "154a"],
    ["a#2", "13ff"],
    ["b2", "130d"],
    ["c3", "11c7"],
    ["c#3", "10b9"],
    ["d3", "1000"],
    ["d#3", "f14"],
    ["e3", "e4f"],
    ["f3", "d6a"],
    ["f#3", "cb3"],
    ["g3", "bed"],
    ["g#3", "b5b"],
    ["a3", "a90"],
    ["a#3", "a00"],
    ["b3", "990"],
    ["c4", "904"],
    ["c#4", "877"],
    ["d4", "7f0"],
    ["d#4", "792"],
    ["e4", "719"],
    ["f4", "6ae"],
    ["f#4", "65d"],
    ["g4", "600"],
    ["g#4", "5a9"],
    ["a4", "549"],
    ["a#4", "50a"],
    ["b4", "4be"],
    ["c5", "46e"]
]

for a in range(0,len(pitch_values)):
    if len(pitch_values[a][1])==3:
        pitch_values[a][1]="0"+pitch_values[a][1]
    pitch_values[a][1]+="h"

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    file_finished="song: dw "
    file_pitch_values=[]
    if os.path.exists(file_name):
        with open(file_name,"r") as file:
            notes=file.readline().split(" ")
        for note in notes:
            for pitch in pitch_values:
                if note==pitch[0]:
                    file_pitch_values.append(pitch[1])
            if note=="off":
                file_pitch_values.append("3")
            if note=="end":
                file_pitch_values.append("0")
            if note=="loop":
                file_pitch_values.append("1")
        file_finished+=",".join(file_pitch_values)
        with open(output_file,"w") as file:
            file.write(file_finished)
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")