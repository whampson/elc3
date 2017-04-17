/**
 * Testbench for testing the memory control unit.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_memcontrol();

    timeunit 10ns;
    timeprecision 1ns;
    
    logic           Clk, Reset;
    
    // MemoryControlUnit signals
    logic           MIO_EN;
    logic           R_W;
    logic   [15:0]  Address;
    logic   [15:0]  Data_FromCPU;
    logic   [15:0]  Data_FromKeyboard;
    logic   [15:0]  Data_ToCPU;
    logic   [15:0]  Data_ToVideo;
    
    // FakeMemory signals
    logic           CE, OE, WE;
    logic           LB, UB;
    logic   [19:0]  ADDR;
    wire    [15:0]  DQ;
    
    MemoryControlUnit memCtl
    (
        .SRAM_CE_N(CE),
        .SRAM_OE_N(OE),
        .SRAM_WE_N(WE),
        .SRAM_LB_N(LB),
        .SRAM_UB_N(UB),
        .SRAM_ADDR(ADDR),
        .SRAM_DQ(DQ),
        .*
    );
    FakeMemory fakeMem(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        MIO_EN = 1'b0;
        R_W = 1'b0;
        Address = 16'h0000;
        Data_FromKeyboard = 16'h0000;
        Data_FromCPU = 16'h0000;
        Reset = 1'b1;
    #2  Reset = 1'b0;
    
        // Test basic read
        Address = 16'h0001;
        MIO_EN = 1'b1;
    #4  if (Data_ToCPU != 16'b0001_000_000_1_01111)
            $display("Basic read failed!");
        MIO_EN = 1'b0;
    
        // Test basic write/read
    #2  Address = 16'h000A;
        Data_FromCPU = 16'hCAFE;
        R_W = 1'b1;
        MIO_EN = 1'b1;
    #4  MIO_EN = 1'b0;  // End write cycle
        R_W = 1'b0;
        Data_FromCPU = 16'h0000;
        
    #2  Address = 16'h0000;
    #2  Address = 16'h000A; // Begin readback
        MIO_EN = 16'b1;
    #4  if (Data_ToCPU != 16'hCAFE)
            $display("Basic write/read failed!");
        MIO_EN = 1'b0;
        
        // Test memory-mapped keyboard input
        Data_FromKeyboard = 16'hC0FF;
    #2  Address = 16'hFE02;
        MIO_EN = 1'b1;
    #4  if (Data_ToCPU != 16'hC0FF)
            $display("Keyboard read failed!");
        MIO_EN = 1'b0;
    
        // Test memory-mapped diaplay output
        Data_FromCPU = 16'hECEB;
    #2  Address = 16'hFE06;
        MIO_EN = 1'b1;
        R_W = 1'b1;
    #4  MIO_EN = 1'b0;
        R_W = 1'b0;
        if (Data_ToVideo != 16'hECEB)
            $display("Video write failed!");
    end

endmodule
