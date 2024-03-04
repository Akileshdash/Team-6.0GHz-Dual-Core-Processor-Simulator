
#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Core_Object
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
    
    #Special Purpose Registers

    #For Instruction Fetch
    instruction_reg_after_IF::String

    #For instruction Decode / Register Fetch
    rs2::Int
    rs1::Int
    rd::Int
    immediate_value_or_offset::Int
    operator::String
    instruction_reg_after_ID_RF::String

    #For Execution
    execution_reg::Int
    instruction_reg_after_Execution::String

    #For Memory Access
    mem_reg::Int
    instruction_reg_after_Memory_Access::String

    #For write Back
    writeBack_of_last_instruction::Bool

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

    #Special Purpose Registers
    #For Instruction Fetch
    instruction_reg_after_IF = "uninitialized"

    #For instruction Decode
    rs2 = -1
    rs1 = -1
    rd = -1
    immediate_value_or_offset = 0
    operator = ""
    instruction_reg_after_ID_RF = "uninitialized"

    #For Executions
    execution_reg = 0
    instruction_reg_after_Execution = "uninitialized"

    #For Memory Access
    mem_reg = 0
    instruction_reg_after_Memory_Access = "uninitialized"

    #Write Back
    writeBack_of_last_instruction = false
    return Core_Object(id,registers, pc, program,instruction_reg_after_IF,rs2,rs1,rd,immediate_value_or_offset,operator,instruction_reg_after_ID_RF,execution_reg,instruction_reg_after_Execution,mem_reg,instruction_reg_after_Memory_Access,writeBack_of_last_instruction)
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


# function run(processor::Processor)

#                             #===========================================
#                                         Parallel Processing
#                             ============================================#

#     # while processor.cores[1].pc<=length(processor.cores[1].program)&&processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
#     #     processor.clock+=1
#     #     Decode_and_execute(processor.cores[1],processor.memory)
#     #     Decode_and_execute(processor.cores[2],processor.memory)
#     # end
#     # while processor.cores[1].pc<=length(processor.cores[1].program)
#     #     processor.clock+=1
#     #     Decode_and_execute(processor.cores[1],processor.memory)
#     # end
#     # while processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
#     #     processor.clock+=1
#     #     Decode_and_execute(processor.cores[2],processor.memory)
#     # end

#                             #===========================================
#                                         Sequential Processing
#                                     (Uncomment the below two loops)
#                             ============================================#

#     # while processor.cores[1].pc<=length(processor.cores[1].program)
#     #     processor.clock+=1
#     #     Decode_and_execute(processor.cores[1],processor.memory)
#     # end
#     # while processor.cores[2].pc<=(length(processor.cores[2].program)+length(processor.cores[1].program))
#     #     processor.clock+=1
#     #     Decode_and_execute(processor.cores[2],processor.memory)
#     # end


#     while processor.cores[1].pc<=length(processor.cores[1].program)
#         processor.clock+=1
#         # writeBack()
#         # memory()
#         # execute()
#         # instructionDecode_RegisterFetch()
#         instruction_Fetch(processor.cores[1],processor.memory)
#         println(processor.cores[1].instruction_fetch_register)
#     end
# end
