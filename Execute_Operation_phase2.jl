include("Helper_Functions.jl")

function  Execute_Operation(core::Core_Object)
    Instruction_to_decode = core.instruction_reg_after_Execution
    #Since Julia is 1 indexing arr[0] is not defined
    core.rs1+=1
    core.rs2+=1
    core.rd+=1
        #======================================================================
                            Executing R Format Operations          
        ======================================================================#
    
    if core.present_operator=="ADD/SUB"
        if Int(Instruction_to_decode[2])-48==0
            #Add operation
            if core.data_forwarding_on
                if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 + core.registers[core.rs2]
                elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                    core.execution_reg = core.registers[core.rs1] + core.data_forwarding_reg_rs2
                else    #i.e both are dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 + core.data_forwarding_reg_rs2
                end                    
            else
                core.execution_reg = core.registers[core.rs1] + core.registers[core.rs2]
            end
        elseif Int(Instruction_to_decode[2])-48==1
            #Sub operation
            if core.data_forwarding_on
                if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 - core.registers[core.rs2]
                elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                    core.execution_reg = core.registers[core.rs1] - core.data_forwarding_reg_rs2
                else    #i.e rs1 and rs2 are dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 - core.data_forwarding_reg_rs2
                end                    
            else
                core.execution_reg = core.registers[core.rs1] - core.registers[core.rs2]
            end
        end
    elseif core.present_operator=="SLL"
        if core.data_forwarding_on
            if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                core.execution_reg = core.data_forwarding_reg_rs1 << core.registers[core.rs2]
            elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                core.execution_reg = core.registers[core.rs1] << core.data_forwarding_reg_rs2
            else    #i.e both are dependent
                core.execution_reg = core.data_forwarding_reg_rs1 << core.data_forwarding_reg_rs2
            end                    
        else
            core.execution_reg = core.registers[core.rs1] << core.registers[core.rs2]
        end
    elseif core.present_operator=="XOR"
        if core.data_forwarding_on
            if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                core.execution_reg = core.data_forwarding_reg_rs1 $ core.registers[core.rs2]
            elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                core.execution_reg = core.registers[core.rs1] $ core.data_forwarding_reg_rs2
            else    #i.e both are dependent
                core.execution_reg = core.data_forwarding_reg_rs1 $ core.data_forwarding_reg_rs2
            end                    
        else
            core.execution_reg = core.registers[core.rs1] $ core.registers[core.rs2]
        end
    elseif core.present_operator=="SRL/SRA"
        if Int(Instruction_to_decode[2])-48==0
            #SRL operation
            if core.data_forwarding_on
                if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 >>> core.registers[core.rs2]
                elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                    core.execution_reg = core.registers[core.rs1] >>> core.data_forwarding_reg_rs2
                else    #i.e both are dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 >>> core.data_forwarding_reg_rs2
                end                    
            else
                core.execution_reg = core.registers[core.rs1] >>> core.registers[core.rs2]
            end
        elseif Int(Instruction_to_decode[2])-48==1
            #SRA operation
            if core.data_forwarding_on
                if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 >> core.registers[core.rs2]
                elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                    core.execution_reg = core.registers[core.rs1] >> core.data_forwarding_reg_rs2
                else    #i.e both are dependent
                    core.execution_reg = core.data_forwarding_reg_rs1 >> core.data_forwarding_reg_rs2
                end                    
            else
                core.execution_reg = core.registers[core.rs1] >> core.registers[core.rs2]
            end
        end
    elseif core.present_operator=="OR"
        if core.data_forwarding_on
            if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                core.execution_reg = core.data_forwarding_reg_rs1 | core.registers[core.rs2]
            elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                core.execution_reg = core.registers[core.rs1] | core.data_forwarding_reg_rs2
            else    #i.e both are dependent
                core.execution_reg = core.data_forwarding_reg_rs1 | core.data_forwarding_reg_rs2
            end                    
        else
            core.execution_reg = core.registers[core.rs1] | core.registers[core.rs2]
        end
    elseif core.present_operator=="AND"
        if core.data_forwarding_on
            if core.data_forwarding_reg_rs1!=0&&core.data_forwarding_reg_rs2==0         #i.e rs1 is dependent and rs2 is not dependent
                core.execution_reg = core.data_forwarding_reg_rs1 & core.registers[core.rs2]
            elseif core.data_forwarding_reg_rs1==0&&core.data_forwarding_reg_rs2!=0         #i.e rs1 is not dependent and rs2 is dependent
                core.execution_reg = core.registers[core.rs1] & core.data_forwarding_reg_rs2
            else    #i.e both are dependent
                core.execution_reg = core.data_forwarding_reg_rs1 & core.data_forwarding_reg_rs2
            end                    
        else
            core.execution_reg = core.registers[core.rs1] & core.registers[core.rs2]
        end

        #======================================================================
                            Executing I Format Operations          
        ======================================================================#
 
    elseif core.present_operator=="ADDI"
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_i + core.immediate_value_or_offset
            # println("Came here for execution")
        else
            core.execution_reg = core.registers[core.rs1] + core.immediate_value_or_offset
        end
    elseif core.present_operator=="XORI"
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_i $ core.immediate_value_or_offset
        else
            core.execution_reg = core.registers[core.rs1] $ core.immediate_value_or_offset
        end
    elseif core.present_operator=="ORI"
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_i | core.immediate_value_or_offset
        else
            core.execution_reg = core.registers[core.rs1] | core.immediate_value_or_offset
        end
    elseif core.present_operator=="ANDI"
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_i & core.immediate_value_or_offset
        else
            core.execution_reg = core.registers[core.rs1] & core.immediate_value_or_offset
        end
    elseif core.present_operator=="SLLI"
        imm_value = parse(Int,Instruction_to_decode[8:12], base=2)
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_i << core.immediate_value_or_offset
        else
            core.execution_reg = core.registers[core.rs1] << imm_value
        end
    elseif core.present_operator=="SRLI/SRAI"
        imm_value = parse(Int,Instruction_to_decode[8:12], base=2)
        if Int(Instruction_to_decode[2])-48==0
            #SRLI operation
            core.execution_reg = core.registers[core.rs1] >>> imm_value
        elseif Int(Instruction_to_decode[2])-48==1
            #SRAI operation
            core.execution_reg = core.registers[core.rs1] >> imm_value
        end

        #======================================================================
                            Executing L Format Operations          
        ======================================================================#
 
    elseif core.present_operator=="LA"
        core.execution_reg = parse(UInt,Instruction_to_decode[1:12], base=2)    # Storing Address
    elseif core.present_operator=="LW"
        offset = parse(UInt,Instruction_to_decode[1:12], base=2)
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_rs1 + offset
        else
            core.execution_reg = core.registers[core.rs1]+offset       # Storing Address
        end
    elseif core.present_operator=="LS"
        core.execution_reg = core.immediate_value_or_offset             # Storing Address
    elseif core.present_operator=="LB"
        if core.data_forwarding_on
            core.execution_reg = core.data_forwarding_reg_rs1 + core.immediate_value_or_offset        # Storing Address
        else
            core.execution_reg = core.registers[core.rs1]+core.immediate_value_or_offset        # Storing Address
        end

        #======================================================================
                            Executing S Format Operations          
        ======================================================================#
 
    elseif core.present_operator=="SW"||core.present_operator=="SB"
        if core.data_forwarding_on&&core.rd_dependent_on_previous_instruction
            core.execution_reg = core.data_forwarding_reg_rd + core.immediate_value_or_offset           # Storing Address
        else
            core.execution_reg = core.registers[core.rd] + core.immediate_value_or_offset           # Storing Address
        end
    # elseif core.present_operator=="SB"
    #     core.execution_reg = core.registers[core.rd] + core.immediate_value_or_offset                # Storing Address

        #======================================================================
                            Executing B Format Operations          
        ======================================================================# 

    elseif core.present_operator=="BEQ"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)+1
        rs1_value = core.registers[core.rs1]
        rs2_value = core.registers[rd]
        if core.rs1_dependent_on_previous_instruction&&!core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
        elseif !core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs2_value = core.execution_reg
        elseif core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
            rs2_value = core.execution_reg
        end
        if core.rs1_dependent_on_second_previous_instruction
            rs1_value = core.previous_mem_reg
        end
        if core.rs2_dependent_on_second_previous_instruction
            rs2_value = core.previous_mem_reg
        end
        if rs1_value == rs2_value
            if offset!=1
                core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
                # println("Instruction fetched from pc : ",core.pc)
                core.rd = -1
            end
        end
    elseif core.present_operator=="BNE"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)+1
        rs1_value = core.registers[core.rs1]
        rs2_value = core.registers[rd]
        if core.rs1_dependent_on_previous_instruction&&!core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
        elseif !core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs2_value = core.execution_reg
        elseif core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
            rs2_value = core.execution_reg
        end
        if core.rs1_dependent_on_second_previous_instruction
            rs1_value = core.previous_mem_reg
        end
        if core.rs2_dependent_on_second_previous_instruction
            rs2_value = core.previous_mem_reg
        end
        if rs1_value != rs2_value
            if offset!=1
                core.pc = core.pc + offset - 1        #Because after IF stage we are incrementing the pc
                # println("Instruction fetched from pc : ",core.pc)
                core.rd = -1
            end
        end
    elseif core.present_operator=="BLT"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)+1
        rs1_value = core.registers[core.rs1]
        rs2_value = core.registers[rd]
        if core.rs1_dependent_on_previous_instruction&&!core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
        elseif !core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs2_value = core.execution_reg
        elseif core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
            rs2_value = core.execution_reg
        end
        if core.rs1_dependent_on_second_previous_instruction
            rs1_value = core.previous_mem_reg
        end
        if core.rs2_dependent_on_second_previous_instruction
            rs2_value = core.previous_mem_reg
        end
        if rs1_value < rs2_value
            if offset!=1
                core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
                # println("Instruction fetched from pc : ",core.pc)
                core.rd = - 1
            end
        end
    elseif core.present_operator=="BGE"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        rd = parse(Int,Instruction_to_decode[21:25], base=2)+1
        rs1_value = core.registers[core.rs1]
        rs2_value = core.registers[rd]
        if core.rs1_dependent_on_previous_instruction&&!core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
        elseif !core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs2_value = core.execution_reg
        elseif core.rs1_dependent_on_previous_instruction&&core.rs2_dependent_on_previous_instruction
            rs1_value = core.execution_reg
            rs2_value = core.execution_reg
        end
        if core.rs1_dependent_on_second_previous_instruction
            rs1_value = core.previous_mem_reg
        end
        if core.rs2_dependent_on_second_previous_instruction
            rs2_value = core.previous_mem_reg
        end
        if rs1_value >= rs2_value
            if offset!=1
                core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
                # println("Instruction fetched from pc : ",core.pc)
                core.rd = -1
            end
        end


        #======================================================================
                            Executing JAL Format Operations          
        ======================================================================# 

    elseif core.present_operator=="JAL"
        # core.registers[core.rd] = core.pc + 1     To be done in WB stage
        core.execution_reg = core.pc      #Because after IF stage we are incrementing the pc
        offset = bin_string_to_signed_int(Instruction_to_decode[1:20])
        core.pc = core.pc + offset  - 1
        #println("Instruction Fetched = ",core.pc)

        #======================================================================
                            Executing JALR Format Operations          
        ======================================================================# 

    elseif instruction_type=="JALR"
        #core.registers[core.rd] = core.pc + 1 To be done in WB stage
        core.execution_reg = core.pc      #Because after IF stage we are incrementing the pc
        core.pc = core.registers[core.rs1] + core.immediate_value_or_offset
    end
    core.rs1-=1
    core.rs2-=1
    core.rd-=1
    core.data_forwarding_reg_i = 0
    if !core.data_forwarding_for_Store_rs
        core.data_forwarding_reg_rs1 = 0
    end
    core.data_forwarding_reg_rs2 = 0
    core.data_forwarding_on = false
    core.rs1_dependent_on_previous_instruction = false
    core.rs2_dependent_on_previous_instruction = false
    core.rd_dependent_on_previous_instruction = false
    core.rs1_dependent_on_second_previous_instruction = false
    core.rs2_dependent_on_second_previous_instruction = false
 end
 