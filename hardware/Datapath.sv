/**
 * The eLC-3 datapath.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module Datapath
(
    input   logic           Clk, Reset,
    input   logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC, // Register load signals
    input   logic           GatePC, GateMDR, GateALU, GateMARMUX,                // Bus gates
    input   logic           ADDR1MUX,                                            // Mux select signals
    input   logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX, MARMUX,              // Mux select signals
    input   logic   [1:0]   ALUK,                                                // ALU function select signal
    input   logic           MIO_EN, R_W                                          // RAM operation signals
);

    logic   [15:0]  MAR, MDR, IR, PC;
    logic   [15:0]  MAR_In, MDR_In, IR_In, PC_In;
    logic   [2:0]   SR1MUX_Out, SR2MUX_Out, DRMUX_Out;
    logic   [15:0]  MARMUX_Out, MDRMUX_Out, PCMUX_Out, ADDR1MUX_Out, ADDR2MUX_Out;
    logic   [15:0]  ALU;
    logic   [15:0]  SR1, SR2;
    logic   [15:0]  Bus;
    logic           N, Z, P;
    
    Register        _MAR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(MAR_In),
        .Out(MAR),
        .Load(LD_MAR)
    );
    
    Register        _MDR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(MDR_In),
        .Out(MDR),
        .Load(LD_MDR)
    );
    
    Register        _IR
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(IR_In),
        .Out(IR),
        .Load(LD_IR)
    );
    
    Register        _PC
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(PC_In),
        .Out(PC),
        .Load(LD_PC)
    );
    
    RegisterFile    _GenPurposeRegs
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Bus),
        .LD_REG(LD_REG),
        .DR(DRMUX_Out),
        .SR1(SR1MUX_Out),
        .SR2(IR[2:0]),
        .SR1_Out(SR1),
        .SR2_Out(SR2)
    );
    
    Mux_4to1 #(3)   _DRMUX
    (
        .In0(IR[11:9]),
        .In1(3'b111),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(DRMUX_Out),
        .Select(DRMUX)
    );
    
    Mux_4to1 #(3)   _SR1MUX
    (
        .In0(IR[11:9]),
        .In1(IR[8:6]),
        .In2(3'b110),
        .In3(3'bZZZ),   // Unused
        .Out(SR1MUX_Out),
        .Select(SR1MUX)
    );

endmodule
