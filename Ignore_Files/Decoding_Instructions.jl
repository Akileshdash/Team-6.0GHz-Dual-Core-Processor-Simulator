include("Helper_Functions.jl")
include("Execute_Operation.jl")


#==========================================================================================================
        Decoding and executing a single Instruction which pointed by the program counter at that time
===========================================================================================================#

function Decode_and_execute(core::Core_Object,memory)
    Instruction_to_decode = int_to_8bit_bin(memory[core.pc,4])*int_to_8bit_bin(memory[core.pc,3])*int_to_8bit_bin(memory[core.pc,2])*int_to_8bit_bin(memory[core.pc,1])
    opcode = Instruction_to_decode[end-6:end]
    instruction_type = " "
    for (format_op, bin) in instruction_formats
        if format_op == opcode
            instruction_type = bin
            break
        end
    end
    if instruction_type=="R"
        # Chosen Instruction is R
        rd = parse(Int,Instruction_to_decode[end-11:end-7], base=2)+1
        rs1 = parse(Int,Instruction_to_decode[13:17], base=2)+1
        rs2 = parse(Int,Instruction_to_decode[8:12], base=2)+1
        Instruction_differentiator = Instruction_to_decode[18:20]
        operator = ""
        for (temp1, temp2) in R_format_instructions
            if temp1 == Instruction_differentiator
                operator = temp2
                break
            end
        end
        Execute_Operation_R(operator,rd,rs1,rs2,core,memory,Instruction_to_decode)

    elseif instruction_type=="I"
        # Chosen Instruction is I
        rd = parse(Int,Instruction_to_decode[end-11:end-7], base=2)+1
        rs1 = parse(Int,Instruction_to_decode[13:17], base=2)+1
        imm_value =bin_string_to_signed_int(Instruction_to_decode[1:12])
        Instruction_differentiator = Instruction_to_decode[18:20]
        operator = ""
        for (temp1, temp2) in I_format_instructions
            if temp1 == Instruction_differentiator
                operator = temp2
                break
            end
        end
        Execute_Operation_I(operator,rd,rs1,imm_value,core,memory,Instruction_to_decode)

    elseif instruction_type=="L"
        rs = parse(Int,Instruction_to_decode[13:17],base = 2)+1
        rd = parse(Int,Instruction_to_decode[21:25],base = 2)+1
        offset =bin_string_to_signed_int(Instruction_to_decode[1:12])
        Instruction_differentiator = Instruction_to_decode[18:20]
        operator = ""
        for (temp1, temp2) in L_format_instructions
            if temp1 == Instruction_differentiator
                operator = temp2
                break
            end
        end
        Execute_Operation_L(operator,rd,rs,offset,core,memory,Instruction_to_decode)

        
    elseif instruction_type=="S"
        #S_format_instruction = imm[1:7]*int_to_5bit_bin(rs-1)*int_to_5bit_bin(rd-1)*"010"*imm[8:12]*S_format_instruction
        rs = parse(Int,Instruction_to_decode[8:12], base=2)+1
        rd = parse(Int,Instruction_to_decode[13:17], base=2)+1
        offset = bin_string_to_signed_int(Instruction_to_decode[1:7]*Instruction_to_decode[21:25])
        Instruction_differentiator = Instruction_to_decode[18:20]
        for (temp1, temp2) in S_format_instructions
            if temp1 == Instruction_differentiator
                operator = temp2
                break
            end
        end
        Execute_Operation_S(operator,rd,rs,offset,core,memory,Instruction_to_decode)

    elseif instruction_type=="B"
        # Chosen Instruction is B
        rs1 = parse(Int,Instruction_to_decode[13:17], base=2)+1
        rs2 = parse(Int,Instruction_to_decode[8:12], base=2)+1
        offset = bin_string_to_signed_int(Instruction_to_decode[1]*Instruction_to_decode[end-7]*Instruction_to_decode[2:7]*Instruction_to_decode[end-11:end-8]*"0")
        Instruction_differentiator = Instruction_to_decode[18:20]
        operator = ""
        for (temp1, temp2) in B_format_instructions
            if temp1 == Instruction_differentiator
                operator = temp2
                break
            end
        end
        Execute_Operation_B(operator,rs1,rs2,offset,core,memory,Instruction_to_decode)

    elseif instruction_type=="U"
    elseif instruction_type=="JAL"
        # Chosen Instruction is JAL
        rd = parse(Int,Instruction_to_decode[end-11:end-7], base=2)+1
        offset = bin_string_to_signed_int(Instruction_to_decode[1]*Instruction_to_decode[13:20]*Instruction_to_decode[12]*Instruction_to_decode[2:11])
        core.registers[rd] = core.pc + 1
        core.registers[1] = 0
        core.pc = core.pc + offset - 1
    elseif instruction_type=="JALR"
        # Chosen Instruction is JALR
        rd = parse(Int,Instruction_to_decode[end-11:end-7], base=2)+1
        offset = bin_string_to_signed_int(Instruction_to_decode[1:12])
        rs = parse(Int,Instruction_to_decode[13:17], base=2)+1
        core.registers[rd] = core.pc + 1 
        core.pc = core.registers[rs] + offset - 1
    elseif instruction_type=="ECALL"
        #decoding of ecall
    end
    core.pc+=1
end