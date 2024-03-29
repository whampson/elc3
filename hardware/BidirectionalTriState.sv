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

    logic   [N-1:0] DataIn_Buffer, DataOut_Buffer;
    
    // Update the input and output buffers every clock cycle
    always_ff @(posedge Clk) begin
        DataIn_Buffer <= Data;
        DataOut_Buffer <= In;
    end
    
    assign Data = (WriteEnable) ? DataOut_Buffer : {N{1'bZ}};
    assign Out = DataIn_Buffer;

endmodule
