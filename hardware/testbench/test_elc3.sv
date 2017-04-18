module test_elc3();

    logic           CLOCK_50;
    logic   [3:0]   KEY;
    logic   [17:0]  SW;
    logic   [8:0]   LEDG;
    logic   [17:0]  LEDR;
    logic   [6:0]   HEX0, HEX1, HEX2, HEX3;
    logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N;
    logic           SRAM_LB_N, SRAM_UB_N;
    logic   [19:0]  SRAM_ADDR;
    logic   [15:0]  SRAM_DQ;
    
    logic Clk, Reset, Run;
    
    assign CLOCK_50 = Clk;
    assign KEY[0] = ~Reset;
    assign KEY[3] = ~Run;
    
    logic   [15:0]  R0, R1, R2, R3, R4, R5, R6, R7;
    
    
    elc3 theELC3(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    always begin : INTERNAL_MONITORING
    #1  R0 = theELC3.dp._GenPurposeRegs.R0_Out;
        R1 = theELC3.dp._GenPurposeRegs.R1_Out;
        R2 = theELC3.dp._GenPurposeRegs.R2_Out;
        R3 = theELC3.dp._GenPurposeRegs.R3_Out;
        R4 = theELC3.dp._GenPurposeRegs.R4_Out;
        R5 = theELC3.dp._GenPurposeRegs.R5_Out;
        R6 = theELC3.dp._GenPurposeRegs.R6_Out;
        R7 = theELC3.dp._GenPurposeRegs.R7_Out;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        SW = 16'h0000;
        KEY = 4'h0;
        Run = 1'b0;
        Reset = 1'b1;
    #2  Reset = 1'b0;
    end
endmodule
