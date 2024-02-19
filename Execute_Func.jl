
mutable struct Core1
    # Define Core properties here
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
end

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

    
#====================================================================================================================
                                            I Format Instructions          
====================================================================================================================#


#9    #ADDI rd rs1 imm_value
    elseif opcode == "ADDI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        imm_value = parse(Int, parts[4]) #Immediate value
        I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] + imm_value
       
#10    #XORI rd rs1 imm_value
    elseif opcode == "XORI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        imm_value = parse(Int, parts[4]) #Immediate value
        I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"100"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] $ imm_value

#11    #ORI rd rs1 imm_value
    elseif opcode == "ORI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        imm_value = parse(Int, parts[4]) #Immediate value
        I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"110"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] | imm_value

#12    #ANDI rd rs1 imm_value
    elseif opcode == "ANDI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        imm_value = parse(Int, parts[4]) #Immediate value
        I_format_instruction = int_to_signed_12bit_bin(imm_value)*int_to_5bit_bin(rs1-1)*"111"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] & imm_value

#13    #SLLI rd rs1 shamt                     (shift amount immediate)
    elseif opcode == "SLLI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        shamt = parse(Int, parts[4]) #Shift Amount
        R_format_instruction = "0000000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"001"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] << imm_value

#14    #SRLI rd rs1 shamt                     (shift amount immediate)
    elseif opcode == "SRLI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        shamt = parse(Int, parts[4]) #Shift Amount
        R_format_instruction = "0000000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] >>> imm_value


#13    #SRAI rd rs1 shamt                     (shift amount immediate)
    elseif opcode == "SRAI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        shamt = parse(Int, parts[4]) #Shift Amount
        R_format_instruction = "0100000"*int_to_5bit_bin(shamt)*int_to_5bit_bin(rs1-1)*"101"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] = core.registers[rs1] >> imm_value


    #LI rd immediate
    elseif opcode == "LI"
        rd = parse(Int, parts[2][2:end])+1
        imm_value = parse(Int, parts[3]) #Immediate value
        core.registers[rd] =  imm_value

    #MV rd rs               # same as ADDI rd rs 0
    elseif opcode == "MV"
        rd = parse(Int, parts[2][2:end])+1
        rs = parse(Int, parts[3][2:end])+1
        I_format_instruction = int_to_signed_12bit_bin(0)*int_to_5bit_bin(rs1-1)*"000"*int_to_5bit_bin(rd-1)*I_format_instruction
        core.registers[rd] =  core.registers[rs]

    
#====================================================================================================================
                                            L Format Instructions          ( Load Format )
====================================================================================================================#


#16    #LB rd, offset(rs)
    elseif opcode == "LB"
        rd = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rs = match(r"\(([^)]+)\)", parts[3])
        rs = rs.captures[1][2:end]
        rs = parse(Int, rs)+1
        L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"000"*int_to_5bit_bin(rd-1)*L_format_instruction
        core.registers[rd]=memory[1,core.registers[rs]+offset+1]
        #Function has to be written after Memory 2d Array is formed

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

#17    #LW rd offset(rs)
    elseif opcode == "LW"
        rd = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rs = match(r"\(([^)]+)\)", parts[3])
        rs = rs.captures[1][2:end]
        rs = parse(Int, rs)+1
        L_format_instruction = int_to_signed_12bit_bin(offset)*int_to_5bit_bin(rs-1)*"010"*int_to_5bit_bin(rd-1)*L_format_instruction
        core.registers[rd]=memory[1,core.registers[rs]+offset+1]
        #Function has to be written after Memory 2d Array is formed

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

    
#====================================================================================================================
                                            S Format Instructions          ( Store Format )
====================================================================================================================#

#20    #SB rs, offset(rd)
    elseif opcode == "SB"
        rs = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rd = match(r"\(([^)]+)\)", parts[3])
        rd = rd.captures[1][2:end]
        rd = parse(Int, rd)+1
        memory[1,core.registers[rd]+offset+1]=core.registers[rs]
        memory[2,core.registers[rd]+offset+1]=core.id
        imm = int_to_signed_12bit_bin(offset)
        S_format_instruction = imm[1:7]*int_to_5bit_bin(rs-1)*int_to_5bit_bin(rd-1)*"000"*imm[8:12]*S_format_instruction
        #Function has to be written after Memory 2d Array is formed
        

