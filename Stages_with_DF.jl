include("Execute_Operation_phase2.jl")
                            
#==========================================================================================================
                                               Run Function
===========================================================================================================#


function run_with_DF(processor::Processor)
    println("Running with DF")
    while !processor.cores[1].writeBack_of_last_instruction
        processor.clock+=1
        if processor.cores[1].stall_in_present_clock
            #println("Stall Present at clock : ",processor.clock)
            processor.cores[1].stall_count+=1
        end 
        writeBack(processor.cores[1],processor)
        memory_access(processor.cores[1],processor)
        execute(processor.cores[1],processor)
        instructionDecode_RegisterFetch(processor.cores[1],processor)
        instruction_Fetch(processor.cores[1],processor)
    end
end

#==========================================================================================================
                                            Write Back
===========================================================================================================#

function writeBack(core::Core_Object,processor::Processor)
    core.instruction_reg_after_Write_Back = Instruction_to_decode = core.instruction_reg_after_Memory_Access
    if Instruction_to_decode!="uninitialized"
        # println("Instruction Write Back at clock : ",processor.clock)
        core.instruction_count+=1
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
        # println("Instruction Memory Access at clock : ",processor.clock)
        rs1 = parse(Int,Instruction_to_decode[13:17], base=2) + 1
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        operator = get_instruction(opcode, func3)
        core.previous_mem_reg = core.mem_reg
        if !core.data_forwarding_for_Store_rs
            core.mem_reg = core.execution_reg
        end
        address = core.execution_reg
        if operator == "LW"
            core.mem_reg = return_word_from_memory_littleEndian(memory,address)
        elseif operator=="LA"
            core.mem_reg = core.execution_reg
        elseif operator == "LB"
            row,col = address_to_row_col(address)
            core.mem_reg = memory[row,col]
        elseif operator=="SW"
            bin = ""
            row,col = address_to_row_col(address)
            if core.data_forwarding_for_Store_rs
                bin = int_to_32bit_bin(core.mem_reg)
                core.data_forwarding_for_Store_rs = false
            # if core.data_forwarding_for_Store_rs
            #     bin = int_to_32bit_bin(core.data_forwarding_reg_rs1)
            #     core.data_forwarding_reg_rs1 = 0
            #     core.data_forwarding_for_Store_rs = false
            else
                bin = int_to_32bit_bin(core.registers[rs1])
            end
            in_memory_place_word(memory,row,col,bin)
        elseif operator == "SB"
            address = core.execution_reg
            row,col = address_to_row_col(address)
            memory[row,col] = core.registers[rs1]
        end
        core.writeBack_of_last_instruction = false
        core.registers[1]=0
        if core.writeBack_of_second_last_instruction
            return
        end
        if core.instruction_reg_after_Write_Back!="uninitialized"
            core.writeBack_of_second_last_instruction = true
        else
            core.writeBack_of_second_last_instruction = false
        end
    end
end

#==========================================================================================================
                                                  Ex
===========================================================================================================#

function execute(core::Core_Object,processor::Processor)
    if core.stall_due_to_load
        if core.rs1_dependent_on_previous_instruction
            core.data_forwarding_reg_rs1 = core.mem_reg
            core.rs1_dependent_on_previous_instruction = false
            core.instruction_reg_after_Execution = "uninitialized"
        end
        return
    end
    if core.stall_in_present_clock||core.stall_at_execution||core.stall_due_to_df
        core.instruction_reg_after_Execution = "uninitialized"
        return
    end
    core.instruction_reg_after_Execution = core.instruction_reg_after_ID_RF
    if core.instruction_reg_after_Execution!="uninitialized"
        # println("Instruction Executed at clock : ",processor.clock)
        Execute_Operation(core) 
        core.writeBack_of_last_instruction = false
    end
    core.registers[1]=0
end

#==========================================================================================================
                                                ID / RF
===========================================================================================================#

