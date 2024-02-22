.text

li x1,1
blt x0,x1,one
bne x0,x1,zero

one:
    mv x0,x1

zero:
    mv x1,x0
    bne x0,x1,one