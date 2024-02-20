#Every file is included in sim.jl
#So it is enough to just include sim.jl

include("sim.jl")
file_path = "./test.asm"
initial_index=1     #For putting in 
text_instructions,data_instructions = parse_assembly(file_path)

println(typeof(text_instructions))

sim = processor_Init()  
#in text instruct , commas,colon and spaces are removed

final_text_inst = text_inst_parser(text_instructions)
println(final_text_inst)

data_inst_final, label_array = data_inst_parser(data_instructions)
println(data_inst_final)
println(label_array)

# encoding_Instructions(sim.cores[1],sim.memory)

initial_index=encoding_Instructions(sim.cores[1],sim.memory,initial_index)
initial_index=encoding_Instructions(sim.cores[2],sim.memory,initial_index)
# println(sim.cores[1].program)
#show(sim)
#run(sim)
show(sim)
println(initial_index)
# for i in 1:2
#     println(sim.cores[i].registers)
# end

