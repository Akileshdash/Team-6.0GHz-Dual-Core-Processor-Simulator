operator_array = ["add","sub","sll","xor","srl","sra","or","and","addi","xori","ori","andi","slli","srli","srai","li","andi","mv","lb","lh","lw","lbu","lhu","sb","sh","sw","beq","bne","blt","bgt","bge","bltu","bgeu","lui","jal","jalr","j",]


mutable struct Core1
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
end

mutable struct Processor
    memory::Array{UInt8,2}
    clock::Int
    cores::Array{Core1,1}
end


function find_index_for_label(label_array, label)
    for row in label_array
        if row[1] == label
            return row[2]
        end
    end
    return nothing  # Return nothing if the string is not found
end


function find_and_remove(search_string, string_array)
    index = indexin([search_string], string_array)

    if isempty(index)
        return nothing
    else
        index = first(index)  # Get the first index (assuming no duplicates)
        removed_element = popat!(string_array, index)
        return index
    end
end

function int_to_5bit_bin(n::Int)
    binary_str = string(n, base=2, pad=5)
    return binary_str
end

function int_to_12bit_bin(n::Int)
    binary_str = string(n, base=2, pad=12)
    return binary_str
end

function int_to_signed_12bit_bin(n::Int)
    binary_str = string(n + 2^12, base=2)
    return binary_str[end-11:end]
end

function int_to_signed_13bit_bin(n::Int)
    binary_str_13bit = string(n + 2^13, base=2)[end-12:end]
    return binary_str_13bit
end

function int_to_20bit_bin(n::Int)
    binary_str = string(n + 2^20, base=2)[2:end]
    return binary_str
end

function int_to_32bit_bin(n::Int)
    binary_str_20bit = string(n + 2^20, base=2)[2:end]
    binary_str_32bit = string("0" ^ (32 - length(binary_str_20bit)), binary_str_20bit)
    return binary_str_32bit
end

function int_to_signed_32bit_bin(n::Int)
    binary_str_32bit = string(n + 2^32, base=2)[end-31:end]
    return binary_str_32bit
end

function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

function show(proc::Processor)
    println("Processor Memory (in hex):")
    rows_to_show = min(50, size(proc.memory, 1))  # Choose the minimum of 10 and the actual number of rows
    for row in reverse(1:rows_to_show)
        combined_value = UInt32(0)
        print("$row -> ")
        for col in 1:size(proc.memory, 2)
            print("0x$(show_hex(proc.memory[row, col]))\t")
            if col % 4 == 0
                println()
            end
        end
    end
end

# function show_hex(value)
#     hex_str = string(value, base=16)
#     return lpad(hex_str, 8, '0')
# end

#This function extracts the entire word, i.e. 32 bits from the initial index
#considering Big Endian

function in_memory_place_word(memory,row,col,bin)       #Storing 32 bits

    memory[row,col]=parse(Int, bin[25:32], base=2)
    col+=1
    if col<=4
        memory[row,col]=parse(Int, bin[17:24], base=2)
        col+=1
        if col<=4
            memory[row,col]=parse(Int, bin[9:16], base=2)
            col+=1
            if col<=4
                memory[row,col]=parse(Int, bin[1:8], base=2)
            else
                row+=1
                col=1
                memory[row,col]=parse(Int, bin[1:8], base=2)
            end
        else
            col=1
            row+=1
            memory[row,col]=parse(Int, bin[9:16], base=2)
            col+=1
            memory[row,col]=parse(Int, bin[1:8], base=2)
        end
    else
        col=1
        row+=1
        memory[row,col]=parse(Int, bin[17:24], base=2)
        col+=1
        memory[row,col]=parse(Int, bin[9:16], base=2)
        col+=1
        memory[row,col]=parse(Int, bin[1:8], base=2)
    end
end

function in_memory_place_halfword(memory,row,col,bin)       #Storing last 16 bits
    memory[row,col]=parse(Int, bin[25:32], base=2)
    col+=1
    if col<=4
        memory[row,col]=parse(Int, bin[17:24], base=2)
    else
        col=1
        row+=1
        memory[row,col]=parse(Int, bin[17:24], base=2)
    end
end

function return_word_from_memory(memory,row,col)       #returns 32 bits from the specified memory and next 3 memory units
    value=UInt32(memory[row,col])
    col+=1
    if col<=4
        temp =  UInt32(memory[row,col])<<8
        value =  (temp) | (value) 
        col+=1
        if col<=4
            temp =  UInt32(memory[row,col])<<16
            value =  (temp) | (value) 
            col+=1
            if col<=4
                temp =  UInt32(memory[row,col])<<24
                value =  (temp) | (value) 
            else
                col=1
                row+=1
                temp = UInt32(memory[row,col])<<24
                value =  (temp) | (value) 
            end
        else
            col=1
            row+=1
            temp =  UInt32(memory[row,col])<<16
            value =  (temp) | (value) 
            col+=1
            temp =  UInt32(memory[row,col])<<24
            value =  (temp) | (value) 
        end
    else
        col=1
        row+=1
        temp =  UInt32(memory[row,col])<<8
        value =  (temp) | (value) 
        col+=1
        temp =  UInt32(memory[row,col])<<16
        value =  (temp) | (value) 
        col+=1
        temp =  UInt32(memory[row,col])<<24
        value =  (temp) | (value) 
    end
    return value
end
