.text
LI X1,1
LI X2,2
LI X3,3
LI X4,4
LI X5,5
BNE X2,X3,swap
LI X31,100
J exit

swap
    MV X6,X2
    MV X2,X3
    MV X3,X6
    MV X6,X0

exit : 
    LI X0,100