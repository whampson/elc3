module Multiplier
(
    input   logic           Run,
    input   logic   [7:0]   A, B,
    output  logic           Ready,
    output  logic   [15:0]  Out
);

    assign Out = { A, B };      // TEMP
    assign Ready = 1'b0;        // TEMP
    
    // TODO: Multiplier state machine

endmodule
