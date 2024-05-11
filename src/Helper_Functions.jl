include("Processor_Core_Init.jl")

#==============================================================================================
                                    Cache Replacement Functions
==============================================================================================#

function address_present_in_L1_cache(cache::L1_Cache,address)
    address = int_to_32bit_bin(address)
    cache.offset_bits = address[end-cache.length_of_offset_bits+1:end]
    cache.index_bits = address[end-cache.length_of_offset_bits-cache.length_of_index_bits+1:end-cache.length_of_offset_bits]
    cache.tag_bits = address[1:end-cache.length_of_offset_bits-cache.length_of_index_bits]
    set_number = binary_to_uint8(cache.index_bits)
    # println("\n set number = ",set_number)
    # Print the set
    # for i in 1:cache.associativity
    #     println(cache.memory[set_number + 1].set[i])
    # end
    index = findfirst([block.block[1] == cache.tag_bits for block in cache.memory[set_number+1].set])
    if index !== nothing
        # Updating Recency of that block
        old_recency = cache.memory[set_number+1].set[index].recency
        cache.memory[set_number+1].set[index].recency = 0
        for i in 1:cache.associativity  
            if cache.memory[set_number+1].set[i].recency < old_recency  &&  cache.memory[set_number+1].set[i].isValid
                cache.memory[set_number+1].set[i].recency+=1
            end
        end
        # println("Block present, addresss = ",cache.tag_bits," ",cache.index_bits," ",cache.offset_bits)
        # return block_memory[(address%cache.block_size)+2]
        return cache.memory[set_number+1].set[index].block[binary_to_uint8(cache.offset_bits)+2]
    else
        # println("Block Not Found addresss = ",cache.tag_bits," ",cache.index_bits," ",cache.offset_bits)
        return -1
    end
end

function address_present_in_LLC_cache(cache::LLC_Cache,address)
    address = int_to_32bit_bin(address)
    cache.offset_bits = address[end-cache.length_of_offset_bits+1:end]
    cache.index_bits = address[end-cache.length_of_offset_bits-cache.length_of_index_bits+1:end-cache.length_of_offset_bits]
    cache.tag_bits = address[1:end-cache.length_of_offset_bits-cache.length_of_index_bits]
    set_number = binary_to_uint8(cache.index_bits)
    # println("\n set number = ",set_number)
    # Print the set
    # for i in 1:cache.associativity
    #     println(cache.memory[set_number + 1].set[i])
    # end
    index = findfirst([block.block[1] == cache.tag_bits for block in cache.memory[set_number+1].set])
    if index !== nothing
        # Updating Recency of that block
        old_recency = cache.memory[set_number+1].set[index].recency
        cache.memory[set_number+1].set[index].recency = 0
        for i in 1:cache.associativity  
            if cache.memory[set_number+1].set[i].recency < old_recency  &&  cache.memory[set_number+1].set[i].isValid
                cache.memory[set_number+1].set[i].recency+=1
            end
        end
        # println("Block present, addresss = ",cache.tag_bits," ",cache.index_bits," ",cache.offset_bits)
        # return block_memory[(address%cache.block_size)+2]
        return cache.memory[set_number+1].set[index].block[binary_to_uint8(cache.offset_bits)+2]
    else
        # println("Block Not Found addresss = ",cache.tag_bits," ",cache.index_bits," ",cache.offset_bits)
        return -1
    end
end

function place_block_in_L1_cache_from_LLC_Cache(core_id,L1_cache::L1_Cache,LLC_cache::LLC_Cache,address,memory)
    new_block = retrieve_block_from_memory(L1_cache,address,memory)
    new_block.shared_state = true
    set_number = binary_to_uint8(L1_cache.index_bits)
    if L1_cache.LRU_selected
        LRU_cache_replacement_policy(L1_cache,new_block,set_number) 
    elseif L1_cache.Hashing_selected
        Hashing_cache_replacement_policy(L1_cache,new_block,set_number) 
    else
        Random_cache_replacement_policy(L1_cache,new_block,set_number)
    end
    return new_block.block
end

