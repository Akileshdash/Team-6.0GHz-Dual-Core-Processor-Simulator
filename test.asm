.data
array:  .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1   # Array to be sorted
str3: .string "\\n"
str4: .string " "
size:   .word 20                # Size of the array

.text

ADD x10,x10,x10
LI x1,5
LI x2,4
LI x3,3
LI x4,2
LI x5,1
SW x1,0(x0)
SW x2,4(x0)
SW x3,8(x0)
SW x4,12(x0)
SW x5,16(x0)

LI x23,5
LI x20,0    #j increment
LI x21,0    #i increment
LI x4,0
J outer_loop

outer_loop
    BEQ x21,x23,exit
    ADDI x21,x21,1
    MV x20,x0
    MV x4,x0
    J inner_loop

inner_loop 
    BEQ x20,x23,outer_loop
    LW x1,0(x4)
    LW x2,4(x4)
    BGT x1,x2,swap
    ADDI x20,x20,1
    ADDI x4,x4,4
    J inner_loop

swap
    SW x1,4(x4)
    SW x2,0(x4)
    ADDI x20,x20,1
    ADDI x4,x4,4
    J inner_loop

exit
