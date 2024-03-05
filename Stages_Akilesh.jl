include("Execute_Operation_phase2.jl")
                            
#==========================================================================================================
                                               Run Function
===========================================================================================================#


function run(processor::Processor)
    while !processor.cores[1].writeBack_of_last_instruction
        processor.clock+=1
        if processor.cores[1].stall_in_present_clock
            println("Stall Present at clock : ",processor.clock)
            processor.cores[1].stall_count+=1
        end 
        writeBack(processor.cores[1],processor)
        memory_access(processor.cores[1],processor)
        execute(processor.cores[1],processor)
        instructionDecode_RegisterFetch(processor.cores[1],processor)
        instruction_Fetch(processor.cores[1],processor)
        # sleep(0.75)
    end
end

#==========================================================================================================
                                            Write Back
===========================================================================================================#

function writeBack(core::Core_Object,processor::Processor)
    core.instruction_reg_after_Write_Back = Instruction_to_decode = core.instruction_reg_after_Memory_Access
    if Instruction_to_decode!="uninitialized"
        println("Instruction Write Back at clock : ",processor.clock)
        rd = parse(Int,Instruction_to_decode[21:25], base=2) + 1
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        operator = get_instruction(opcode, func3)
        if any(value ->operator  in values(value), values(operator_dict_RI))
            core.registers[rd] = core.mem_reg
        elseif operator=="LA"||operator=="LW"||operator=="LB"||operator=="JAL"||operator=="JALR"
            core.registers[rd] = core.mem_reg
        end
        core.writeBack_of_last_instruction = true
        core.writeBack_of_second_last_instruction = true
    end
    core.registers[1]=0
end

#==========================================================================================================
                                                  Mem
===========================================================================================================#

function memory_access(core::Core_Object,processor::Processor)
    memory = processor.memory
    core.instruction_reg_after_Memory_Access = Instruction_to_decode = core.instruction_reg_after_Execution
    if core.instruction_reg_after_Memory_Access!="uninitialized"
        # core.Bus_in_use = true
        println("Instruction Memory Access at clock : ",processor.clock)
        rs1 = parse(Int,Instruction_to_decode[13:17], base=2) + 1
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        operator = get_instruction(opcode, func3)

        core.mem_reg = address = core.execution_reg
        if operator == "LW"
            core.mem_reg = return_word_from_memory_littleEndian(memory,address)
        elseif operator=="LA"
            core.mem_reg = core.execution_reg
        elseif operator == "LB"
            row,col = address_to_row_col(address)
            core.mem_reg = memory[row,col]
        elseif operator=="SW"
            row,col = address_to_row_col(address)
            bin = int_to_32bit_bin(core.registers[rs1])
            in_memory_place_word(memory,row,col,bin)
        elseif operator == "SB"
            address = core.execution_reg
            row,col = address_to_row_col(address)
            memory[row,col] = core.registers[rs1]
        end
        core.writeBack_of_last_instruction = false
        if core.instruction_reg_after_Write_Back!="uninitialized"
            core.writeBack_of_second_last_instruction = true
        else
            core.writeBack_of_second_last_instruction = false
        end
    end
    core.registers[1]=0
end

#==========================================================================================================
                                                  Ex
===========================================================================================================#

function execute(core::Core_Object,processor::Processor)
    # println("at execute clock :  ",processor.clock," core.stall_in_present_clock= ",core.stall_in_present_clock)
    if core.stall_in_present_clock||core.stall_at_execution
        core.instruction_reg_after_Execution = "uninitialized"
        return
    end
    core.instruction_reg_after_Execution = core.instruction_reg_after_ID_RF
    if core.instruction_reg_after_Execution!="uninitialized"
        println("Instruction Executed at clock : ",processor.clock)
        Execute_Operation(core) 
        core.writeBack_of_last_instruction = false
        core.writeBack_of_second_last_instruction = false
    end
    core.registers[1]=0
end

#==========================================================================================================
                                                ID / RF
===========================================================================================================#

