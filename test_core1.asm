.data
arr1: .word 1,2,3,4,5
str:  .string "akilesh"
str2:  .string "\0"
str3:  .string "\t"
str4:  .string "\n"

.text
    li x30,20
    li x31,20
    j exit
    li x1,1
    li x2,2

    exit:
    li x31,100