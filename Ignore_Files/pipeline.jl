n = 10
array_2d = fill("0", n, n)

stage_array = ["IF", "ID/RF", "EX", "MEM", "WB"]


for i in 1:n
    for j in 1:n
        print(array_2d[i, j], "\t")
    end
    println()
end

println("-------------------------------------------------------")

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



for i in 1:n
    for j in 1:n
        print(array_2d[i, j], "\t")
    end
    println()
end


#========================================
# loop:

clock++, row = 1

--------------------
while focus_block == "0"
    row++
end

focus_block = array_2d[row][clock]


if focus_block == "WB"
    writeBack(processor.cores[1])
    row++
end

if focus_block == "MEM"
    memory_access(processor.cores[1],processor.memory)
    row++
end

if focus_block == "EX"
    execute(processor.cores[1])
    row++
end

if focus_block == "ID/RF"
    instructionDecode_RegisterFetch(processor.cores[1])
    row++
end

if focus_block == "IF"
    instruction_Fetch(processor.cores[1],processor.memory)
    row++
end

if focus_block == "-1"
    clock++
    j ---------------------
end






========================================#
