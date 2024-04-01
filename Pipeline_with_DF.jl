include("Execute_Operation.jl")

#==========================================================================================================
                                               Run Function
===========================================================================================================#

function run_with_df(processor::Processor)
    sim.cores[1].data_forwarding = true
    println("Running with DF")
    while !processor.cores[1].write_back_of_last_instruction_done
        processor.clock+=1
        processor.cores[1].clock+=1
        # println("\n",processor.cores[1].clock)
        operation_writeBack(    processor.cores[1],  processor.cores[1].instruction_WriteBack,  processor.cores[1].instruction_MEM)
        operation_memory_access(processor.cores[1],  processor.cores[1].instruction_MEM,        processor.cores[1].instruction_EX, processor)
        operation_execute(      processor.cores[1],  processor.cores[1].instruction_EX,         processor.cores[1].instruction_ID_RF)
        operation_instructionDecode_RegisterFetch(processor.cores[1] ,processor.cores[1].instruction_ID_RF)
        operation_instruction_Fetch(processor.cores[1],processor.cores[1].instruction_IF, processor)
        stall_manager(processor.cores[1])
        processor.cores[1].registers[1] = 0
    end
end

#==========================================================================================================
                                            Write Back
===========================================================================================================#
function operation_writeBack(core::Core_Object,instruction_WriteBack::Instruction,instruction_MEM::Instruction)
    temp = instruction_WriteBack.pipeline_reg
    copy_properties!(instruction_WriteBack,instruction_MEM)
    if instruction_WriteBack.stall_present
        return
    end
    if instruction_WriteBack.Four_byte_instruction!="uninitialized"
        core.instruction_count+=1
        if instruction_WriteBack.operator != "BEQ" && instruction_WriteBack.operator != "BNE" && instruction_WriteBack.operator != "BGE" && instruction_WriteBack.operator != "BLT" && instruction_WriteBack.operator != "SW" && instruction_WriteBack.operator != "SB"
            core.registers[instruction_WriteBack.rd+1] = instruction_WriteBack.pipeline_reg
        end
        # println("WB")
        core.write_back_of_last_instruction_done = true
        core.write_back_of_second_last_instruction_done = true
    else
        instruction_WriteBack.pipeline_reg = temp
    end
end
#==========================================================================================================
                                                  Mem
===========================================================================================================#

function operation_memory_access(core::Core_Object,instruction_MEM::Instruction,instruction_EX::Instruction,processor::Processor)
    copy_properties!(instruction_MEM, instruction_EX)
    if instruction_MEM.stall_present
        core.instruction_WriteBack.stall_present = true

        return
    end
    if instruction_MEM.stall_due_to_latency
        instruction_MEM.Four_byte_instruction = "uninitialized"
        return
    end
    if instruction_MEM.Four_byte_instruction!="uninitialized"
        # println("MEM")

        #--------------------------------------------------------------------------------------------#
        memory = processor.memory
        address = instruction_EX.pipeline_reg
        if instruction_MEM.operator == "LW"
            instruction_MEM.pipeline_reg = return_word_from_memory_littleEndian(memory,address)
        elseif instruction_MEM.operator == "LB"
            row,col = address_to_row_col(address)
            instruction_MEM.pipeline_reg = memory[row,col]
        elseif instruction_MEM.operator=="SW"
            row,col = address_to_row_col(address)
            bin = int_to_32bit_bin(core.registers[instruction_MEM.rs1+1])
            in_memory_place_word(memory,row,col,bin)
        end
        #--------------------------------------------------------------------------------------------#

        core.write_back_of_last_instruction_done = false
        if (core.instruction_WriteBack.Four_byte_instruction != "uninitialized")
            core.write_back_of_second_last_instruction_done = true
        else
            core.write_back_of_second_last_instruction_done = false
        end
        if core.instruction_IF.Four_byte_instruction != "uninitialized"
            core.write_back_of_second_last_instruction_done = false
        end
    end
    if (instruction_MEM.operator == "ADD/SUB") && (instruction_MEM.Four_byte_instruction[2]=='0') && (core.add_variable_latency > 1)
        core.instruction_ID_RF.stall_due_to_latency = false
        core.instruction_IF.stall_due_to_latency = false
    end
end

#==========================================================================================================
                                                  Ex
===========================================================================================================#

