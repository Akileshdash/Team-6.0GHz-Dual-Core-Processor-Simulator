include("sim.jl")
include("string_to_binaryString.jl")

function binary_to_uint8(binary::String)
    result = 0
    for (i, bit) in enumerate(reverse(binary))
        if bit == '1'
            result += 2^(i-1)
        end
    end
    return result
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

function get_loc_vars(core_id::Int)
    mem_pc = 2049 + 1024*(core_id-1)
    row = mem_pc/4
    col = 0
    if mem_pc%4 != 0
        col = mem_pc%4
    else
        col = 4
    end 

    return mem_pc, row, col
end

function alloc_dataSeg_in_memory(memory::Array{UInt8,2}, data_inst_final::Vector{Any}, core::Core1, variable_array::Vector{Any})
    
    variable_address_array = []
    mem_pc, row, col = get_loc_vars(core.id)

    string_flag = false
    word_flag = false

    for i in eachindex(data_inst_final)
        str = data_inst_final[i]
        if str == ".word" 
            word_flag = true
            string_flag = false
            continue
        end

        if str == ".string" 
            word_flag = false
            string_flag = true
            continue
        end

        if str in variable_array
            #println("found ", str)
            push!(variable_address_array, mem_pc)
            continue
        end

        # memory[mem_pc_to_row(mem_pc)][mem_pc_to_col(mem_pc)] = 
        if string_flag
            binary_of_str_array = string_to_binary_8bit_string_array(String(str))
            println(str, " ", binary_of_str_array)

            for k in eachindex(binary_of_str_array)
                #println(k, " ", binary_to_uint8(binary_of_str_array[k]), " ", str)
                memory[mem_pc_to_row(mem_pc),mem_pc_to_col(mem_pc)] = binary_to_uint8(binary_of_str_array[k])
                #parse(UInt8, binary_of_str_array[i])
                mem_pc += 1
            end
            memory[mem_pc_to_row(mem_pc),mem_pc_to_col(mem_pc)] = C_NULL
            mem_pc += 1
        end

        if word_flag
            # parse(Int, parts[2][2:end])
            num = parse(Int , str)
            bin_str = int_to_32bit_bin(num)
            in_memory_place_word(memory, mem_pc_to_row(mem_pc), mem_pc_to_col(mem_pc), bin_str)
            mem_pc += 4
        end
    end

    # print(binary_of)
    return variable_address_array
end