function instructionDecode_RegisterFetch(core::Core_Object,processor::Processor)
    if core.stall_in_present_clock
        return
    end
    core.instruction_reg_after_ID_RF = Instruction_to_decode = core.instruction_reg_after_IF
    if core.instruction_reg_after_ID_RF!="uninitialized"
        println("Instruction Decoded at clock : ",processor.clock)
        # Register Fetch
        core.rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
        core.rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)
        
        core.immediate_value_or_offset = bin_string_to_signed_int(Instruction_to_decode[1:12])

        #Instruction Decode
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        core.operator = get_instruction(opcode, func3)
        if opcode=="0010011"    # I Format Instructions
            if core.rs1==core.rd
                core.stall_in_next_clock = true
                println("It is dependent 0.1")
            elseif core.rs1 == core.rd_second_before
                if !core.writeBack_of_second_last_instruction
                    core.stall_at_execution = true
                    core.stall_in_next_clock = true
                    println("It is dependent 0.2")
                end
            end

        elseif opcode!="1100011"        #Checking It is not a branch Statement
            #Checking Data Dependency on one instruction before
            if core.rs2==core.rd||core.rs1==core.rd
                core.stall_in_next_clock = true
                println("It is dependent 1")
            #Checking Data Dependency on one more instruction before
            elseif core.rs1==core.rd_second_before || core.rs2==core.rd_second_before
                if !core.writeBack_of_second_last_instruction
                    core.stall_at_execution = true
                    core.stall_in_next_clock = true
                    println("It is dependent 2")
                end
            end

        elseif opcode=="1100011"    #Chechking It is a branch Instruction

            #In Branch instructions Data is Dependent on last instruction 

            if core.rs1==core.rd||rd==core.rd
                core.stall_in_next_clock = true
                println("It is dependent 3")
                core.writeBack_of_last_instruction = false
                core.stall_at_instruction_fetch = true
                core.rd_second_before = core.rd
                core.rd=rd
                return
            end

            #Checking Data Dependency on second last instruction 

            if core.rs1==core.rd_second_before || rd==core.rd_second_before
                if !core.writeBack_of_second_last_instruction
                    core.stall_at_instruction_fetch = true
                    core.stall_at_execution = true
                    core.stall_in_next_clock = true
                    println("It is dependent 4")
                end
                core.stall_at_instruction_fetch = true
                return
            end
            offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
            if core.operator == "BEQ"
                if core.registers[core.rs1+1]==core.registers[rd+1]
                    if offset!=1        #Branch to be chosen is not the next one
                        core.stall_at_instruction_fetch = true
                        if core.stall_at_execution && core.stall_in_next_clock
                            core.stall_at_execution = false
                            core.stall_in_next_clock = false
                        end
                    end
                end
            end
        end
        core.writeBack_of_last_instruction = false
        core.rd_second_before = core.rd
        core.rd=rd
    end
    core.registers[1]=0
end


#==========================================================================================================
                                                 IF
===========================================================================================================#

function instruction_Fetch(core::Core_Object,processor::Processor)
    memory = processor.memory
    if core.stall_at_instruction_fetch 
        core.instruction_reg_after_IF = "uninitialized"
        core.stall_at_instruction_fetch = false
        core.stall_count+=1
        println("Stall due to branch statment at clock : ",processor.clock," core.stall_in_next_clock = ",core.stall_in_next_clock)
        if core.stall_in_next_clock
            core.stall_in_present_clock = true
            core.stall_in_next_clock = false
        end
        return
    end
    if core.stall_at_execution
        if core.writeBack_of_second_last_instruction
            core.stall_at_execution = false
            core.stall_in_present_clock = false
            return 
        end
    end
    if core.stall_in_present_clock
        if core.writeBack_of_last_instruction
            core.stall_in_present_clock = false
            core.writeBack_of_last_instruction = false
        else
            core.stall_in_present_clock = true
        end
        return
    end
    if core.pc<=length(core.program)
        println("Instruction fetch at clock : ",processor.clock)
        core.instruction_reg_after_IF = int_to_8bit_bin(memory[core.pc,4])*int_to_8bit_bin(memory[core.pc,3])*int_to_8bit_bin(memory[core.pc,2])*int_to_8bit_bin(memory[core.pc,1])
        core.writeBack_of_last_instruction = false
        core.pc+=1
    else
        core.instruction_reg_after_IF = "uninitialized"
    end
    core.registers[1]=0
    if core.stall_in_next_clock
        core.stall_in_present_clock = true
        core.stall_in_next_clock = false
    end
end
