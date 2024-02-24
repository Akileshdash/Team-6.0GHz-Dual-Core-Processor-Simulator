include("Processor_Core_Init.jl")

#======================================================================
                    Executing R Format Operations          
======================================================================#
 
function  Execute_Operation_R(operator,rd,rs1,rs2,core::Core1,memory,Instruction_to_decode)
   if operator=="ADD/SUB"
        if Int(Instruction_to_decode[2])-48==0
            #Add operation
            core.registers[rd] = core.registers[rs1] + core.registers[rs2]
        elseif Int(Instruction_to_decode[2])-48==1
            #Sub operation
            core.registers[rd] = core.registers[rs1] - core.registers[rs2]
        end
    elseif operator=="SLL"
        core.registers[rd] = core.registers[rs1] << core.registers[rs2]
    elseif operator=="XOR"
        core.registers[rd] = core.registers[rs1] $ core.registers[rs2]
    elseif operator=="SRL/SRA"
        if Int(Instruction_to_decode[2])-48==0
            #SRL operation
            core.registers[rd] = core.registers[rs1] >>> core.registers[rs2]
        elseif Int(Instruction_to_decode[2])-48==1
            #SRA operation
            core.registers[rd] = core.registers[rs1] >> core.registers[rs2]
        end
    elseif operator=="OR"
        core.registers[rd] = core.registers[rs1] | core.registers[rs2]
    elseif operator=="AND"
        core.registers[rd] = core.registers[rs1] & core.registers[rs2]
    end
end

#======================================================================
                    Executing I Format Operations          
======================================================================#
 
function  Execute_Operation_I(operator,rd,rs1,imm_value,core::Core1,memory,Instruction_to_decode)
    if operator=="ADDI"
        core.registers[rd] = core.registers[rs1] + imm_value
    elseif operator=="XORI"
        core.registers[rd] = core.registers[rs1] $ imm_value
    elseif operator=="ORI"
        core.registers[rd] = core.registers[rs1] | imm_value
    elseif operator=="ANDI"
        core.registers[rd] = core.registers[rs1] & imm_value
    elseif operator=="SLLI"
        core.registers[rd] = core.registers[rs1] << imm_value
    elseif operator=="SRLI/SRAI"
        imm_value = parse(Int,Instruction_to_decode[8:12], base=2)
        if Int(Instruction_to_decode[2])-48==0
            #SRLI operation
            core.registers[rd] = core.registers[rs1] >>> imm_value
        elseif Int(Instruction_to_decode[2])-48==1
            #SRAI operation
            core.registers[rd] = core.registers[rs1] >> imm_value
        end
    end
end

#======================================================================
                    Executing L Format Operations          
======================================================================#
 
function Execute_Operation_L(operator,rd,rs,offset,core::Core1,memory,Instruction_to_decode)
    if operator=="LA"
        address = parse(UInt,Instruction_to_decode[1:12], base=2)
        core.registers[rd] = address
    elseif operator=="LW"
        address = core.registers[rs]+offset
        row,col = address_to_row_col(address)
        core.registers[rd] = return_word_from_memory_littleEndian(memory,address)
    elseif operator=="LS"
        address = parse(UInt,Instruction_to_decode[1:12], base=2)
        core.registers[rd] = return_word_from_memory_littleEndian(memory,address)
    elseif operator=="LB"
        address = core.registers[rs] + offset
        row,col = address_to_row_col(address)
        core.registers[rd] = memory[row,col]
    end
end

#======================================================================
                    Executing S Format Operations          
======================================================================#
 
function Execute_Operation_S(operator,rd,rs,offset,core,memory,Instruction_to_decode)
    if operator=="SW"
        address = core.registers[rd] + offset
        row,col = address_to_row_col(address)
        bin = int_to_32bit_bin(core.registers[rs])
        in_memory_place_word(memory,row,col,bin)
    elseif operator=="SB"
        address = core.registers[rd] + offset
        row,col = address_to_row_col(address)
        memory[row,col] = core.registers[rs]
    end
end

#======================================================================
                    Executing B Format Operations          
======================================================================#
 
function Execute_Operation_B(operator,rs1,rs2,offset,core::Core1,memory,Instruction_to_decode)
    if operator=="BEQ"
        if core.registers[rs1] == core.registers[rs2]
            core.pc = core.pc +  offset - 1     #-1 bcz in decode_execute function we are incrementing pc again
        end
    elseif operator=="BNE"
        if core.registers[rs1] != core.registers[rs2]
            core.pc = core.pc + offset - 1
        end
    elseif operator=="BLT"
        if core.registers[rs1] < core.registers[rs2]
            core.pc = core.pc + offset - 1
        end
    elseif operator=="BGE"
        if core.registers[rs1] >= core.registers[rs2]
            core.pc = core.pc + offset - 1
        end
    end
end