function place_block_in_L1_cache_from_main_memory(cache::L1_Cache,address,memory)
    new_block = retrieve_block_from_memory(cache,address,memory)      #Returns a string array of the bytes from memory
    set_number = binary_to_uint8(cache.index_bits)
    if cache.LRU_selected
        LRU_cache_replacement_policy(cache,new_block,set_number) 
    elseif cache.Hashing_selected
        Hashing_cache_replacement_policy(cache,new_block,set_number) 
    else
        Random_cache_replacement_policy(cache,new_block,set_number)
    end
    return new_block.block
end

function place_block_in_LLC_cache_from_main_memory(cache::LLC_Cache,address,memory)
    new_block = retrieve_block_from_memory(cache,address,memory)      #Returns a string array of the bytes from memory
    set_number = binary_to_uint8(cache.index_bits)
    if cache.LRU_selected
        LRU_cache_replacement_policy(cache,new_block,set_number) 
    elseif cache.Hashing_selected
        Hashing_cache_replacement_policy(cache,new_block,set_number) 
    else
        Random_cache_replacement_policy(cache,new_block,set_number)
    end
    # return new_block.block
end

function retrieve_block_from_memory(cache::L1_Cache,address,memory)
    Block = block_Init(cache.block_size)
    address_in_bits = int_to_32bit_bin(address)
    zeros = repeat("0",cache.length_of_offset_bits)
    block_lower_bound = binary_to_uint8(address_in_bits[1:end-cache.length_of_offset_bits]*zeros)
    block_upper_bound = block_lower_bound+cache.block_size-1
    # println("address = ",address," block_lower_bound = ",block_lower_bound," block_upper_bound = ",block_upper_bound)
    # tag 
    Block.block[1] = cache.tag_bits
    #Filling remaining with memory
    for byte_address in block_lower_bound:block_upper_bound
        Block.block[(byte_address % cache.block_size)+2] = int_to_8bit_bin(return_byte_from_memory(memory,byte_address))
    end
    return Block
end

function retrieve_block_from_memory(cache::LLC_Cache,address,memory)
    Block = block_Init(cache.block_size)
    address_in_bits = int_to_32bit_bin(address)
    zeros = repeat("0",cache.length_of_offset_bits)
    block_lower_bound = binary_to_uint8(address_in_bits[1:end-cache.length_of_offset_bits]*zeros)
    block_upper_bound = block_lower_bound+cache.block_size-1
    # println("address = ",address," block_lower_bound = ",block_lower_bound," block_upper_bound = ",block_upper_bound)
    # tag 
    Block.block[1] = cache.tag_bits
    #Filling remaining with memory
    for byte_address in block_lower_bound:block_upper_bound
        Block.block[(byte_address % cache.block_size)+2] = int_to_8bit_bin(return_byte_from_memory(memory,byte_address))
    end
    return Block
end

function LRU_cache_replacement_policy(cache::L1_Cache,Block,set_number)
    # println("new block = ",Block)
    index = nothing
    #If initially any empty block is present in the set
    for (block_index, block) in enumerate(cache.memory[set_number + 1].set)
        if !block.isValid
            index = block_index
            Block.isValid = true
            cache.memory[set_number + 1].set[index] = deepcopy(Block)
            break
        end
    end
    if index == nothing
        #From previous function we know set number 
        tag_to_be_replaced = cache.memory[set_number+1].set
        recencies = [block.recency for block in cache.memory[set_number + 1].set]
        max_recency_index = argmax(recencies)
        Block.isValid = true
        cache.memory[set_number + 1].set[max_recency_index] = deepcopy(Block)
    end
    for block in cache.memory[set_number + 1].set 
        if block.isValid
            block.recency+=1 
        end
    end
    #Printing the set 
    # println("After Replacement Policy ----------------------------------------------------------")
    # println("\n set number = ",set_number)
    # for i in 1:cache.associativity
    #     println(cache.memory[set_number + 1].set[i])
    # end
    # println("-------------------------------------------------------------------------------")
end

function Hashing_cache_replacement_policy(cache::L1_Cache,Block,set_number)
    hash_value = (binary_to_uint8(Block.block[1])%cache.block_size) + 1
    Block.isValid = true
    cache.memory[set_number + 1].set[hash_value] = deepcopy(Block)
