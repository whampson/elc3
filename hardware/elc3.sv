/**
 * The eLC-3 toplevel.
 * All main parts of the eLC-3 link togetehr here.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module elc3
(
    // DE2-115 inputs and outputs
    input                   CLOCK_50,
    input           [3:0]   KEY,
    input           [17:0]  SW,
    output  logic   [8:0]   LEDG,
    output  logic   [17:0]  LEDR,
    output  logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output  logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
    output  logic           SRAM_LB_N, SRAM_UB_N,
    output  logic   [19:0]  SRAM_ADDR,
    inout   wire    [15:0]  SRAM_DQ
);

    // Synchronized reset, run, and continue signals
    logic           Reset;
    logic           Run;
    logic           Continue;
    
    logic   [3:0]   Opcode;
    
    logic           Halted, Paused, Invalid;
    assign          LEDG[0] = Halted;
    assign          LEDG[1] = Paused;
    assign          LEDR[17] = Invalid;
    
    // eLC-3 control signals
    logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC; // Register load signals
    logic           GatePC, GateMDR, GateMUL, GateALU, GateMARMUX;       // Bus gates
    logic           ADDR1MUX;                                            // Mux select signals
    logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX;                      // Mux select signals
    logic           SR2MUX, MARMUX;                                      // Mux select signal
    logic   [1:0]   ALUK;                                                // ALU function select signal
    logic           MIO_EN, R_W;                                         // RAM operation signals
    logic           MUL_EN;
    logic           MUL_R;
    logic           BEN;
    logic           IR_5;
	logic			IR_11;
    logic   [3:0]   IR_15_12;
    
    logic   [15:0]  PC, R0, R1;
    
    // eLC-3 memory signals
    logic   [15:0]  Address;
    logic           Mem_CE, Mem_OE, Mem_WE;
    logic           Mem_LB, Mem_UB;
    assign          SRAM_ADDR = { 4'b0000, Address };
    
    // eLC-3 data signals
    logic   [15:0]  Data_FromCPU, Data_ToCPU;           // Data to/from datapath
    logic   [15:0]  Data_FromSRAM, Data_ToSRAM;         // Data to/from SRAM chip
    logic   [15:0]  Data_FromKeyboard, Data_ToVideo;    // I/O
    logic   [15:0]  Data_ToHexDisplays0, Data_ToHexDisplays1;
    logic   [15:0]  Data_FromSwitches;                  // "Keyboard" input
    assign          Data_FromSwitches = SW[15:0];
    assign          Data_FromKeyboard = Data_FromSwitches;
    //assign          Data_ToHexDisplays = Data_ToVideo;
    assign          Data_ToHexDisplays0 = PC;
    assign          Data_ToHexDisplays1 = Data_ToVideo;
    //assign          LEDR[15:0] = Data_ToVideo;
    assign          LEDG[7:4] = Opcode;
    
//    assign          Data_FromCPU = 16'hCAFE;
//    assign          Address = Data_FromSwitches;

//    // eLC-3 datapath
    Datapath dp
    (
        .Clk(CLOCK_50),
        .In(Data_ToCPU),
        .Out(Data_FromCPU),
        .*
    );
    
    // eLC-3 control unit
    ControlUnit ctl
    (
        .Clk(CLOCK_50),
        .*
    );

    // eLC-3 memory addressing unit, contains KBDR, KBSR, DDR, and DSR
    MemoryControlUnit memCtl
    (
        .Clk(CLOCK_50),
        .*
    );
    
    BidirectionalTriState memTristate
    (
        .Clk(CLOCK_50),
        .WriteEnable(~SRAM_WE_N),
        .In(Data_ToSRAM),
        .Out(Data_FromSRAM),
        .Data(SRAM_DQ)
    );
    
    // SRAM emulation
    // ===== Comment-out when synthesizing to FPGA!! =====a //
//    FakeMemory fakeMem
//    (
//        .Clk(CLOCK_50),
//        .Reset(Reset),
//        .CE(SRAM_CE_N),
//        .OE(SRAM_OE_N),
//        .WE(SRAM_WE_N),
//        .LB(SRAM_LB_N),
//        .UB(SRAM_UB_N),
//        .ADDR(SRAM_ADDR),
//        .DQ(SRAM_DQ)
//    );

    // 7-segment display converters
    HexDriver hx0(.In(Data_ToHexDisplays1[3:0]), .Out(HEX0));
    HexDriver hx1(.In(Data_ToHexDisplays1[7:4]), .Out(HEX1));
    HexDriver hx2(.In(Data_ToHexDisplays1[11:8]), .Out(HEX2));
    HexDriver hx3(.In(Data_ToHexDisplays1[15:12]), .Out(HEX3));
    HexDriver hx4(.In(Data_ToHexDisplays0[3:0]), .Out(HEX4));
    HexDriver hx5(.In(Data_ToHexDisplays0[7:4]), .Out(HEX5));
    HexDriver hx6(.In(Data_ToHexDisplays0[11:8]), .Out(HEX6));
    HexDriver hx7(.In(Data_ToHexDisplays0[15:12]), .Out(HEX7));

    // Reset, Run, and Continue signal synchronizers
    Synchronizer syncReset(.Clk(CLOCK_50), .In(~KEY[0]), .Out(Reset));
    Synchronizer syncRun(.Clk(CLOCK_50), .In(~KEY[3]), .Out(Run));
    Synchronizer syncContinue(.Clk(CLOCK_50), .In(~KEY[2]), .Out(Continue));
    
    // Memory control signal synchronizers
    Synchronizer syncCE(.Clk(CLOCK_50), .In(~Mem_CE), .Out(SRAM_CE_N));
    Synchronizer syncOE(.Clk(CLOCK_50), .In(~Mem_OE), .Out(SRAM_OE_N));
    Synchronizer syncWE(.Clk(CLOCK_50), .In(~Mem_WE), .Out(SRAM_WE_N));
    Synchronizer syncLB(.Clk(CLOCK_50), .In(~Mem_LB), .Out(SRAM_LB_N));
    Synchronizer syncUB(.Clk(CLOCK_50), .In(~Mem_UB), .Out(SRAM_UB_N));

endmodule
