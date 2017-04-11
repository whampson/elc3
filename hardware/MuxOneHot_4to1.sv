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
module MuxOneHot_4to1 #(N = 16)
(
    input   logic   [3:0]   Select,
    input   logic   [N-1:0] In0, In1, In2, In3,
    output  logic   [N-1:0] Out
);

    always_comb begin
        unique case (Select)
            4'b0001:    Out = In0;
            4'b0010:    Out = In1;
            4'b0100:    Out = In2;
            4'b1000:    Out = In3;
            default:    Out = {N{1'bZ}};
        endcase
    end

endmodule