end

function Random_cache_replacement_policy(cache::L1_Cache,Block,set_number)
    Block.isValid = true
    cache.memory[set_number + 1].set[rand(1:cache.block_size)] = deepcopy(Block)
end

function LRU_cache_replacement_policy(cache::LLC_Cache,Block,set_number)
    # println("new block = ",Block)
    index = nothing
    #If initially any empty block is present in the set
    for (block_index, block) in enumerate(cache.memory[set_number + 1].set)
        if !block.isValid
            index = block_index
            Block.isValid = true
            cache.memory[set_number + 1].set[index] = deepcopy(Block)
            break
        end
    end
    if index == nothing
        #From previous function we know set number 
        tag_to_be_replaced = cache.memory[set_number+1].set
        recencies = [block.recency for block in cache.memory[set_number + 1].set]
        max_recency_index = argmax(recencies)
        Block.isValid = true
        cache.memory[set_number + 1].set[max_recency_index] = deepcopy(Block)
    end
    for block in cache.memory[set_number + 1].set 
        if block.isValid
            block.recency+=1 
        end
    end
    #Printing the set 
    # println("After Replacement Policy ----------------------------------------------------------")
    # println("\n set number = ",set_number)
    # for i in 1:cache.associativity
    #     println(cache.memory[set_number + 1].set[i])
    # end
    # println("-------------------------------------------------------------------------------")
end

function Hashing_cache_replacement_policy(cache::LLC_Cache,Block,set_number)
    hash_value = (binary_to_uint8(Block.block[1])%cache.block_size) + 1
    Block.isValid = true
    cache.memory[set_number + 1].set[hash_value] = deepcopy(Block)
end

function Random_cache_replacement_policy(cache::LLC_Cache,Block,set_number)
    Block.isValid = true
    cache.memory[set_number + 1].set[rand(1:cache.block_size)] = deepcopy(Block)
end


function write_through_cache(L1_cache::L1_Cache,bin,LLC_cache::LLC_Cache,memory,address)
    address = int_to_32bit_bin(address)
    # First Updating that Byte in the L1 Cache
    L1_cache.offset_bits = address[end-L1_cache.length_of_offset_bits+1:end]
    L1_cache.index_bits = address[end-L1_cache.length_of_offset_bits-L1_cache.length_of_index_bits+1:end-L1_cache.length_of_offset_bits]
    L1_cache.tag_bits = address[1:end-L1_cache.length_of_offset_bits-L1_cache.length_of_index_bits]
    set_number = binary_to_uint8(L1_cache.index_bits)
    index = findfirst([block.block[1] == L1_cache.tag_bits for block in L1_cache.memory[set_number+1].set])
    if index !== nothing
        # Updating Recency of that block
        old_recency = L1_cache.memory[set_number+1].set[index].recency
        L1_cache.memory[set_number+1].set[index].recency = 0
        for i in 1:L1_cache.associativity  
            if L1_cache.memory[set_number+1].set[i].recency < old_recency  &&  L1_cache.memory[set_number+1].set[i].isValid
                L1_cache.memory[set_number+1].set[i].recency+=1
            end
        end
        #Updating that byte in the block of L1 Cache
        L1_cache.memory[set_number+1].set[index].block[binary_to_uint8(L1_cache.offset_bits)+2] = bin
    end

    # Then Updating that Byte in LLC Cache
    LLC_cache.offset_bits = address[end-LLC_cache.length_of_offset_bits+1:end]
    LLC_cache.index_bits = address[end-LLC_cache.length_of_offset_bits-LLC_cache.length_of_index_bits+1:end-LLC_cache.length_of_offset_bits]
    LLC_cache.tag_bits = address[1:end-LLC_cache.length_of_offset_bits-LLC_cache.length_of_index_bits]
    set_number = binary_to_uint8(LLC_cache.index_bits)
    index = findfirst([block.block[1] == LLC_cache.tag_bits for block in LLC_cache.memory[set_number+1].set])
    if index !== nothing
        # Updating Recency of that block
        old_recency = LLC_cache.memory[set_number+1].set[index].recency
        LLC_cache.memory[set_number+1].set[index].recency = 0
        for i in 1:LLC_cache.associativity  
            if LLC_cache.memory[set_number+1].set[i].recency < old_recency  &&  LLC_cache.memory[set_number+1].set[i].isValid
                LLC_cache.memory[set_number+1].set[i].recency+=1
            end
        end
        #Updating that byte in the block of LLC Cache
        LLC_cache.memory[set_number+1].set[index].block[binary_to_uint8(LLC_cache.offset_bits)+2] = bin
    end

    # Printing the Set
    # println("------------------------------------------------------------------------------------------------")
    # println("Updated Set")
    # for i in 1:L1_cache.associativity
    #     println(L1_cache.memory[set_number + 1].set[i])
    # end
    # println("------------------------------------------------------------------------------------------------")
    # Updating in the main memory also
    address = binary_to_uint8(address)
    # println("address = ",address)
    row,col = address_to_row_col(address)
    memory[row,col]=parse(Int, bin, base=2)
