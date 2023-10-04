from serpent_alg import * 

val1 = input("enter 256bit key : ")

valout = makeSubkeys(val1)

for i in range(len(valout)):
    print(valout[i])