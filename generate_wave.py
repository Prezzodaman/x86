import math

file_finished="wave_table: db "
wave_values=[]

counter=0
while counter<6.2:
    wave_values.append(int(math.sin(counter)*127))
    counter+=0.1
for value in wave_values:
    file_finished+=str(value)+","
file_finished=file_finished[:-1] + " ; length: " + str(len(wave_values))
    
with open("wave_table.asm","w") as file:
    file.write(file_finished)