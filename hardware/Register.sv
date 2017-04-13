/**
 * An N-bit data register.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Register #(N = 16)
(
    input   logic           Clk, Reset,
    input   logic           Load,
    input   logic   [N-1:0] In,
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
    end

endmodule
