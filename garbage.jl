n = 10
array_2d = fill("0", n, n)

stage_array = ["IF", "ID/RF", "EX", "MEM", "WB"]


# for i in 1:n
#     for j in 1:n
#         print(array_2d[i, j], "\t")
#     end
#     println()
# end

# println("-------------------------------------------------------")

for i in 1:n
    for j in 1:i-1
        array_2d[i, j] = "-1"
    end
    
    for j in i:i+4
        if j > n
            break
        end
        array_2d[i, j] = string(j - i + 1)
    end
end


for i in 1:n
    for j in 1:n
        if array_2d[i, j] == "1"
            array_2d[i, j] = "IF"
        end

        if array_2d[i, j] == "2"
            array_2d[i, j] = "ID/RF"
        end

        if array_2d[i, j] == "3"
            array_2d[i, j] = "EX"
        end

        if array_2d[i, j] == "4"
            array_2d[i, j] = "MEM"
        end

        if array_2d[i, j] == "5"
            array_2d[i, j] = "WB"
        end
    end
    # println()
end



function print_2d(array_2d::Matrix{String})
    for i in 1:n
        for j in 1:n
            print(array_2d[i, j], "\t")
        end
        println()
    end
end

print_2d(array_2d)


#############################################################


# while processor.cores[1].pc<=length(processor.cores[1].program)
#     processor.clock+=1
#     row = 1

#     focus_block = array_2d[row, processor.clock]

#     while focus_block == "0"
#         row += 1
#     end

#     focus_block = array_2d[row, processor.clock]

#     if focus_block == "WB"
#         writeBack(processor.cores[1])
#         row +=1 
#     end
    
#     focus_block = array_2d[row, processor.clock]

#     if focus_block == "MEM"
#         memory_access(processor.cores[1],processor.memory)
#         row += 1 
#     end

#     focus_block = array_2d[row, processor.clock]
    
#     if focus_block == "EX"
#         execute(processor.cores[1])
#         row += 1 
#     end

#     focus_block = array_2d[row, processor.clock]
    
#     if focus_block == "ID/RF"
#         instructionDecode_RegisterFetch(processor.cores[1])
#         row += 1
#     end

#     focus_block = array_2d[row, processor.clock]
    
#     if focus_block == "IF"
#         instruction_Fetch(processor.cores[1],processor.memory)
#         row += 1
#     end

#     focus_block = array_2d[row, processor.clock]
    
#     if focus_block == "-1"
#         continue
#     end
# end

################################################################

#we have passed the coordinates of the cell where the stall was first detected
function shift_right(array_2d::Matrix{String}, row::Int, col::Int, stalls::Int)
    copy_array = fill("0", n-row+1, n-col)
    nrow, ncol = size(copy_array)

    for i in row:n
        for j in col+1:n
            copy_array[i-row+1, j-col] = array_2d[i, j]  # Copy each element from src to dest
        end
    end

    for i in 1:nrow
        for j in 1:ncol
            print(copy_array[i, j], "\t")
        end
        println()
    end

    for i in row:n
        for j in col+1:col+stalls
            array_2d[i, j] = "stall" # Copy each element from src to dest
        end
    end

    println("------------------------------")
    print_2d(array_2d)

    for i in row:n
        for j in col+stalls+1:n
            array_2d[i, j] = copy_array[i-row+1, j-col-stalls] # Copy each element from src to dest
        end
    end

    println("------------------------------")
    print_2d(array_2d)

end

###################################################################

println("--------------------------------")
shift_right(array_2d, 2, 3, 2)

