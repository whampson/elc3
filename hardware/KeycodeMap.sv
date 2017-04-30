/**
 * Maps PS/2 keycodes to ASCII values.
 * Only alphanumeric, backspace, and return keys are mapped.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module KeycodeMap
(
    input   logic   [7:0]   Keycode,
    output  logic   [7:0]   ASCII
);

    always_comb begin
        case (Keycode)
            8'h66   :   ASCII = 8'h08;  // Backspace
            8'h5A   :   ASCII = 8'h0A;  // Enter/Return (LF)
            8'h29   :   ASCII = 8'h20;  // Space
            8'h45   :   ASCII = 8'h30;  // '0'
            8'h16   :   ASCII = 8'h31;  // '1'
            8'h1E   :   ASCII = 8'h32;  // '2'
            8'h26   :   ASCII = 8'h33;  // '3'
            8'h25   :   ASCII = 8'h34;  // '4'
            8'h2E   :   ASCII = 8'h35;  // '5'
            8'h36   :   ASCII = 8'h36;  // '6'
            8'h3D   :   ASCII = 8'h37;  // '7'
            8'h3E   :   ASCII = 8'h38;  // '8'
            8'h46   :   ASCII = 8'h39;  // '9'
            8'h70   :   ASCII = 8'h30;  // '0' (numpad)
            8'h69   :   ASCII = 8'h31;  // '1' (numpad)
            8'h72   :   ASCII = 8'h32;  // '2' (numpad)
            8'h7A   :   ASCII = 8'h33;  // '3' (numpad)
            8'h6B   :   ASCII = 8'h34;  // '4' (numpad)
            8'h73   :   ASCII = 8'h35;  // '5' (numpad)
            8'h74   :   ASCII = 8'h36;  // '6' (numpad)
            8'h6C   :   ASCII = 8'h37;  // '7' (numpad)
            8'h75   :   ASCII = 8'h38;  // '8' (numpad)
            8'h7D   :   ASCII = 8'h39;  // '9' (numpad)
            8'h1C   :   ASCII = 8'h41;  // 'A'
            8'h32   :   ASCII = 8'h42;  // 'B'
            8'h21   :   ASCII = 8'h43;  // 'C'
            8'h23   :   ASCII = 8'h44;  // 'D'
            8'h24   :   ASCII = 8'h45;  // 'E'
            8'h2B   :   ASCII = 8'h46;  // 'F'
            8'h34   :   ASCII = 8'h47;  // 'G'
            8'h33   :   ASCII = 8'h48;  // 'H'
            8'h43   :   ASCII = 8'h49;  // 'I'
            8'h3B   :   ASCII = 8'h4A;  // 'J'
            8'h42   :   ASCII = 8'h4B;  // 'K'
            8'h4B   :   ASCII = 8'h4C;  // 'L'
            8'h3A   :   ASCII = 8'h4D;  // 'M'
            8'h31   :   ASCII = 8'h4E;  // 'N'
            8'h44   :   ASCII = 8'h4F;  // 'O'
            8'h4D   :   ASCII = 8'h50;  // 'P'
            8'h15   :   ASCII = 8'h51;  // 'Q'
            8'h2D   :   ASCII = 8'h52;  // 'R'
            8'h1B   :   ASCII = 8'h53;  // 'S'
            8'h2C   :   ASCII = 8'h54;  // 'T'
            8'h3C   :   ASCII = 8'h55;  // 'U'
            8'h2A   :   ASCII = 8'h56;  // 'V'
            8'h1D   :   ASCII = 8'h57;  // 'W'
            8'h22   :   ASCII = 8'h58;  // 'X'
            8'h35   :   ASCII = 8'h59;  // 'Y'
            8'h1A   :   ASCII = 8'h5A;  // 'Z'
            default :   ASCII = 8'h00;
        endcase
    end

endmodule
