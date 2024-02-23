include("parser.jl")
include("Decoding_Instructions.jl")
include("Encoding_Instructions.jl")

file_path_1 = "./test_core1.asm"
file_path_2 = "./test_core2.asm"

sim = processor_Init()  
encoding_all_instructions_to_memory(sim)

show(sim,769,789)
println(".\n.\n.\n")
show(sim,512,532)

run(sim)
show(sim,769,789)
println(".\n.\n.\n")
show(sim,512,532)
println("Number of clocks = ",sim.clock)

