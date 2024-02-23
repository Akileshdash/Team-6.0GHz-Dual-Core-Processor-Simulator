include("sim.jl")
include("allocating_data_seg_in_mem.jl")
include("Helper_Functions.jl")

file_path_1 = "./test_core1.asm"
file_path_2 = "./test_core2.asm"

initial_index=1     
sim = processor_Init()  

#core 1
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
variable_address_array = alloc_dataSeg_in_memory(sim.memory, data_inst_final, sim.cores[1], variable_array)
variable_address_array .-=1
initial_index = encoding_Instructions(sim.cores[1],sim.memory,initial_index,variable_array,label_array,variable_address_array)

#core 2
text_instructions,data_instructions = parse_assembly(file_path_2)
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

sim.cores[2].program = final_text_inst
variable_address_array = alloc_dataSeg_in_memory(sim.memory, data_inst_final, sim.cores[2], variable_array)
variable_address_array .-=1
initial_index = encoding_Instructions(sim.cores[2],sim.memory,initial_index,variable_array,label_array,variable_address_array)

show(sim,769,789)
println(".\n.\n.\n")
show(sim,512,532)

show(sim,1,40)

# run(sim)

# show(sim,512,532)
# show(sim,767,787)

# println("core 1 registers : ",sim.cores[1].registers)
# println("core 2 registers : ",sim.cores[2].registers)

println(sim.cores[1].pc)
println(sim.cores[2].pc)