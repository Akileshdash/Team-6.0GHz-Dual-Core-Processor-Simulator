function replace_commas_with_spaces(input_string::String)
    return replace(input_string, ',' => ' ')
end

function replace_colon_with_space(input_string::String)
    return replace(input_string, ':' => ' ')
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

#= to be executed in the main file

for i in eachindex(text_instructions)
    mutable_str = String(text_instructions[i])
    modified_str = replace_commas_with_spaces(mutable_str)
    final_str = replace_colon_with_space(modified_str)
    push!(sim.cores[1].program, final_str)
    println(modified_str, "  ", final_str)
end

=#