end
#==========================================================================================================
                                                Stall Manager
===========================================================================================================#

function stall_manager(core::Core_Object,processor::Processor)
    #Terminating the stall
    if ((core.write_back_of_last_instruction_done)&&(core.stall_present_due_to_data_depend_previous_inst))||((core.write_back_of_second_last_instruction_done)&&(core.stall_present_due_to_data_depend_second_previous_inst))
        if core.stall_present_due_to_data_depend_previous_inst
            core.stall_present_due_to_data_depend_previous_inst = false
        elseif core.stall_present_due_to_data_depend_second_previous_inst
            core.stall_present_due_to_data_depend_second_previous_inst = false
        end
        core.instruction_IF.stall_present = false
        core.instruction_ID_RF.stall_present = false
        core.instruction_EX.stall_present = false
        core.instruction_MEM.stall_present = false
        core.instruction_WriteBack.stall_present = false
        core.write_back_of_last_instruction_done = false
    end

    if core.stall_due_to_jump 
        core.stall_count += 1
        core.stall_due_to_jump = false
    end

    if core.stall_due_to_load
        core.instruction_EX.stall_due_to_load = true
        core.instruction_ID_RF.stall_due_to_load = true
        core.instruction_IF.stall_due_to_load = true
        core.stall_due_to_load = false
    end

    if core.L1_cache.temp_penalty_mem_access > 1
        core.instruction_IF.stall_due_to_mem_access = true
        core.instruction_ID_RF.stall_due_to_mem_access = true
        core.instruction_EX.stall_due_to_mem_access = true
        core.instruction_MEM.stall_due_to_mem_access = true
        core.instruction_WriteBack.stall_due_to_mem_access = true
        core.L1_cache.temp_penalty_mem_access-=1
        # println("core.L1_cache.temp_penalty_mem_access = ",core.L1_cache.temp_penalty_mem_access)
    elseif core.L1_cache.temp_penalty_mem_access == 1
        core.instruction_IF.stall_due_to_mem_access = false
        core.instruction_ID_RF.stall_due_to_mem_access = false
        core.instruction_EX.stall_due_to_mem_access = false
        core.instruction_MEM.stall_due_to_mem_access = false
        core.instruction_WriteBack.stall_due_to_mem_access = false
        if core.L1_cache.temp_penalty_IF_access > 1 && core.L1_cache.temp_penalty_mem_access == 1
            core.instruction_IF.stall_due_to_IF_access = true
            core.instruction_ID_RF.stall_due_to_IF_access = true
            core.instruction_EX.stall_due_to_IF_access = true
            core.instruction_MEM.stall_due_to_IF_access = true
            core.instruction_WriteBack.stall_due_to_IF_access = true
            core.L1_cache.temp_penalty_IF_access-=1
            # println("core.L1_cache.temp_penalty_IF_access = ",core.L1_cache.temp_penalty_IF_access)
        elseif core.L1_cache.temp_penalty_IF_access == 1 && core.L1_cache.temp_penalty_mem_access == 1
            core.instruction_IF.stall_due_to_IF_access = false
            core.instruction_ID_RF.stall_due_to_IF_access = false
            core.instruction_EX.stall_due_to_IF_access = false
            core.instruction_MEM.stall_due_to_IF_access = false
            core.instruction_WriteBack.stall_due_to_IF_access = false
        end
    end
