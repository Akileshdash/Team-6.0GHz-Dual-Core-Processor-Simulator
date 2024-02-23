#Every file is included in sim.jl
#So it is enough to just include sim.jl

include("sim.jl")
include("allocating_data_seg_in_mem.jl")
include("Helper_Functions.jl")

file_path_1 = "./test_core1.asm"
file_path_2 = "./test_core2.asm"

initial_index=1     
sim = processor_Init()  

text_instructions,data_instructions = parse_assembly(file_path_1)
final_text_inst = text_inst_parser(text_instructions)
data_inst_final, variable_array = data_inst_parser(data_instructions)

label_array = Vector{Tuple{String, Int}}()
for str in final_text_inst
    if !(in(split(str,' ')[1], operator_array))
        label = split(str,' ')[1]
        index = find_and_remove(label, final_text_inst)
        push!(label_array, (label, index))
    end
end

sim.cores[1].program = final_text_inst

# text_instructions,data_instructions = parse_assembly(file_path_2)
# final_text_inst = text_inst_parser(text_instructions)
# data_inst_final, variable_array = data_inst_parser(data_instructions)
# sim.cores[2].program = final_text_inst
# initial_index = encoding_Instructions(sim.cores[2],sim.memory,initial_index,variable_array)

#println(sim.cores[2].pc)
variable_address_array = alloc_dataSeg_in_memory(sim.memory, data_inst_final, sim.cores[1], variable_array)
variable_address_array .-=1
# println(variable_array)
# println(variable_address_array)

initial_index = encoding_Instructions(sim.cores[1],sim.memory,initial_index,variable_array,label_array,variable_address_array)

# println("----------------------------")

run(sim)
println(sim.cores[1].registers)
show(sim,512,532)

