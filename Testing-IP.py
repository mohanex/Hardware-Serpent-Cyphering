from serpent_alg import * 

val1 = input("enter hex value to Permutate : ")

valout = IP(hexstring2bitstring(val1))


print(bitstring2hexstring(valout))
