#Every file is included in sim.jl
#So it is enough to just include sim.jl

include("sim.jl")
include("parser.jl")

file_path = "./Bubble_Sort.asm"
text_instructions,data_instructions = parse_assembly(file_path)

for i in eachindex(text_instructions)
    mutable_str = String(text_instructions[i])
    modified_str = replace_commas_with_spaces(mutable_str)
    final_str = replace_colon_with_space(modified_str)
    push!(sim.cores[1].program, final_str)
    #println(modified_str, "  ", final_str)
end
println(sim.cores[1].program)
show(sim)
run(sim)
show(sim)
for i in 1:2
    println(sim.cores[i].registers)
end


println(data_instructions)
data_instructions_2 = []


for i in eachindex(data_instructions)
    mutable_str = String(data_instructions[i])
    modified_str = replace_commas_with_spaces(mutable_str)
    final_str = replace_colon_with_space(modified_str)
    push!(data_instructions_2, final_str)
    println(mutable_str, "\t", final_str)
end

println(sim.cores[2].id)

println(data_instructions_2)

data_inst_diss = []
label_array = []

for i in eachindex(data_instructions_2)
    if occursin(".word", data_instructions_2[i])
        split_list = split(data_instructions_2[i], ".word")
        for j in eachindex(split_list)
            if split_list[j] == ""
                continue
            end
            if j == 1
                push!(label_array, strip(split_list[j]))
                push!(data_inst_diss, strip(split_list[j]))
                push!(data_inst_diss, ".word")
                continue
            end
            
            new_split_list = split(split_list[j], " ")
            for k in eachindex(new_split_list)
                if new_split_list[k] == ""
                    continue
                end
                push!(data_inst_diss, new_split_list[k])
            end
        end
    end

    if occursin(".string", data_instructions_2[i])
        split_list = split(data_instructions_2[i], ".string")
        for j in eachindex(split_list)
            if split_list[j] == ""
                continue
            end
            if j == 1
                push!(label_array, strip(split_list[j]))
                push!(data_inst_diss, strip(split_list[j]))
                push!(data_inst_diss, ".string")
                continue
            end
            temp_str = String(split_list[j])
            final_str = replace_d_quotes_with_space(temp_str)
            push!(data_inst_diss, strip(final_str))
            
        end
    end
end

println("---")
println(data_inst_diss)
println("------")
println(label_array)

function int_to_binary_string(num::Int)
    return bin(num)[3:end]
end

