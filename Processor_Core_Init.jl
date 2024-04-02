
#==========================================================================================================
                                             Cache
===========================================================================================================#
mutable struct Block
    size::Int
    recency::Int
    block::Array{String, 1}
    isValid::Bool
end

function block_Init(size)
    recency = 0
    block = fill("", size + 1)
    isValid = false
    return Block(size, recency, block, isValid)
end

mutable struct Set
    associativity::Int
    set::Array{Block, 1}
end

function set_Init(associativity, block_size)
    set = Block[]
    for _ in 1:associativity
        push!(set, block_Init(block_size))
    end
    return Set(associativity, set)
end

mutable struct Cache
    size::Int
    block_size::Int
    associativity::Int
    memory::Array{Set, 1}
    length_of_offset_bits::Int
    length_of_index_bits::Int
    offset_bits::String
    index_bits::String
    tag_bits::String
end

function cache_Init()
    size = 64000
    block_size = 16
    associativity = 16
    number_of_sets = div(div(size, block_size),associativity)
    memory = Set[]
    for _ in 1:number_of_sets
        push!(memory, set_Init(associativity, block_size))
    end
    length_of_offset_bits = Int(log2(block_size))
    length_of_index_bits = Int(ceil(log2(number_of_sets)))
    offset_bits = ""
    index_bits = ""
    tag_bits = ""
    return Cache(
        size,
        block_size,
        associativity,
        memory,
        length_of_offset_bits,
        length_of_index_bits,
        offset_bits,
        index_bits,
        tag_bits
    )
end

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
    stall_due_to_latency::Bool
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
    stall_due_to_latency = false
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
        stall_due_to_load,
        stall_due_to_latency
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
    rd_dependent::Bool  #Temp we need to remove it

    #variable_latency
    add_variable_latency::Int
    variable_latency::Int
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
    rd_dependent = false

    #Variable latency
    add_variable_latency = 1
    variable_latency = 0
    
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
        rd_dependent,
        add_variable_latency,
        variable_latency
    )
end

#==========================================================================================================
                                        Processor Initializing
===========================================================================================================#

mutable struct Processor
    cache::Cache
    memory::Array{UInt8,2}
    main_memory_latency::Int
    clock::Int
    cores::Array{Core_Object,1}
    hits::Int
    accesses::Int
end

function processor_Init()
    cache = cache_Init()
    memory = zeros(UInt8, (1024, 4))
    main_memory_latency = 1
    clock = 0
    cores = [core_Init(1), core_Init(2)] 
    hits = 0
    accesses = 0
    return Processor(cache, memory, main_memory_latency, clock, cores, hits, accesses)
end