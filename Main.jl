include("parser.jl")
include("Encoding_Instructions.jl")
include("Pipeline_without_DF.jl")
include("Pipeline_with_DF.jl")

file_path_2 = "./Assembly_Codes/Selection_Sort.s"
file_path_1 = "./Assembly_Codes/Bubble_Sort.s"

#Initialize a processor object ( Check "Processor_Core_Init.jl" File)
sim = processor_Init()  

#After Creation of Processor, we are encoding the asm instructions in both files into the memory of processor Check the file "Encoding_Instructions.jl" for this function
encoding_all_instructions_to_memory(sim)
println("encoding done")

print("How much latency in ADD : ")
i = readline()
for j in 1:2
    sim.cores[j].add_variable_latency = parse(Int,i)
end
print("How much latency in SUB : ")
i = readline()
for j in 1:2
    sim.cores[j].sub_variable_latency = parse(Int,i)
end
print("How much latency in ADDI : ")
i = readline()
for j in 1:2
    sim.cores[j].addi_variable_latency = parse(Int,i)
end

#Now we are running the processor ( Check the file "Stages.jl" to run the processor parallely or sequentially)
println("To run the simulator with:\nData Forwarding \tpress 1\nWithout Data Forwarding\tpress 2")
i = readline()
if i=="1"
    run_with_DF(sim)
else
    run_without_DF(sim)
end


#Display a block of the memory of processor (syntax explained at the top of this file) Check the file "Helper_Functions" for this function

# println("\nData Segment of Core 2 : \n")
# Display_Memory(sim,769,790)
# println("\nData Segment of Core 1 : \n")
# Display_Memory(sim,513,535)

println(sim.cores[1].registers)
println("---------------------------------------------------------------------------------------------------------------------------------------------------------")
println("|\tTotal Number of clocks = ",sim.clock,"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t|")
println("---------------------------------------------------------------------------------------------------------------------------------------------------------")
println("|\tCore No.\tinstructions executed\t\tClock Count\t\tstalls\t\tPrediction Accuracy\t\tIPC\t\t\t|")
println("|\t1\t\t\t",sim.cores[1].instruction_count,"\t\t\t",sim.cores[1].clock,"\t\t\t",sim.cores[1].stall_count,"\t\t",sim.cores[1].branch_taken_count/sim.cores[1].branch_count,"\t\t",sim.cores[1].instruction_count/sim.clock,"\t|")
println("|\t2\t\t\t",sim.cores[2].instruction_count,"\t\t\t",sim.cores[2].clock,"\t\t\t",sim.cores[2].stall_count,"\t\t",sim.cores[2].branch_taken_count/sim.cores[2].branch_count,"\t\t",sim.cores[2].instruction_count/sim.clock,"\t|")
println("---------------------------------------------------------------------------------------------------------------------------------------------------------")


