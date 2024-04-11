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
7. Branch Prediction
    - 2 bit branch prediction implemented
8. Caches
    - Single cache shared among the two Cores of the processor. 
    - Cache size can be varied , depends on the input of the user
    - Cache replacement Policy : 
        - Least Recently Used
        - Hashing
        - Random
    - Hit Time and Miss Rate are also user defined values
9. GUI
    - The front end of GUI is completed but we have to connect it to the backend. We are expecting it to be completed by phase 4.
# Computer Organization Project

## Description
This project is a simulator of a dual-core processor for the ISA of RISC-V. It was developed as a part of the Computer Organization Course.

## Table of Contents
- [File Structure Overview](#file-structure-overview)
- [Minutes of Meeting](#minutes-of-meetings)
<!-- - [Detailed Description](#detailed-description)
- [Instructions for Usage](#instructions-for-usage)
- [Example](#example)
- [Contributing Guidelines](#contributing-guidelines)
- [License](#license)
- [Additional Resources](#additional-resources) -->

---

## File Structure Overview

- `/src`: This directory contains all the source code files for the project.
- `/docs`: Documentation files including user guides, and different  a report about implementation of different aspects of the project.
- `/Assembly_Codes`: Test files for testing used in the project.

/Computer Organization Project <br>
├── /src <br>
> ├── `parser.jl`: This code preprocesses assembly code into an array of strings which could be then processed by the code.<br>
├── `Encoding Instructions.jl`: This file converts assembly instructions into 32-bit encoded instruction, inline with RISC-V standards. <br>
├── `Execute_Operations.jl`: This directory contains all the source code files for the project. <br>
├── `Helper_Functions.jl`: This file contains all the miscellaneous functions used across the entire project. <br>
├── `Main.jl`: This file contains the driver code of the project. <br>
├── `Pipeline_with_DF.jl`: This file contains implementation of Pipline with Data-Forwarding. <br>
├── `Pipeline_without_DF.jl`: This file contains implementation of Pipline without Data-Forwarding. <br>
├── `Processor_Core_Init.jl`: This file contains 4 classes used across the project. Namely: Cache, Instruction, Core, and Processor.

├── /Assembly_Codes <br>
>├── `Bubble_Sort.jl`: This file contains assembly code for Bubble-Sort.<br>
├── `Selection_Sort.jl`: This file contains assembly code for Selection-Sort. <br>

└── README.md # Project README <br>

## Minutes of Meetings

### `Meeting 14: Date: 9 Apr 2024 `
- Decided to add user defined input, for Cache size, Block size, Associativity and Cache Replacement Policy. Pre-existing user inputs are Variable Latency of arithmetic opearations and Data forwarding.
- Successfully created a front-end for our code. Attaching it with the backend remains.

### `Meeting 13: Date: 5 Apr 2024 `
- Based on disucssion with sir on 4 Apr, we decided to not split the cache into data and insturction type. Also, time taken for write back remains unchanged at 1 clock cycle.
- Initially, we decide to further the project without taking user inputs. 
    - Read operation from Cache takes 10 cycles.
    - Read operation from Memory takes 100 cycles.
    


### `Meeting 12: Date: 2 Apr 2024 `
- Discussion about implementation details of the Cache in the existing Simulator.
- Specific focus on separation of Data and Instruction Cache to optimise for performance.
- To ask sir about Write Back policy of the cache.


### `Meeting 11: Date: 8 Mar 2024 `
- Hazard Detection
    - Data Hazard Done
    - Structural Hazard
        - Mem of Load and Store and IF at same clock hazard detection planned to implement
- IPC Calcukation
- Branch Predictor Accuracy
- Variable Latency
    - Planned for Add, Sub and Addi as these were the only arithmetic instructions which we used in the sorting files
### `Meeting 10: Date: 6 Mar 2024 `
- Data Forwarding
    - Data dependency check when interupted by branch and jump statements .
- Branch Prediction
    - Consideration of always branch not taken .
        - even though this would yield lesser branch prediction accuracy this was planned to implement because it was comparatively easier .

### `Meeting 9: Date: 3 Mar 2024 `
- Discussion on Stalls
    - Read after write and write after read hazards detection
    - Stalls due to Branch 
    - Stalls due to jump statements
- Data Forwarding
    - Dependecy check on last and second last instructions
    - stalls till memory stage for load and store statements dependency
### `Meeting 8: Date: 29 Feb 2024 `
- 5 stage cycle separation and Makefile - Preet
    - For IF , we need to create a new special purpose register
- pipelining
    - We need to store a new temporary register
        - It is a special purpose register which we need to store in the each of the core itself.
    - For each function we need to find the cycles/stages omitted - LavKush
    - Stalls
        - Predictions   -   Static or Dynamic Prediction : 1 or 2 bit predictor 
            - break statements
            - jump statements
        - Hazards
            - write after read 
            - read after write
            - write after write
        - For each function we need to find the cycles/stages omitted - LavKush
- Data forwading and IPC and Hazards(conceptual) - Akilesh


### `Meeting 7: Date: 23 Feb 2024`
- Restructured code for improved readability.
- Successfully executed **Selection-Sort** and **Bubble-Sort** on our simulator.
- Planned implementation of GUI the following day.
- Planned to test the robustness of the simulator the next day.

### `Meeting 6: Date: 22 Feb 2024`
- Successfully implemented parsing of **.data** and storing it in memory.
- Completed encoding and decoding of all instructions.
- Minor bug fixes.

### `Meeting 5: Date: 21 Feb 2024`
- Implemented **Selection-Sort** in Assembly Language.

### `Meeting 4: Date: 20 Feb 2024`
- Implemented **.data** parsing for **.word** and **.string**.
- Added necessary helper functions.
- Implemented transcoding algorithm to store strings.
- Started implementation of encoded instructions into memory.

### `Meeting 3: Date: 19 Feb 2024`
- Implemented LW using Big-Endian Format and LB.
- Implemented JAL and JALR.
- Added Integer to Binary String functions.

### `Meeting 2: Date: 18 Feb 2024`
- Resolved the issue raised earlier.
- Implemented parser.jl (Analyzing data_instruction and text_instructions).
- Successfully implemented **Bubble-Sort** in Assembly Language.
- Added instructions addi and sub.

### `Meeting 1: Date: 14 Feb 2024`
#### _Skipping Prom Night for this dual-core processor_
- **Members present:** Akilesh, Lavkush Kumar, and Preet Madhav Bobde.
- **Decisions:** 
  - The project is decided to be implemented in Julia language.
  - Reason: Julia is as fast as compiled C and as easy as Python to write.

