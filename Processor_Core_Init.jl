
#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Core_Object
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
    
    #Special Purpose Registers
    stall_count::Int
    stall_present::Bool
    stall_at_execution::Bool
    stall_in_next_clock::Bool
    # Bus_in_use

    #For Instruction Fetch
    instruction_reg_after_IF::String

    #For instruction Decode / Register Fetch
    rd_second_before::Int
    rs2::Int
    rs1::Int
    rd::Int
    immediate_value_or_offset::Int
    operator::String
    instruction_reg_after_ID_RF::String
    temp_reg::String

    #For Execution
    execution_reg::Int
    instruction_reg_after_Execution::String

    #For Memory Access
    mem_reg::Int
    instruction_reg_after_Memory_Access::String

    #For write Back
    instruction_reg_after_Write_Back::String
    writeBack_of_last_instruction::Bool
    writeBack_of_second_last_instruction::Bool

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
    stall_count = 0
    stall_present = false
    stall_at_execution = false
    stall_in_next_clock = false
    #For Instruction Fetch
    instruction_reg_after_IF = "uninitialized"

    #For instruction Decode
    rd_second_before = -1
    rs2 = -1
    rs1 = -1
    rd = -1
    immediate_value_or_offset = 0
    operator = ""
    instruction_reg_after_ID_RF = "uninitialized"
    temp_reg = "uninitialized"

    #For Executions
    execution_reg = 0
    instruction_reg_after_Execution = "uninitialized"

    #For Memory Access
    mem_reg = 0
    instruction_reg_after_Memory_Access = "uninitialized"

    #Write Back
    instruction_reg_after_Write_Back = "uninitialized"
    writeBack_of_last_instruction = false
    writeBack_of_second_last_instruction = false
    return Core_Object(id,registers, pc, program,stall_count,stall_present,stall_at_execution,stall_in_next_clock,instruction_reg_after_IF,rd_second_before,rs2,rs1,rd,immediate_value_or_offset,operator,instruction_reg_after_ID_RF,temp_reg,execution_reg,instruction_reg_after_Execution,mem_reg,instruction_reg_after_Memory_Access,instruction_reg_after_Write_Back,writeBack_of_last_instruction,writeBack_of_second_last_instruction)
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
