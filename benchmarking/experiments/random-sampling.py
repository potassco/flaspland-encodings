import os
import random

SAMPLE_SIZE = 7
SEED = 7
random.seed(SEED)

levels = range(0,10)
trains = {2: [3,5,6,9,10,12,17,18,20,24,33,34,36,40,48,65,66,68,72,80,96], 
		3: [7,11,13,14,19,21,22,25,26,28,35,37,38,41,42,44,49,50,52,56,67,69,70,73,74,76,81,82,84,88,97,98,100,104,112], 
		4: [15,23,27,29,30,39,43,45,46,51,53,54,57,58,60,71,75,77,78,83,85,86,89,90,92,99,101,102,105,106,108,113,114,116,120], 
		5: [31,47,55,59,61,62,79,87,91,93,94,103,107,109,110,115,117,118,121,122,124]}

for level in levels:
	print(f"Level_{level}:\n")
	
	for train in trains:
		chosen = sorted(random.sample(trains[train], k=SAMPLE_SIZE))
		[print(f"Level_{level}/{train}-" + str(format(x, '#009b')[2:]) + ".lp") for x in chosen]
		print("\n")
	print("\n")