function instructionDecode_RegisterFetch(core::Core_Object,processor::Processor)
    if core.stall_due_to_df
        if core.regi_dependent_on_previous_instruction
            #We are forwarding the data loaded from the mem reg to another temp reg which will be accessed in the execution stage
            core.data_forwarding_reg_i = core.mem_reg
            core.regi_dependent_on_previous_instruction = false
        end
        if core.rs1_dependent_on_previous_instruction
            core.data_forwarding_reg_rs1 = core.mem_reg
            if core.data_forwarding_for_branch
                core.rs1_dependent_on_previous_instruction = false
            end
        end
        if core.rs2_dependent_on_previous_instruction
            core.data_forwarding_reg_rs2 = core.mem_reg
            if core.data_forwarding_for_branch
                core.rs2_dependent_on_previous_instruction = false
                
            end
        end
        return
    end
    if core.stall_in_present_clock
        return
    end
    core.instruction_reg_after_ID_RF = Instruction_to_decode = core.instruction_reg_after_IF
    if core.instruction_reg_after_ID_RF!="uninitialized"

        # Register Fetch
        core.rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
        core.rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)
        core.immediate_value_or_offset = bin_string_to_signed_int(Instruction_to_decode[1:12])

        #Updating Previous Operator and second previous operator before updating present operator
        core.second_previous_operator = core.previous_operator
        core.previous_operator = core.present_operator

        #Instruction Decode
        opcode = Instruction_to_decode[26:32]
        func3 = Instruction_to_decode[18:20]
        core.present_operator = get_instruction(opcode, func3)

        # println("Instruction Decoded at clock : ",processor.clock)
        #======================================================================
                            Checking for I Format Operations          
        ======================================================================#
        #I Type Instructions done
        #Data forwarding for I instructions done .Dependency of I instructions on Load Statements done. There is no dependency on Store statements
        if opcode=="0010011"    # I Format Instructions
            if (core.rs1==core.rd)&&(core.previous_operator!="SW"||core.previous_operator!="SB")
                core.data_forwarding_on = true
                core.regi_dependent_on_previous_instruction = true
                #=If previous instruction was LW or LB, then we have to wait till they load into the 
                temporary mem reg. So there will be one stall=#
                if core.previous_operator == "LW"||core.previous_operator == "LB"
                    core.stall_due_to_df = true
                else
                    core.data_forwarding_reg_i = core.execution_reg
                end
            elseif (core.rs1 == core.rd_second_before)&&(core.second_previous_operator!="SW"||core.second_previous_operator!="SB")
                if !core.writeBack_of_second_last_instruction
                    core.data_forwarding_on = true
                    core.data_forwarding_reg_i = core.mem_reg
                end
            end

        #======================================================================
                            Checking for R Format Operations          
        ======================================================================#
        #R Type Instructions done
        elseif opcode=="0110011"        #Checking It is not a branch Statement
            #Checking Data Dependency on one instruction before
            if (core.rs2==core.rd||core.rs1==core.rd)&&(core.previous_operator!="SW"||core.previous_operator!="SB")
                if core.rs1==core.rd
                    core.rs1_dependent_on_previous_instruction = true
                    core.data_forwarding_on = true
                    if core.previous_operator == "LW"||core.previous_operator == "LB"
                        core.stall_due_to_df = true
                    else
                        core.data_forwarding_reg_rs1  = core.execution_reg
                    end
                end
                if core.rs2==core.rd
                    core.rs2_dependent_on_previous_instruction = true
                    core.data_forwarding_on = true
                    if core.previous_operator == "LW"||core.previous_operator == "LB"
                        core.stall_due_to_df = true
                    else
                        core.data_forwarding_reg_rs2  = core.execution_reg
                    end
                end
            end

            #Checking Data Dependency on one more instruction before
            if core.rs1==core.rd_second_before || core.rs2==core.rd_second_before
                if core.rs1==core.rd_second_before&&core.rs1!=core.rd
                    core.data_forwarding_reg_rs1 = core.mem_reg
                    data_forwarding_on = true
                end
                if core.rs2==core.rd_second_before&&core.rs2!=core.rd
                    core.data_forwarding_reg_rs2 = core.mem_reg        
                    data_forwarding_on = true
                end
            end
        
        #======================================================================
                            Checking for J Format Operations          
        ======================================================================#
        #It is jump statement
        elseif opcode=="1101111"     #JAL Statement
            core.rd_second_before = core.rd
            core.rd = -1
            core.stall_due_to_jump = true
            core.writeBack_of_last_instruction = false
            return
        #======================================================================
                            Checking for L & S Format Operations          
        ======================================================================#
        #Data Forwarding for Load and Store Instructions done
        elseif opcode=="0000011"||opcode=="0100011"        # Load and Store Statements respective opcodes
            #LW = 0000011 , SW = 0100011
            #For Load : LW rd, rs2(rs1)
            #For Store: SW rs1,rs2(rd)

            #Checking dependency on last instruction

            if (core.rs1==core.rd||rd==core.rd)&&(core.previous_operator!="BEQ"&&core.previous_operator!="BNE"&&core.previous_operator!="BLT"&&core.previous_operator!="BGE")
                #Checking if destination register is dependent or not
                #Checking if destination register is dependent or not only for Store statments
                #As for Load statements anything in destination register will be overwritten
                #Hence no need to check its dependency
                if core.rs1==core.rd
                    if core.present_operator=="SW" && core.previous_operator=="LW"
                        core.data_forwarding_for_Store_rs = true
                        core.rs1_dependent_on_previous_instruction = true
                    elseif core.present_operator=="LW" 
                        core.data_forwarding_on = true
                        core.data_forwarding_reg_rs1 = core.execution_reg
                    end
                    core.writeBack_of_last_instruction = false
                    core.rd_second_before = core.rd
                    core.rd=rd
                    return
                end
                if core.rs1==core.rd_second_before
                    if core.present_operator=="SW" && core.second_previous_operator=="LW"
                    elseif  core.present_operator=="LW" && core.previous_operator=="JAL"
                    end
                    core.writeBack_of_last_instruction = false
                    core.rd_second_before = core.rd
                    core.rd=rd
                    return 
                end
                if rd==core.rd && opcode=="SW" && core.previous_operator!="SW"
                    core.data_forwarding_reg_rd = core.execution_reg
                    core.data_forwarding_on = true
                end

            
                #No need to check the second last instruction for rs1 for store as in mean time wb of second last instruction will be done 
                if core.rs1==core.rd && core.previous_operator!="SW" && core.previous_operator!="JAL"
                    core.data_forwarding_on = true
                    #Same don't check the second last previous dependency for rd for load statements
                    if rd==core.rd_second_before && opcode=="0100011" core.second_previous_operator!="SW"
                        core.data_forwarding_reg_rd = core.mem_reg
                    end
                    core.data_forwarding_reg_rs1  = core.execution_reg
                    core.data_forwarding_on = true
                    core.data_forwarding_for_Store_rs = true
                #But for Store we need to check the second last instruction rd for rs1.
                #If rs1 is dependent on previous rd ,then no need to check for the dependence on second last rd as it will get overwritten by the last instruction
                elseif core.rs1==core.rd_second_before
                    core.data_forwarding_on = true
                    core.data_forwarding_reg_rs1 = core.mem_reg
                end
            end
            # if rd==core.rd_second_before && opcode=="0100011" && core.second_previous_operator!="SW"
            




        #======================================================================
                            Checking for B Format Operations          
        ======================================================================#
        #Branch Statement
        elseif opcode=="1100011"    #Checking It is a branch Instruction
            #BEQ rs1,rd,rs2
            #If BEQ x5,x6,label
            #core.rs1 = 5
            #rd = 6
            #In Branch instructions Data is Dependent on last instruction   ( Done )
            if (core.rs1==core.rd||rd==core.rd)&&(core.previous_operator!="BEQ"&&core.previous_operator!="BNE"&&core.previous_operator!="BLT"&&core.previous_operator!="BGE")
                core.data_forwarding_on = true
                core.data_forwarding_for_branch = true
                if core.rs1==core.rd
                    core.rs1_dependent_on_previous_instruction = true
                end
                if rd==core.rd
                    core.rs2_dependent_on_previous_instruction = true
                end
                if core.previous_operator!="LW"&&core.previous_operator!="LB"&&core.previous_operator!="SW"&&core.previous_operator!="SB"
                    core.stall_at_instruction_fetch = true
                end
                if core.previous_operator == "LW"||core.previous_operator == "LB"
                    core.stall_due_to_df = true
                end
                core.rd_second_before = core.rd
                core.rd=-1
                return
            end

            #Checking Data Dependency on second last instruction .
            #If dependent on last instruction then no need to check for second last instruction as it will be wb due to that stall
            #that's why we are returning in the previous if condition
            if (core.rs1==core.rd_second_before || rd==core.rd_second_before)&&(core.second_previous_operator!="BEQ"&&core.second_previous_operator!="BNE"&&core.second_previous_operator!="BLT"&&core.second_previous_operator!="BGE")
                if core.rs1==core.rd_second_before
                    core.rs1_dependent_on_second_previous_instruction = true
                end
                if rd==core.rd_second_before
                    core.rs2_dependent_on_second_previous_instruction = true
                end
                core.stall_at_instruction_fetch = true
                core.rd_second_before = core.rd
                core.rd=-1
                return
            end

            #Branch Prediction - Static Prediction : i.e the branch is always not taken
            offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
            if core.present_operator == "BEQ"
                if core.registers[core.rs1+1]==core.registers[rd+1]
                    if offset!=1        #Branch to be chosen is not the next one
                        core.stall_at_instruction_fetch = true
                        if core.stall_at_execution && core.stall_in_next_clock
                            core.stall_at_execution = false
                            core.stall_in_next_clock = false
                        end
                    end
                end
            elseif core.present_operator == "BNE"
                if core.registers[core.rs1+1]!=core.registers[rd+1]
                    if offset!=1        #Branch to be chosen is not the next one
                        core.stall_at_instruction_fetch = true
                        if core.stall_at_execution && core.stall_in_next_clock
                            core.stall_at_execution = false
                            core.stall_in_next_clock = false
                        end
                    end
                end
            elseif core.present_operator == "BLT"
                if core.registers[core.rs1+1]<core.registers[rd+1]
                    if offset!=1        #Branch to be chosen is not the next one
                        core.stall_at_instruction_fetch = true
                        if core.stall_at_execution && core.stall_in_next_clock
                            core.stall_at_execution = false
                            core.stall_in_next_clock = false
                        end
                    end
                end
            elseif core.present_operator == "BGE"
                if core.registers[core.rs1+1]>=core.registers[rd+1]
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
    if core.stall_due_to_jump
        core.stall_due_to_jump = false
        core.stall_count+=1
        core.instruction_reg_after_IF = "uninitialized"
        return
    end
    if core.stall_due_to_load
        if !core.rs1_dependent_on_previous_instruction
            core.stall_due_to_load = false
            return
        end
    end
    if core.stall_due_to_df
        if core.data_forwarding_for_branch
            if (!core.rs1_dependent_on_previous_instruction)&&(!core.rs2_dependent_on_previous_instruction)
                core.stall_due_to_df = false
                core.data_forwarding_for_branch = false
                return
            end
        end
        if !core.regi_dependent_on_previous_instruction&&!core.rs1_dependent_on_previous_instruction&&!core.rs2_dependent_on_previous_instruction
            core.stall_due_to_df = false
            return
        end
        core.stall_count+=1
        core.instruction_reg_after_IF = "uninitialized"
        core.data_forwarding_on = false
        return
    end
    if core.stall_at_instruction_fetch 
        core.instruction_reg_after_IF = "uninitialized"
        core.stall_at_instruction_fetch = false
        core.stall_count+=1
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
            core.writeBack_of_second_last_instruction = true
        else
            core.stall_in_present_clock = true
        end
        return
    end
    if core.pc<=length(core.program)
        # println("Instruction fetch at clock : ",processor.clock)
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
