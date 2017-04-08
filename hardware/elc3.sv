/**
 * The eLC-3 toplevel.
 * All main parts of the eLC-3 link togetehr here.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module elc3
(
    // DE2-115 inputs and outputs
    input                   CLOCK_50,
    input           [3:0]   KEY,
    input           [17:0]  SW,
    output  logic   [8:0]   LEDG,
    output  logic   [17:0]  LEDR
);

    // TODO: create the eLC-3!
    
    // 4-bit register test on DE2-115
    Register #(4) test
    (
        .Clk(CLOCK_50),
        .Reset(~KEY[0]),
        .Load(~KEY[3]),
        .Data_In(SW[3:0]),
        .Data_Out(LEDG[3:0])
    );

endmodule
