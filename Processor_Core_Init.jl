
#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Core_Object
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}

    #Special Purpose Registers
    instruction_count::Int
    stall_count::Int
    stall_in_present_clock::Bool
    stall_at_instruction_fetch::Bool
    stall_at_execution::Bool
    stall_in_next_clock::Bool
    stall_due_to_jump::Bool
    stall_due_to_load::Bool
    stall_due_to_df::Bool
    data_forwarding_on::Bool
    data_forwarding_for_Store_rs::Bool
    data_forwarding_reg_i::Int
    data_forwarding_reg_rs1::Int
    data_forwarding_reg_rs2::Int
    data_forwarding_reg_rd::Int
    data_forwarding_for_branch::Bool
    regi_dependent_on_previous_instruction::Bool
    rs1_dependent_on_previous_instruction::Bool
    rs2_dependent_on_previous_instruction::Bool
    rd_dependent_on_previous_instruction::Bool
    rs1_dependent_on_second_previous_instruction::Bool
    rs2_dependent_on_second_previous_instruction::Bool

    #For Instruction Fetch
    instruction_reg_after_IF::String

    #For instruction Decode / Register Fetch
    rd_second_before::Int
    rs2::Int
    rs1::Int
    rd::Int
    immediate_value_or_offset::Int
    present_operator::String
    previous_operator::String
    second_previous_operator::String
    instruction_reg_after_ID_RF::String
    temp_reg::String

    #For Execution
    execution_reg::Int
    instruction_reg_after_Execution::String

    #For Memory Access
    previous_mem_reg::Int
    mem_reg::Int
    instruction_reg_after_Memory_Access::String

    #For write Back
    instruction_reg_after_Write_Back::String
    writeBack_of_last_instruction::Bool
    writeBack_of_second_last_instruction::Bool

    #For Branch prediction
    branch_to_be_taken_in_next_clock::Bool
    branch_to_be_taken_in_present_clock::Bool
    branch_pc::Int
    branch_count::Int
    branch_taken_count::Int
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
    instruction_count = 0
    stall_count = 0
    stall_in_present_clock = false
    stall_at_instruction_fetch = false
    stall_at_execution = false
    stall_in_next_clock = false
    stall_due_to_jump = false
    stall_due_to_load = false
    stall_due_to_df = false
    data_forwarding_on = false
    data_forwarding_for_Store_rs = false
    data_forwarding_reg_i = 0
    data_forwarding_reg_rs1 = 0
    data_forwarding_reg_rs2 = 0
    data_forwarding_reg_rd = 0
    data_forwarding_for_branch = false
    regi_dependent_on_previous_instruction = false
    rs1_dependent_on_previous_instruction = false
    rs2_dependent_on_previous_instruction = false
    rd_dependent_on_previous_instruction = false
    rs1_dependent_on_second_previous_instruction = false
    rs2_dependent_on_second_previous_instruction = false

    #For Instruction Fetch
    instruction_reg_after_IF = "uninitialized"

    #For instruction Decode
    rd_second_before = -1
    rs2 = -1
    rs1 = -1
    rd = -1
    immediate_value_or_offset = 0
    present_operator = ""
    previous_operator = ""
    second_previous_operator = ""
    instruction_reg_after_ID_RF = "uninitialized"
    temp_reg = "uninitialized"

    #For Executions
    execution_reg = 0
    instruction_reg_after_Execution = "uninitialized"

    #For Memory Access
    previous_mem_reg = 0
    mem_reg = 0
    instruction_reg_after_Memory_Access = "uninitialized"

    #Write Back
    instruction_reg_after_Write_Back = "uninitialized"
    writeBack_of_last_instruction = false
    writeBack_of_second_last_instruction = false

    #Branch Prediction
    branch_to_be_taken_in_next_clock = false
    branch_to_be_taken_in_present_clock = false
    branch_pc = 0
    branch_count = 0
    branch_taken_count = 0
    return Core_Object(id,registers, pc, program,instruction_count,stall_count,stall_in_present_clock,stall_at_instruction_fetch,stall_at_execution,stall_in_next_clock,stall_due_to_jump,stall_due_to_load,stall_due_to_df,data_forwarding_on,data_forwarding_for_Store_rs,data_forwarding_reg_i,data_forwarding_reg_rs1,data_forwarding_reg_rs2,data_forwarding_reg_rd,data_forwarding_for_branch,regi_dependent_on_previous_instruction,rs1_dependent_on_previous_instruction,rs2_dependent_on_previous_instruction,rd_dependent_on_previous_instruction,rs1_dependent_on_second_previous_instruction,rs2_dependent_on_second_previous_instruction,instruction_reg_after_IF,rd_second_before,rs2,rs1,rd,immediate_value_or_offset,present_operator,previous_operator,second_previous_operator,instruction_reg_after_ID_RF,temp_reg,execution_reg,instruction_reg_after_Execution,previous_mem_reg,mem_reg,instruction_reg_after_Memory_Access,instruction_reg_after_Write_Back,writeBack_of_last_instruction,writeBack_of_second_last_instruction,branch_to_be_taken_in_next_clock,branch_to_be_taken_in_present_clock,branch_pc,branch_count,branch_taken_count)
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