function operation_execute(core::Core_Object,instruction_EX::Instruction,instruction_ID_RF::Instruction)
    if !instruction_EX.stall_due_to_latency
        copy_properties!(instruction_EX,instruction_ID_RF)
        # Variable Latency
        if  (instruction_EX.operator == "ADD/SUB") && (instruction_EX.Four_byte_instruction[2]=='0') && core.add_variable_latency > 1
            core.variable_latency = core.add_variable_latency
        end
    end
    if instruction_EX.stall_present
        core.stall_count+=1
        core.instruction_MEM.stall_present = true
        instruction_EX.Four_byte_instruction="uninitialized"
        return
    end
    if latency_present(core,instruction_EX)
        core.write_back_of_last_instruction_done = false
        return 
    end
    if instruction_EX.stall_due_to_load
        core.stall_count+=1
        instruction_EX.Four_byte_instruction="uninitialized"
        instruction_EX.stall_due_to_load = false
        return
    end
    if instruction_EX.Four_byte_instruction!="uninitialized"
        Execute_Operation(core,instruction_EX)
        core.write_back_of_last_instruction_done = false
        # println("EX")
    end
end

#==========================================================================================================
                                                ID / RF
===========================================================================================================#

function operation_instructionDecode_RegisterFetch(core::Core_Object,instruction::Instruction)
    if instruction.stall_due_to_latency
        return
    end
    if instruction.stall_due_to_branch
        instruction.stall_due_to_branch = false
        instruction.Four_byte_instruction = "uninitialized"
        return 
    end
    if instruction.stall_present
        return
    end
    if instruction.stall_due_to_load
        instruction.stall_due_to_load = false
        return
    end
    instruction.Four_byte_instruction = Instruction_to_decode = core.instruction_IF.Four_byte_instruction
    if Instruction_to_decode!="uninitialized"
        #Instuction decode
        instruction.rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
        instruction.rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
        instruction.rd = parse(Int,Instruction_to_decode[21:25], base=2)
        instruction.immediate_value_or_offset = bin_string_to_signed_int(Instruction_to_decode[1:12])

        #Operator Decode
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        instruction.operator = get_instruction(opcode, func3)

        # Register Fetch
        if instruction.rs1!=0 instruction.source_reg[1] = core.registers[instruction.rs1+1]
        else instruction.source_reg[1] = 0
        end
        if instruction.rs2!=0 instruction.source_reg[2] = core.registers[instruction.rs2+1]
        else instruction.source_reg[2] = 0
        end
        core.write_back_of_last_instruction_done = false

        #For Jump statements no need to check for dependency
        if (opcode == "1101111") || (opcode == "1100111")                              #Jump Statements
            core.stall_due_to_jump = true
            core.instruction_IF.stall_due_to_jump = true

        #For Branch Statements we are first predicting and then checking for dependency
        #Priority is dependency and then prediction
        elseif (opcode == "1100011")          #Branch Statements
            core.branch_count+=1
            core.branch_taken = predict(core)
            core.branch_pc = core.pc - 1
            if (core.branch_taken) && (instruction.immediate_value_or_offset != 1)           # i.e. branch is taken
                core.instruction_IF.stall_due_to_branch = true
                offset = div(bin_string_to_signed_int(instruction.Four_byte_instruction[1:12]*"0"),4)
                core.pc = offset + core.pc - 1
                core.stall_count+=1
            #Branch not taken ,no need to consider
            end
            #Checking dependency
            previous_instruction = core.instruction_EX
            second_previous_instruction = core.instruction_MEM
            check_Dependency(opcode,instruction,previous_instruction,second_previous_instruction,core)
        else
            #Checking dependency
            previous_instruction = core.instruction_EX
            second_previous_instruction = core.instruction_MEM
            check_Dependency(opcode,instruction,previous_instruction,second_previous_instruction,core)
        end
        # println("ID/RF")
    end
end

#==========================================================================================================
                                                 IF
===========================================================================================================#

function operation_instruction_Fetch(core::Core_Object,instruction::Instruction,processor::Processor)
    if instruction.stall_due_to_latency
        return
    end
    if instruction.stall_present
        return
    end
    #Stall in next clock due to data dependency
    if (core.instruction_ID_RF.stall_present) && (!core.stall_due_to_jump)
        instruction.stall_present = true
    end
    if instruction.stall_due_to_branch
        instruction.stall_due_to_branch = false
        instruction.Four_byte_instruction = "uninitialized"
        return
    end
    if instruction.stall_due_to_jump
        instruction.stall_due_to_jump = false
        instruction.Four_byte_instruction = "uninitialized"
        return
    end
    if instruction.stall_due_to_load
        instruction.stall_due_to_load = false
        return
    end
    memory = processor.memory
    if core.pc<=length(core.program)
        instruction.Four_byte_instruction = int_to_8bit_bin(memory[core.pc,4])*int_to_8bit_bin(memory[core.pc,3])*int_to_8bit_bin(memory[core.pc,2])*int_to_8bit_bin(memory[core.pc,1])
        core.write_back_of_last_instruction_done = false
        # println("IF")
        core.pc+=1
    else
        instruction.Four_byte_instruction = "uninitialized"
    end
