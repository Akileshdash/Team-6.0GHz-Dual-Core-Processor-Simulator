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
    memory::Array{UInt8,2}
    clock::Int
    cores::Array{Core1,1}
end

function processor_Init()
    memory = zeros(UInt8, (1024, 4))
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    return Processor(memory, clock, cores)
end

function run(processor::Processor)
    while processor.clock < max(length(processor.cores[1].program), length(processor.cores[2].program))
        for i in 1:2
            if processor.clock < length(processor.cores[i].program) && processor.cores[i].pc<=length(processor.cores[i].program)                
                execute(processor.cores[i],processor.memory)
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

function int_to_20bit_bin(n::Int)
    binary_str = string(n + 2^20, base=2)[2:end]
    return binary_str
end

sim = processor_Init()  


function show_hex(value::UInt8)
    hex_str = string(value, base=16)
    padded_str = rpad(hex_str, 2, '0')
    return padded_str
end

function show(proc::Processor)
    println("Processor Memory (in hex):")
    for row in reverse(1:size(proc.memory, 1))  # Iterate through rows in reverse order
        combined_value = UInt32(0)
        print("$row -> ")
        for col in 1:size(proc.memory, 2)
            print("0x$(show_hex(proc.memory[row, col]))\t")
            if col % 4 == 0
                println()
            end
        end
    end
end


sim.memory[1,2]=200
sim.memory[1,1]=100
sim.memory[2,2]=10

sim.cores[1].registers[1] = 0   #X0
sim.cores[1].registers[3] = 800   #X2
sim.cores[1].registers[4] = 9   #X2
sim.cores[2].registers[3] = 9   #X3

sim.cores[1].program = ["LB X0 1(X0)"]

show(sim)
run(sim)

println("\nCores : \n")
for i in 1:2
    println(sim.cores[i].registers)
end