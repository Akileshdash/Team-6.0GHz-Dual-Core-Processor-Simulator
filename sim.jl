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
    while processor.cores[1].pc<=length(processor.cores[1].program)                      
        execute(processor.cores[1],processor.memory)
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



function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

function show(proc::Processor)
    println("Processor Memory (in hex):")
    rows_to_show = min(10, size(proc.memory, 1))  # Choose the minimum of 10 and the actual number of rows
    for row in reverse(1:rows_to_show)
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

sim = processor_Init()  

# sim.memory[1,2]=200
# sim.memory[1,1]=100
# sim.memory[2,2]=10

# sim.cores[1].registers[1] = 0   #X0
# sim.cores[1].registers[3] = 800   #X2
# sim.cores[1].registers[4] = 9   #X2
# sim.cores[2].registers[3] = 9   #X3

# sim.cores[1].program = ["LB X0 1(X0)"]

# run(sim)

# println("\nCores : \n")
# for i in 1:2
#     println(sim.cores[i].registers)
# end