end
#==========================================================================================================
                                            Latency Manager
===========================================================================================================#

function latency_present(core::Core_Object,instruction_EX::Instruction)
    latency_manager(core,instruction_EX)
    if core.variable_latency!=0
        return true
    else
        core.instruction_MEM.stall_due_to_latency = false
        core.instruction_EX.stall_due_to_latency = false
        return false
    end
end

function latency_manager(core::Core_Object,instruction_EX::Instruction)
    if (instruction_EX.operator == "ADD/SUB") && (instruction_EX.Four_byte_instruction[2]=='0') && (core.add_variable_latency > 1) && (core.variable_latency!=0)    # ADD Instruction
        #----------------------------------------------------------------------------------------------------
        #First Ex stage
        if core.add_variable_latency == core.variable_latency
            # println("EX latency 1")#, latency count = ",core.variable_latency)
            core.variable_latency -= 1
            core.instruction_MEM.stall_due_to_latency = true
            core.instruction_EX.stall_due_to_latency = true
            if core.data_forwarding
                data_forward(core,instruction_EX)
            end
            return
        end
        #----------------------------------------------------------------------------------------------------
        #latency for middle ex stages where stall will be present below ex stage
        if core.add_variable_latency != core.variable_latency
            # println("EX latency 2")#, latency count = ",core.variable_latency)
            core.instruction_ID_RF.stall_due_to_latency = true
            core.instruction_IF.stall_due_to_latency = true
            if core.instruction_ID_RF.Four_byte_instruction!="uninitialized"
                core.stall_count += 1
            end
            core.variable_latency -= 1
            return
        end
    end
end
#==========================================================================================================
                            Copying Properties from one instruction to another
===========================================================================================================#

function copy_properties!(target::Instruction, source::Instruction)
    for field in fieldnames(Instruction)
        if String(field) != "stall_present" && String(field) != "source_reg"
            setfield!(target, field, getfield(source, field))
        end
        if String(field) == "source_reg"
            target.source_reg[1]=source.source_reg[1]
            target.source_reg[2]=source.source_reg[2]
        end
    end
end

#==========================================================================================================
                                            Branch Predictor
===========================================================================================================#

function predict(core::Core_Object)
    if ( core.branch_predict_bit_1 && core.branch_predict_bit_2 ) || ( core.branch_predict_bit_1 && !core.branch_predict_bit_2 ) 
        return true
    elseif ( !core.branch_predict_bit_1 && !core.branch_predict_bit_2 ) || ( !core.branch_predict_bit_1 && core.branch_predict_bit_2 ) 
        return false
    end
end

function updatePrediction(taken::Bool,core::Core_Object)
    if core.branch_predict_bit_1 && core.branch_predict_bit_2
        if !taken
            core.branch_predict_bit_2 = false
        end
    elseif core.branch_predict_bit_1 && !core.branch_predict_bit_2
        if taken
            core.branch_predict_bit_2 = true
        else
            core.branch_predict_bit_1 = false
        end
    elseif !core.branch_predict_bit_1 && !core.branch_predict_bit_2
        if taken
            core.branch_predict_bit_2 = true
        end
    elseif !core.branch_predict_bit_1 && core.branch_predict_bit_2
        if taken
            core.branch_predict_bit_1 = true
        else
            core.branch_predict_bit_2 = false
        end
    end
end

#==========================================================================================================
                                          Dependency Checker
===========================================================================================================#

function previous_instruction_checker(previous_instruction)
    if (previous_instruction.rd!=0) && ( previous_instruction.operator!="BEQ" && previous_instruction.operator!="BNE" && previous_instruction.operator!="BLT" && previous_instruction.operator!="BGE" && previous_instruction.operator!="SW" && previous_instruction.operator!="SB" )
        return true
    end
    return false
end

function second_previous_instruction_checker(core::Core_Object,second_previous_instruction)
    if (second_previous_instruction.rd!=0) && (!core.write_back_of_second_last_instruction_done) && ( second_previous_instruction.operator!="BEQ" && second_previous_instruction.operator!="BNE" && second_previous_instruction.operator!="BLT" && second_previous_instruction.operator!="BGE" && second_previous_instruction.operator!="SW" && second_previous_instruction.operator!="SB" )
        return true
    end
    return false
