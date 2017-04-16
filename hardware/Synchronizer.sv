/**
 * A synchronizer. Used to make asynchronous signals synchronous.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Synchronizer #(N = 1)
(
    
    input   logic           Clk,
    input   logic   [N-1:0] In,
    output  logic   [N-1:0] Out
);

    always_ff @(posedge Clk) begin
        Out <= In;
    end

endmodule
