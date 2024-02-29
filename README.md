# Team 6.0GHz Dual Core Processor Simulator
## Computer Organization Project

This project is a simulator of a dual-core processor for the ISA of RISC-V. It was developed as a part of the Computer Organization Course.

## Usage

1. Run the main file using the command: 
``` bash
julia main.jl 
```
2. To simulate other assembly files, place your ASM file within the folder named "Assembly_Codes" and update the file paths in the main file accordingly.
3. `file_path_1` is processed by core 1, and `file_path_2` is processed by core 2.
4. The simulator aims to mimic the functionality of Ripes. Reasons:
    - The address starts from 0 and goes till 4095.
    - Each memory unit holds a maximum of 1 byte (8 bits).
    - Instructions in the files are first encoded into 32-bit binary strings and placed in memory from the first address bit.
    - Instructions of core 1 are encoded and placed in memory before those of core 2.
    - Execution occurs in parallel; each processor cycle executes one instruction from both cores.
5. Helper Functions:
    - To display memory, use the function:
      ``` julia
      Display_Memory(processor, starting_row, ending_row)
      ```
      - `processor`: object of the processor created
      - `starting_row`: Lower address
      - `ending_row`: Upper address
    - Example: 
        ```julia
        Display_Memory(sim, 513, 530) 
        #displays data segment for Core1
        ```
6. Memory Partition Decisions:
    - The data segment for both cores is fixed: 1024 bytes for each core's data segment.
    - Data Segment:
      - For Core 1, data segment starts from address 2048 to 3071 (starting_row = 513).
      - For Core 2, data segment starts from address 3072 to 4095 (starting_row = 769).
    - Text Segment (Instructions):
      - For Core 1, instructions are stored from address 0 (starting_row = 1).
      - For Core 2, instructions are stored after the instructions of Core 1 (starting_row = next row after the last instruction of Core 1).

## Minutes of Meetings
### Meeting 8: Date: 29 Feb 2024
1. 5 stage cycle separation and Makefile - Preet
    a. For IF , we need to create a new special purpose register
2. pipelining
    i. We need to store a new temporary register
        a. It is a special purpose register which we need to store in the each of the core itself.
   ii.For each function we need to find the cycles/stages omitted - LavKush 
  iii.Stalls
    a.Predictions   -   Static or Dynamic Prediction : 1 or 2 bit predictor 
        1.break statements
        2.jump statements
    b.Hazards
        1.write after read 
        2.read after write
        3.write after write
    i.For each function we need to find the cycles/stages omitted - LavKush
3. Data forwading and IPC and Hazards(conceptual) - Akilesh


### Meeting 7: Date: 23 Feb 2024
- Restructured code for improved readability.
- Successfully executed **Selection-Sort** and **Bubble-Sort** on our simulator.
- Planned implementation of GUI the following day.
- Planned to test the robustness of the simulator the next day.

### Meeting 6: Date: 22 Feb 2024
- Successfully implemented parsing of **.data** and storing it in memory.
- Completed encoding and decoding of all instructions.
- Minor bug fixes.

### Meeting 5: Date: 21 Feb 2024
- Implemented **Selection-Sort** in Assembly Language.

### Meeting 4: Date: 20 Feb 2024
- Implemented **.data** parsing for **.word** and **.string**.
- Added necessary helper functions.
- Implemented transcoding algorithm to store strings.
- Started implementation of encoded instructions into memory.

### Meeting 3: Date: 19 Feb 2024
- Implemented LW using Big-Endian Format and LB.
- Implemented JAL and JALR.
- Added Integer to Binary String functions.

### Meeting 2: Date: 18 Feb 2024
- Resolved the issue raised earlier.
- Implemented parser.jl (Analyzing data_instruction and text_instructions).
- Successfully implemented **Bubble-Sort** in Assembly Language.
- Added instructions addi and sub.

### Meeting 1: Date: 14 Feb 2024
#### _Skipping Prom Night for this dual-core processor_
- **Members present:** Akilesh, Lavkush Kumar, and Preet Madhav Bobde.
- **Decisions:** 
  - The project is decided to be implemented in Julia language.
  - Reason: Julia is as fast as compiled C and as easy as Python to write.

