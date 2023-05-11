import sys
import os

if len(sys.argv)>2:
    file_name=sys.argv[1]
    output_file=sys.argv[2]
    if os.path.exists(file_name):
        input_data=[]
        with open(file_name,"r") as file:
            input_data=file.readlines()
        input_data=input_data[1:]
        
        track_amount=len(input_data[0].split("|")[1:])
        length=len(input_data)
        tracks=[]
        for a in range(0,track_amount):
            tracks.append([])
        last_note=[]
        for a in range(0,track_amount):
            last_note.append([""])
        for line in input_data:
            if "\n" in line:
                line=line[:-1].strip("\n")
            line_split=line.split("|")[1:]
            for track in range(0,track_amount):
                commands=[]
                note=line_split[track][0:3]
                note_name=""
                note_on=False
                # command order:
                # track number (only used in this program), note on/off, note number, velocity
                # track 10 or above is assumed to be drums (because each channel is monophonic, so that's to get around it!)
                # not relevant for this program, but essential to know
                track_temp=track
                if track>9:
                    track_temp=9
                if note=="...":
                    commands.append(0)
                    commands.append(0)
                elif note!="^^^":
                    note=note[:2]+str(int(note[-1:])-1)
                    note_name=note.lower().replace("-","_").replace("#","_sharp_")
                    commands.append(0x90+track_temp)
                    commands.append(note_name)
                    note_on=True
                    last_note[track]=note_name
                if note=="^^^":
                    commands.append(0x80+track_temp)
                    commands.append(last_note[track])
                volume=line_split[track][6:8]
                if volume=="..":
                    if note_on:
                        commands.append(127)
                    else:
                        commands.append(0)
                else:
                    commands.append((int(volume)*2)-1)
                #instrument=line_split[track][3:5]
                
                tracks[track].append(commands)
        
        tracks_sorted=[]
        for track in tracks:
            blank=True
            for set in track:
                if set!=[0,0,0]:
                    blank=False
            if not blank:
                tracks_sorted.append(track)
        label_start=file_name.split(".")[0].replace(" ","_")
        file_finished=label_start + "_play:\n"
        file_finished+="\tmov byte [midi_tracks]," + str(len(tracks_sorted)-1) + "\n"
        for a in range(0,len(tracks_sorted)):
            if a==0:
                file_finished+="\tmov word [midi_track_offset],"
            else:
                file_finished+="\tmov word [midi_track_offset+" + str(a*2) + "],"
            file_finished+=label_start + "_track_" + str(a+1) + "\n"
        file_finished+="\tmov word [midi_length]," + label_start + "_length\n\tcall midi_play_song\n\tret\n\n"
    
        file_finished+=label_start + "_length equ " + str(length) + "\n"
        for counter,track in enumerate(tracks_sorted):
            track_string=label_start + "_track_" + str(counter+1) + ": db "
            for set in range(0,len(track)):
                for command in range(0,3):
                    track_string+=str(track[set][command]) + ","
            file_finished+=track_string[:-1]+"\n"
                
        with open(output_file,"w") as file:
            file.write(file_finished)
    else:
        print("File \"" + file_name + "\" doesn't exist!")
else:
    print("Input and output name required!")