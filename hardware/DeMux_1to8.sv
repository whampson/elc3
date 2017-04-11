/**
 * An N-bit 1:8 de-multiplexer.
 * 
 * Outputs that are not currently being used will output a Hi-Z signal.
 * Default data width is 16 bits.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module DeMux_1to8 #(N = 16)
(
    input   logic   [2:0]   Select,
    input   logic   [N-1:0] In,
    output  logic   [N-1:0] Out0, Out1, Out2, Out3, Out4, Out5, Out6, Out7
);

    always_comb begin
        Out0 = {N{1'bZ}};
        Out1 = {N{1'bZ}};
        Out2 = {N{1'bZ}};
        Out3 = {N{1'bZ}};
        Out4 = {N{1'bZ}};
        Out5 = {N{1'bZ}};
        Out6 = {N{1'bZ}};
        Out7 = {N{1'bZ}};
        
        case (Select)
            3'b000: Out0 = In;
            3'b001: Out1 = In;
            3'b010: Out2 = In;
            3'b011: Out3 = In;
            3'b100: Out4 = In;
            3'b101: Out5 = In;
            3'b110: Out6 = In;
            3'b111: Out7 = In;
        endcase
    end

endmodule
