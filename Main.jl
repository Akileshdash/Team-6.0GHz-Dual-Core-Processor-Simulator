#=  About the Project

*** This is a simulator of a dual core processor for ISA of RISC-V developed as a part of Computer Organization Course in sem 4 ***

1.This is the main file which needs to be run by command : " julia main.jl "
2.To simulate other asm files in this simulator, change the file paths below by adding your asm file within the folder " Assembly_Codes "
3.file_path_1 is processed by core 1 and file_path_2 is processed by core 1
4.The simulator has the same functonality as Ripes. Reasons : 
    i] The Address starts from 0 and goes till 4095.
   ii] Each memory unit holds maximum of 1 byte i.e. 8bits 
  iii] The Instructions in the files are first encoded into 32 bit binary string and placed in the memory from the first address bit 
   iv] While Encoding, the instructions of core 1 are encoded first and placed in memory.
       Then the instructions of core 2 are encoded and placed the memory after that of core 1.
    v] Now while executing the processor we use the function "run(processor)" ,where in place of processor we have to pass the object of processor
   vi] It will execute parallely . i.e. for each cycle of processor , both the cores will execute one instruction each.
5.Helper Functions : 
    i] To display the memory of the processor use the function (the function displays 4 memory units in a row at a time in hexadecimal value) 
                *Note : It displays the memory in reverse manner. i.e. address 0 at bottom at address 4095 at top 
                        = >         Display_Memory(processor,starting_row,ending_row)                 
                            where : processor = object of processor created
                                    starting_row  = Lower address
                                    ending_row = Upper address
                        = > Example ( paste the following code in quotes[".."] below after run command ) : "Display_Memory(sim,513,530)"    #For Displaying Data Segment of Core 1

6.Memory Partitions Decisions : 
    i] The Data segment for both cores are fixed , i.e 1024 bytes for each core's data segment. One core cannot access the data segment of other core .
        But the Text segment, where instructions are stored is not fixed. 
        The memory addresses from 0 to 2048 are shared memory address between both cores for storing instructions
   ii] Data Segment : 
        For Core 1 , data segment starts from address 2048 to 3071           (starting_row = 513)        =======>      Display_Memory(sim,513,535)
        For Core 2 , data segment starts from address 3072 to 4096           (starting_row = 769)        =======>      Display_Memory(sim,769,790)
  iii] Text Segment ( Instructions ):
        For Core 1 ,  Instructions are stored from address 0                 (starting_row = 1)            =======>      Display_Memory(sim,1,20)
        For Core 2 ,  Instructions are stored after instructions of core 1    (starting_row = next row after the last instruction of core 1)        =======>      Display_Memory(sim,1,20)
=#

include("parser.jl")
# include("Decoding_Instructions.jl")
include("Encoding_Instructions.jl")
include("Stages.jl")

file_path_1 = "./Assembly_Codes/Bubble_Sort.asm"
file_path_2 = "./Assembly_Codes/Selection_Sort.asm"

#Initialize a processor object ( Check "Processor_Core_Init.jl" File)
sim = processor_Init()  

#After Creation of Processor, we are encoding the asm instructions in both files into the memory of processor
#Check the file "Encoding_Instructions.jl" for this function
encoding_all_instructions_to_memory(sim)

println("Encoding Done")

#Now we are running the processor ( Check the file "Processor_Core_Init.jl" to run the processor parallely or sequentially)
run(sim)



#Display a block of the memory of processor (syntax explained at the top of this file)
#Check the file "Helper_Functions" for this function
# println("\nData Segment of Core 2 : \n")
# Display_Memory(sim,769,790)
# println("\nData Segment of Core 1 : \n")
# Display_Memory(sim,513,535)
# println("\nCode Segment : \n")
# Display_Memory(sim,1,20)

println(sim.cores[1].registers)
println(sim.clock)
#Printing the total number of clocks the processor has taken to execute both the cores instructions 
# println("\nNumber of clocks taken for comuting both instructions ( parallely ) = ",sim.clock)

