#Every file is included in sim.jl
#So it is enough to just include sim.jl

include("sim.jl")

file_path = "./test.asm"
text_instructions,data_instructions = parse_assembly(file_path)

for i in eachindex(text_instructions)
    mutable_str = String(text_instructions[i])
    modified_str = replace_commas_with_spaces(mutable_str)
    final_str = replace_colon_with_space(modified_str)
    push!(sim.cores[1].program, final_str)
    println(modified_str, "  ", final_str)
end

# println(text_instructions)
println(data_instructions)
println(sim.cores[1].program)