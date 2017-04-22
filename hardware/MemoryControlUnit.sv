/**
 * Control unit for the eLC-3 memory.
 * Handles memory-mapped I/O and conversion from eLC-3
 * memory control signals to SRAM chip control signals.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module MemoryControlUnit
(
    input   logic           Clk, Reset,
    input   logic           MIO_EN,
    input   logic           R_W,
    input   logic   [15:0]  Address,
    input   logic   [15:0]  Data_FromSRAM,
    input   logic   [15:0]  Data_FromCPU,
    input   logic   [15:0]  Data_FromKeyboard,
    output  logic           Mem_CE, Mem_OE, Mem_WE,
    output  logic           Mem_LB, Mem_UB,
    output  logic   [15:0]  Data_ToSRAM,
    output  logic   [15:0]  Data_ToCPU,
    output  logic   [15:0]  Data_ToVideo
);

    // Keyboard data and status; display data and status
    logic           LD_KBSR;
    logic           LD_DDR, LD_DSR;
    logic   [15:0]  KBDR, KBSR;
    logic   [15:0]  DDR, DSR;
    
    // Input MUX select signal
    logic   [1:0]   INMUX;
    
    assign Data_ToSRAM = Data_FromCPU;
    assign Data_ToVideo = DDR;
    
    assign Mem_CE = 1'b1;
    assign Mem_LB = 1'b1;
    assign Mem_UB = 1'b1;
    
    // Memory-mapped I/O logic
    always_comb begin
        LD_KBSR     = 1'b0;
        LD_DDR      = 1'b0;
        LD_DSR      = 1'b0;
        INMUX       = 2'b00;
        Mem_OE      = 1'b0;
        Mem_WE      = 1'b0;
        
        unique case (Address)
            // Read/write KBSR
            16'hFE00: begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_KBSR = 1'b1;
                    else
                        INMUX = 2'b01;
                end
            end
            
            // Read KBDR
            16'hFE02: begin
                if (MIO_EN)
                    INMUX = 2'b10;
            end
            
            // Read/write DSR
            16'hFE04: begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_DSR = 1'b1;
                    else
                        INMUX = 2'b11;
                end
            end
            
            // Write DDR
            16'hFE06: begin
                if (MIO_EN && R_W) begin
                    LD_DDR = 1'b1;
                end
            end
            
            // Read/write SRAM
            default : begin
                if (MIO_EN) begin
                    if (R_W)
                        Mem_WE = 1'b1;
                    else begin
                        Mem_OE = 1'b1;
                        INMUX = 2'b00;
                    end
                end
            end
        endcase
    end
    
    Register        _KBDR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Data_FromKeyboard),
        .Out(KBDR),
        .Load(1'b1)
    );
    
    Register        _KBSR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Data_FromCPU),
        .Out(KBSR),
        .Load(LD_KBSR)
    );
    
    Register        _DDR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Data_FromCPU),
        .Out(DDR),
        .Load(LD_DDR)
    );
    
    Register        _DSR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Data_FromCPU),
        .Out(DSR),
        .Load(LD_DSR)
    );

    Mux_4to1        _INMUX
    (
        .In0(Data_FromSRAM),
        .In1(KBSR),
        .In2(KBDR),
        .In3(DSR),
        .Out(Data_ToCPU),
        .Select(INMUX)
    );
    
//    // Tri-state buffer for data lines between eLC-3 memory control logic and SRAM chip
//    BidirectionalTriState memTristate
//    (
//        .Clk(Clk),
//        .In(TriState_In),           // Data going into tri-state to memory
//        .Out(TriState_Out),         // Data coming out of tri-state from memory
//        .Data(SRAM_DQ),             // Bus travelling between tri-state and SRAM chip
//        .WriteEnable(Mem_WE_Out)    // Read or write to SRAM
//    );
//    
//    // SRAM control signal synchronizers
//    Synchronizer syncCE(.*, .In(Mem_CE), .Out(Mem_CE_Out));
//    Synchronizer syncOE(.*, .In(Mem_OE), .Out(Mem_OE_Out));
//    Synchronizer syncWE(.*, .In(Mem_WE), .Out(Mem_WE_Out));
//    Synchronizer syncLB(.*, .In(Mem_LB), .Out(Mem_LB_Out));
//    Synchronizer syncUB(.*, .In(Mem_UB), .Out(Mem_UB_Out));

endmodule
