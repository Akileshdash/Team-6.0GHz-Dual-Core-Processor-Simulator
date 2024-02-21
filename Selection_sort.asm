.data
arr: .word 1,2,4096,16,256
size: .word 5
str3: .string "\n"
str4: .string "  "
.text
main:
        lw x29 size
        addi x25 x29 -1
        #get base address
        la x8, arr
        #init i
        addi x15, x0, 0
        #for loop i
Loop1:
        beq x15 ,x25 ,exit
        #init min_id
        add x16, x0, x15
        #init j
        addi x6, x15, 1
        #for loop j
Loop2:
        beq x6 ,x29,swap 
        slli x7, x6, 2
        slli x28, x16, 2
        add x5, x8, x28
        lw x31, 0(x5)
        add x5, x8, x7
        lw x30, 0(x5)
        bge x30, x31, nochange
        add x16, x0, x6
nochange:
        addi x6, x6, 1
        addi x9, x0, 5
        blt x6, x9, Loop2
swap:
        #get a[i] 
        slli x29, x15, 2
        add x5, x29, x8
        #load a[i] in x30
        lw x30, 0(x5)
        #get a[min_id]
        slli x28, x16, 2
        add x5, x28, x8
       
        lw x31, 0(x5)
        #put a[min_id] in a[i]
        add x5, x29, x8
        sw x31, 0(x5)
        #get a[min_id]
        add x5, x28, x8
        sw x30, 0(x5)
        addi x1, x0, 4
        addi x15, x15, 1
        blt x15, x1, Loop1
exit:
print:
    mv x4,x29
    mv x5,x8
    j print1
print1:
    addi x4,x4,-1
    li a7,1
    lw a0,0(x5)
    addi x5,x5,4
    ecall
    li a7,4
    la a0,str4
    ecall
    bne x4,x0,print1
    