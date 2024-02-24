#Bubble Sort
.data
array:  .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1   # Array to be sorted
str3: .string "\\n"
str4: .string " "
size:   .word 20                # Size of the array

.text

#Initializing Code
#x20 is the pointer to the start of array
lw x23,size     #contains the size of array
la x20,array

#Storing final end of array in x21
addi x21,x23,-2
slli x21,x21,2
add x21,x20,x21

#x5 is the pointer to each element in the array 
mv x5,x20

# initialize i variable to x12
# i ranges from 0 to 19,i = 0, considering x0
li x12,0
# increasing i till size, ie till x4
lw x4,size
addi x6,x4,1
#############################
#Print Code
jal x1, bubblesort

#print:
#    mv x4,x23
#    mv x5,x20
#    jal x3,print1
#    jalr x2
   
#print1:
#    addi x4,x4,-1
#    li a7,1
#    lw a0,0(x5)
#    addi x5,x5,4
#    ecall
#    li a7,4
#    la a0,str4
#    ecall
#    bne x4,x0,print1
#    li a7,4
#    la a0,str3
#    ecall
#    jalr x3
  
swap:
    #temp variable is x14
    sw x10,4(x13)
    sw x11,0(x13)
    j j_increment
    
j_increment:  
    addi x13,x13,4
    j check
    
check:
    lw x10,0(x13)
    lw x11,4(x13)
    bgt x13,x21, bubblesort
    bgt x10,x11, swap
    blt x13,x21 j_increment
    j bubblesort
    
bubblesort:
    #reinitiating pointer to start of array
    mv x5,x20
    beq x12,x23,exit
    addi x12,x12,1
    # initialize j variable to x13,j ranges from 0 to n-2
    mv x13,x20
    j check
 
exit:
    li x31,100