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
    output  logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4,
    output  logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
    output  logic           SRAM_LB_N, SRAM_UB_N,
    output  logic   [19:0]  SRAM_ADDR,
    inout   wire    [15:0]  SRAM_DQ
);

    // Synchronized master reset signal
    logic           Reset;
    logic           Run;
    logic           Continue;
    
    logic   [3:0]   Opcode;
    
    logic           Halted, Paused, Invalid;
    assign          LEDG[0] = Halted;
    assign          LEDG[1] = Paused;
    assign          LEDR[0] = Invalid;
    
    // eLC-3 control signals
    logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC; // Register load signals
    logic           GatePC, GateMDR, GateALU, GateMARMUX;                // Bus gates
    logic           ADDR1MUX;                                            // Mux select signals
    logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX;                      // Mux select signals
    logic           SR2MUX, MARMUX;                                      // Mux select signal
    logic   [1:0]   ALUK;                                                // ALU function select signal
    logic           MIO_EN, R_W;                                         // RAM operation signals
    logic           BEN;
    logic           IR_5;
	logic			IR_11;
    logic   [3:0]   IR_15_12;
    
    // eLC-3 memory address signal
    logic   [15:0]  Address;
    
    // eLC-3 data signals
    logic   [15:0]  To_CPU, From_CPU;       // Data to/from datapath
    logic   [15:0]  To_HexDisplays;         // "Video" output
    logic   [15:0]  From_Switches;          // "Keyboard" input

    // eLC-3 datapath
    Datapath dp
    (
        .Clk(CLOCK_50),
        .In(To_CPU),
        .Out(From_CPU),
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
        .Data_FromCPU(From_CPU),
        .Data_ToCPU(To_CPU),
        .Data_FromKeyboard(From_Switches),
        .Data_ToVideo(To_HexDisplays),
        .*
    );
    
    // SRAM emulation
    // ===== Comment-out when synthesizing to FPGA!! =====a //
    FakeMemory fakeMem
    (
        .Clk(CLOCK_50),
        .Reset(Reset),
        .CE(SRAM_CE_N),
        .OE(SRAM_OE_N),
        .WE(SRAM_WE_N),
        .LB(SRAM_LB_N),
        .UB(SRAM_UB_N),
        .ADDR(SRAM_ADDR),
        .DQ(SRAM_DQ)
    );

    // 7-segment display converters
    HexDriver hx0(.In(To_HexDisplays[3:0]),   .Out(HEX0));
    HexDriver hx1(.In(To_HexDisplays[7:4]),   .Out(HEX1));
    HexDriver hx2(.In(To_HexDisplays[11:8]),  .Out(HEX2));
    HexDriver hx3(.In(To_HexDisplays[15:12]), .Out(HEX3));

    HexDriver hx4(.In(Opcode), .Out(HEX4));

    // Switch synchronizer
    Synchronizer #(16) syncSW
    (
        .Clk(CLOCK_50),
        .In(SW[15:0]),
        .Out(From_Switches)
    );

    // Reset, Run, and Continue signal synchronizers
    Synchronizer syncReset
    (
        .Clk(CLOCK_50),
        .In(~KEY[0]),
        .Out(Reset)
    );
    Synchronizer syncRun
    (
        .Clk(CLOCK_50),
        .In(~KEY[3]),
        .Out(Run)
    );
    Synchronizer syncContinue
    (
        .Clk(CLOCK_50),
        .In(~KEY[2]),
        .Out(Continue)
    );

endmodule
