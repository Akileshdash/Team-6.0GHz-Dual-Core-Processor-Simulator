include("Helper_Functions.jl")

function parse_assembly(file_path::String)
    text_instructions = String[]
    data_instructions = String[]
    
    # Open the file
    file = open(file_path, "r")
    
    # Flag to indicate whether parsing text section or data section
    parsing_text_section = false
    parsing_data_section = false
    
    # Read each line in the file
    for line in eachline(file)
        # If encountering .text section, set flag to start parsing instructions
        if occursin(".text", line)
            parsing_text_section = true
            parsing_data_section = false
            continue
        end
        
        # If encountering .data section, set flag to start parsing data
        if occursin(".data", line)
            parsing_data_section = true
            parsing_text_section = false
            continue
        end
        
        # If not in .text or .data section, continue to next line
        if !(parsing_text_section || parsing_data_section)
            continue
        end
        
        # Remove comments from the line
        line = split(line, '#')[1]
        
        # Remove leading and trailing whitespace
        line = strip(line)
        
        # If the line is empty after removing comments and whitespace, continue to next line
        if isempty(line)
            continue
        end
        
        # Check if parsing text section or data section and add the instruction accordingly
        if parsing_text_section
            push!(text_instructions, line)
        elseif parsing_data_section
            push!(data_instructions, line)
        end
    end
    
    # Close the file
    close(file)
    
    return text_instructions, data_instructions
end

#-----------------------------------------------------------

#========================================================
            Text Instruction Parsing
========================================================#

function text_inst_parser(text_instructions::Vector{String})
    list = []
    for i in eachindex(text_instructions)
        mutable_str = String(text_instructions[i])
        modified_str = replace_commas_with_spaces(mutable_str)
        final_str = replace_colon_with_space(modified_str)
        push!(list, strip(final_str))
        #println(modified_str, "  ", final_str)
    end

    return list
end

#========================================================
            Data Instruction Parsing
========================================================#

function data_inst_parser(data_instructions::Vector{String})
    list = []
    data_instructions_2 = []
    for i in eachindex(data_instructions)
        mutable_str = String(data_instructions[i])
        modified_str = replace_commas_with_spaces(mutable_str)
        final_str = replace_colon_with_space(modified_str)
        push!(data_instructions_2, final_str)
        #println(mutable_str, "\t", final_str)
    end
    
    # println(data_instructions_2)

    varibale_array = []
    
    for i in eachindex(data_instructions_2)
        if occursin(".word", data_instructions_2[i])
            split_list = split(data_instructions_2[i], ".word")
            for j in eachindex(split_list)
                if split_list[j] == ""
                    continue
                end
                if j == 1
                    push!(varibale_array, strip(split_list[j]))
                    push!(list, strip(split_list[j]))
                    push!(list, ".word")
                    continue
                end
                
                new_split_list = split(split_list[j], " ")
                for k in eachindex(new_split_list)
                    if new_split_list[k] == ""
                        continue
                    end
                    push!(list, new_split_list[k])
                end
            end
        end
    
        if occursin(".string", data_instructions_2[i])
            split_list = split(data_instructions_2[i], ".string")
            for j in eachindex(split_list)
                if split_list[j] == ""
                    continue
                end
                if j == 1
                    push!(varibale_array, strip(split_list[j]))
                    push!(list, strip(split_list[j]))
                    push!(list, ".string")
                    continue
                end
                temp_str = String(split_list[j])
                final_str = replace_d_quotes_with_space(temp_str)
                push!(list, replace_wrong_nline_with_right_nline(final_str[2:end]))
                
            end
        end
    end

    return list, varibale_array
end

#========================================================
            Data varibles Allocation
========================================================#

function alloc_dataSeg_in_memory(memory::Array{UInt8,2}, data_inst_final::Vector{Any}, core::Core1, variable_array::Vector{Any})
    
    variable_address_array = []
    mem_pc = 2049 + 1024*(core.id-1)
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
            push!(variable_address_array, mem_pc)
            continue
        end
 
        if string_flag
            binary_of_str_array = string_to_binary_8bit_string_array(String(str))
            for k in eachindex(binary_of_str_array)
                memory[mem_pc_to_row(mem_pc),mem_pc_to_col(mem_pc)] = binary_to_uint8(binary_of_str_array[k])
                mem_pc += 1
            end
            memory[mem_pc_to_row(mem_pc),mem_pc_to_col(mem_pc)] = C_NULL
            mem_pc += 1
        end

        if word_flag
            num = parse(Int , str)
            bin_str = int_to_32bit_bin(num)
            in_memory_place_word(memory, mem_pc_to_row(mem_pc), mem_pc_to_col(mem_pc), bin_str)
            mem_pc += 4
        end
    end
    return variable_address_array
end