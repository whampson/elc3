/**
 * The eLC-3 arithmetic and loguc unit.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module ALU
(
    input   logic   [1:0]   Fn,
    input   logic   [15:0]  A, B,
    output  logic   [15:0]  Out
);

    always_comb begin
        case (Fn)
            2'b00:  Out = A + B;    // ADD
            2'b01:  Out = A & B;    // AND
            2'b10:  Out = ~A;       // NOT
            2'b11:  Out = A;        // PASSA
        endcase
    end

endmodule
