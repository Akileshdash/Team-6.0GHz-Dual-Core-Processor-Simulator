include("Execute_Func.jl")
include("parser.jl")
include("Decoding_Instructions.jl")

function run(processor::Processor)
    while processor.cores[1].pc<=length(processor.cores[1].program)+1                      
        Decode_and_execute(processor.cores[1],processor.memory)
    end
end


