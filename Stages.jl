include("Execute_Operation_phase2.jl")
                            
#==========================================================================================================
                                               Run Function
===========================================================================================================#


function run(processor::Processor)
    while processor.cores[1].pc<=length(processor.cores[1].program)
        processor.clock+=1
        instruction_Fetch(processor.cores[1],processor.memory)
        processor.clock+=1
        instructionDecode_RegisterFetch(processor.cores[1])
        processor.clock+=1
        execute(processor.cores[1])
        processor.clock+=1
        memory_access(processor.cores[1],processor.memory)
        processor.clock+=1
        writeBack(processor.cores[1])
    end
end

#==========================================================================================================
                                                 IF
===========================================================================================================#

function instruction_Fetch(core::Core_Object,memory)
    core.instruction_reg_after_IF = int_to_8bit_bin(memory[core.pc,4])*int_to_8bit_bin(memory[core.pc,3])*int_to_8bit_bin(memory[core.pc,2])*int_to_8bit_bin(memory[core.pc,1])
    core.pc+=1
    core.registers[1]=0
end

#==========================================================================================================
                                                ID / RF
===========================================================================================================#

function instructionDecode_RegisterFetch(core::Core_Object)
    # Register Fetch
    core.instruction_reg_after_ID_RF = Instruction_to_decode = core.instruction_reg_after_IF
    core.rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
    core.rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
    core.rd = parse(Int,Instruction_to_decode[21:25], base=2)
    core.immediate_value_or_offset = bin_string_to_signed_int(Instruction_to_decode[1:12])

    #Instruction Decode
    opcode = Instruction_to_decode[26:32]
    func3 = Instruction_to_decode[18:20]
    core.operator = get_instruction(opcode, func3)
    core.registers[1]=0
end

#==========================================================================================================
                                                  Ex
===========================================================================================================#

function execute(core::Core_Object)
    core.instruction_reg_after_Execution = core.instruction_reg_after_ID_RF
    Execute_Operation(core)
    core.registers[1]=0
end

#==========================================================================================================
                                                  Mem
===========================================================================================================#

function memory_access(core::Core_Object,memory)
    core.instruction_reg_after_Memory_Access = Instruction_to_decode = core.instruction_reg_after_Execution

    rs1 = parse(Int,Instruction_to_decode[13:17], base=2) + 1
    opcode = Instruction_to_decode[26:32]
    func3 = Instruction_to_decode[18:20]
    # operator = operator_dict[opcode][func3]
    operator = get_instruction(opcode, func3)

    core.mem_reg = address = core.execution_reg
    if operator == "LW"
        core.mem_reg = return_word_from_memory_littleEndian(memory,address)
    elseif operator=="LA"
        core.mem_reg = core.execution_reg
    elseif operator == "LB"
        row,col = address_to_row_col(address)
        core.mem_reg = memory[row,col]
    elseif operator=="SW"
        row,col = address_to_row_col(address)
        bin = int_to_32bit_bin(core.registers[rs1])
        in_memory_place_word(memory,row,col,bin)
    elseif operator == "SB"
        address = core.execution_reg
        row,col = address_to_row_col(address)
        memory[row,col] = core.registers[rs1]
    end
    core.registers[1]=0
end

#==========================================================================================================
                                            Write Back
===========================================================================================================#

function writeBack(core::Core_Object)
    Instruction_to_decode = core.instruction_reg_after_Memory_Access
    rd = parse(Int,Instruction_to_decode[21:25], base=2) + 1
    opcode = Instruction_to_decode[26:32]
    func3 = Instruction_to_decode[18:20]
    operator = get_instruction(opcode, func3)
    

    if any(value ->operator  in values(value), values(operator_dict_RI))
        core.registers[rd] = core.mem_reg
    elseif operator=="LA"||operator=="LW"||operator=="LB"||operator=="JAL"||operator=="JALR"
        core.registers[rd] = core.mem_reg
    end
    core.registers[1]=0
end