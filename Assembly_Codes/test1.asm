.data 
arr: .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
size: .word 20
temp: .word 100000

.text
lw x30,temp             #1
la x1,arr               #2
lw x2,size              #3
mv x3,x1                #4
addi x3,x3,-4           #5
li x7,0                 #6

outer_loop:    
    addi x3,x3,4        #7
    beq x7,x2,exit      #8
    li x10,0            #9
    lw x5,temp          #10
    lw x6,0(x3)         #11
    addi x7,x7,1        #12
    mv x9,x7            #13
    mv x4,x3            #14
    jal x31,smallest_to_swap        #15
    
smallest_to_swap:
    beq x9,x2,swap      #16
    addi x4,x4,4        #17
    lw x8,0(x4)         #18
    blt x8,x5,update_min_1          #19
    addi x9,x9,1        #20
    j smallest_to_swap  #21
    

update_min_1:
    blt x8,x6,update_min#22
    addi x9,x9,1        #23
    j smallest_to_swap  #24
    
update_min:
    mv x5,x8            #25
    mv x10,x4           #26
    addi x9,x9,1        #27
    j smallest_to_swap  #28
    
swap:
    beq x5,x30,outer_loop#29
    sw x5,0(x3)         #30
    sw x6,0(x10)        #31
    j outer_loop        #32

exit:
    li x31,100          #33