/**
 * An N-bit 2:1 multiplexer.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Mux_2to1 #(N = 16)
(
    input   logic           Select,
    input   logic   [N-1:0] In0, In1,
    output  logic   [N-1:0] Out
);

    always_comb begin
        case (Select)
            1'b0:   Out = In0;
            1'b1:   Out = In1;
        endcase
    end

endmodule
