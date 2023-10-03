from serpent_alg import * 

val1 = input("enter X0 : ")
val2 = input("enter X1 : ")
val3 = input("enter X2 : ")
val4 = input("enter X3 : ")
valout = LTBitslice([val1,val2,val3,val4])
concatenated_binary = ''.join(valout)


print(bitstring2hexstring(concatenated_binary))
