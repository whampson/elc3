/**
 * Datapath testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 * Control Image : http://i.imgur.com/NNblKM7.png?1
 */
module ControlUnit
(
    input   logic           Clk, Reset, Run, Continue,
    input   logic           BEN,
    input   logic           IR_5,
    input   logic           IR_11,
    input   logic   [3:0]   IR_15_12,
    output  logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC,
    output  logic           GatePC, GateMDR, GateALU, GateMARMUX,
    output  logic           ADDR1MUX,
    output  logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX,
    output  logic           SR2MUX, MARMUX,
    output  logic   [1:0]   ALUK,
    output  logic           MIO_EN, R_W,
    output  logic           Halted, Paused, Invalid,
    output  logic   [3:0]   Opcode
);

    //logic           [3:0]   Opcode;
    
    assign Opcode = IR_15_12;
    assign SR2MUX = IR_5;
    
    /* ===== Valid states ===== */
    enum logic [7:0]
    {
        // TODO: MUL states
        State_00        = 8'd0,
        State_01        = 8'd1,
        State_02        = 8'd2,
        State_03        = 8'd3,
        State_04        = 8'd4,
        State_05        = 8'd5,
        State_06        = 8'd6,
        State_07        = 8'd7,
        //State_08        = 8'd8,
        State_09        = 8'd9,
        State_10        = 8'd10,
        State_11        = 8'd11,
        State_12        = 8'd12,
        State_13        = 8'd13,
        State_14        = 8'd14,
        State_15        = 8'd15,
        State_16_nR1    = 8'd016,   // nR: State when data from memory is NOT ready
        State_16_nR2    = 8'd116,
        State_16_R      = 8'd216,   //  R: State when data from memory is ready
        //State_17        = 8'd17,
        State_18        = 8'd18,
        //State_19        = 8'd19,
        State_20        = 8'd20,
        State_21        = 8'd21,
        State_22        = 8'd22,
        State_23        = 8'd23,
        State_24_nR1    = 8'd024,
        State_24_nR2    = 8'd124,
        State_24_R      = 8'd224,
        State_25_nR1    = 8'd025,
        State_25_nR2    = 8'd125,
        State_25_R      = 8'd225,
        State_26        = 8'd26,
        State_27        = 8'd27,
        State_28_nR1    = 8'd028,
        State_28_nR2    = 8'd128,
        State_28_R      = 8'd228,
        State_29_nR1    = 8'd029,
        State_29_nR2    = 8'd129,
        State_29_R      = 8'd229,
        State_30        = 8'd30,
        State_31        = 8'd31,
        State_32        = 8'd32,
        State_33_nR1    = 8'd033,
        State_33_nR2    = 8'd133,
        State_33_R      = 8'd233,
        //State_34        = 8'd34,
        State_35        = 8'd35,
        
        INVALID         = 8'd254,
        HALT            = 8'd255
    } State, Next_State;
    
    /* ===== State transition ===== */
    always_ff @(posedge Clk) begin
        if (Reset)
            State <= HALT;
        else
            State <= Next_State;
    end
    
    /* ===== Next state logic ===== */
    always_comb begin
        Next_State = State;     // Default next state is to stay at current State
        
        unique case (State)
            /* ===== FETCH ===== */
            State_18:       Next_State = State_33_nR1;
            State_33_nR1:   Next_State = State_33_nR2;
            State_33_nR2:   Next_State = State_33_R;
            State_33_R:     Next_State = State_35;
            State_35: begin
                // Uncomment for debugging on FPGA
                //if (Continue)
                    Next_State = State_32;
                //else
                //    Next_State = State_35;
            end
            
            /* ===== DECODE ===== */
            State_32: begin
                // Uncomment for debugging on FPGA
                //if (~Continue) begin
                    case (Opcode)
                        4'b0000:    Next_State = State_00;      // BR
                        4'b0001:    Next_State = State_01;      // ADD
                        4'b0010:    Next_State = State_02;      // LD
                        4'b0011:    Next_State = State_03;      // ST
                        4'b0100:    Next_State = State_04;      // JSR
                        4'b0101:    Next_State = State_05;      // AND
                        4'b0110:    Next_State = State_06;      // LDR
                        4'b0111:    Next_State = State_07;      // STR
                        4'b1001:    Next_State = State_09;      // NOT
                        4'b1010:    Next_State = State_10;      // LDI
                        4'b1011:    Next_State = State_11;      // STI
                        4'b1100:    Next_State = State_12;      // JMP
                        4'b1101:    Next_State = State_13;      // MUL
                        4'b1110:    Next_State = State_14;      // LEA
                        4'b1111:    Next_State = State_15;      // TRAP
                        default:    Next_State = INVALID;       // (invalid opcode)
                    endcase
                //end
                //else
                //    Next_State = State_32;
            end
            
            /* ===== EXECUTE =====*/
            // BR
            State_00:       Next_State = (BEN) ? State_22 : State_18;   // If BEN is 1, branch to address, continue otherwise
            State_22:       Next_State = State_18;
            
            // ADD
            State_01:       Next_State = State_18;
            
            // LD
            State_02:       Next_State = State_25_nR1;
            
            // ST
            State_03:       Next_State = State_23;
            
            // JSR
            State_04:       Next_State = (IR_11) ? State_21 : State_20; // If IR[11] is 1, use PC + off11, otherwise use BaseR.
            State_20:       Next_State = State_18;
            State_21:       Next_State = State_18;
            
            // AND
            State_05:       Next_State = State_18;
            
            // LDR
            State_06:       Next_State = State_25_nR1;
            
            // STR
            State_07:       Next_State = State_23;
            
            // NOT
            State_09:       Next_State = State_18;
            
            // LDI
            State_10:       Next_State = State_24_nR1;
            State_24_nR1:   Next_State = State_24_nR2;
            State_24_nR2:   Next_State = State_24_R;
            State_24_R:     Next_State = State_26;
            State_26:       Next_State = State_25_nR1;
            
            // STI
            State_11:       Next_State = State_29_nR1;
            State_29_nR1:   Next_State = State_29_nR2;
            State_29_nR2:   Next_State = State_29_R;
            State_29_R:     Next_State = State_31;
            State_31:       Next_State = State_23;
            
            // JMP
            State_12:       Next_State = State_18;
            
            // MUL
            // TODO: states
            State_13:       Next_State = HALT;  // Go to HALT for now
            
            // LEA
            State_14:       Next_State = State_18;
            
            // TRAP
            State_15:       Next_State = State_28_nR1;
            State_28_nR1:   Next_State = State_28_nR2;
            State_28_nR2:   Next_State = State_28_R;
            State_28_R:     Next_State = State_30;
            State_30:       Next_State = State_18;
            
            // ST/STR/STI (memory write)
            State_23:       Next_State = State_16_nR1;
            State_16_nR1:   Next_State = State_16_nR2;
            State_16_nR2:   Next_State = State_16_R;
            State_16_R:     Next_State = State_18;
            
            // LD/LDR/LDI (memory read)
            State_25_nR1:   Next_State = State_25_nR2;
            State_25_nR2:   Next_State = State_25_R;
            State_25_R:     Next_State = State_27;
            State_27:       Next_State = State_18;
            
            /* ===== INVALID (invalid opcode) ===== */
            INVALID: begin
                // Pause to alert user
                if (Continue)
                    Next_State = HALT;
                else
                    Next_State = INVALID;
            end
            
            /* ===== HALT (end execution) ===== */
            HALT: begin
                if (Run)
                    Next_State = State_18;
                else
                    Next_State = HALT;
            end
        endcase
    end
    
    /* ===== Control signal output logic ===== */
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
        
        Halted      = 1'b0;
        Paused      = 1'b0;
        Invalid     = 1'b0;

        unique case (State)
            /* ===== FETCH ===== */
            // MAR <- PC; PC <- PC + 1
            State_18: begin 
                GatePC = 1'b1;      // Allow the contents of PC onto the bus
                LD_MAR = 1'b1;      // Allow MAR to be loaded with the contents of the bus
                PCMUX = 2'b00;      // Get new PC value from PC + 1
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
            // MDR <- M[MAR]
            State_33_nR1:
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
            State_33_nR2:
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
            State_33_R: begin 
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end
            // IR <- MDR
            State_35: begin 
                GateMDR = 1'b1;     // Allow contents of MDR onto the bus
                LD_IR = 1'b1;       // Load contents of bus into IR
                Paused = 1'b1;
            end
            
            /* ===== DECODE ===== */
            // BEN <- IR[11] & N + IR[10] & Z + IR[9] & P; [IR[15:12]]
            State_32:
                LD_BEN = 1'b1;      // Allow BEN register to be loaded
            
            /* ===== EXECUTE ===== */
            /* -- ADD -- */
            // DR <- SR1 + OP2, setCC
            State_01: begin
                DRMUX = 2'b00;      // Select DR from IR[11:9]
                SR1MUX = 2'b01;     // Select SR1 from IR[8:6]
                ALUK = 2'b00;       // Set ALU to add SR1 and SR2
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            /* -- LD -- */
            // MAR <- PC + off9
            State_02: begin
                ADDR1MUX = 1'b0;
                ADDR2MUX = 2'b10;
                MARMUX = 1'b1;
                GateMARMUX = 1'b1;
                LD_MAR = 1'b1;
            end
            
            /* -- STR -- */
            // MAR <- BaseR + off6
            State_07: begin
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                ADDR2MUX = 2'b01;
                MARMUX = 1'b1;
                GateMARMUX = 1'b1;
                LD_MAR = 1'b1;
            end
            
            /* -- LDI -- */
            // MAR <- PC + off9
            State_10: begin
                ADDR1MUX = 1'b0;
                ADDR2MUX = 2'b10;
                MARMUX = 1'b1;
                GateMARMUX = 1'b1;
                LD_MAR = 1'b1;
            end
            // MDR <- M[MAR]
            State_24_nR1: begin
                MIO_EN = 1'b1;
            end
            State_24_nR2: begin
                MIO_EN = 1'b1;
            end
            State_24_R: begin
                MIO_EN = 1'b1;
                LD_MDR = 1'b1;
            end
            // MAR <- MDR
            State_26: begin
                LD_MAR = 1'b1;
                GateMDR = 1'b1;
            end
            
            /* -- ST/STR/STI -- */
            // MDR <- SR
            State_23: begin
                SR1MUX = 2'b00;
                ALUK = 2'b11;
                LD_MDR = 1'b1;
                GateALU = 1'b1;
            end
            // M[MAR] <- MDR
            State_16_nR1: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
            end
            State_16_nR2: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
            end
            State_16_R: begin
                MIO_EN = 1'b0;
                R_W = 1'b0;
            end
            
            /* -- LD/LDR/LDI -- */
            // MDR <- M[MAR]
            State_25_nR1: begin
                MIO_EN = 1'b1;
            end
            State_25_nR2: begin
                MIO_EN = 1'b1;
            end
            State_25_R: begin
                MIO_EN = 1'b1;
                LD_MDR = 1'b1;
            end
            // DR <- MDR; setCC
            State_27: begin
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GateMDR = 1'b1;
            end
            
            INVALID:
                Invalid = 1'b1;
            
            HALT:
                Halted = 1'b1;
        endcase
    end

endmodule
