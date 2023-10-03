from serpent_alg import * 

val1 = input("enter 4bits input : ")
val2 = input("enter S-boxe number : ")

valout = S(val2, val1)


print(bitstring2hexstring(valout))