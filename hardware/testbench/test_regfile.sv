/**
 * Register file testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_regfile();

    timeunit 10ns;
    timeprecision 1ns;
    
    // Register file I/O signals
    logic           Clk, Reset;
    logic           LD_REG;
    logic   [2:0]   DR, SR1, SR2;
    logic   [15:0]  In;
    logic   [15:0]  SR1_Out, SR2_Out;
    
    // Monitoring signals
    // Current contents of general purpose registers
    logic   [15:0]  R0, R1, R2, R3, R4, R5, R6, R7;
    
    
    RegisterFile regFile(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    always begin : INTERNAL_MONITORING
    #1  R0 = regFile.R0_Out;
        R1 = regFile.R1_Out;
        R2 = regFile.R2_Out;
        R3 = regFile.R3_Out;
        R4 = regFile.R4_Out;
        R5 = regFile.R5_Out;
        R6 = regFile.R6_Out;
        R7 = regFile.R7_Out;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        Reset = 1'b1;
        In = 16'h0000;
        LD_REG = 1'b0;
        DR = 3'b000;
        SR1 = 3'b000;
        SR2 = 3'b000;
    #2  Reset = 1'b0;
        
        // Load '0xCAFE' into R3
    #2  DR = 3'b011;
        In = 16'hCAFE;
        LD_REG = 1'b1;
    #2  LD_REG = 1'b0;
    
        // Load '0xBEEF' into R2
    #2  DR = 3'b010;
        In = 16'hBEEF;
        LD_REG = 1'b1;
    #2  LD_REG = 1'b0;
    
        // Output R0 and R2
    #2  SR1 = 3'b000;
        SR2 = 3'b010;
        
        // Output R2 and R3
    #2  SR1 = 3'b010;
        SR2 = 3'b011;
    end

endmodule
