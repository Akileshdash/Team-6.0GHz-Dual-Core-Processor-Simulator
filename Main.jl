#Every file is included in sim.jl
#So it is enough to just include sim.jl

include("sim.jl")
file_path_1 = "./test_core1.asm"
file_path_2 = "./test_core2.asm"

initial_index=1     
sim = processor_Init()  

text_instructions,data_instructions = parse_assembly(file_path_1)
final_text_inst = text_inst_parser(text_instructions)
data_inst_final, variable_array = data_inst_parser(data_instructions)
sim.cores[1].program = final_text_inst
initial_index=encoding_Instructions(sim.cores[1],sim.memory,initial_index,variable_array)

text_instructions,data_instructions = parse_assembly(file_path_2)
final_text_inst = text_inst_parser(text_instructions)
sim.cores[2].program = final_text_inst

show(sim)
#initial_index=encoding_Instructions(sim.cores[2],sim.memory,initial_index)

println(sim.cores[1].pc)
println(sim.cores[2].pc)
