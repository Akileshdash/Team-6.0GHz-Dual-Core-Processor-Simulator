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
    
    if core.operator=="ADD/SUB"
        if Int(Instruction_to_decode[2])-48==0
            #Add operation
            core.execution_reg = core.registers[core.rs1] + core.registers[core.rs2]
        elseif Int(Instruction_to_decode[2])-48==1
            #Sub operation
            core.execution_reg = core.registers[core.rs1] - core.registers[core.rs2]
        end
    elseif core.operator=="SLL"
         core.execution_reg = core.registers[core.rs1] << core.registers[core.rs2]
    elseif core.operator=="XOR"
         core.execution_reg = core.registers[core.rs1] $ core.registers[core.rs2]
    elseif core.operator=="SRL/SRA"
        if Int(Instruction_to_decode[2])-48==0
            #SRL operation
            core.execution_reg = core.registers[core.rs1] >>> core.registers[core.rs2]
        elseif Int(Instruction_to_decode[2])-48==1
            #SRA operation
            core.execution_reg = core.registers[core.rs1] >> core.registers[core.rs2]
        end
    elseif core.operator=="OR"
         core.execution_reg = core.registers[core.rs1] | core.registers[core.rs2]
    elseif core.operator=="AND"
         core.execution_reg = core.registers[core.rs1] & core.registers[core.rs2]

        #======================================================================
                            Executing I Format Operations          
        ======================================================================#
 
    elseif core.operator=="ADDI"
        core.execution_reg = core.registers[core.rs1] + core.immediate_value_or_offset
    elseif core.operator=="XORI"
        core.execution_reg = core.registers[core.rs1] $ core.immediate_value_or_offset
    elseif core.operator=="ORI"
        core.execution_reg = core.registers[core.rs1] | core.immediate_value_or_offset
    elseif core.operator=="ANDI"
        core.execution_reg = core.registers[core.rs1] & core.immediate_value_or_offset
    elseif core.operator=="SLLI"
        imm_value = parse(Int,Instruction_to_decode[8:12], base=2)
        core.execution_reg = core.registers[core.rs1] << imm_value
    elseif core.operator=="SRLI/SRAI"
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
 
    elseif core.operator=="LA"
        core.execution_reg = parse(UInt,Instruction_to_decode[1:12], base=2)    # Storing Address
    elseif core.operator=="LW"
        offset = parse(UInt,Instruction_to_decode[1:12], base=2)
        core.execution_reg = core.registers[core.rs1]+offset       # Storing Address
    elseif core.operator=="LS"
        core.execution_reg = core.immediate_value_or_offset             # Storing Address
    elseif core.operator=="LB"
        core.execution_reg = core.registers[core.rs1]+core.immediate_value_or_offset        # Storing Address

        #======================================================================
                            Executing S Format Operations          
        ======================================================================#
 
    elseif core.operator=="SW"
        core.execution_reg = core.registers[core.rd] + core.immediate_value_or_offset           # Storing Address
    elseif core.operator=="SB"
        core.execution_reg = core.registers[core.rd] + core.immediate_value_or_offset                # Storing Address

        #======================================================================
                            Executing B Format Operations          
        ======================================================================# 

    elseif core.operator=="BEQ"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        if core.registers[core.rs1] == core.registers[core.rd]
            core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
        end
    elseif core.operator=="BNE"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        if core.registers[core.rs1] != core.registers[core.rd]
            core.pc = core.pc + offset - 1        #Because after IF stage we are incrementing the pc
        end
    elseif core.operator=="BLT"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        if core.registers[core.rs1] < core.registers[core.rd]
            core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
        end
    elseif core.operator=="BGE"
        offset = div(bin_string_to_signed_int(Instruction_to_decode[1:12]*"0"),4)
        if core.registers[core.rs1] >= core.registers[core.rd]
            core.pc = core.pc + offset - 1      #Because after IF stage we are incrementing the pc
        end


        #======================================================================
                            Executing JAL Format Operations          
        ======================================================================# 

    elseif core.operator=="JAL"
        # core.registers[core.rd] = core.pc + 1     To be done in WB stage
        core.execution_reg = core.pc      #Because after IF stage we are incrementing the pc
        offset = bin_string_to_signed_int(Instruction_to_decode[1:20])
        core.pc = core.pc + offset  - 1

        #======================================================================
                            Executing JALR Format Operations          
        ======================================================================# 

    elseif instruction_type=="JALR"
        #core.registers[core.rd] = core.pc + 1 To be done in WB stage
        core.execution_reg = core.pc      #Because after IF stage we are incrementing the pc
        core.pc = core.registers[core.rs1] + core.immediate_value_or_offset
    end
 end
 