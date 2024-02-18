mutable struct Core1
    # Define Core properties here
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
end

function core_Init()
    registers = fill(0, 32)
    pc = 1
    program = []
    return Core1(registers, pc, program)
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
        imm_value = parse(Int, parts[4][2:end]) #Immediate value
        core.registers[rd] = core.registers[rs1] + imm_value
    
    #SUB rd rs1 rs2
    elseif opcode == "SUB"
        rd = parse(Int, parts[2][2:end])+1
        rs1 = parse(Int, parts[3][2:end])+1
        rs2 = parse(Int, parts[4][2:end])+1
        core.registers[rd] = core.registers[rs1] - core.registers[rs2]

    #LD rd offset(rs)
    elseif opcode == "LD"
        rd = parse(Int, parts[2][2:end])+1
        offset = parse(Int, parts[3][1:'('])
    end
    core.pc += 1
end


mutable struct Processor
    memory::Array{Int,1}
    clock::Int
    cores::Array{Core1,1}
end

function processor_Init()
    memory = fill(0, 4096)
    clock = 0
    cores = [core_Init(), core_Init()] 
    return Processor(memory, clock, cores)
end

function run(processor::Processor)
    while processor.clock < max(length(processor.cores[1].program), length(processor.cores[2].program))
        for i in 1:2
            if processor.clock < length(processor.cores[i].program)
                execute(processor.cores[i],processor.memory)
            end
        end

        processor.clock += 1
    end
end

sim = processor_Init()  

sim.cores[1].registers[2] = 8
sim.cores[1].registers[3] = 9
sim.cores[1].program = ["ADD X1 X2 X3"]

run(sim)

for i in 1:2
    println(sim.cores[i].registers)
end