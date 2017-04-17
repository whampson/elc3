/**
 * Testbench for FakeMemory module.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_fakemem();

    timeunit 10ns;
    timeprecision 1ns;
    
    logic           Clk, Reset;
    logic           CE, OE, WE; // Active-low
    logic           LB, UB;     // Active-low
    logic   [19:0]  ADDR;
    wire    [15:0]  DQ;
    
    FakeMemory fakeMem(.*);
    
    logic   [15:0]  DataOut;
    assign  DQ = (~CE && ~WE) ? DataOut : 16'hZZZZ;
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        CE = 1'b1;
        OE = 1'b1;
        WE = 1'b1;
        LB = 1'b0;
        UB = 1'b0;
        Reset = 1'b1;
    #2  Reset = 1'b0;
    
        // Test read
        ADDR = 19'd1;
        CE = 1'b0;
        OE = 1'b0;
    #2  if (DQ != 16'b0001_000_000_1_01111)
            $display("Initial read failed!");
    #2  CE = 1'b1;
        OE = 1'b1;
        
        // Test write/read
    #2  ADDR = 19'd10;
        CE = 1'b0;
        WE = 1'b0;
        DataOut = 16'hBEEF;
    #2  ADDR = 19'd0;
        CE = 1'b1;
        WE = 1'b1;
        DataOut = 16'h0000;
    #2  ADDR = 19'd10;
        CE = 1'b0;
        OE = 1'b0;
    #2  if (DQ != 16'hBEEF)
            $display("Read after write failed!");
    #2  CE = 1'b1;
        OE = 1'b1;
    end

endmodule
