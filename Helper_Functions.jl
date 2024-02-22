include("Processor_Core_Init.jl")

operator_array = ["add","sub","sll","xor","srl","sra","or","and","addi","xori","ori","andi","slli","srli","srai","li","andi","mv","lb","lh","lw","lbu","lhu","sb","sh","sw","beq","bne","blt","bgt","bge","bltu","bgeu","lui","jal","jalr","j",]

instruction_formats = [
    "0110011" => "R",
    "0010011" => "I",
    "0000011" => "L",  # Load Format
    "0100011" => "S",  # Store Format
    "1100011" => "B",  # Break Format
    "0110111" => "U",  # Upper Immediate Format
    "1101111" => "JAL",  # Jump Format
    "1100111" => "JALR"  # Jump and Link Register Format
]

R_format_instructions = [
    "000" => "ADD/SUB",
    "001" => "SLL",
    "010" => "SLT",
    "011" => "SLTU",
    "100" => "XOR",
    "101" => "SRL/SRA",
    "110" => "OR",
    "111" => "AND",
]

I_format_instructions = [
    "000" => "ADDI",
    "001" => "SLLI",
    "010" => "SLTI",
    "011" => "SLTIU",
    "100" => "XORI",
    "101" => "SRLI/SRAI",
    "110" => "OR",
    "111" => "ANDI",
]

B_format_instructions = [
    "000" => "BEQ",
    "001" => "BNE",
    "100" => "BLT",
    "101" => "BGE",
    "110" => "BLTU",
    "111" => "BGEU",
]

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

function int_to_8bit_bin(n::UInt8)
    binary_str = string(n, base=2, pad=8)
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
    binary_str_13bit = string(n + 2^13, base=2)
    return binary_str_13bit[end-12:end]
end

function int_to_20bit_bin(n::Int)
    binary_str = string(n + 2^20, base=2)[2:end]
    return binary_str
end

function int_to_signed_20bit_bin_string(value::Int)
    if value < 0
        value += 2^20
    end
    bin_str = string(value, base=2)
    bin_str = string("0"^(20 - length(bin_str)), bin_str)
    return bin_str
end


function int_to_32bit_bin(n::Int)
    binary_str_20bit = string(n + 2^20, base=2)[2:end]
    binary_str_32bit = string("0" ^ (32 - length(binary_str_20bit)), binary_str_20bit)
    return binary_str_32bit
end

function int_to_signed_32bit_bin(n::Int)
    binary_str_32bit = string(n + 2^32, base=2)
    return binary_str_32bit[end-31:end]
end

function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

# function show(proc::Processor)
#     println("Processor Memory (in hex):")
#     # rows_to_show = min(15, size(proc.memory, 1))  # Choose the minimum of 10 and the actual number of rows
#     rows_to_show = min(550, 550)
#     for row in reverse(510:rows_to_show)
#         combined_value = UInt32(0)
#         print("$row -> ")
#         for col in 1:size(proc.memory, 2)
#             print("0x$(show_hex(proc.memory[row, col]))\t")
#             if col % 4 == 0
#                 println()
#             end
#         end
#     end
# end

function show(proc::Processor)
    println("Processor Memory (in hex):")
    rows_to_show = min(11, size(proc.memory, 1))  # Choose the minimum of 10 and the actual number of rows
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

function bin_string_to_signed_int(bin_str::AbstractString)
    decimal_value = parse(Int, bin_str, base=2)
    num_bits = count(x -> x == '0' || x == '1', bin_str)
    if bin_str[1] == '1'
        decimal_value -= 2 ^ num_bits
    end
    return decimal_value
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
