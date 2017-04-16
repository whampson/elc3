/**
 * A synchronizer. Used to make asynchronous signals synchronous.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Synchronizer
(
    
    input   Clk,
    input   In,
    output  Out
);

    always_ff @(posedge Clk) begin
        Out <= In;
    end

endmodule
