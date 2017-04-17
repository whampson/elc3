/**
 * Datapath testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module ControlUnit
(
    input   logic           Clk, Reset, Run,
    input   logic           BEN,
    input   logic           IR_5,
    input   logic   [3:0]   IR_15_12,
    output  logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC,
    output  logic           GatePC, GateMDR, GateALU, GateMARMUX,
    output  logic           ADDR1MUX,
    output  logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX,
    output  logic           SR2MUX, MARMUX,
    output  logic   [1:0]   ALUK,
    output  logic           MIO_EN, R_W
);

    logic           [3:0]   Opcode;
    enum    logic   [7:0]
    {
        RUN     = 8'd0,
        HALT    = 8'd255
    } State, NextState;
    
    assign Opcode = IR_15_12;
    assign SR2MUX = IR_5;
    
    // State transition
    always_ff @(posedge Clk) begin
        if (Reset)
            State <= HALT;
        else
            State <= NextState;
    end
    
    // Next state logic
    always_comb begin
        NextState = State;
        unique case (State)
            RUN :   NextState = HALT;
            HALT:   begin
                if (Run)
                    NextState = RUN;
                else
                    NextState = HALT;
            end
        endcase
    end
    
    // Control signal output logic
    always_comb begin
        // Default values
        LD_MAR      = 1'b0;
        LD_MDR      = 1'b0;
        LD_IR       = 1'b0;
        LD_BEN      = 1'b0;
        LD_REG      = 1'b0;
        LD_CC       = 1'b0;
        LD_PC       = 1'b0;

        GatePC      = 1'b0;
        GateMDR     = 1'b0;
        GateALU     = 1'b0;
        GateMARMUX  = 1'b0;

        ADDR1MUX    = 1'b0;
        ADDR2MUX    = 2'b00;
        PCMUX       = 2'b00;
        DRMUX       = 2'b00;
        SR1MUX      = 2'b00;
        MARMUX      = 1'b0;
        ALUK        = 2'b00;

        MIO_EN      = 1'b0;
        R_W         = 1'b0;

        unique case (State)
            RUN :   ;
            HALT:   ;
        endcase
        
    end

endmodule
