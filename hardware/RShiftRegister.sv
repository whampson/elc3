/**
 * An N-bit right-shift register.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module RShiftRegister #(N = 16)
(
    input   logic           Clk, Reset,
    input   logic           Load,
    input   logic           ShiftEnable,
    input   logic           ShiftIn,
    input   logic   [N-1:0] In,
    output  logic           ShiftOut,
    output  logic   [N-1:0] Out
);

    logic   [N-1:0] Next;
    
    always_ff @(posedge Clk) begin
        Out <= Next;
    end
    
    always_comb begin
        Next = Out;
        if (Reset)
            Next = {N{1'b0}};
        else if (Load)
            Next = In;
        else if (ShiftEnable)
            Next = { ShiftIn, Out[N-1:1] };
    end
    
    assign ShiftOut = Out[0];

endmodule
