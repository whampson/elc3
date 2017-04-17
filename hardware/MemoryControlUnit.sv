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
    input   logic   [15:0]  Data_FromCPU,
    input   logic   [15:0]  Data_FromKeyboard,
    output  logic   [15:0]  Data_ToCPU,
    output  logic   [15:0]  Data_ToVideo,
    output  logic           SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
    output  logic           SRAM_LB_N, SRAM_UB_N,
    output  logic   [19:0]  SRAM_ADDR,
    inout   wire    [15:0]  SRAM_DQ
);

    // Keyboard data and status; display data and status
    logic           LD_KBDR, LD_KBSR;
    logic           LD_DDR, LD_DSR;
    logic   [15:0]  KBDR, KBSR;
    logic   [15:0]  DDR, DSR;
    assign          Data_ToVideo = DDR;
    
    // Input MUX select signal
    logic   [1:0]   INMUX;
    
    // Data to/from SRAM (passes through tri-state)
    logic   [15:0]  Data_FromSRAM, Data_ToSRAM;
    assign          Data_ToSRAM = Data_FromCPU;

    // Synchronized SRAM control signals (these are active-high)
    logic           Mem_OE;
    logic           Mem_CE;
    logic           Mem_WE;
    logic           Mem_LB;
    logic           Mem_UB;
    
    // Memory addressing and control
    assign          SRAM_ADDR = {4'b0000, Address };    // SRAM is 1M x 16, eLC-3 memory is only 64K x 16
    assign          Mem_LB = 1'b1;
    assign          Mem_UB = 1'b1;
    
    // Memory-mapped I/O logic
    always_comb begin
        LD_KBDR     = 1'b0;
        LD_KBSR     = 1'b0;
        LD_DDR      = 1'b0;
        LD_DSR      = 1'b0;
        INMUX       = 2'b00;
        Mem_CE      = 1'b0;
        Mem_OE      = 1'b0;
        Mem_WE      = 1'b0;
        
        unique case (Address)
            // Read/write KBSR
            16'hFE00:   begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_KBSR = 1'b1;
                    else
                        INMUX = 2'b01;
                end
            end
            
            // Read/write KBDR
            16'hFE02:   begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_KBDR = 1'b1;
                    else
                        INMUX = 2'b10;
                end
            end
            
            // Read/write DSR
            16'hFE04:   begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_DSR = 1'b1;
                    else
                        INMUX = 2'b11;
                end
            end
            
            // Write DDR
            16'hFE06:   begin
                if (MIO_EN) begin
                    if (R_W)
                        LD_DDR = 1'b1;
                end
            end
            
            // Read/write SRAM
            default :   begin
                if (MIO_EN) begin
                    Mem_CE = 1'b1;
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
        .Load(LD_KBDR)
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
    
    // Tri-state buffer for data lines between eLC-3 memory control logic and SRAM chip
    BidirectionalTriState memTristate
    (
        .Clk(Clk),
        .In(Data_ToSRAM),           // Data going into tri-state to memory
        .Out(Data_FromSRAM),        // Data coming out of tri-state from memory
        .Data(SRAM_DQ),             // Bus travelling between tri-state and SRAM chip
        .WriteEnable(Mem_WE)        // Read or write to SRAM
    );
    
    // SRAM control signal synchronizers
    // Converts active-high synchronized signals to active-low async SRAM signals
    Synchronizer syncCE(.Clk(Clk), .In(~Mem_CE), .Out(SRAM_CE_N));
    Synchronizer syncOE(.Clk(Clk), .In(~Mem_OE), .Out(SRAM_OE_N));
    Synchronizer syncWE(.Clk(Clk), .In(~Mem_WE), .Out(SRAM_WE_N));
    Synchronizer syncLB(.Clk(Clk), .In(~Mem_LB), .Out(SRAM_LB_N));
    Synchronizer syncUB(.Clk(Clk), .In(~Mem_UB), .Out(SRAM_UB_N));

endmodule
