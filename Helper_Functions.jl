include("Processor_Core_Init.jl")

#= 30 Helper Functions have been defined =#

operator_array = ["add","sub","sll","xor","srl","sra","or","and","addi","xori","ori","andi","slli","srli","srai","li","la","andi","mv","lb","lh","lw","lbu","lhu","sb","sh","sw","beq","bne","blt","bgt","bge","bltu","bgeu","lui","jal","jalr","j",]

instruction_formats = [
    "0110011" => "R",
    "0010011" => "I",
    "0000011" => "L",  # Load Format
    "0100011" => "S",  # Store Format
    "1100011" => "B",  # Break Format
    "0110111" => "U",  # Upper Immediate Format
    "1101111" => "JAL",  # Jump Format
    "1100111" => "JALR",  # Jump and Link Register Format
    "1111111" => "ECALL",  # ecall format
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
L_format_instructions = [
    "000" => "LB",
    "001" => "LH",
    "010" => "LW",
    "011" => "LA",
    "100" => "LBU",
    "101" => "LHU",
    "110" => "LS",
]
S_format_instructions = [
    "000" => "SB",
    "001" => "SH",
    "010" => "SW",
]
B_format_instructions = [
    "000" => "BEQ",
    "001" => "BNE",
    "100" => "BLT",
    "101" => "BGE",
    "110" => "BLTU",
    "111" => "BGEU",
]
#==============================================================================================#
instruction_formats_2 = Dict(
    "0110011" => "R",
    "0010011" => "I",
    "0000011" => "L",  # Load Format
    "0100011" => "S",  # Store Format
    "1100011" => "B",  # Break Format
    "0110111" => "U",  # Upper Immediate Format
    "1101111" => "JAL",  # Jump Format
    "1100111" => "JALR",  # Jump and Link Register Format
    "1111111" => "ECALL",  # ecall format
)
operator_dict = Dict(
    #R
    "0110011" => Dict(
        "000" => "ADD/SUB",
        "001" => "SLL",
        "010" => "SLT",
        "011" => "SLTU",
        "100" => "XOR",
        "101" => "SRL/SRA",
        "110" => "OR",
        "111" => "AND",
    ),
    #I
    "0010011" => Dict(
        "000" => "ADDI",
        "001" => "SLLI",
        "010" => "SLTI",
        "011" => "SLTIU",
        "100" => "XORI",
        "101" => "SRLI/SRAI",
        "110" => "OR",
        "111" => "ANDI",
    ),
    #L
    "0000011" => Dict(
        "000" => "LB",
        "001" => "LH",
        "010" => "LW",
        "011" => "LA",
        "100" => "LBU",
        "101" => "LHU",
        "110" => "LS",
    ),
    #S
    "0100011" => Dict(
        "000" => "SB",
        "001" => "SH",
        "010" => "SW",
    ),
    #B
    "1100011" =>Dict(
        "000" => "BEQ",
        "001" => "BNE",
        "100" => "BLT",
        "101" => "BGE",
        "110" => "BLTU",
        "111" => "BGEU",
    ),
    #JAL
    "1101111" => Dict(
        "anything" => "JAL",
    ),
    #JALR
    "1100111" => Dict(
        "anything" => "JALR",
    ),
)
operator_dict_RI = Dict(
    #R
    "0110011" => Dict(
        "000" => "ADD/SUB",
        "001" => "SLL",
        "010" => "SLT",
        "011" => "SLTU",
        "100" => "XOR",
        "101" => "SRL/SRA",
        "110" => "OR",
        "111" => "AND",
    ),
    #I
    "0010011" => Dict(
        "000" => "ADDI",
        "001" => "SLLI",
        "010" => "SLTI",
        "011" => "SLTIU",
        "100" => "XORI",
        "101" => "SRLI/SRAI",
        "110" => "OR",
        "111" => "ANDI",
    ),
)

function get_instruction(opcode::AbstractString, func3::AbstractString)
    if opcode in keys(operator_dict) && func3 in keys(operator_dict[opcode])
        return operator_dict[opcode][func3]
    elseif opcode in keys(operator_dict)
        return operator_dict[opcode]["anything"]
    else
        return "Unknown Instruction"
    end
end


function replace_commas_with_spaces(input_string::String)
    return replace(input_string, "," => " ")
end

function replace_colon_with_space(input_string::String)
    return replace(input_string, ":" => "")
end

function replace_d_quotes_with_space(input_string::String)
    return replace(input_string, "\"" => "")
end

function replace_wrong_nline_with_right_nline(input_string::String)
    return replace(input_string, "\\n" => "\n")
end

function mem_pc_to_row(mem_pc::Int)
    row = mem_pc/4

    return Int(ceil(row))
end

function mem_pc_to_col(mem_pc::Int)
    if mem_pc%4 != 0
        col = mem_pc%4
    else
        col = 4
    end 
    return col
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

#============================================================================================================
                                    Integer to Binary String Helper Functions
=============================================================================================================#
 
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

function bin_string_to_signed_int(bin_str::AbstractString)
    decimal_value = parse(Int, bin_str, base=2)
    num_bits = count(x -> x == '0' || x == '1', bin_str)
    if bin_str[1] == '1'
        decimal_value -= 2 ^ num_bits
    end
    return decimal_value
end

function binary_to_uint8(binary::String)
    result = 0
    for (i, bit) in enumerate(reverse(binary))
        if bit == '1'
            result += 2^(i-1)
        end
    end
    return result
end

function string_to_binary_8bit_string_array(str::String)
    hex_array = transcode(UInt8, str)
    binary_array = [bitstring(UInt8(x)) for x in hex_array]
    return binary_array
end

function binary_to_letters(binary_strings::Vector{String})
    letters = Char[]
    for binary_str in binary_strings
        decimal_value = parse(Int, binary_str, base=2)
        letter = Char(decimal_value)
        push!(letters, letter)
    end
    return join(letters)
end

function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

#============================================================================================================
                                    Display Memory Helper Function
=============================================================================================================#
 

function Display_Memory(proc::Processor, start_row::Int, end_row::Int)
    println("Processor Memory (in hex):")
    
    # Ensure start_row and end_row are within the valid range
    start_row = max(1, start_row)
    end_row = min(size(proc.memory, 1), end_row)
    
    for row in reverse(start_row:end_row)
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

function return_word_from_memory_littleEndian(memory,address)
    row = div(address,4) + 1
    col = (address%4) + 1
    temp = UInt32(memory[row,col])
    col+=1
    if col<=4
        temp = temp | ((UInt32(memory[row,col]))<<8)
        col+=1
        if col<=4
            temp = temp | ((UInt32(memory[row,col]))<<16)
            col+=1
            if col<=4
                temp = temp | ((UInt32(memory[row,col]))<<24)
            else
                col=1
                row+=1
                temp = temp | ((UInt32(memory[row,col]))<<24)
            end
        else
            col = 1
            row+=1
            temp = temp | ((UInt32(memory[row,col]))<<16)
            col+=1
            temp = temp | ((UInt32(memory[row,col]))<<24)
        end
    else
        row+=1
        col=1
        temp = temp | ((UInt32(memory[row,col]))<<8)
        col+=1
        temp = temp | ((UInt32(memory[row,col]))<<16)
        col+=1
        temp = temp | ((UInt32(memory[row,col]))<<24)
    end
    return temp
end

function address_to_row_col(address)
    row = div(address,4) + 1
    col = (address%4) + 1
    return row,col
end
################################################################

function print_2d(array_2d::Matrix{String})
    for i in 1:n
        for j in 1:n
            print(array_2d[i, j], "\t")
        end
        println()
    end
end
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

    # for i in 1:nrow
    #     for j in 1:ncol
    #         print(copy_array[i, j], "\t")
    #     end
    #     println()
    # end

    for i in row:n
        for j in col+1:col+stalls
            array_2d[i, j] = "stall" # Copy each element from src to dest
        end
    end

    println("------------------------------")
    # print_2d(array_2d)

    for i in row:n
        for j in col+stalls+1:n
            array_2d[i, j] = copy_array[i-row+1, j-col-stalls] # Copy each element from src to dest
        end
    end

    println("------------------------------")
    print_2d(array_2d)

end