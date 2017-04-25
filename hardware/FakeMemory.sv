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

    parameter NumWords = 64;
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
            MemoryArray[0]  <= 16'b0000_0000_0000_0000;     // NOP
            MemoryArray[1]  <= 16'b1010_111_000000001;      // LDI  R7,#1
            MemoryArray[2]  <= 16'b1100_000_111_000000;     // JMP  R7
            MemoryArray[3]  <= 16'hFE02;
            MemoryArray[4]  <= 16'hFE06;
            MemoryArray[5]  <= 16'b0001_011_001_1_01010;    // ADD  R3,R3,#10
            MemoryArray[6]  <= 16'b0001_101_101_1_10000;    // ADD  R5,R5,#-16
            MemoryArray[7]  <= 16'b1101_001_011_0_00_101;   // MUL  R1,R3,R5
            MemoryArray[8]  <= 16'b1101_010_011_1_00100;    // MUL  R2,R3,#4
            MemoryArray[9]  <= 16'b1011_011_111111011;      // STI  R1,#-6
            MemoryArray[10] <= 16'b1011_011_111111011;      // STI  R2,#-7
            MemoryArray[11] <= 16'b1111_0000_00100101;      // TRAP x25
            MemoryArray[12] <= 16'h0000;
            MemoryArray[13] <= 16'h0000;
            MemoryArray[14] <= 16'h0000;
            MemoryArray[15] <= 16'h0000;
            MemoryArray[16] <= 16'h0000;
            MemoryArray[17] <= 16'h0000;
            MemoryArray[18] <= 16'h0000;
            MemoryArray[19] <= 16'h0000;
            MemoryArray[20] <= 16'h0000;
            MemoryArray[21] <= 16'h0000;
            MemoryArray[22] <= 16'h0000;
            MemoryArray[23] <= 16'h0000;
            MemoryArray[24] <= 16'h0000;
            MemoryArray[25] <= 16'h0000;
            MemoryArray[26] <= 16'h0000;
            MemoryArray[27] <= 16'h0000;
            MemoryArray[28] <= 16'h0000;
            MemoryArray[29] <= 16'h0000;
            MemoryArray[30] <= 16'h0000;
            MemoryArray[31] <= 16'h0000;
            MemoryArray[32] <= 16'h0000;
            MemoryArray[33] <= 16'h0000;
            MemoryArray[34] <= 16'h0000;
            MemoryArray[35] <= 16'h0000;
            MemoryArray[36] <= 16'h0000;
            MemoryArray[37] <= 16'h0030;                    // TRAP x25 (HALT)
            MemoryArray[38] <= 16'h0000;
            MemoryArray[39] <= 16'h0000;
            MemoryArray[40] <= 16'h0000;
            MemoryArray[41] <= 16'h0000;
            MemoryArray[42] <= 16'h0000;
            MemoryArray[43] <= 16'h0000;
            MemoryArray[44] <= 16'h0000;
            MemoryArray[45] <= 16'h0000;
            MemoryArray[46] <= 16'h0000;
            MemoryArray[47] <= 16'h0000;
            MemoryArray[48] <= 16'b0000_111_111111111;       // TRAP_HALT   BRnzp #-1
            MemoryArray[49] <= 16'h0000;
            MemoryArray[50] <= 16'h0000;
            MemoryArray[51] <= 16'h0000;
            MemoryArray[52] <= 16'h0000;
            MemoryArray[53] <= 16'h0000;
            MemoryArray[54] <= 16'h0000;
            MemoryArray[55] <= 16'h0000;
            MemoryArray[56] <= 16'h0000;
            MemoryArray[57] <= 16'h0000;
            MemoryArray[58] <= 16'h0000;
            MemoryArray[59] <= 16'h0000;
            MemoryArray[60] <= 16'h0000;
            MemoryArray[61] <= 16'h0000;
            MemoryArray[62] <= 16'h0000;
            MemoryArray[63] <= 16'h0000;
        end
        else if (~CE && OE && ~WE && ADDR[19:AddrWidth] == {19-AddrWidth{1'b0}}) begin
            // Write to memory, but only if address is in range
            if (~UB)
                MemoryArray[ADDR[AddrWidth-1:0]][15:8] <= DQ[15:8];
            if (~LB)
                MemoryArray[ADDR[AddrWidth-1:0]][7:0] <= DQ[7:0];
        end
    end

endmodule
