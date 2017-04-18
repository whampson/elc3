/**
 * A "fake" memory module to act as SRAM during simulation.
 * This module should *NOT* be synthesized to the FPGA.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module FakeMemory
(
    input   logic           Clk, Reset,
    input   logic           CE, OE, WE,
    input   logic           LB, UB,
    input   logic   [19:0]  ADDR,
    inout   wire    [15:0]  DQ
);

    parameter NumWords = 16;
    parameter AddrWidth = $clog2(NumWords);

    logic   [15:0]  MemoryArray[NumWords-1:0];
    logic   [15:0]  Output;
    logic   [15:0]  DataWire;
    
    assign Output = MemoryArray[ADDR[AddrWidth-1:0]];
    assign DQ = DataWire;
    
    // Read logic
    always_comb begin
        DataWire = 16'hZZZZ;
        if (~CE && ~OE && WE) begin
            if (~UB)
                DataWire[15:8] = Output[15:8];
            if (~LB)
                DataWire[7:0] = Output[7:0];
        end
    end

    always_ff @(posedge Clk) begin
        if (Reset) begin
            // Initial memory contents
            MemoryArray[0]  <= 16'b0001_000_000_1_01111;    // ADD R0,R0,#15
            MemoryArray[1]  <= 16'b0010_001_000000010;      // LD  R1,DISP (PC + 2)
            MemoryArray[2]  <= 16'b0111_000_001_000000;     // STR R0,R1,#0
            MemoryArray[3]  <= 16'h0000;                    // NOP/HALT
            MemoryArray[4]  <= 16'hFE06;                    // :DISP
            MemoryArray[5]  <= 16'h0000;
            MemoryArray[6]  <= 16'h0000;
            MemoryArray[7]  <= 16'h0000;
            MemoryArray[8]  <= 16'h0000;
            MemoryArray[9]  <= 16'h0000;
            MemoryArray[10] <= 16'h0000;
            MemoryArray[11] <= 16'h0000;
            MemoryArray[12] <= 16'h0000;
            MemoryArray[13] <= 16'h0000;
            MemoryArray[14] <= 16'h0000;
            MemoryArray[15] <= 16'h0000;                    // NOP
        end
        else if (~CE && OE && ~WE && ADDR[19:AddrWidth] == {19-AddrWidth+1{1'b0}}) begin
            // Write to memory, but only if address is in range
            if (~UB)
                MemoryArray[ADDR[AddrWidth-1:0]][15:8] <= DQ[15:8];
            if (~LB)
                MemoryArray[ADDR[AddrWidth-1:0]][7:0] <= DQ[7:0];
        end
    end

endmodule
