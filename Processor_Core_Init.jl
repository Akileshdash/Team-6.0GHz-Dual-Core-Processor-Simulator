                            
#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Core_Object
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
end

mutable struct Processor
    memory::Array{UInt8,2}
    clock::Int
    cores::Array{Core_Object,1}
end

function core_Init(id)
    registers = fill(0, 32)
    pc = 1
    program = []
    return Core_Object(id,registers, pc, program)
end

function processor_Init()
    memory = zeros(UInt8, (1024, 4))
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    return Processor(memory, clock, cores)
end

                            
#==========================================================================================================
                                               Run Function
===========================================================================================================#


function run(processor::Processor)

                            #===========================================
                                        Parallel Processing
                            ============================================#

    while processor.cores[1].pc<=length(processor.cores[1].program)&&processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
        processor.clock+=1
        Decode_and_execute(processor.cores[1],processor.memory)
        Decode_and_execute(processor.cores[2],processor.memory)
    end
    while processor.cores[1].pc<=length(processor.cores[1].program)
        processor.clock+=1
        Decode_and_execute(processor.cores[1],processor.memory)
    end
    while processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
        processor.clock+=1
        Decode_and_execute(processor.cores[2],processor.memory)
    end

                            #===========================================
                                        Sequential Processing
                                    (Uncomment the below two loops)
                            ============================================#

    # while processor.cores[1].pc<=length(processor.cores[1].program)
    #     processor.clock+=1
    #     Decode_and_execute(processor.cores[1],processor.memory)
    # end
    # while processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
    #     processor.clock+=1
    #     Decode_and_execute(processor.cores[2],processor.memory)
    # end
end
