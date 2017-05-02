/**
 * eLC-3 (toplevel) testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_elc3();

    timeunit 10ns;
    timeprecision 1ns;

    logic           CLOCK_50;
    logic           PS2_KBCLK;
    logic           PS2_KBDAT;
    logic   [3:0]   KEY;
    logic   [17:0]  SW;
    logic   [8:0]   LEDG;
    logic   [17:0]  LEDR;
    logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N;
    logic           SRAM_LB_N, SRAM_UB_N;
    logic   [19:0]  SRAM_ADDR;
    wire    [15:0]  SRAM_DQ;
    logic           VGA_CLK;
    logic           VGA_SYNC_N, VGA_BLANK_N;
    logic           VGA_VS, VGA_HS;
    logic   [7:0]   VGA_R, VGA_G, VGA_B;
    
    logic Clk, Reset, Run;
    
    assign CLOCK_50 = Clk;
    assign KEY[0] = ~Reset;
    assign KEY[3] = ~Run;
    
    logic   [15:0]  Bus;
    logic   [15:0]  MAR, MDR, IR, PC;
    logic   [15:0]  R0, R1, R2, R3, R4, R5, R6, R7;
    logic   [15:0]  SR1, SR2;
    logic           N, Z, P;
    
    logic   [7:0]   State;
    logic   [3:0]   Opcode;
    logic           MIO_EN, R_W;
    
    elc3 theELC3(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    always begin : INTERNAL_MONITORING
    #1  Bus = theELC3.dp.Bus;
        MAR = theELC3.dp.MAR;
        MDR = theELC3.dp.MDR;
        IR = theELC3.dp.IR;
        PC = theELC3.dp.PC;
        R0 = theELC3.dp._GenPurposeRegs.R0_Out;
        R1 = theELC3.dp._GenPurposeRegs.R1_Out;
        R2 = theELC3.dp._GenPurposeRegs.R2_Out;
        R3 = theELC3.dp._GenPurposeRegs.R3_Out;
        R4 = theELC3.dp._GenPurposeRegs.R4_Out;
        R5 = theELC3.dp._GenPurposeRegs.R5_Out;
        R6 = theELC3.dp._GenPurposeRegs.R6_Out;
        R7 = theELC3.dp._GenPurposeRegs.R7_Out;
        SR1 = theELC3.dp.SR1;
        SR2 = theELC3.dp.SR2;
        N = theELC3.dp.N;
        Z = theELC3.dp.Z;
        P = theELC3.dp.P;
        State = theELC3.ctl.State;
        Opcode = theELC3.ctl.Opcode;
        MIO_EN = theELC3.MIO_EN;
        R_W = theELC3.R_W;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        SW = 16'd60;
        //KEY = 4'h0;
        Run = 1'b0;
        Reset = 1'b1;
    #4  Reset = 1'b0;
    
    #2  Run = 1'b1;
    #2  Run = 1'b0;
    end
endmodule
