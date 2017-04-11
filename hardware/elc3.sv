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
    output  logic   [17:0]  LEDR
);

    // TODO: create the eLC-3!
    logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC; // Register load signals
    logic           GatePC, GateMDR, GateALU, GateMARMUX;                // Bus gates
    logic           ADDR1MUX;                                            // Mux select signals
    logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX, SR2MUX, MARMUX;      // Mux select signals
    logic   [1:0]   ALUK;                                                // ALU function select signal
    logic           MIO_EN, R_W;                                         // RAM operation signals
    logic           BEN;
    logic           IR_5;
    logic   [3:0]   IR_15_11;
    logic   [15:0]  In, Out;

    Datapath dp(.Clk(CLOCK_50), .Reset(~KEY[0]), .*);

endmodule
