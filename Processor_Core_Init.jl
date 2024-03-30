
#==========================================================================================================
                                        Instruction Object
===========================================================================================================#

mutable struct Instruction
    Four_byte_instruction::String
    source_reg::Array{Int, 1}    # For Storing the contents of source registers
    rs1::Int
    rs2::Int
    rd::Int
    immediate_value_or_offset::Int
    operator::String
    pipeline_reg::Int
    stall_present::Bool
    stall_due_to_jump::Bool
    stall_due_to_branch::Bool
    stall_due_to_load::Bool
end

function instruction_Init()
    Four_byte_instruction="uninitialized"
    source_reg = fill(0,2)
    rs1 = 0
    rs2 = 0
    rd = 0
    immediate_value_or_offset = 0
    operator = "uninitialized"
    pipeline_reg = 0
    stall_present = false
    stall_due_to_jump = false
    stall_due_to_branch = false
    stall_due_to_load = false
    return Instruction(
        Four_byte_instruction,
        source_reg,
        rs1,
        rs2,
        rd,
        immediate_value_or_offset,
        operator,
        pipeline_reg,
        stall_present,
        stall_due_to_jump,
        stall_due_to_branch,
        stall_due_to_load
    )
end

#==========================================================================================================
                                        Core Initializing
===========================================================================================================#

mutable struct Core_Object
    id::Int
    registers::Array{Int, 1}
    pc::Int
    program::Array{String, 1}
    clock::Int
    instruction_count::Int
    
    #Stall
    stall_count::Int
    stall_due_to_jump::Bool
    stall_present_due_to_data_depend_previous_inst::Bool
    stall_present_due_to_data_depend_second_previous_inst::Bool
    stall_due_to_load::Bool

    #Objects for instructions
    instruction_IF::Instruction
    instruction_ID_RF::Instruction
    instruction_EX::Instruction
    instruction_MEM::Instruction
    instruction_WriteBack::Instruction
    
    #Write back
    write_back_of_last_instruction_done::Bool
    write_back_of_second_last_instruction_done::Bool

    #Branch Predictor
    branch_predict_bit_1::Bool
    branch_predict_bit_2::Bool
    branch_taken::Bool
    branch_count::Int
    branch_correct_predict_count::Int
    branch_pc::Int

    #Data Forwarding
    data_forwarding::Bool
    rs1_dependent_on_previous_instruction::Bool
    rs1_dependent_on_second_previous_instruction::Bool
    rs2_dependent_on_previous_instruction::Bool
    rs2_dependent_on_second_previous_instruction::Bool
    rd_dependent_on_previous_instruction::Bool
    rd_dependent_on_second_previous_instruction::Bool
    store_dependency::Bool
    branch_dependency::Bool

    #variable_latency
    add_variable_latency::Int
end

function core_Init(id)
    registers = fill(0, 32)
    pc = 1
    program = []
    clock = 0
    instruction_count = 0

    #Stall
    stall_count = 0
    stall_due_to_jump = false
    stall_present_due_to_data_depend_previous_inst = false
    stall_present_due_to_data_depend_second_previous_inst = false
    stall_due_to_load = false

    #Objects for instructions
    instruction_IF = instruction_Init()
    instruction_ID_RF = instruction_Init()
    instruction_EX = instruction_Init()
    instruction_MEM = instruction_Init()
    instruction_WriteBack = instruction_Init()

    #write back
    write_back_of_last_instruction_done = false
    write_back_of_second_last_instruction_done = false

    #Branch Predictor
    branch_predict_bit_1 = true
    branch_predict_bit_2 = true
    branch_taken = true
    branch_count = 0
    branch_correct_predict_count = 0
    branch_pc = 0
    
    #Data Forwarding
    data_forwarding = false
    rs1_dependent_on_previous_instruction = false
    rs1_dependent_on_second_previous_instruction = false
    rs2_dependent_on_previous_instruction = false
    rs2_dependent_on_second_previous_instruction = false
    rd_dependent_on_previous_instruction = false
    rd_dependent_on_second_previous_instruction = false
    store_dependency = false
    branch_dependency = false

    #Variable latency
    add_variable_latency = 1
    
    return Core_Object(
        id,
        registers, 
        pc, 
        program,
        clock,
        instruction_count,
        stall_count,
        stall_due_to_jump,
        stall_present_due_to_data_depend_previous_inst,
        stall_present_due_to_data_depend_second_previous_inst,
        stall_due_to_load,
        instruction_IF,
        instruction_ID_RF,
        instruction_EX,
        instruction_MEM,
        instruction_WriteBack,
        write_back_of_last_instruction_done,
        write_back_of_second_last_instruction_done,
        branch_predict_bit_1,
        branch_predict_bit_2,
        branch_taken,
        branch_count,
        branch_correct_predict_count,
        branch_pc,
        data_forwarding,
        rs1_dependent_on_previous_instruction,
        rs1_dependent_on_second_previous_instruction,
        rs2_dependent_on_previous_instruction,
        rs2_dependent_on_second_previous_instruction,
        rd_dependent_on_previous_instruction,
        rd_dependent_on_second_previous_instruction,
        store_dependency,
        branch_dependency,
        add_variable_latency
    )
end

#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Processor
    memory::Array{UInt8,2}
    clock::Int
    cores::Array{Core_Object,1}
end

function processor_Init()
    memory = zeros(UInt8, (1024, 4))
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    return Processor(memory, clock, cores)
end