end

#==========================================================================================================
                                            Dependency Checker
===========================================================================================================#

function check_Dependency(opcode, instruction::Instruction, previous_instruction::Instruction, second_previous_instruction::Instruction, core::Core_Object)
    # ( Data Hazard on previous instruction )
    #--------------------------------------------------------------------------------------------#
    if opcode == "0110011"          # R Format Instructions
        if ( (instruction.rs1 == previous_instruction.rd || instruction.rs2 == previous_instruction.rd) ) && previous_instruction_checker(previous_instruction)
            if previous_instruction.operator != "LW" && previous_instruction.operator != "LB"
                if instruction.rs1 == previous_instruction.rd
                    core.rs1_dependent_on_previous_instruction = true
                end
                if instruction.rs2 == previous_instruction.rd
                    core.rs2_dependent_on_previous_instruction = true
                end
            else
                if instruction.rs1 == previous_instruction.rd
                    core.rs1_dependent_on_second_previous_instruction = true
                    core.stall_due_to_load = true
                end
                if instruction.rs2 == previous_instruction.rd
                    core.rs2_dependent_on_second_previous_instruction = true
                    core.stall_due_to_load = true
                end
            end
        end
        if ( (instruction.rs1 == second_previous_instruction.rd || instruction.rs2 == second_previous_instruction.rd) ) && second_previous_instruction_checker(core,second_previous_instruction)
            if instruction.rs1 == second_previous_instruction.rd
                core.rs1_dependent_on_second_previous_instruction = true
            end
            if instruction.rs2 == second_previous_instruction.rd
                core.rs2_dependent_on_second_previous_instruction = true
            end
        end
    #--------------------------------------------------------------------------------------------#
    elseif opcode == "0010011" || opcode == "0000011"     # I & L Format Instructions
        if (instruction.rs1==previous_instruction.rd) && previous_instruction_checker(previous_instruction)
            if previous_instruction.operator != "LW" && previous_instruction.operator != "LB"
                core.rs1_dependent_on_previous_instruction = true
            else
                core.rs1_dependent_on_second_previous_instruction = true
                core.stall_due_to_load = true
            end
        end
        if (instruction.rs1==second_previous_instruction.rd) && second_previous_instruction_checker(core,second_previous_instruction)
            core.rs1_dependent_on_second_previous_instruction = true
        end
            
    #--------------------------------------------------------------------------------------------#
    elseif opcode == "0100011" || opcode == "1100011"     # S & B Format Instructions
        if ( (instruction.rs1 == previous_instruction.rd) || (instruction.rd == previous_instruction.rd) ) && previous_instruction_checker(previous_instruction)
            # Which instruction's dependency
            if opcode == "0100011" core.store_dependency = true
            else core.branch_dependency = true
            end
            if previous_instruction.operator != "LW" && previous_instruction.operator != "LB"
                if instruction.rs1 == previous_instruction.rd
                    core.rs1_dependent_on_previous_instruction = true
                end
                if instruction.rd == previous_instruction.rd
                    core.rd_dependent_on_previous_instruction = true
                end
            else
                if instruction.rs1 == previous_instruction.rd
                    core.rs1_dependent_on_second_previous_instruction = true
                    core.stall_due_to_load = true
                end
                if instruction.rd == previous_instruction.rd
                    core.rd_dependent_on_second_previous_instruction = true
                    core.stall_due_to_load = true
                end
            end
        end
        if ( (instruction.rs1 == second_previous_instruction.rd) || (instruction.rd == second_previous_instruction.rd) ) && second_previous_instruction_checker(core,second_previous_instruction)
            # Which instruction's dependency
            if opcode == "0100011" core.store_dependency = true
            else core.branch_dependency = true
            end
            if instruction.rs1 == second_previous_instruction.rd
                core.rs1_dependent_on_second_previous_instruction = true
            end
            if instruction.rd == second_previous_instruction.rd
                core.rd_dependent_on_second_previous_instruction = true
            end
        end
    end
end
