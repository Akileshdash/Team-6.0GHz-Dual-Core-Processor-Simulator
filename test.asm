.data
str: .string "Addition: "
str1: .string " \n"
str2: .string "Subtraction: "

.text
MV X31,X2
SW X2,8(X0)

Label: 
    ADD X10,X5,X6