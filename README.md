# Implementation-of-a-32-bit-RISC-V-CPU-Core-using-Transaction--Level-Verilog
Building a 32-bit RISC-V CPU Core using TL-verilog.

- Utilized Transaction-Level Verilog to define high-level behavioral models of
the CPU architecture, enhancing understanding of modern circuit design
methodologies.
- Implemented the RISC-V instruction set architecture (RV32I), gaining
proficiency in both the theoretical and practical aspects of CPU
microarchitecture.
- Leveraged the Makerchip online IDE for collaborative development and
testing, showcasing adaptability to emerging technologies in open-source
hardware ecosystems.

## The CPU design encompasses various stages including:

- Logic: Responsible for the program counter (PC) management, ensuring sequential execution of instructions while handling non-sequential branch and jump instructions.
- Fetch: Retrieves instructions from the instruction memory (IMem) based on the program counter value.
- Decode Logic: Interprets instructions by breaking them into fields based on type, facilitating subsequent operations.
- Register File Read: Reads registers from the register file based on the decoded instruction's requirements.
- Arithmetic Logic Unit (ALU): Performs arithmetic and logical operations based on the instruction's operation field.
- Register File Write: Writes the result value from the ALU back to the destination register specified in the instruction.
- DMem: Manages data memory operations, necessary for store and load instructions.
https://github.com/disharnadas/Implementation-of-a-32-bit-RISC-V-CPU-Core-using-Transaction--Level-Verilog/blob/main/images/RISC-V_CPU_Block_Diagram.png



## Processor Design Flow:
1. **Fetch**

   Designing the basic processor of 3 stages fetch, decode and execute based on RISC-V ISA.
   * Program Counter (PC): Holds the address of next Instruction
   * Instruction Memory (IM): Holds the set of instructions to be executed
   fetching instructions from memory based on the program counter value and controlling the instruction memory read operation.
  
2. **Decode**
   During decode, the processor identifies instruction types and formats, enabling appropriate processing.
   There are 6 types of Instructions:

- R-type - Register
- I-type - Immediate
- S-type - Store
- B-type - Branch (Conditional Jump)
- U-type - Upper Immediate
- J-type - Jump (Unconditional Jump)
- Instruction Format includes Opcode, immediate value, source address, destination address. During Decode Stage, processor decodes the instruction based on instruction format and type of instruction.

3. **Register File Read and Write**

    Register file operations involve simultaneous read and write operations, governed by control signals and addresses.
    Here the Register file is 2 read, 1 write means 2 read and 1 write operation can happen simultanously.

Inputs:
- Read_Enable - Enable signal to perform read operation
- Read_Address1 - Address1 from where data has to be read
- Read_Address2 - Address2 from where data has to be read
- Write_Enable - Enable signal to perform write operation
- Write_Address - Address where data has to be written
- Write_Data - Data to be written at Write_Address

Outputs:
- Read_Data1 - Data from Read_Address1
- Read_Data2 - Data from Read_Address2

4. **Execute**

    Execution stage involves the operation of both operands based on the opcode.

5. **Control Logic**
    * Control logic handles branch target address calculation during the decode stage and verifies branch conditions before execution.
    * During Decode Stage, branch target address is calculated and fed into PC mux. Before Execute Stage, once the operands are ready branch condition is checked.

6. **Load and store instructions and memory**

    Load and store instructions involve data memory operations, with added provisions for delay and memory management.
Inputs:

- Read_Enable - Enable signal to perform read operation
- Write_Enable - Enable signal to perform write operation
- Address - Address specified whether to read/write from
- Write_Data - Data to be written on Address (Store Instruction)
Output:

- Read_Data - Data to be read from Address (Load Instruction)

7. **Completing the RISC-V CPU**
    The RISC-V CPU design is completed with the addition of jump instructions, ensuring comprehensive instruction decoding and ALU functionality for all instructions in the RV32I base integer instruction set.
    Below is final Snapshot of the Complete Pipelined RISC-V CPU.
    https://github.com/disharnadas/Implementation-of-a-32-bit-RISC-V-CPU-Core-using-Transaction--Level-Verilog/blob/main/images/Final_CPU.png
    Simulation Passed:
    https://github.com/disharnadas/Implementation-of-a-32-bit-RISC-V-CPU-Core-using-Transaction--Level-Verilog/blob/main/images/SIMULATION_PASSED.png


**Acknowledgement**
    Acknowledgments are extended to [Steve Hoover](https://github.com/stevehoover), Founder, Redwood EDA.



