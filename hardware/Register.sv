/**
 * An N-bit data register.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Register #(N = 16)
(
    input   logic           Clk, Reset, Load,
    input   logic   [N-1:0] Data_In,
    output  logic   [N-1:0] Data_Out
);

    logic   [N-1:0] Data_Next;
    
    always_ff @(posedge Clk) begin
        Data_Out <= Data_Next;
    end
    
    always_comb begin
        Data_Next = Data_Out;
        if (Reset)
            Data_Next = {N{1'b0}};
        else if (Load)
            Data_Next = Data_In;
    end

endmodule
