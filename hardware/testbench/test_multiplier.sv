module test_multiplier();

    timeunit 10ns;
    timeprecision 1ns;
    
    logic           Clk, Reset;
    logic           Run;
    logic   [7:0]   A, B;
    logic           Ready;
    logic   [15:0]  Out;
    
    // Internal signals
    logic   [8:0]   MUL;
    logic   [7:0]   A_Out, B_Out;
    logic           A0;
    logic           X;
    logic           M;
    
    logic           LD_A;
    logic           LD_B;
    logic           LD_MUL;
    logic           LD_X;
    logic           CLR_A;
    logic           SH;
    logic           AMUX;
    logic           ADDMUX;
    
    logic   [1:0]   State;
    logic   [3:0]   Counter;
    
    Multiplier mul(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    always begin : INTERNAL_MONITORING
    #1  MUL = mul.MUL;
        A_Out = mul.A_Out;
        B_Out = mul.B_Out;
        A0 = mul.A0;
        X = mul.X;
        M = mul.M;
        LD_A = mul.LD_A;
        LD_B = mul.LD_B;
        LD_MUL = mul.LD_MUL;
        LD_X = mul.LD_X;
        CLR_A = mul.CLR_A;
        SH = mul.SH;
        AMUX = mul.AMUX;
        ADDMUX = mul.ADDMUX;
        State = mul.State;
        Counter = mul.Counter;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        A = 8'd127;
        B = -8'd8;
        
        Run = 1'b0;
        Reset = 1'b1;
    #2  Reset = 1'b0;
    
        Run = 1'b1;
    #2  Run = 1'b0;
    end

endmodule
