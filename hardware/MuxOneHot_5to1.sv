/**
 * An N-bit 4:1 multiplexer with one-hot addressing.
 * Default data width is 16 bits.
 *
 * The output line will output Hi-Z unless exactly one of the four addressing
 * bits is high. For this reason, this multiplexer can be used like a tri-state
 * buffer.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module MuxOneHot_5to1 #(N = 16)
(
    input   logic   [4:0]   Select,
    input   logic   [N-1:0] In0, In1, In2, In3, In4,
    output  logic   [N-1:0] Out
);

    always_comb begin
        unique case (Select)
            5'b00001:   Out = In0;
            5'b00010:   Out = In1;
            5'b00100:   Out = In2;
            5'b01000:   Out = In3;
            5'b10000:   Out = In4;
            default:    Out = {N{1'b0}};
        endcase
    end

endmodule
