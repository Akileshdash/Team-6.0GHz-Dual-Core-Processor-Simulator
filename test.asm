.data
array:  .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1   # Array to be sorted
str3: .string "\\n"
str4: .string " "
size:   .word 20                # Size of the array

.text

#Initializing Code
#x20 is the pointer to the start of array
#lw x23,size     #contains the size of array
#la x20,array

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
#lw x4,size
addi x6,x4,1
#############################
#Print Code
jal x2, print


print:
    mv x4,x23
    mv x5,x20
    jalr x2
   