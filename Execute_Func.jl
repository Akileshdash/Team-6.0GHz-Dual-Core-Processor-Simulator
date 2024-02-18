
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

    #ADD rd rs1 rs2
    if opcode == "ADD"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        core.registers[rd] = core.registers[rs1] + core.registers[rs2]

    #ADD rd rs1 imm_value
    elseif opcode == "ADDI"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        imm_value = parse(Int, parts[4]) #Immediate value
        core.registers[rd] = core.registers[rs1] + imm_value
    
    #SUB rd rs1 rs2
    elseif opcode == "SUB"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        core.registers[rd] = core.registers[rs1] - core.registers[rs2]

    #LI rd immediate
    elseif opcode == "LI"
        rd = parse(Int, parts[2][2:end])+1
        imm_value = parse(Int, parts[3]) #Immediate value
        core.registers[rd] =  imm_value

    #MV rd rs
    elseif opcode == "MV"
        rd = parse(Int, parts[2][2:end])+1
        rs = parse(Int, parts[3][2:end])+1
        core.registers[rd] =  core.registers[rs]

    #LW rd offset(rs)
    elseif opcode == "LW"
        rd = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rs = match(r"\(([^)]+)\)", parts[3])
        rs = rs.captures[1][2:end]
        rs = parse(Int, rs)+1
        println("LW")
        core.registers[rd]=memory[1,core.registers[rs]+offset+1]

    #SW rs offset(rd)
    elseif opcode == "SW"
        rs = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rd = match(r"\(([^)]+)\)", parts[3])
        rd = rd.captures[1][2:end]
        rd = parse(Int, rd)+1
        memory[1,core.registers[rd]+offset+1]=core.registers[rs]
        memory[2,core.registers[rd]+offset+1]=core.id

    #J Label
    elseif opcode == "J"
        label = parts[2]
        #println(label)
        core.pc = findfirst(x -> x == label,core.program)+1
        println("program conuter =  ",core.pc)
    end
    core.pc += 1
end