end

#==========================================================================================================
                                            Data Forwarding
===========================================================================================================#

function data_forward(core::Core_Object,instruction_EX::Instruction)
    # Checking dependency for rs1
    if core.rs1_dependent_on_previous_instruction
        instruction_EX.source_reg[1] = core.instruction_MEM.pipeline_reg 
        core.rs1_dependent_on_previous_instruction = false
    elseif core.rs1_dependent_on_second_previous_instruction
        instruction_EX.source_reg[1] = core.instruction_WriteBack.pipeline_reg
        core.rs1_dependent_on_second_previous_instruction = false
    end
    # Checking dependency for rs2
    if core.rs2_dependent_on_previous_instruction
        instruction_EX.source_reg[2] = core.instruction_MEM.pipeline_reg 
        core.rs2_dependent_on_previous_instruction = false
    elseif core.rs2_dependent_on_second_previous_instruction
        instruction_EX.source_reg[2] = core.instruction_WriteBack.pipeline_reg
        core.rs2_dependent_on_second_previous_instruction = false
    end
    # Checking dependency for rd because we have done encoding like that for Store and branch statements
    if core.rd_dependent_on_previous_instruction
        instruction_EX.rd = core.instruction_MEM.pipeline_reg 
        core.rd_dependent_on_previous_instruction = false
        core.rd_dependent = true
    elseif core.rd_dependent_on_second_previous_instruction
        instruction_EX.rd = core.instruction_WriteBack.pipeline_reg
        core.rd_dependent_on_second_previous_instruction = false
        core.rd_dependent = false
    end
end

#= 30 Helper Functions have been defined =#
operator_array = ["add","sub","sll","xor","srl","sra","or","and","addi","xori","ori","andi","slli","srli","srai","li","la","andi","mv","lb","lh","lw","lbu","lhu","sb","sh","sw","beq","bne","blt","bgt","bge","bltu","bgeu","lui","jal","jalr","j",]

instruction_formats = [
    "0110011" => "R",
    "0010011" => "I",
    "0000011" => "L",  # Load Format
    "0100011" => "S",  # Store Format
    "1100011" => "B",  # Break Format
    "0110111" => "U",  # Upper Immediate Format
    "1101111" => "JAL",  # Jump Format
    "1100111" => "JALR",  # Jump and Link Register Format
    "1111111" => "ECALL",  # ecall format
]
#==============================================================================================#

operator_dict = Dict(
    #R
    "0110011" => Dict(
        "000" => "ADD/SUB",
        "001" => "SLL",
        "010" => "SLT",
        "011" => "SLTU",
        "100" => "XOR",
        "101" => "SRL/SRA",
        "110" => "OR",
        "111" => "AND",
    ),
    #I
    "0010011" => Dict(
        "000" => "ADDI",
        "001" => "SLLI",
        "010" => "SLTI",
        "011" => "SLTIU",
        "100" => "XORI",
        "101" => "SRLI/SRAI",
        "110" => "OR",
        "111" => "ANDI",
    ),
    #L
    "0000011" => Dict(
        "000" => "LB",
        "001" => "LH",
        "010" => "LW",
        "011" => "LA",
        "100" => "LBU",
        "101" => "LHU",
        "110" => "LS",
    ),
    #S
    "0100011" => Dict(
        "000" => "SB",
        "001" => "SH",
        "010" => "SW",
    ),
    #B
    "1100011" =>Dict(
        "000" => "BEQ",
        "001" => "BNE",
        "100" => "BLT",
        "101" => "BGE",
        "110" => "BLTU",
        "111" => "BGEU",
    ),
    #JAL
    "1101111" => Dict(
        "anything" => "JAL",
    ),
    #JALR
    "1100111" => Dict(
        "anything" => "JALR",
    ),
)

function get_instruction(opcode::AbstractString, func3::AbstractString)
    if opcode in keys(operator_dict) && func3 in keys(operator_dict[opcode])
        return operator_dict[opcode][func3]
    elseif opcode in keys(operator_dict)
        return operator_dict[opcode]["anything"]
    else
        return "Unknown Instruction"
    end
