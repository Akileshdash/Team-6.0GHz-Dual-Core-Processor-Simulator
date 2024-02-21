.data
size:   .word 800
size1:   .string "\n\\\nt"
size2:   .string "abc\n"

.text
MV x4,x3
JAL x2,code
ADD x1,x1,x2
ADD x1,x1,x2
ADD x1,x1,x2

code:
    MV x1,x2