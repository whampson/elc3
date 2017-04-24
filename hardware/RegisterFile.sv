/**
 * eLC-3 register file. Contains all general purpose registers (R0-R7) and
 * register selection logic.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module RegisterFile
(
    input   logic           Clk, Reset,
    input   logic           LD_REG,             // Register load signal
    input   logic   [2:0]   DR, SR1, SR2,       // Register selection bits (000 is R0, 001 is R1, etc.)
    input   logic   [15:0]  In,                 // Input data
    output  logic   [15:0]  SR1_Out, SR2_Out, R0, R1    // Output of SR1 and SR2
);

    // Internal load, input, and output signals
    logic           R0_Ld,  R1_Ld,  R2_Ld,  R3_Ld,  R4_Ld,  R5_Ld,  R6_Ld,  R7_Ld;
    logic   [15:0]  R0_In,  R1_In,  R2_In,  R3_In,  R4_In,  R5_In,  R6_In,  R7_In;
    logic   [15:0]  R0_Out, R1_Out, R2_Out, R3_Out, R4_Out, R5_Out, R6_Out, R7_Out;
    
    
    assign R0 = R0_Out;
    assign R1 = R1_Out;
    
    // General purpose registers
    Register        _R0(.Clk(Clk), .Reset(Reset), .In(R0_In), .Out(R0_Out), .Load(R0_Ld));
    Register        _R1(.Clk(Clk), .Reset(Reset), .In(R1_In), .Out(R1_Out), .Load(R1_Ld));
    Register        _R2(.Clk(Clk), .Reset(Reset), .In(R2_In), .Out(R2_Out), .Load(R2_Ld));
    Register        _R3(.Clk(Clk), .Reset(Reset), .In(R3_In), .Out(R3_Out), .Load(R3_Ld));
    Register        _R4(.Clk(Clk), .Reset(Reset), .In(R4_In), .Out(R4_Out), .Load(R4_Ld));
    Register        _R5(.Clk(Clk), .Reset(Reset), .In(R5_In), .Out(R5_Out), .Load(R5_Ld));
    Register        _R6(.Clk(Clk), .Reset(Reset), .In(R6_In), .Out(R6_Out), .Load(R6_Ld));
    Register        _R7(.Clk(Clk), .Reset(Reset), .In(R7_In), .Out(R7_Out), .Load(R7_Ld));
    
    // De-multiplexer for selecting destination register data line
    DeMux_1to8      _DRSelect
    (
        .In(In),
        .Out0(R0_In),
        .Out1(R1_In),
        .Out2(R2_In),
        .Out3(R3_In),
        .Out4(R4_In),
        .Out5(R5_In),
        .Out6(R6_In),
        .Out7(R7_In),
        .Select(DR)
    );
    
    // De-multiplexer for selecting destination register load line
    DeMux_1to8 #(1) _LDSelect
    (
        .In(LD_REG),
        .Out0(R0_Ld),
        .Out1(R1_Ld),
        .Out2(R2_Ld),
        .Out3(R3_Ld),
        .Out4(R4_Ld),
        .Out5(R5_Ld),
        .Out6(R6_Ld),
        .Out7(R7_Ld),
        .Select(DR)
    );
    
    // Multiplexer for selecting SR1 output
    Mux_8to1        _SR1_OutMux
    (
        .In0(R0_Out),
        .In1(R1_Out),
        .In2(R2_Out),
        .In3(R3_Out),
        .In4(R4_Out),
        .In5(R5_Out),
        .In6(R6_Out),
        .In7(R7_Out),
        .Out(SR1_Out),
        .Select(SR1)
    );
    
    // Multiplexer for selecting SR2 output
    Mux_8to1        _SR2_OutMux
    (
        .In0(R0_Out),
        .In1(R1_Out),
        .In2(R2_Out),
        .In3(R3_Out),
        .In4(R4_Out),
        .In5(R5_Out),
        .In6(R6_Out),
        .In7(R7_Out),
        .Out(SR2_Out),
        .Select(SR2)
    );

endmodule
