/**
 * The eLC-3 datapath.
 *
 * @author Wes Hampson, Xavier Rocha
 * Datapath Image : https://www.irif.fr/~carton/Enseignement/Architecture/Cours/Inoutput/datapath.png
 */
module Datapath
(
    input   logic           Clk, Reset,
    input   logic   [15:0]  In,                                                  // Data from RAM
    input   logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC, // Register load signals
    input   logic           GatePC, GateMDR, GateALU, GateMARMUX,                // Bus gates
    input   logic           ADDR1MUX,                                            // Mux select signals
    input   logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX,                      // Mux select signals
    input   logic           SR2MUX, MARMUX,                                      // Mux select signal
    input   logic   [1:0]   ALUK,                                                // ALU function select signal
    input   logic           MIO_EN,                                              // RAM operation signals
    output  logic   [15:0]  Out, PC, R0, R1,                                                // Data to RAM
    output  logic   [15:0]  Address,                                             // Current RAM address
    output  logic           BEN,                                                 // Branch enable signal
    output  logic           IR_5,                                                // Bit 5 of instruction register
	output  logic           IR_11,												 // Bit 11 of instruction register
    output  logic   [3:0]   IR_15_12                                             // Bits 15-12 of instruction register
);

    /* ==== Internal signals ==== */
    logic   [15:0]  Bus;                                // The main data bus between CPU components
    logic   [3:0]   Gate;                               // Concatenation of Gate* signals
    logic   [15:0]  MAR, MDR, IR/*, PC*/;                   // The current contents of MAR, MDR, IR, and PC
    logic   [2:0]   SR1MUX_Out, DRMUX_Out;              // Outputs of general purpose register selection MUXes
    logic   [15:0]  SR2MUX_Out;                         // Output of ALU input B data selection MUX
    logic   [15:0]  MARMUX_Out, MDRMUX_Out, PCMUX_Out;  // Outputs of MAR, MDR, and PC register data selection MUXes
    logic   [15:0]  ADDR1MUX_Out, ADDR2MUX_Out;         // Outputs of memory addressing MUXes
    logic   [15:0]  ALU;                                // Output of the ALU
    logic   [15:0]  SR1, SR2;                           // Contents of SR1 and SR2 from register file
    logic           BEN_In;                             // Next state of branch enable register
    logic           N, Z, P;                            // Current contents of condition code registers (CCs)
    logic           N_In, Z_In, P_In;                   // Next states for condition code registers
    
    assign IR_5     = IR[5];
	assign IR_11	= IR[11];
    assign IR_15_12 = IR[15:12];
    assign Out = MDR;                                   // Anything leaving the datapath comes from MDR
    assign Address = MAR;                               // RAM address comes from MAR
    
    /* ==== NZP logic ==== */
    assign N_In = Bus[15];
    assign Z_In = (Bus == 16'h0000) ? 1'b1 : 1'b0;
    assign P_In = ~N_In & ~Z_In;
    
    /* ==== Branch enable logic ==== */
    assign BEN_In = (IR[11] & N) | (IR[10] & Z) | (IR[9] & P);
	
    /* ==== Register definitions ==== */
    // Memory address register
    Register        _MAR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .Out(MAR),
        .Load(LD_MAR)
    );
    
    // Memory data register
    Register        _MDR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(MDRMUX_Out),
        .Out(MDR),
        .Load(LD_MDR)
    );
    
    // Instruction register
    Register        _IR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .Out(IR),
        .Load(LD_IR)
    );
    
    // Program counter (instruction pointer)
    Register        _PC
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(PCMUX_Out),
        .Out(PC),
        .Load(LD_PC)
    );
    
    // Branch enable status register
    Register #(1)   _BEN
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(BEN_In),
        .Out(BEN),
        .Load(LD_BEN)
    );
    
    // Negative result status register
    Register #(1)   _N
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(N_In),
        .Out(N),
        .Load(LD_CC)
    );
    
    // Zero result status register
    Register #(1)   _Z
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Z_In),
        .Out(Z),
        .Load(LD_CC)
    );
    
    // Positive result status register
    Register #(1)   _P
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(P_In),
        .Out(P),
        .Load(LD_CC)
    );
    
    // General purpose registers (R0-R7)
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
        .SR2_Out(SR2),
        .R0(R0),            // DEBUG
        .R1(R1)             // DEBUG
    );
    
    /* ==== The arithmetic and logic unit ==== */
    ALU             _ALU
    (
        .A(SR1),
        .B(SR2MUX_Out),
        .Fn(ALUK),
        .Out(ALU)
    );

    /* ==== Multiplexer definitions ==== */
    // MUX for choosing where destination register selection should be read from
    Mux_4to1 #(3)   _DRMUX
    (
        .In0(IR[11:9]),
        .In1(3'b111),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(DRMUX_Out),
        .Select(DRMUX)
    );
    
    // MUX for choosing where source register 1 selection bits should be read from
    Mux_4to1 #(3)   _SR1MUX
    (
        .In0(IR[11:9]),
        .In1(IR[8:6]),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(SR1MUX_Out),
        .Select(SR1MUX)
    );
    
    // MUX for selecting where input B of the ALU should be read from
    Mux_2to1        _SR2MUX
    (
        .In0(SR2),
        .In1({ {11{IR[4]}}, IR[4:0] }), // SEXT(IR[4:0])
        .Out(SR2MUX_Out),
        .Select(SR2MUX)
    );
    
    // MUX for selecting where the next value of PC is read from
    Mux_4to1        _PCMUX
    (
        .In0(PC + 16'd1),
        .In1(Bus),
        .In2(ADDR1MUX_Out + ADDR2MUX_Out),
        .In3(16'hZZZZ), // Unused
        .Out(PCMUX_Out),
        .Select(PCMUX)
    );
    
    // MUX for selecting where to read base memory address from
    Mux_2to1        _ADDR1MUX
    (
        .In0(PC),
        .In1(SR1),
        .Out(ADDR1MUX_Out),
        .Select(ADDR1MUX)
    );
    
    // MUX for selection where to read address offset from
    Mux_4to1        _ADDR2MUX
    (
        .In0(16'h0000),
        .In1({ {10{IR[ 5]}}, IR[ 5:0] }),   // SEXT(IR[ 5:0])
        .In2({ { 7{IR[ 8]}}, IR[ 8:0] }),   // SEXT(IR[ 8:0])
        .In3({ { 5{IR[10]}}, IR[10:0] }),   // SEXT(IR[10:0])
        .Out(ADDR2MUX_Out),
        .Select(ADDR2MUX)
    );
    
    // MUX for selecting where to read the next value for MAR from
    Mux_2to1        _MARMUX
    (
        .In0({ {8{1'b0}}, IR[7:0] }),       // ZEXT(IR[7:0])
        .In1(ADDR1MUX_Out + ADDR2MUX_Out),
        .Out(MARMUX_Out),
        .Select(MARMUX)
    );
    
    // MUX for selecting where to read the next value for MDR from
    Mux_2to1        _MDRMUX
    (
        .In0(Bus),
        .In1(In),
        .Out(MDRMUX_Out),
        .Select(MIO_EN)
    );
    
    // One-hot MUX for selecting which data line is currently allowed on the bus
    // (works like a tri-state buffer)
    MuxOneHot_4to1  _GateMux
    (
        // Input order must follow 'Gate' definition (little-endian, see above)
        .In0(MARMUX_Out),
        .In1(ALU),
        .In2(MDR),
        .In3(PC),
        .Out(Bus),
        .Select({ GatePC, GateMDR, GateALU, GateMARMUX })
    );

endmodule
