include("Encoding_Instructions.jl")

function execute(core::Core1, memory)
    parts = split(core.program[core.pc], ' ') 
    opcode = parts[1]

    R_format_instruction = "0110011"
    I_format_instruction = "0010011"
    L_format_instruction = "0000011"        #Load Format it also comes under I Format
    S_format_instruction = "0100011"        #Store Format
    B_format_instruction = "1100011"        #Break Format
    U_format_instruction = "0110111"        #Upper Immediate Format
    JAL_format_instruction = "1101111"        #Jump Format
    JALR_format_instruction = "1100111"        #Jump Format

#====================================================================================================================
                                            R Format Instructions          
====================================================================================================================#


#1    #ADD rd rs1 rs2
    if opcode == "ADD"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] + core.registers[rs2]

#2    #SUB rd rs1 rs2
    elseif opcode == "SUB"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] - core.registers[rs2]
    
#3    #SLL rd, rs1, rs2
    elseif opcode == "SLL"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"001"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] << core.registers[rs2]

#4    #XOR rd, rs1, rs2
    elseif opcode == "XOR"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"100"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] $ core.registers[rs2]

#5    #SRL rd, rs1, rs2
    elseif opcode == "SRL"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] >>> core.registers[rs2]
        
#6    #SRA rd, rs1, rs2
    elseif opcode == "SRA"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] >> core.registers[rs2]

#7    #OR rd, rs1, rs2
    elseif opcode == "OR"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0100000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"110"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] | core.registers[rs2]
    
#8    #AND rd, rs1, rs2
    elseif opcode == "AND"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        R_format_instruction = "0000000"*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"111"*int_to_5bit_bin(rd-1)*R_format_instruction
        core.registers[rd] = core.registers[rs1] & core.registers[rs2]

    
