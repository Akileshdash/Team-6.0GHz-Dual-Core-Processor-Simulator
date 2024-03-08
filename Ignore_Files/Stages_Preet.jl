include("Execute_Operation_phase2.jl")
include("pipeline.jl")
                    
#==========================================================================================================
                                               Run Function basics
===========================================================================================================#

n = 20
array_2d = fill("0", n, n)

stage_array = ["IF", "ID/RF", "EX", "MEM", "WB"]


# for i in 1:n
#     for j in 1:n
#         print(array_2d[i, j], "\t")
#     end
#     println()
# end

# println("-------------------------------------------------------")

for i in 1:n
    for j in 1:i-1
        array_2d[i, j] = "-1"
    end
    
    for j in i:i+4
        if j > n
            break
        end
        array_2d[i, j] = string(j - i + 1)
    end
end


for i in 1:n
    for j in 1:n
        if array_2d[i, j] == "1"
            array_2d[i, j] = "IF"
        end

        if array_2d[i, j] == "2"
            array_2d[i, j] = "ID/RF"
        end

        if array_2d[i, j] == "3"
            array_2d[i, j] = "EX"
        end

        if array_2d[i, j] == "4"
            array_2d[i, j] = "MEM"
        end

        if array_2d[i, j] == "5"
            array_2d[i, j] = "WB"
        end
    end
    # println()
end



# for i in 1:n
#     for j in 1:n
#         print(array_2d[i, j], "\t")
#     end
#     println()
# end

                            
#==========================================================================================================
                                               Run Function
===========================================================================================================#

function run(processor::Processor)
    limit = length(processor.cores[1].program) + 4
    while processor.cores[1].pc<=limit
        processor.clock+=1
        row = 1

        if processor.clock > 6
            break
        end
    
        focus_block = array_2d[row, processor.clock]
        # 1
        println(focus_block, " at (", row, ", ", processor.clock, ")")
    
        while focus_block == "0"
            row += 1
            focus_block = array_2d[row, processor.clock]
        end
    
        focus_block = array_2d[row, processor.clock]
        # 2
        println(focus_block, " at (", row, ", ", processor.clock, ")")
    
        if focus_block == "WB"
            println("WB identified ")
            writeBack(processor.cores[1])
            row +=1 
        end
        
        focus_block = array_2d[row, processor.clock]
        # 3
        println(focus_block, " at (", row, ", ", processor.clock, ")")

        if focus_block == "MEM"
            println("MEM identified ")
            memory_access(processor.cores[1],processor.memory)
            row += 1 
        end
    
        focus_block = array_2d[row, processor.clock]
        # 4
        println(focus_block, " at (", row, ", ", processor.clock, ")")
      
        if focus_block == "EX"
            println("EX identified ")
            execute(processor.cores[1])
            row += 1 
        end
    
        focus_block = array_2d[row, processor.clock]
        # 5
        println(focus_block, " at (", row, ", ", processor.clock, ")")
      
        if focus_block == "ID/RF"
            println("ID/RF identified ")
            stall = instructionDecode_RegisterFetch(processor.cores[1])
            if stall
                shift_right(array_2d, row, processor.clock, 2)
                limit+=2
            end
            row += 1
        end
    
        focus_block = array_2d[row, processor.clock]
        # 6
        println(focus_block, " at (", row, ", ", processor.clock, ")")
      
        if focus_block == "IF"
            println("IF identified ")
            instruction_Fetch(processor.cores[1],processor.memory)
            row += 1
        end
    
        focus_block = array_2d[row, processor.clock]
        # 7
        println(focus_block, " at (", row, ", ", processor.clock, ")")

        println("-----------------------------------------")
        
        if focus_block == "-1" || focus_block == "stall"
            continue
        end
    end
end


# function run(processor::Processor)
#     while processor.cores[1].pc<=length(processor.cores[1].program)
#         processor.clock+=1
#         instruction_Fetch(processor.cores[1],processor.memory)
#         processor.clock+=1
#         instructionDecode_RegisterFetch(processor.cores[1])
#         processor.clock+=1
#         execute(processor.cores[1])
#         processor.clock+=1
#         memory_access(processor.cores[1],processor.memory)
#         processor.clock+=1
#         writeBack(processor.cores[1])
#     end
# end

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
    #Stall Condition
    Instruction_to_decode = core.instruction_reg_after_IF
    println(Instruction_to_decode)
    nxt_rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
    nxt_rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
    println("nxt_rs1 = ", nxt_rs1)
    println("nxt_rs2 = ", nxt_rs2)
    println("core.rd = ", core.rd)
    if (nxt_rs1 == core.rd && nxt_rs1 != 0) || (nxt_rs2 == core.rd && nxt_rs2 != 0)
        core.rs2 = parse(Int,Instruction_to_decode[8:12], base=2)
        core.rs1 = parse(Int,Instruction_to_decode[13:17], base=2)
        core.rd = parse(Int,Instruction_to_decode[21:25], base=2)
        return true
    end

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
    return false
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