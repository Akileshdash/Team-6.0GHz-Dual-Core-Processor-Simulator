mutable struct Core1
    # Define Core properties here
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
end

function core_Init(id)
    registers = fill(0, 32)
    pc = 1
    program = []
    return Core1(id,registers, pc, program)
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
        offset = replace(parts[3], r"[^0-9]" => "")
        offset = parse(Int, offset)
        rs = match(r"\(([^)]+)\)", parts[3])
        rs = rs.captures[1][2:end]
        #Further Function has to be written
        ###################################

    #SW rs offset(rd)
    elseif opcode == "SW"
        rs = parse(Int, parts[2][2:end])+1
        offset = match(r"\d+", parts[3])
        offset = parse(Int, offset.match)
        rd = match(r"\(([^)]+)\)", parts[3])
        rd = rd.captures[1][2:end]
        rd = parse(Int, rd)
        println(core.registers[rd+1]+offset+1)
        memory[1,core.registers[rd+1]+offset+1]=core.registers[rs]
        memory[2,core.registers[rd+1]+offset+1]=core.id
        #Further Function has to be written
        ###################################

    #J Label
    elseif opcode == "J"
        label = parts[2]
        #println(label)
        core.pc = findfirst(x -> x == label,core.program)+1
        println("program conuter =  ",core.pc)
    end
    core.pc += 1
end

mutable struct Processor
    memory::Array{Int,2}
    clock::Int
    cores::Array{Core1,1}
end

function processor_Init()
    memory = fill(0,(4096, 4096))
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    return Processor(memory, clock, cores)
end

function run(processor::Processor)
    while processor.clock < max(length(processor.cores[1].program), length(processor.cores[2].program))
        for i in 1:2
            if processor.clock < length(processor.cores[i].program) && processor.cores[i].pc<=length(processor.cores[i].program)                
                execute(processor.cores[i],processor.memory)

            for i in 1:2
                println(sim.cores[i].registers)
            end
            println("\n")

            end
        end
        processor.clock += 1
    end
end

sim = processor_Init()  

sim.cores[1].registers[1] = 0   #X0
sim.cores[1].registers[3] = 8   #X2
sim.cores[1].registers[4] = 9   #X3
sim.cores[2].registers[3] = 9   #X3
sim.cores[1].program = ["MV X31 X2","SW X2 8(X0)"]
sim.cores[2].program = ["SW X2 0(X0)"]

run(sim)

for i in 1:2
    println(sim.cores[i].registers)
end
println()
for i in 1:40
    print(sim.memory[1,i]," ")
end
println()
for i in 1:40
    print(sim.memory[2,i]," ")
end


#=
1.Add
2.Addi
3.Sub
5.LD
4.LW
6.la
7.li
8.mv
8.srl
9.sra
10.srli
8.slli
9.jal
10.jalr
11.j
12.ecall
13.bgt
14.bne
15.beq
16.bnez
17.
=#