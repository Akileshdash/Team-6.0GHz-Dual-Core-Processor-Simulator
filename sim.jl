include("Execute_Func.jl")
include("parser.jl")

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

function int_to_5bit_bin(n::Int)
    binary_str = string(n, base=2, pad=5)
    
    return binary_str
end

function int_to_signed_12bit_bin(n::Int)
    binary_str = string(n + 2^12, base=2)[2:end]
    return binary_str
end


sim = processor_Init()  

sim.cores[1].registers[1] = 0   #X0
sim.cores[1].registers[3] = 800   #X2
sim.cores[1].registers[4] = 9   #X3
sim.cores[2].registers[3] = 9   #X3
# sim.cores[1].program = ["MV X31 X2","SW X2 8(X0)"]
# sim.cores[2].program = ["SW X2 0(X0)","SW X2 10(X0)","LW x31 0(X0)"]
sim.cores[1].program = ["ADDI X15 X1 -50"]

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
println()

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