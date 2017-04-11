/**
 * ALU testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_alu();

    timeunit 10ns;
    timeprecision 1ns;
    
    logic           Clk;
    logic   [15:0]  A, B, Out;
    logic   [1:0]   Fn;
    
    ALU alu(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin : TEST_VECTORS
        /* --- Test ADD --- */
        // Unsigned addition
        Fn = 2'b00;
        A = 16'd100;
        B = 16'd55;
    #2  if (Out != 16'd155)
            $display("100 + 55 failed!");
        
        // Signed addition
        A = -16'd1;
        B = 16'd6;
    #2  if (Out != 16'd5)
            $display("-1 + 6 failed!");
        
        A = -16'd64;
        B = -16'd32;
    #2  if (Out != -16'd96)
            $display("-64 + -32 failed!");
        
        // Overflow
        A = 16'h7FF0;
        B = 16'h0010;
    #2  if (Out != -16'd32768)
            $display("0x7FF0 + 0x0010 did not overflow properly!");
        
        /* --- Test AND --- */
        Fn = 2'b01;
        A = 16'hCAFE;
        B = 16'hFF00;
    #2  if (Out != 16'hCA00)
            $display("0xCAFE & 0xFF00 failed!");
        
        /* --- Test NOT --- */
        Fn = 2'b10;
        A = 16'hECEB;
    #2  if (Out != 16'h1314)
            $display("NOT(0xECEB) failed!");
    
        /* --- Test PASSA --- */
        Fn = 2'b11;
        A = 16'hF00D;
    #2  if (Out != 16'hF00D)
            $display("PASS(0xF00D) failed!");
    end
    
endmodule