end

#==============================================================================================
                                    Parser Functions
==============================================================================================#

function replace_commas_with_spaces(input_string::String)
    return replace(input_string, "," => " ")
end

function replace_colon_with_space(input_string::String)
    return replace(input_string, ":" => "")
end

function replace_d_quotes_with_space(input_string::String)
    return replace(input_string, "\"" => "")
end

function replace_wrong_nline_with_right_nline(input_string::String)
    return replace(input_string, "\\n" => "\n")
end

function mem_pc_to_row(mem_pc::Int)
    row = mem_pc/4

    return Int(ceil(row))
end

function mem_pc_to_col(mem_pc::Int)
    if mem_pc%4 != 0
        col = mem_pc%4
    else
        col = 4
    end 
    return col
end

function find_index_for_label(label_array, label)
    for row in label_array
        if row[1] == label
            return row[2]
        end
    end
    return nothing  # Return nothing if the string is not found
end

function find_and_remove(search_string, string_array)
    index = indexin([search_string], string_array)

    if isempty(index)
        return nothing
    else
        index = first(index)  # Get the first index (assuming no duplicates)
        removed_element = popat!(string_array, index)
        return index
    end
end

#============================================================================================================
                                    Integer to Binary String Helper Functions
=============================================================================================================#
 
function int_to_5bit_bin(n::Int)
    binary_str = string(n, base=2, pad=5)
    return binary_str
end

function int_to_8bit_bin(n::UInt8)
    binary_str = string(n, base=2, pad=8)
    return binary_str
end

function int_to_12bit_bin(n::Int)
    binary_str = string(n, base=2, pad=12)
    return binary_str
end

function int_to_signed_12bit_bin(n::Int)
    binary_str = string(n + 2^12, base=2)
    return binary_str[end-11:end]
end

function int_to_signed_13bit_bin(n::Int)
    binary_str_13bit = string(n + 2^13, base=2)
    return binary_str_13bit[end-12:end]
end

function int_to_20bit_bin(n::Int)
    binary_str = string(n + 2^20, base=2)[2:end]
    return binary_str
end

function int_to_signed_20bit_bin_string(value::Int)
    if value < 0
        value += 2^20
    end
    bin_str = string(value, base=2)
    bin_str = string("0"^(20 - length(bin_str)), bin_str)
    return bin_str
end

function int_to_32bit_bin(n::Int)
    # binary_str_20bit = string(n + 2^20, base=2)[2:end]
    # binary_str_32bit = string("0" ^ (32 - length(binary_str_20bit)), binary_str_20bit)
    binary_str_32bit = string(n, base=2, pad=32)
    return binary_str_32bit
end

function int_to_signed_32bit_bin(n::Int)
    binary_str_32bit = string(n + 2^32, base=2)
    return binary_str_32bit[end-31:end]
end

function bin_string_to_signed_int(bin_str::AbstractString)
    decimal_value = parse(Int, bin_str, base=2)
    num_bits = count(x -> x == '0' || x == '1', bin_str)
    if bin_str[1] == '1'
        decimal_value -= 2 ^ num_bits
    end
    return decimal_value
end

function binary_to_uint8(binary::String)
    result = 0
    for (i, bit) in enumerate(reverse(binary))
        if bit == '1'
            result += 2^(i-1)
        end
    end
    return result
end

function string_to_binary_8bit_string_array(str::String)
    hex_array = transcode(UInt8, str)
    binary_array = [bitstring(UInt8(x)) for x in hex_array]
    return binary_array
end

function binary_to_letters(binary_strings::Vector{String})
    letters = Char[]
    for binary_str in binary_strings
        decimal_value = parse(Int, binary_str, base=2)
        letter = Char(decimal_value)
        push!(letters, letter)
    end
    return join(letters)
end

function show_hex(value)
    hex_str = string(value, base=16)
    return lpad(hex_str, 2, '0')
end

#============================================================================================================
                                    Display Memory Helper Function
=============================================================================================================#
 

