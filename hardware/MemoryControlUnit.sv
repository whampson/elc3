/**
 * Control unit for the eLC-3 memory.
 * Handles memory-mapped I/O and conversion from eLC-3
 * memory control signals to SRAM chip control signals.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module MemoryControlUnit
(
    input   logic           Clk,
    input   logic           MIO_EN,
    input   logic           R_W,
    input   logic   [15:0]  Address,
    input   logic   [15:0]  Data_FromCPU,
    input   logic   [15:0]  Data_FromSRAM,
    input   logic   [15:0]  Data_FromKeyboard,
    output  logic   [15:0]  Data_ToCPU,
    output  logic   [15:0]  Data_ToSRAM,
    output  logic   [15:0]  Data_ToVideo,
    output  logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
    output  logic           SRAM_LB_N, SRAM_UB_N,
    output  logic   [19:0]  SRAM_ADDR,
    inout   wire    [15:0]  SRAM_DQ
);

    // Synchronized SRAM control signals (these are active-high)
    logic           Mem_OE;
    logic           Mem_CE;
    logic           Mem_WE;
    logic           Mem_LB;
    logic           Mem_UB;
    
    // Memory addressing and control
    assign          SRAM_ADDR = {4'b0000, Address };    // SRAM is 1M x 16, eLC-3 memory is only 64K x 16
    assign          Mem_CE = MIO_EN;                    // SRAM chip enable
    assign          Mem_OE = R_W;                       // Output enable (read)
    assign          Mem_WE = ~R_W;                      // Write enable
    assign          Mem_LB = 1'b1;
    assign          Mem_UB = 1'b1;
    
    // TODO: memory-mapped I/O for KBDR, KBSR, DDR, and DSR
    
    // Tri-state buffer for data lines between eLC-3 memory control logic and SRAM chip
    BidirectionalTriState memTristate
    (
        .In(Data_ToSRAM),                               // Data going into tri-state to memory
        .Out(Data_FromSRAM),                            // Data coming out of tri-state from memory
        .Data(SRAM_DQ),                                 // Bus travelling between tri-state and SRAM chip
        .WriteEnable(Mem_WE)                            // Read or write to SRAM
    );
    
    // SRAM control signal synchronizers
    // Converts active-high synchronized signals to active-low async SRAM signals
    Synchronizer syncCE(.Clk(Clk), .In(~Mem_CE), .Out(SRAM_CE_N));
    Synchronizer syncOE(.Clk(Clk), .In(~Mem_OE), .Out(SRAM_OE_N));
    Synchronizer syncWE(.Clk(Clk), .In(~Mem_WE), .Out(SRAM_WE_N));
    Synchronizer syncLB(.Clk(Clk), .In(~Mem_LB), .Out(SRAM_LB_N));
    Synchronizer syncUB(.Clk(Clk), .In(~Mem_UB), .Out(SRAM_UB_N));

endmodule
