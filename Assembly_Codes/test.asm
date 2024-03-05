.text
li x1,3
li x2,10
jal x10,loop
loop:
addi x3,x3,1
beq x3,x2,exit
jalr x10
exit:
li x31,100



