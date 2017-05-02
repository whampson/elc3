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
            MemoryArray[0]  <= 16'h0000;
            MemoryArray[1]  <= 16'h0000;
            MemoryArray[2]  <= 16'h0000;
            MemoryArray[3]  <= 16'h0000;
            MemoryArray[4]  <= 16'h0000;
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
            MemoryArray[32] <= 16'h002A;                    // ; TRAP x20 (GETC)
            MemoryArray[33] <= 16'h0000;
            MemoryArray[34] <= 16'h0000;
            MemoryArray[35] <= 16'h0000;
            MemoryArray[36] <= 16'h0000;
            MemoryArray[37] <= 16'h0030;                    // ; TRAP x25 (HALT)
            MemoryArray[38] <= 16'hFE00;                    // :OS_KBSR
            MemoryArray[39] <= 16'hFE02;                    // :OS_KBDR
            MemoryArray[40] <= 16'h0000;
            MemoryArray[41] <= 16'h0000;
            MemoryArray[42] <= 16'b1010_000_111111011;      // TRAP_GETC    LDI R0,OS_KBSR
            MemoryArray[43] <= /*16'b0000_011_111111110*/16'h0000;      //              BRzp TRAP_GETC
            MemoryArray[44] <= 16'b1010_000_111111010;      //              LDI R0,OS_KBDR
            MemoryArray[45] <= 16'b1100_000_111_000000;     //              RET
            MemoryArray[46] <= 16'h0000;
            MemoryArray[47] <= 16'h0000;
            MemoryArray[48] <= 16'b1011_000_000000000;      // :TRAP_HALT   STI R0,OS_HALT      ; Killer poke!!
            MemoryArray[49] <= 16'hFFFF;                    // :OS_HALT
            MemoryArray[50] <= 16'h0000;
            MemoryArray[51] <= 16'h0000;
            MemoryArray[52] <= 16'h0000;
            MemoryArray[53] <= 16'h0000;
            MemoryArray[54] <= 16'h0000;
            MemoryArray[55] <= 16'h0000;
            MemoryArray[56] <= 16'h0000;
            MemoryArray[57] <= 16'h0000;
            MemoryArray[58] <= 16'h0000;
            MemoryArray[59] <= 16'b0000_0000_0000_0000;     // :START       NOP
            MemoryArray[60] <= 16'b1111_0000_00100000;      //              TRAP x20
            MemoryArray[61] <= 16'b1111_0000_00100101;      // :END         TRAP x25
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
