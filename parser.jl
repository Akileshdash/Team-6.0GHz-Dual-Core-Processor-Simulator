function replace_commas_with_spaces(input_string::String)
    return replace(input_string, "," => " ")
end

function replace_colon_with_space(input_string::String)
    return replace(input_string, ":" => "")
end

function replace_d_quotes_with_space(input_string::String)
    return replace(input_string, "\"" => "")
end

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
        push!(list, final_str)
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
    
    #println(data_instructions_2)

    label_array = []
    
    for i in eachindex(data_instructions_2)
        if occursin(".word", data_instructions_2[i])
            split_list = split(data_instructions_2[i], ".word")
            for j in eachindex(split_list)
                if split_list[j] == ""
                    continue
                end
                if j == 1
                    push!(label_array, strip(split_list[j]))
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
                    push!(label_array, strip(split_list[j]))
                    push!(list, strip(split_list[j]))
                    push!(list, ".string")
                    continue
                end
                temp_str = String(split_list[j])
                final_str = replace_d_quotes_with_space(temp_str)
                push!(list, final_str)
                
            end
        end
    end

    return list, label_array
end