function Display_Memory(proc::Processor, start_row::Int, end_row::Int)
    println("Processor Memory (in hex):")
    
    # Ensure start_row and end_row are within the valid range
    start_row = max(1, start_row)
    end_row = min(size(proc.memory, 1), end_row)
    
    for row in reverse(start_row:end_row)
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

function in_memory_place_word(memory,row,col,bin)       #Storing 32 bits

    memory[row,col]=parse(Int, bin[25:32], base=2)
    col+=1
    if col<=4
        memory[row,col]=parse(Int, bin[17:24], base=2)
        col+=1
        if col<=4
            memory[row,col]=parse(Int, bin[9:16], base=2)
            col+=1
            if col<=4
                memory[row,col]=parse(Int, bin[1:8], base=2)
            else
                row+=1
                col=1
                memory[row,col]=parse(Int, bin[1:8], base=2)
            end
        else
            col=1
            row+=1
            memory[row,col]=parse(Int, bin[9:16], base=2)
            col+=1
            memory[row,col]=parse(Int, bin[1:8], base=2)
        end
    else
        col=1
        row+=1
        memory[row,col]=parse(Int, bin[17:24], base=2)
        col+=1
        memory[row,col]=parse(Int, bin[9:16], base=2)
        col+=1
        memory[row,col]=parse(Int, bin[1:8], base=2)
    end
end

function in_memory_place_halfword(memory,row,col,bin)       #Storing last 16 bits
    memory[row,col]=parse(Int, bin[25:32], base=2)
    col+=1
    if col<=4
        memory[row,col]=parse(Int, bin[17:24], base=2)
    else
        col=1
        row+=1
        memory[row,col]=parse(Int, bin[17:24], base=2)
    end
end

function return_word_from_memory(memory,row,col)       #returns 32 bits from the specified memory and next 3 memory units
    value=UInt32(memory[row,col])
    col+=1
    if col<=4
        temp =  UInt32(memory[row,col])<<8
        value =  (temp) | (value) 
        col+=1
        if col<=4
            temp =  UInt32(memory[row,col])<<16
            value =  (temp) | (value) 
            col+=1
            if col<=4
                temp =  UInt32(memory[row,col])<<24
                value =  (temp) | (value) 
            else
                col=1
                row+=1
                temp = UInt32(memory[row,col])<<24
                value =  (temp) | (value) 
            end
        else
            col=1
            row+=1
            temp =  UInt32(memory[row,col])<<16
            value =  (temp) | (value) 
            col+=1
            temp =  UInt32(memory[row,col])<<24
            value =  (temp) | (value) 
        end
    else
        col=1
        row+=1
        temp =  UInt32(memory[row,col])<<8
        value =  (temp) | (value) 
        col+=1
        temp =  UInt32(memory[row,col])<<16
        value =  (temp) | (value) 
        col+=1
        temp =  UInt32(memory[row,col])<<24
        value =  (temp) | (value) 
    end
    return value
end

function return_word_from_memory_littleEndian(memory,address)
    row = div(address,4) + 1
    col = (address%4) + 1
    temp = UInt32(memory[row,col])
    col+=1
    if col<=4
        temp = temp | ((UInt32(memory[row,col]))<<8)
        col+=1
        if col<=4
            temp = temp | ((UInt32(memory[row,col]))<<16)
            col+=1
            if col<=4
                temp = temp | ((UInt32(memory[row,col]))<<24)
            else
                col=1
                row+=1
                temp = temp | ((UInt32(memory[row,col]))<<24)
            end
        else
            col = 1
            row+=1
            temp = temp | ((UInt32(memory[row,col]))<<16)
            col+=1
            temp = temp | ((UInt32(memory[row,col]))<<24)
        end
    else
        row+=1
        col=1
        temp = temp | ((UInt32(memory[row,col]))<<8)
        col+=1
        temp = temp | ((UInt32(memory[row,col]))<<16)
        col+=1
        temp = temp | ((UInt32(memory[row,col]))<<24)
    end
    return temp
end

function return_byte_from_memory(memory,address)
    row,col = address_to_row_col(address)
    return memory[row,col]
end

function address_to_row_col(address)
    row = div(address,4) + 1
    col = (address%4) + 1
    return row,col
end
