mutable struct Core
    # Define Core properties here
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
    # program::[]
end

function Core()
    registers = fill(0, 32)
    pc = 0
    program = []
    return Core(registers, pc, program)
end

function execute(core::Core, memory)
    #parts = split(program[pc], ' '), chatgpt equivalent
    parts = core.program[core.pc].split()
    opcode = parts[0]
    println(opcode)

    if opcode == "ADD"
        println("1")
        rd = parse(Int, parts[2][2:end])
        rs1 = parse(Int, parts[3][2:end])
        rs2 = parse(Int, parts[4][2:end])
        core.registers[rd] = core.registers[rs1] + core.registers[rs2]
    elseif opcode == "LD"
        println("2")
    
    core.pc += 1
    end
end


mutable struct Processor
    memory::Array{Int,1}
    clock::Int
    cores::Array{Core,1}
end

function Processor()
    memory = fill(0, 4096)
    clock = 0
    cores = [Core(), Core()]
    return Processor(memory, clock, cores)
end

function run(processor::Processor)
    while processor.clock < max(length(processor.cores[1].program), length(processor.cores[2].program))
        for i in 1:2
            if processor.clock < length(processor.cores[i].program)
                processor.cores[i].execute(processor.memory)
            end
        end
        
        processor.clock += 1
    end
end

sim = Processor()
sim.cores[1].register[2] = 8

for i in 1:2
    println(sim.cores[i].registers)
end