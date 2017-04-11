/**
 * The eLC-3 datapath.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Datapath
(
    input   logic           Clk, Reset,
    
    /* eLC-3 datapath control signals */
    input   logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC, // Register load signals
    input   logic           GatePC, GateMDR, GateALU, GateMARMUX,                // Bus gates
    input   logic           ADDR1MUX,                                            // Mux select signals
    input   logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX, MARMUX,              // Mux select signals
    input   logic   [1:0]   ALUK,                                                // ALU function select signal
    input   logic           MIO_EN, R_W                                          // RAM operation signals
);

    /* Internal signals */
    logic   [15:0]  Bus;                                // The main data bus between CPU components
    logic   [15:0]  MAR, MDR, IR, PC;                   // The current contents of MAR, MDR, IR, and PC
    //logic   [15:0]  MAR_In, MDR_In, IR_In, PC_In;       // Input signals for MAR, MDR, IR, and PC
    logic   [2:0]   SR1MUX_Out, SR2MUX_Out, DRMUX_Out;  // Outputs of general purpose register selection MUXes
    logic   [15:0]  MARMUX_Out, MDRMUX_Out, PCMUX_Out;  // Outputs of MAR, MDR, and PC register data selection MUXes
    logic   [15:0]  ADDR1MUX_Out, ADDR2MUX_Out;         // Outputs of memory addressing MUXes
    logic   [15:0]  ADDR;                               // Current memory address
    logic   [15:0]  ALU;                                // Output of the ALU
    logic   [15:0]  SR1, SR2;                           // Contents of SR1 and SR2 from register file
    logic           N, Z, P;                            // Current contents of condition code registers (CCs)
    
    /* ADDR is the sum of base address (ADDR1) and offset (ADDR2) */
    assign ADDR = ADDR1MUX_Out + ADDR2MUX_Out;
    
    /* Memory address register */
    Register        _MAR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .Out(MAR),
        .Load(LD_MAR)
    );
    
    /* Memory data register */
    Register        _MDR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(MDRMUX_Out),
        .Out(MDR),
        .Load(LD_MDR)
    );
    
    /* Instruction register */
    Register        _IR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .Out(IR),
        .Load(LD_IR)
    );
    
    /* Program counter (instruction pointer) */
    Register        _PC
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(PCMUX_Out),
        .Out(PC),
        .Load(LD_PC)
    );
    
    /* Module containing 8 general purpose registers (R0-R7)
       and their selection logic */
    RegisterFile    _GenPurposeRegs
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .LD_REG(LD_REG),
        .DR(DRMUX_Out),
        .SR1(SR1MUX_Out),
        .SR2(IR[2:0]),
        .SR1_Out(SR1),
        .SR2_Out(SR2)
    );
    
    /* MUX for choosing where to read the destination register
       selection bits from */
    Mux_4to1 #(3)   _DRMUX
    (
        .In0(IR[11:9]),
        .In1(3'b111),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(DRMUX_Out),
        .Select(DRMUX)
    );
    
    /* MUX for choosing where to read the source register 1
       selection bits from */
    Mux_4to1 #(3)   _SR1MUX
    (
        .In0(IR[11:9]),
        .In1(IR[8:6]),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(SR1MUX_Out),
        .Select(SR1MUX)
    );
    
    /* MUX for selecting where to read input B of the ALU from */
    Mux_2to1        _SR2MUX
    (
        .In0(SR2),
        .In1({ {11{IR[4]}}, IR[4:0] }), // SEXT(IR[4:0])
        .Out(SR2MUX_Out),
        .Select(IR[5])
    );
    
    /* The ALU */
    ALU             _ALU
    (
        .A(SR1),
        .B(SR2MUX_Out),
        .Fn(ALUK)
    );
    
    /* MUX for selecting where the next value of PC is read from */
    Mux_4to1        _PCMUX
    (
        .In0(PC + 16'd1),
        .In1(Bus),
        .In2(ADDR),
        .In3(16'hZZZZ), // Unused
        .Out(PCMUX_Out),
        .Select(PCMUX)
    );
    
    /* MUX for selecting where to read base address from */
    Mux_2to1        _ADDR1MUX
    (
        .In0(PC),
        .In1(SR1),
        .Out(ADDR1MUX_Out),
        .Select(ADDR1MUX)
    );
    
    /* MUX for selection where to read address offset from */
    Mux_4to1        _ADDR2MUX
    (
        .In0(16'h0000),
        .In1({ {10{IR[ 5]}}, IR[ 5:0] }),   // SEXT(IR[ 5:0])
        .In2({ { 7{IR[ 8]}}, IR[ 8:0] }),   // SEXT(IR[ 8:0])
        .In3({ { 5{IR[10]}}, IR[10:0] }),   // SEXT(IR[10:0])
        .Out(ADDR2MUX_Out),
        .Select(ADDR2MUX)
    );
    
    /* MUX for selecting where to read the next value for MAR from */
    Mux_2to1        _MARMUX
    (
        .In0({ {8{1'b0}}, IR[7:0] }),       // ZEXT(IR[7:0])
        .In1(ADDR),
        .Out(MARMUX_Out),
        .Select(MARMUX)
    );

endmodule
