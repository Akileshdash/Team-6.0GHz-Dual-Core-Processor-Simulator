include("Execute_Func.jl")
include("parser.jl")


function core_Init(id)
    registers = fill(0, 32)
    pc = 1
    program = []
    return Core1(id,registers, pc, program)
end

function processor_Init()
    memory = zeros(UInt8, (1024, 4))
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    return Processor(memory, clock, cores)
end

function run(processor::Processor)
    while processor.cores[1].pc<=length(processor.cores[1].program)                      
        Decode_and_execute(processor.cores[1],processor.memory)
    end
end


