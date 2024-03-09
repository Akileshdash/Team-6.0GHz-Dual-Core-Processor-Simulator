#Selection Sort
.data 
arr: .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
size: .word 20
temp: .word 100000
.text
lw x30,temp
#Loading Address in x1
la x1,arr
#Load size in x2
lw x2,size
#pointer i in x3
mv x3,x1    #initial address
addi x3,x3,-4
#maintaining index in x7
li x7,0

outer_loop:    
    addi x3,x3,4
    beq x7,x2,exit
    li x10,0
    #Min in x5
    lw x5,temp
    lw x6,0(x3)
    addi x7,x7,1
    mv x9,x7
    #find smallest after x3
    #pointer j in x4    
    mv x4,x3
    jal x31,smallest_to_swap
    
smallest_to_swap:
    beq x9,x2,swap
    addi x4,x4,4
    lw x8,0(x4)
    blt x8,x5,update_min_1
    addi x9,x9,1
    j smallest_to_swap
    

update_min_1:
    blt x8,x6,update_min
    addi x9,x9,1
    j smallest_to_swap
    
update_min:
    mv x5,x8
    mv x10,x4
    addi x9,x9,1
    j smallest_to_swap
    
swap:
    beq x5,x30,outer_loop
    sw x5,0(x3)
    sw x6,0(x10)
    j outer_loop

exit:
    li x31,100