#21    #SH rs offset(rd)
    elseif opcode == "SH"
        rs = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rd = match(r"\(([^)]+)\)", parts[3])
        rd = rd.captures[1][2:end]
        rd = parse(Int, rd)+1
        memory[1,core.registers[rd]+offset+1]=core.registers[rs]
        memory[2,core.registers[rd]+offset+1]=core.id
        imm = int_to_signed_12bit_bin(offset)
        S_format_instruction = imm[1:7]*int_to_5bit_bin(rs-1)*int_to_5bit_bin(rd-1)*"001"*imm[8:12]*S_format_instruction
        #Function has to be written after Memory 2d Array is formed

#22    #SW rs offset(rd)
    elseif opcode == "SW"
        rs = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rd = match(r"\(([^)]+)\)", parts[3])
        rd = rd.captures[1][2:end]
        rd = parse(Int, rd)+1
        memory[1,core.registers[rd]+offset+1]=core.registers[rs]
        memory[2,core.registers[rd]+offset+1]=core.id
        imm = int_to_signed_12bit_bin(offset)
        S_format_instruction = imm[1:7]*int_to_5bit_bin(rs-1)*int_to_5bit_bin(rd-1)*"010"*imm[8:12]*S_format_instruction
        #Function has to be written after Memory 2d Array is formed

    
#====================================================================================================================
                                            B Format Instructions          ( Branch Format )
====================================================================================================================#

#23    #BEQ  rs1 rs2 offset
    elseif opcode == "BEQ"
        rs1 = parse(Int, parts[2][2:end])+1
        rs2 = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4]) 
        imm = int_to_signed_12bit_bin(offset)
        imm = '0'*imm[1:11]
        B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"000"*imm[9:12]*imm[2]*B_format_instruction
        #Function has to be written after Memory 2d Array is formed

#24    #BNE  rs1 rs2 offset
    elseif opcode == "BNE"
        rs1 = parse(Int, parts[2][2:end])+1
        rs2 = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4]) 
        imm = int_to_signed_12bit_bin(offset)
        imm = '0'*imm[1:11]
        B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"001"*imm[9:12]*imm[2]*B_format_instruction
        #Function has to be written after Memory 2d Array is formed

#25    #BLT  rs1 rs2 offset
    elseif opcode == "BLT"
        rs1 = parse(Int, parts[2][2:end])+1
        rs2 = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4]) 
        imm = int_to_signed_12bit_bin(offset)
        imm = '0'*imm[1:11]
        B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"100"*imm[9:12]*imm[2]*B_format_instruction
        #Function has to be written after Memory 2d Array is formed

#26    #BGE  rs1 rs2 offset
    elseif opcode == "BGE"
        rs1 = parse(Int, parts[2][2:end])+1
        rs2 = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4]) 
        imm = int_to_signed_12bit_bin(offset)
        imm = '0'*imm[1:11]
        B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"101"*imm[9:12]*imm[2]*B_format_instruction
        #Function has to be written after Memory 2d Array is formed

#27    #BLTU  rs1 rs2 offset
    elseif opcode == "BLTU"
        rs1 = parse(Int, parts[2][2:end])+1
        rs2 = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4]) 
        imm = int_to_signed_12bit_bin(offset)
        imm = '0'*imm[1:11]
        B_format_instruction = imm[1]*imm[3:8]*int_to_5bit_bin(rs2-1)*int_to_5bit_bin(rs1-1)*"110"*imm[9:12]*imm[2]*B_format_instruction
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

#30     #JAL rd, offset
        rd = parse(Int, parts[2][2:end])+1
        offset = parse(Int, parts[3])        
        offset = int_to_20bit_bin(offset)
        core.registers[rd] = core.pc+1
        core.pc=core.pc+offset
        JAL_format_instruction=imm[1]*imm[11:19]*imm[10]*imm[2:9]*int_to_5bit_bin(rd-1)*JAL_format_instruction
        #Function has to be written after Memory 2d Array is formed

#31     #JALR rd, rs, offset
        rd = parse(Int, parts[2][2:end])+1
        rs = parse(Int, parts[3][2:end])+1
        offset = parse(Int, parts[4])      
        core.registers[rd] = core.pc+1
        #JALR_format_instruction=imm[1]*imm[11:19]*imm[10]*imm[2:9]*int_to_5bit_bin(rd-1)*JALR_format_instruction
        #Function has to be written after Memory 2d Array is formed

#30        #J Label
    elseif opcode == "J"
        label = parts[2]
        #println(label)
        core.pc = findfirst(x -> x == label,core.program)+1
        println("program conuter =  ",core.pc)
    end
    core.pc += 1
end