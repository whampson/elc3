/**
 * An N-bit 4:1 multiplexer.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Mux_4to1 #(N = 16)
(
    input   logic   [1:0]   Select,
    input   logic   [N-1:0] In0, In1, In2, In3,
    output  logic   [N-1:0] Out
);

    always_comb begin
        case (Select)
            2'b00:  Out = In0;
            2'b01:  Out = In1;
            2'b10:  Out = In2;
            2'b11:  Out = In3;
        endcase
    end

endmodule
