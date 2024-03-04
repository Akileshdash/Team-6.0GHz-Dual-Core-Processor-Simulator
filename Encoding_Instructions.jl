include("Helper_Functions.jl")

#==========================================================================================================
                                Encoding all instructions to memory
===========================================================================================================#

function encoding_all_instructions_to_memory(sim)
    initial_index=1     

    #For core 1
    text_instructions,data_instructions = parse_assembly(file_path_1)
    final_text_inst = text_inst_parser(text_instructions)
    final_data_inst, variable_array = data_inst_parser(data_instructions)

    label_array_1 = Vector{Tuple{String, Int}}()
    for str in final_text_inst
        if !(in(split(str,' ')[1], operator_array))
            label = split(str,' ')[1]
            index = find_and_remove(label, final_text_inst)
            push!(label_array_1, (label, index))
        end
    end

    sim.cores[1].program = final_text_inst
    variable_address_array = alloc_dataSeg_in_memory(sim.memory, final_data_inst, sim.cores[1], variable_array)
    variable_address_array .-=1
    initial_index = encoding_Instructions(sim.cores[1],sim.memory,initial_index,variable_array,label_array_1,variable_address_array)

    #===========================================================================#
    
    #For core 2
    # text_instructions,data_instructions = parse_assembly(file_path_2)
    # final_text_inst = text_inst_parser(text_instructions)
    # final_data_inst, variable_array = data_inst_parser(data_instructions)

    # label_array_2 = Vector{Tuple{String, Int}}()
    # for str in final_text_inst
    #     if !(in(split(str,' ')[1], operator_array))
    #         label = split(str,' ')[1]
    #         index = find_and_remove(label, final_text_inst) + initial_index -1
    #         push!(label_array_2, (label, index))
    #     end
    # end

    # sim.cores[2].program = final_text_inst
    # variable_address_array = alloc_dataSeg_in_memory(sim.memory, final_data_inst, sim.cores[2], variable_array)
    # variable_address_array .-=1
    # initial_index = encoding_Instructions(sim.cores[2],sim.memory,initial_index,variable_array,label_array_2,variable_address_array)
end

#==========================================================================================================
                                Encoding each instrutcion to memory
                                  ( Called by the above Function )
===========================================================================================================#

