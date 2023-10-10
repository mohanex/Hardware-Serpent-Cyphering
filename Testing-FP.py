from serpent_alg import * 

val2 = input("enter hex value to Permutate : ")

valout = FP(hexstring2bitstring(val2))

print(bitstring2hexstring(valout))