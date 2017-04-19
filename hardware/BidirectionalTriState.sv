/**
 * An N-bit tri-state buffer for a bidirectional (inout) data port.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module BidirectionalTriState #(N = 16)
(
    input   logic           Clk,
    input   logic           WriteEnable,
    input   logic   [N-1:0] In,
    output  logic   [N-1:0] Out,
    inout           [N-1:0] Data
);

    logic   [N-1:0] DataOut_Buffer;
    
    // Update the output buffer every clock cycle
    always_ff @(posedge Clk) begin
        DataOut_Buffer <= In;
    end
    
    // Write output from buffer; output Hi-Z when not writing
    assign Data = (WriteEnable) ? DataOut_Buffer : {N{1'bZ}};
    
    assign Out = Data;

endmodule