function encoding_Instructions(core::Core_Object, memory,initial_index,variable_array,label_array,variable_address_array)
    memory_index = core.pc = initial_index
    while (core.pc-initial_index+1)<=length(core.program)                      
        parts = split(core.program[core.pc-initial_index+1],' ') 
        if "" in parts
            filter!(x -> x != "", parts)
        end
        opcode = uppercase(parts[1])
        R_format_instruction = "0110011"
        I_format_instruction = "0010011"
        L_format_instruction = "0000011"        #Load Format it also comes under I Format
        S_format_instruction = "0100011"        #Store Format
        B_format_instruction = "1100011"        #Break Format
        U_format_instruction = "0110111"        #Upper Immediate Format
        JAL_format_instruction = "1101111"        #Jump Format
        JALR_format_instruction = "1100111"        #Jump Format
        ecall_format_instruction = "1111111"        #ecall Format

        #====================================================================================================================
                                                    R Format Instructions          
        ====================================================================================================================#


        #1    #ADD rd rs1 rs2
        if opcode == "ADD"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)
                
        #2    #SUB rd rs1 rs2
        elseif opcode == "SUB"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)
        
        #3    #SLL rd, rs1, rs2
        elseif opcode == "SLL"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"001"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)

        #4    #XOR rd, rs1, rs2
        elseif opcode == "XOR"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"100"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)

        #5    #SRL rd, rs1, rs2
        elseif opcode == "SRL"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)
            
        #6    #SRA rd, rs1, rs2
        elseif opcode == "SRA"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)

        #7    #OR rd, rs1, rs2
        elseif opcode == "OR"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"110"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)
        
        #8    #AND rd, rs1, rs2
        elseif opcode == "AND"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            rs2 = parse(Int, parts[4][2:end])+1
            R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"111"*int_to_5bit_bin(rd-1)*R_format_instruction
            in_memory_place_word(memory,memory_index,1,R_format_instruction)
        

        #====================================================================================================================
                                                    I Format Instructions          
        ====================================================================================================================#


        #9    #ADDI rd rs1 imm_value
        elseif opcode == "ADDI"
            rd = parse(Int, parts[2][2:end])
            rs1 = parse(Int, parts[3][2:end])
            imm_value = parse(Int, parts[4]) #Immediate value
            I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1)*"000"*int_to_5bit_bin(rd)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)
        
        #10    #XORI rd rs1 imm_value
        elseif opcode == "XORI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            imm_value = parse(Int, parts[4]) #Immediate value
            I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"100"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

        #11    #ORI rd rs1 imm_value
        elseif opcode == "ORI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            imm_value = parse(Int, parts[4]) #Immediate value
            I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"110"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

        #12    #ANDI rd rs1 imm_value
        elseif opcode == "ANDI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            imm_value = parse(Int, parts[4]) #Immediate value
            I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"111"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

        #13    #SLLI rd rs1 shamt                     (shift amount immediate)
        elseif opcode == "SLLI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            shamt = parse(Int, parts[4]) #Shift Amount
            I_format_instruction = "0000000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"001"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

        #14    #SRLI rd rs1 shamt                     (shift amount immediate)
        elseif opcode == "SRLI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            shamt = parse(Int, parts[4]) #Shift Amount
            I_format_instruction = "0000000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)


        #13    #SRAI rd rs1 shamt                     (shift amount immediate)
        elseif opcode == "SRAI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            shamt = parse(Int, parts[4]) #Shift Amount
            I_format_instruction = "0100000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)


        #LI rd immediate
        elseif opcode == "LI"
            if parts[2][1] == 'a'
                rd = parse(Int, parts[2][2:end])+10
                imm_value = parse(Int, parts[3]) #Immediate value
                I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(0)*"000"*int_to_5bit_bin(rd)*I_format_instruction
            else
                rd = parse(Int, parts[2][2:end])
                imm_value = parse(Int, parts[3]) #Immediate value
                I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(0)*"000"*int_to_5bit_bin(rd)*I_format_instruction
            end
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

         #12    #ANDI rd rs1 imm_value
        elseif opcode == "ANDI"
            rd = parse(Int, parts[2][2:end])+1
            rs1 = parse(Int, parts[3][2:end])+1
            imm_value = parse(Int, parts[4]) #Immediate value
            I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"111"*int_to_5bit_bin(rd-1)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)

        #MV rd rs               # same as ADDI rd rs 0
        elseif opcode == "MV"
            rd = parse(Int, parts[2][2:end])
            rs = parse(Int, parts[3][2:end])
            I_format_instruction = int_to_signed_12bit_bin(0)*int_to_5bit_bin(rs)*"000"*int_to_5bit_bin(rd)*I_format_instruction
            in_memory_place_word(memory,memory_index,1,I_format_instruction)


        #====================================================================================================================
                                                L Format Instructions          ( Load Format )
        ====================================================================================================================#

        #16    #LA rd, String
        elseif opcode == "LA"
            rs = 1      #Just for encoding ,actually not needed
            if parts[2][1]=='a'
                rd = parse(Int, parts[2][2:end])+11
            else
                rd = parse(Int, parts[2][2:end])+1
            end
            variable_name = parts[3]
            index = findfirst(x -> x == variable_name, variable_array)
            address = variable_address_array[index]
            L_format_instruction = int_to_signed_12bit_bin(address)*int_to_5bit_bin(rs-1)*"011"*int_to_5bit_bin(rd-1)*L_format_instruction
            in_memory_place_word(memory,memory_index,1,L_format_instruction)
    
        #16    #LB rd, offset(rs)
        elseif opcode == "LB"
            rd = parse(Int, parts[2][2:end])+1
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rs = match(r"\(([^)]+)\)", parts[3])
            rs = rs.captures[1][2:end]
            rs = parse(Int, rs)+1
            L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"000"*int_to_5bit_bin(rd-1)*L_format_instruction
            in_memory_place_word(memory,memory_index,1,L_format_instruction)

        #16    #LH rd, offset(rs)
        elseif opcode == "LH"
            rd = parse(Int, parts[2][2:end])+1
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rs = match(r"\(([^)]+)\)", parts[3])
            rs = rs.captures[1][2:end]
            rs = parse(Int, rs)+1
            L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"001"*int_to_5bit_bin(rd-1)*L_format_instruction
            core.registers[rd]=memory[1,core.registers[rs]+offset+1]
            #Function has to be written after Memory 2d Array is formed
            in_memory_place_word(memory,memory_index,1,L_format_instruction)
            
        #17    #LW rd offset(rs)
               #LW rd String
        elseif opcode == "LW"
            #Lets give this opcode name as LS i.e Load string
            if parts[2][1]=='a'
                rd = parse(Int, parts[2][2:end])+10
            else    
                rd = parse(Int, parts[2][2:end])
            end
            if parts[3] in variable_array
                rs = 0
                variable_name = parts[3]
                index = findfirst(x -> x == variable_name, variable_array)
                address = variable_address_array[index]
                #L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"010"*int_to_5bit_bin(rd-1)*L_format_instruction
                L_format_instruction = int_to_signed_12bit_bin(address)*int_to_5bit_bin(rs)*"010"*int_to_5bit_bin(rd)*L_format_instruction
            else
                offset = match(r"\d+", parts[3])
                offset = parse(Int, offset.match)
                rs = match(r"\(([^)]+)\)", parts[3])
                rs = rs.captures[1][2:end]
                rs = parse(Int, rs)
                L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs)*"010"*int_to_5bit_bin(rd)*L_format_instruction
            end
            in_memory_place_word(memory,memory_index,1,L_format_instruction)

        #18    #LBU rd, offset(rs)
        elseif opcode == "LBU"
            rd = parse(Int, parts[2][2:end])+1
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rs = match(r"\(([^)]+)\)", parts[3])
            rs = rs.captures[1][2:end]
            rs = parse(Int, rs)+1
            L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"100"*int_to_5bit_bin(rd-1)*L_format_instruction
            core.registers[rd]=memory[1,core.registers[rs]+offset+1]
            #Function has to be written after Memory 2d Array is formed
            in_memory_place_word(memory,memory_index,1,L_format_instruction)

        #19    #LHU rd, offset(rs)
        elseif opcode == "LHU"
            rd = parse(Int, parts[2][2:end])+1
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rs = match(r"\(([^)]+)\)", parts[3])
            rs = rs.captures[1][2:end]
            rs = parse(Int, rs)+1
            L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"101"*int_to_5bit_bin(rd-1)*L_format_instruction
            core.registers[rd]=memory[1,core.registers[rs]+offset+1]
            #Function has to be written after Memory 2d Array is formed
            in_memory_place_word(memory,memory_index,1,L_format_instruction)


        #====================================================================================================================
                                                S Format Instructions          ( Store Format )
        ====================================================================================================================#

        #20    #SB rs, offset(rd)
        elseif opcode == "SB"
            rs = parse(Int, parts[2][2:end])
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rd = match(r"\(([^)]+)\)", parts[3])
            rd = rd.captures[1][2:end]
            rd = parse(Int, rd)
            imm = int_to_signed_12bit_bin(offset)
            #S_format_instruction = imm[1:7]*int_to_5bit_bin(rs)*int_to_5bit_bin(rd)*"000"*imm[8:12]*S_format_instruction
            S_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs)*"000"*int_to_5bit_bin(rd)*S_format_instruction
            in_memory_place_word(memory,memory_index,1,S_format_instruction)
            

        #21    #SH rs offset(rd)
        elseif opcode == "SH"
            rs = parse(Int, parts[2][2:end])+1
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rd = match(r"\(([^)]+)\)", parts[3])
            rd = rd.captures[1][2:end]
            rd = parse(Int, rd)+1
            imm = int_to_signed_12bit_bin(offset)
            S_format_instruction = imm[1:7]*int_to_5bit_bin(rs-1)*int_to_5bit_bin(rd-1)*"001"*imm[8:12]*S_format_instruction
            bin = string(core.registers[rs], base=2, pad=32) 
            in_memory_place_halfword(memory,row,col,bin)   #Little Endian
            in_memory_place_word(memory,memory_index,1,S_format_instruction)


        #22    #SW rs offset(rd)
        elseif opcode == "SW"
            rs = parse(Int, parts[2][2:end])
            offset = match(r"\d+", parts[3])
            offset = parse(Int, offset.match)
            rd = match(r"\(([^)]+)\)", parts[3])
            rd = rd.captures[1][2:end]
            rd = parse(Int, rd)
            imm = int_to_signed_12bit_bin(offset)
            #S_format_instruction = imm[1:7]*int_to_5bit_bin(rs)*int_to_5bit_bin(rd)*"010"*imm[8:12]*S_format_instruction
            S_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs)*"010"*int_to_5bit_bin(rd)*S_format_instruction
            in_memory_place_word(memory,memory_index,1,S_format_instruction)



        #====================================================================================================================
                                                B Format Instructions          ( Branch Format )
        ====================================================================================================================#

        #23    #BEQ  rs1 rs2 label
        #BEQ  rs1 rs2 offset
        elseif opcode == "BEQ"
            rs1 = parse(Int, parts[2][2:end])+1
            rs2 = parse(Int, parts[3][2:end])+1
            label = parts[4]
            index = find_index_for_label(label_array,label)
            offset = 4*(index - core.pc)         #Offset is in bytes)
            imm = int_to_signed_13bit_bin(offset)
            # B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm[1:12]*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rs2-1)*B_format_instruction
            in_memory_place_word(memory,memory_index,1,B_format_instruction)

        #24    #BNE  rs1 rs2 label
        #BNE  rs1 rs2 offset
        elseif opcode == "BNE"
            rs1 = parse(Int, parts[2][2:end])+1
            rs2 = parse(Int, parts[3][2:end])+1
            label = parts[4]
            index = find_index_for_label(label_array,label)
            offset = 4*(index - core.pc)         #Offset is in bytes)
            imm = int_to_signed_13bit_bin(offset)
            #B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"001"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm[1:12]*int_to_5bit_bin(rs1-1)*"001"*int_to_5bit_bin(rs2-1)*B_format_instruction
            in_memory_place_word(memory,memory_index,1,B_format_instruction)

        #25    #BLT  rs1 rs2 label
        #BLT  rs1 rs2 offset
        elseif opcode == "BLT"
            rs1 = parse(Int, parts[2][2:end])+1
            rs2 = parse(Int, parts[3][2:end])+1
            label = parts[4]
            index = find_index_for_label(label_array,label)
            offset = 4*(index - core.pc)         #Since if offset is odd, then we are ignoring the last bit   
            imm = int_to_signed_13bit_bin(offset)
            #B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"100"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm[1:12]*int_to_5bit_bin(rs1-1)*"100"*int_to_5bit_bin(rs2-1)*B_format_instruction
            in_memory_place_word(memory,memory_index,1,B_format_instruction)

        #25    #BGT  rs1 rs2 label
        #BLT  rs2 rs1 offset
        elseif opcode == "BGT"
            rs1 = parse(Int, parts[2][2:end])
            rs2 = parse(Int, parts[3][2:end])
            label = parts[4]
            index = find_index_for_label(label_array,label)
            offset = 4*(index - core.pc)         #Offset is in bytes
            imm = int_to_signed_13bit_bin(offset)
            #B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs1-1)*int_to_5bit_bin(rs2-1)*"100"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm[1:12]*int_to_5bit_bin(rs2)*"100"*int_to_5bit_bin(rs1)*B_format_instruction
            in_memory_place_word(memory,memory_index,1,B_format_instruction)

        #26    #BGE  rs1 rs2 offset
        elseif opcode == "BGE"
            rs1 = parse(Int, parts[2][2:end])+1
            rs2 = parse(Int, parts[3][2:end])+1
            offset = parse(Int, parts[4]) 
            index = find_index_for_label(label_array,label)
            offset = 4*(index - core.pc)         #Offset is in bytes
            imm = int_to_signed_13bit_bin(offset)
            #B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs1-1)*int_to_5bit_bin(rs2-1)*"101"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm[1:12]*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rs2-1)*B_format_instruction
            in_memory_place_word(memory,memory_index,1,B_format_instruction)

        #27    #BLTU  rs1 rs2 offset
        elseif opcode == "BLTU"
            rs1 = parse(Int, parts[2][2:end])
            rs2 = parse(Int, parts[3][2:end])
            offset = parse(Int, parts[4]) 
            imm = int_to_signed_12bit_bin(offset)
            imm = '0'*imm[1:11]
            # B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"110"*imm[9:12]*imm[2]*B_format_instruction
            B_format_instruction = imm*int_to_5bit_bin(rs1)*"110"*int_to_5bit_bin(rs2)*B_format_instruction
            #Function has to be written after Memory 2d Array is formed

        #28    #BGEU  rs1 rs2 offset
        elseif opcode == "BGEU"
            rs1 = parse(Int, parts[2][2:end])+1
            rs2 = parse(Int, parts[3][2:end])+1
            offset = parse(Int, parts[4]) 
            imm = int_to_signed_12bit_bin(offset)
            imm = '0'*imm[1:11]
            B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"111"*imm[9:12]*imm[2]*B_format_instruction
            #Function has to be written after Memory 2d Array is formed

            
        #====================================================================================================================
                                                U Format Instructions          ( Upper Immediate Format )
        ====================================================================================================================#

        #29     #LUI rd, imm    #Load Upper immediate #Loads the immediate value imm into the upper 20 bits of register rd and sets the lower 12 bits to 0.
        elseif opcode == "LUI"
            rd = parse(Int, parts[2][2:end])+1
            imm_value = parse(Int, parts[3])      #Immediate value
            imm_value = int_to_20bit_bin(imm_value)
            U_format_instruction=imm_value*int_to_5bit_bin(rd-1)*U_format_instruction
            core.registers[rd] =  imm_value
            #Function has to be written after Memory 2d Array is formed


        #====================================================================================================================
                                                J Format Instructions          ( Jump Format )
        ====================================================================================================================#

        #30     #JAL rd label
            #JAL rd, offset
        elseif opcode == "JAL"
            rd = parse(Int, parts[2][2:end])+1
            label = parts[3]
            index = find_index_for_label(label_array,label)
            offset = (index - core.pc)         #Offset is in bytes
            imm = int_to_signed_20bit_bin_string(offset)
            #str = imm[1]*imm[11:end]*imm[10]*imm[2:9]
            #JAL_format_instruction=imm[1]*imm[11:20]*imm[10]*imm[2:9]*int_to_5bit_bin(rd-1)*JAL_format_instruction
            JAL_format_instruction=imm*int_to_5bit_bin(rd-1)*JAL_format_instruction
            in_memory_place_word(memory,memory_index,1,JAL_format_instruction)
       
        #30     #J Label
            #same as #JAL x0,label
        elseif opcode == "J"
            label = parts[2]
            rd = 0
            index = find_index_for_label(label_array,label)
            offset  = (index - core.pc)         #Offset is in bytes
            imm = int_to_signed_20bit_bin_string(offset)
            #JAL_format_instruction=imm[1]*imm[11:20]*imm[10]*imm[2:9]*"00000"*JAL_format_instruction
            JAL_format_instruction=imm*"00000"*JAL_format_instruction
            in_memory_place_word(memory,memory_index,1,JAL_format_instruction)

        #31     #JALR rs        # store in x1 core.pc+1
            #JALR rd, rs, offset
        elseif opcode == "JALR"
            if length(parts)==2
                rs = parse(Int, parts[2][2:end])
                rd = 1
                offset = 0
                imm = int_to_signed_12bit_bin(offset)
                JALR_format_instruction=imm*int_to_5bit_bin(rs)*"000"*int_to_5bit_bin(rd)*JALR_format_instruction
            elseif length(parts)>2
                rd = parse(Int, parts[2][2:end])
                rs = parse(Int, parts[3][2:end])
                offset = parse(Int, parts[4])
                imm = int_to_signed_12bit_bin(offset)
                JALR_format_instruction=imm*int_to_5bit_bin(rs)*"000"*int_to_5bit_bin(rd)*JALR_format_instruction
            end
            in_memory_place_word(memory,memory_index,1,JALR_format_instruction)
        #ecall
        elseif opcode == "ECALL"
            ecall_format_instruction = ("0"^25) * ecall_format_instruction
            in_memory_place_word(memory,memory_index,1,ecall_format_instruction)
        else
                memory_index -= 1   
        end
        core.pc+=1
        memory_index+=1
    end
    temp=core.pc
    core.pc = initial_index
    return temp
end