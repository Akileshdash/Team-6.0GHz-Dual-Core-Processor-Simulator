include("Helper_Functions.jl")

function  Execute_Operation(core::Core_Object,instruction_EX::Instruction)
    rd_dependent = false    #Temporary variable,we need to remove it afterwards
    if !core.data_forwarding
        instruction_EX.source_reg[1] = core.registers[instruction_EX.rs1+1]
        instruction_EX.source_reg[2] = core.registers[instruction_EX.rs2+1]
    else
        # Checking dependency for rs1
        if core.rs1_dependent_on_previous_instruction
            instruction_EX.source_reg[1] = core.instruction_MEM.pipeline_reg 
            core.rs1_dependent_on_previous_instruction = false
        elseif core.rs1_dependent_on_second_previous_instruction
            instruction_EX.source_reg[1] = core.instruction_WriteBack.pipeline_reg
            core.rs1_dependent_on_second_previous_instruction = false
        end
        # Checking dependency for rs2
        if core.rs2_dependent_on_previous_instruction
            instruction_EX.source_reg[2] = core.instruction_MEM.pipeline_reg 
            core.rs2_dependent_on_previous_instruction = false
        elseif core.rs2_dependent_on_second_previous_instruction
            instruction_EX.source_reg[2] = core.instruction_WriteBack.pipeline_reg
            core.rs2_dependent_on_second_previous_instruction = false
        end
        # Checking dependency for rd because we have done encoding like that for Store and branch statements
        if core.rd_dependent_on_previous_instruction
            instruction_EX.rd = core.instruction_MEM.pipeline_reg 
            core.rd_dependent_on_previous_instruction = false
            rd_dependent = true
        elseif core.rd_dependent_on_second_previous_instruction
            instruction_EX.rd = core.instruction_WriteBack.pipeline_reg
            core.rd_dependent_on_second_previous_instruction = false
            rd_dependent = false
        end
    end

    #======================================================================
                        Executing R Format Operations          
    ======================================================================#
    
    if instruction_EX.operator == "ADD/SUB"
        if instruction_EX.Four_byte_instruction[2]=='0'    #ADD 
            instruction_EX.pipeline_reg = instruction_EX.source_reg[1] + instruction_EX.source_reg[2]
        else    #SUB
            instruction_EX.pipeline_reg = instruction_EX.source_reg[1] - instruction_EX.source_reg[2]
        end
    elseif instruction_EX.operator == "SLL"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] << instruction_EX.source_reg[2]
    elseif instruction_EX.operator == "OR"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] | instruction_EX.source_reg[2]
    elseif instruction_EX.operator == "AND"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] & instruction_EX.source_reg[2]

    #======================================================================
                        Executing I Format Operations          
    ======================================================================#

    elseif instruction_EX.operator == "ADDI"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] + instruction_EX.immediate_value_or_offset
    elseif instruction_EX.operator == "ORI"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] | instruction_EX.immediate_value_or_offset
    elseif instruction_EX.operator == "ANDI"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] & instruction_EX.immediate_value_or_offset
    elseif instruction_EX.operator == "SLLI"
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] << instruction_EX.immediate_value_or_offset
    #======================================================================
                        Executing Load Format Operations          
    ======================================================================#

    elseif (instruction_EX.operator == "LA") || (instruction_EX.operator == "LW") || (instruction_EX.operator == "LB")
        instruction_EX.immediate_value_or_offset = parse(UInt,instruction_EX.Four_byte_instruction[1:12], base=2)
        instruction_EX.pipeline_reg = instruction_EX.source_reg[1] + instruction_EX.immediate_value_or_offset

    #======================================================================
                        Executing Store Format Operations          
    ======================================================================#

    elseif (instruction_EX.operator == "SW") || (instruction_EX.operator == "SB")
        if core.data_forwarding && core.store_dependency
            instruction_EX.pipeline_reg = instruction_EX.rd + instruction_EX.immediate_value_or_offset
            core.store_dependency = false
        else
            instruction_EX.pipeline_reg = core.registers[instruction_EX.rd + 1] + instruction_EX.immediate_value_or_offset
        end

    #======================================================================
                        Executing JUMP Format Operations          
    ======================================================================#
    
    elseif instruction_EX.operator == "JAL"
        instruction_EX.pipeline_reg = core.pc           #Because after IF stage we are incrementing the pc
        offset = bin_string_to_signed_int(instruction_EX.Four_byte_instruction[1:20])
        core.pc = core.pc + offset  - 1

    #======================================================================
                        Executing Branch Format Operations          
    ======================================================================# 
    elseif instruction_EX.operator == "BEQ"
        condition = false
        if core.data_forwarding && core.branch_dependency && rd_dependent
            core.branch_dependency = false
            rd_dependent = false
            if instruction_EX.source_reg[1] == instruction_EX.rd 
                condition = true
            end
        else
            if instruction_EX.source_reg[1] == core.registers[instruction_EX.rd+1] 
                condition = true
            end
        end
        if condition      #Branch actually taken
            updatePrediction(true,core)
            if !core.branch_taken       #But prediction is not taken
                offset = div(bin_string_to_signed_int(core.instruction_EX.Four_byte_instruction[1:12]*"0"),4)
                core.pc = core.pc + offset - 2
                core.instruction_IF.stall_due_to_branch = true
                core.instruction_ID_RF.stall_due_to_branch = true
                core.stall_count+=2
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        else         #Branch actually not taken
            updatePrediction(false,core)
            if core.branch_taken        #But prediction is taken
                core.pc = core.branch_pc + 1
                core.instruction_IF.stall_due_to_branch = true
                core.stall_count+=1
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        end
    elseif instruction_EX.operator == "BNE"
        condition = false
        if core.data_forwarding && core.branch_dependency && rd_dependent
            core.branch_dependency = false
            rd_dependent = false
            if instruction_EX.source_reg[1] != instruction_EX.rd 
                condition = true
            end
        else
            if instruction_EX.source_reg[1] != core.registers[instruction_EX.rd+1] 
                condition = true
            end
        end
        if condition      #Branch actually taken
            updatePrediction(true,core)
            if !core.branch_taken       #But prediction is not taken
                offset = div(bin_string_to_signed_int(core.instruction_EX.Four_byte_instruction[1:12]*"0"),4)
                core.pc = core.pc + offset - 2
                core.instruction_IF.stall_due_to_branch = true
                core.instruction_ID_RF.stall_due_to_branch = true
                core.stall_count+=2
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        else         #Branch actually not taken
            updatePrediction(false,core)
            if core.branch_taken        #But prediction is taken
                core.pc = core.branch_pc + 1
                core.instruction_IF.stall_due_to_branch = true
                core.stall_count+=1
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        end
    elseif instruction_EX.operator == "BLT"
        condition = false
        if core.data_forwarding && core.branch_dependency && rd_dependent
            core.branch_dependency = false
            rd_dependent = false
            if instruction_EX.source_reg[1] < instruction_EX.rd 
                # println("Dependent ",instruction_EX.rs1," = ",instruction_EX.source_reg[1]," instruction_EX.rd  = ",instruction_EX.rd)
                condition = true
            end
        else
            if instruction_EX.source_reg[1] < core.registers[instruction_EX.rd+1] 
                # println("Not Dependent ",instruction_EX.rs1," ",instruction_EX.rd)
                condition = true
            end
        end
        if condition      #Branch actually taken
            updatePrediction(true,core)
            if !core.branch_taken       #But prediction is not taken
                offset = div(bin_string_to_signed_int(core.instruction_EX.Four_byte_instruction[1:12]*"0"),4)
                core.pc = core.pc + offset - 2
                core.instruction_IF.stall_due_to_branch = true
                core.instruction_ID_RF.stall_due_to_branch = true
                core.stall_count+=2
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        else         #Branch actually not taken
            updatePrediction(false,core)
            if core.branch_taken        #But prediction is taken
                core.pc = core.branch_pc + 1
                core.instruction_IF.stall_due_to_branch = true
                core.stall_count+=1
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        end
    elseif instruction_EX.operator == "BGE"
        condition = false
        if core.data_forwarding && core.branch_dependency && rd_dependent
            core.branch_dependency = false
            rd_dependent = false
            if instruction_EX.source_reg[1] >= instruction_EX.rd 
                condition = true
            end
        else
            if instruction_EX.source_reg[1] >= core.registers[instruction_EX.rd+1] 
                condition = true
            end
        end
        if condition      #Branch actually taken
            updatePrediction(true,core)
            if !core.branch_taken       #But prediction is not taken
                offset = div(bin_string_to_signed_int(core.instruction_EX.Four_byte_instruction[1:12]*"0"),4)
                core.pc = core.pc + offset - 2
                core.instruction_IF.stall_due_to_branch = true
                core.instruction_ID_RF.stall_due_to_branch = true
                core.stall_count+=2
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        else         #Branch actually not taken
            updatePrediction(false,core)
            if core.branch_taken        #But prediction is taken
                core.pc = core.branch_pc + 1
                core.instruction_IF.stall_due_to_branch = true
                core.stall_count+=1
            else    #Correct prediction
                core.branch_correct_predict_count+=1
            end
        end
    end
end