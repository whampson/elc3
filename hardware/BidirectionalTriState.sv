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

    // I/0 Buffers
    logic   [N-1:0] DataIn_Buffer, DataOut_Buffer;
    
    // Update the buffers every clock cycle
    always_ff @(posedge Clk) begin
        Out <= (~WriteEnable) ? Data : {N{1'bZ}};
        DataOut_Buffer <= In;
    end
    
    // Write output from buffer; output Hi-Z when not writing
    assign Data = (WriteEnable) ? DataOut_Buffer : {N{1'bZ}};

endmodule
