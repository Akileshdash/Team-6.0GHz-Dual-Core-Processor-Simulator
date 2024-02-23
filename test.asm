.data
arr: .word 1,2,3
str1: .string "abcd"
str: .string "  "
str2: .string "ab\ncd"

.text
la x2,arr
li x3,100
sw x3,0(x2)