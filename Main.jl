include("parser.jl")
include("Encoding_Instructions.jl")
include("pipeline_without_DF.jl")
include("pipeline_with_DF.jl")

file_path_1 = "./Assembly_Codes/Bubble_Sort.s"
file_path_2 = "./Assembly_Codes/Selection_Sort.s"

#Initialize a processor object (Check "Processor_Core_Init.jl" File)
sim = processor_Init()  

#After Creation of Processor, we are encoding the asm instructions in both files into the memory of processor Check the file "Encoding_Instructions.jl" for this function
encoding_all_instructions_to_memory(sim)
println("encoding done")
println("Cache Replacement Policy\nLRU\t\tpress 1\nHashing\t\tpress 2\nRandom\t\tpress 3")
i = parse(Int,readline()) 
if i==1
  sim.cache.LRU_selected = true
elseif i==2 
  sim.cache.Hashing_selected = true
else
  sim.cache.Random_selected = true
end
print("What is the miss penalty : ")
sim.cache.miss_penalty = parse(Int,readline())
print("What is the hit time : ")
sim.cache.hit_time = parse(Int,readline())
# print("Add variable latency : ")
# sim.cores[1].add_variable_latency = parse(Int,readline())
println("with DF\t\tpress 1")
println("without DF\tpress 2")
if parse(Int,readline())==1
  run_with_df(sim)
else
  run_without_df(sim)
end

#Display a block of the memory of processor Check the file "Helper_Functions" for this function
# println("\nData Segment of Core 2 : \n")
# Display_Memory(sim,769,790)
# println("\nData Segment of Core 1 : \n")
# Display_Memory(sim,513,535)

println("cache access = ",sim.accesses)
println("Hits = ",sim.hits)
println("Hit Rate = ",(sim.hits/sim.accesses)*100)
println("Miss rate = ",(1-sim.hits/sim.accesses)*100)


println("Core 1 registers : ", sim.cores[1].registers)
# println("Instructions : ",sim.cores[1].instruction_count)
# println("core 1 clocks : ",sim.cores[1].clock)
# println("core 2 clocks : ",sim.cores[2].clock)
# println("Number of stalls : ",sim.cores[1].stall_count)
# println("IPC : ",sim.cores[1].instruction_count/sim.cores[1].clock)
# println("Branch prediction Accuracy: ",(sim.cores[1].branch_correct_predict_count/sim.cores[1].branch_count)*100)
# println("Core 2 registers : ",sim.cores[2].registers)
# println("---------------------------------------------------------------------------------------------------------------------------------------------------------")
# println("|\tTotal Number of clocks = ",sim.clock,"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t|")
# println("---------------------------------------------------------------------------------------------------------------------------------------------------------")
# println("|\tCore No.\tinstructions executed\t\tClock Count\t\tstalls\t\tPrediction Accuracy\t\tIPC\t\t\t|")
# println("|\t1\t\t\t",sim.cores[1].instruction_count,"\t\t\t",sim.cores[1].clock,"\t\t\t",sim.cores[1].stall_count,"\t\t",sim.cores[1].branch_taken_count/sim.cores[1].branch_count,"\t\t",sim.cores[1].instruction_count/sim.clock,"\t|")
# println("|\t2\t\t\t",sim.cores[2].instruction_count,"\t\t\t",sim.cores[2].clock,"\t\t\t",sim.cores[2].stall_count,"\t\t",sim.cores[2].branch_taken_count/sim.cores[2].branch_count,"\t\t",sim.cores[2].instruction_count/sim.clock,"\t|")
# println("---------------------------------------------------------------------------------------------------------------------------------------------------------")


