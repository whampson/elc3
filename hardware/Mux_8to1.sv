/**
 * An N-bit 8:1 multiplexer.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Mux_8to1 #(N = 16)
(
    input   logic   [2:0]   Select,
    input   logic   [N-1:0] In0, In1, In2, In3, In4, In5, In6, In7,
    output  logic   [N-1:0] Out
);

    always_comb begin
        case (Select)
            3'b000: Out = In0;
            3'b001: Out = In1;
            3'b010: Out = In2;
            3'b011: Out = In3;
            3'b100: Out = In4;
            3'b101: Out = In5;
            3'b110: Out = In6;
            3'b111: Out = In7;
        endcase
    end

endmodule
