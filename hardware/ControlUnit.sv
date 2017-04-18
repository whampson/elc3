/**
 * Datapath testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 * Control Image : http://i.imgur.com/NNblKM7.png?1
 */
module ControlUnit
(
    input   logic           Clk, Reset, Run,
    input   logic           BEN,
	input	logic			IR_11,
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
			// RUN,
			HALT,
			STEP,

/*FETCH*/	State_18, 
			State_33_nR1, 	// nR : State when data is NOT Ready (Clk cycle 1)
			State_33_nR2,	// 		(Clk cycle 2)
			State_33_R, 	// R  : State when data is Ready and Signals can be set
			State_35, 
/*DECODE*/	State_32, 
/*ADD*/		State_01,
/*AND*/		State_05, 
/*NOT*/		State_09, 
/*TRAP*/	State_15, State_28_nR1, State_28_nR2, State_28_R, State_30, 
	
/*LEA*/		State_14,		// To State 25...
/*LD*/		State_02, 		// To State 25...
/*LDR*/		State_06, 		// To State 25...
/*LDI*/		State_10, State_24_nR1, State_24_nR2, State_24_R, State_26, // To State 25...
			State_25_nR1, State_25_nR2, State_25_R, State_27,
	
/*STI*/		State_11, State_29_nR1, State_29_nR2, State_29_R, State_31, // To State 23...
/*STR*/		State_07, 		// To State 23...
/*ST*/		State_03, 		// To State 23...
			State_23, State_16_nR1, State_16_nR2, State_16_R,
	
/*JSR*/		State_04, State_21, State_20,
/*JMP*/		State_12, 
/*BR*/		State_00, State_22,
/*MULT*/	State_13
	} State, Next_State;
    
    assign Opcode = IR_15_12;
    assign SR2MUX = IR_5;
    
    // State transition
    always_ff @(posedge Clk) begin
        if (Reset)
            State <= HALT;
        else
            State <= Next_State;
    end
    
    // Next state logic
    always_comb begin
        Next_State = State;		// Default NextState is to stay at current State
        unique case (State)
            // RUN :   NextState = HALT;
			
			/* ===== HALT ===== */
            HALT:   begin
                if (Run)
                    Next_State = State_18;
                else
                    Next_State = HALT;
			end
			
			/* ===== FETCH ===== */
            State_18:		Next_State = State_33_nR1;
            State_33_nR1:   Next_State = State_33_nR2;
            State_33_nR2:   Next_State = State_33_R;
            State_33_R:	 	Next_State = State_35;
            State_35:  		Next_State = State_32;
			
			/* ===== DECODE ===== */
			State_32: begin
                case (Opcode)
                    4'b0000:    Next_State = State_00;      // BR
                    4'b0001:    Next_State = State_01;      // ADD/ADDi
					4'b0010:	Next_State = State_02;		// LD
					4'b0011:	Next_State = State_03;		// ST
                    4'b0100:    Next_State = State_04;      // JSR
                    4'b0101:    Next_State = State_05;      // AND/ANDi
                    4'b0110:    Next_State = State_06;      // LDR
                    4'b0111:    Next_State = State_07;      // STR
                    4'b1001:    Next_State = State_09;      // NOT
					4'b1010:	Next_State = State_10;		// LDI
					4'b1011:	Next_State = State_11;		// STI
                    4'b1100:    Next_State = State_12;      // JMP
                    4'b1101:    Next_State = State_13;      // MULT/MULTi
					4'b1110:	Next_State = State_14;		// LEA
					4'b1111:	Next_State = State_15;		// TRAP
                    default:    Next_State = State_18;
                endcase
			end
			
			/* ===== EXECUTE =====*/
            // BR (State 00)
            State_00:       Next_State = (BEN) ? State_22 : State_18;   // If BEN is 1, branch to address, otherwise do nothing
            State_22:       Next_State = State_18;
            
            // ADD/ADDi (State 01)
            State_01:       Next_State = State_18;
			
			// LD (State 02)
			State_02:		Next_State = State_25_nR1;
			State_25_nR1:	Next_State = State_25_nR2;
			State_25_nR2:	Next_State = State_25_R;
			State_25_R:     Next_State = State_27;
			State_27:       Next_State = State_18;
			
			// ST (State 03)
			State_03:		Next_State = State_23;
			State_23:       Next_State = State_16_nR1;
            State_16_nR1:   Next_State = State_16_nR2;
            State_16_nR2:   Next_State = State_16_R;
			State_16_R:     Next_State = State_18;
            
            // JSR (State 04)
            State_04:       Next_State = (IR_11) ? State_21 : State_20; // If LOC (location) is 1, then choose pc + off11 else choose BaseR.
            State_20:       Next_State = State_18;
			State_21:       Next_State = State_18;
            
            // AND/ANDi (State 05)
            State_05:       Next_State = State_18;
			
            // LDR (State 06)
            State_06:       Next_State = State_25_nR1;
            State_25_nR1:   Next_State = State_25_nR2;
            State_25_nR2:   Next_State = State_25_R;
            State_25_R:     Next_State = State_27;
            State_27:       Next_State = State_18;
            
            // STR (State 07)
            State_07:       Next_State = State_23;
            State_23:       Next_State = State_16_nR1;
            State_16_nR1:   Next_State = State_16_nR2;
            State_16_nR2:   Next_State = State_16_R;
            State_16_R:     Next_State = State_18;
            
            // NOT (State 09)
            State_09:       Next_State = State_18;
            
			// LDI (State 10)
			State_10:		Next_State = State_24_nR1;
			State_24_nR1:	Next_State = State_24_nR2;
			State_24_nR2:	Next_State = State_24_R;
			State_24_R:		Next_State = State_26;
			State_26:		Next_State = State_25_nR1;
			State_25_nR1:   Next_State = State_25_nR2;
            State_25_nR2:   Next_State = State_25_R;
            State_25_R:     Next_State = State_27;
            State_27:       Next_State = State_18;
			
			// STI (State 11)
			State_11:		Next_State = State_29_nR1;
			State_29_nR1:	Next_State = State_29_nR2;
			State_29_nR2:	Next_State = State_29_R;
			State_29_R:		Next_State = State_31;
			State_31:		Next_State = State_23;
			State_23:       Next_State = State_16_nR1;
            State_16_nR1:   Next_State = State_16_nR2;
            State_16_nR2:   Next_State = State_16_R;
            State_16_R:     Next_State = State_18;
			
			
            // JMP (State 12)
            State_12:       Next_State = State_18;
            
            // MULT/MULTi (State 13)
            State_13:       Next_State = HALT; // GOTO HALT for now
			
			// LEA (State 14)
			State_14:		Next_State = State_18;
			
			// TRAP (State 15)
			State_15:		Next_State = State_28_nR1;
			State_28_nR1:	Next_State = State_28_nR2;
			State_28_nR2:	Next_State = State_28_R;
			State_28_R:		Next_State = State_30;
			State_30:		Next_State = State_18;
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
            State_18: begin 
                GatePC = 1'b1;      // Allow the contents of PC onto the bus
                LD_MAR = 1'b1;      // Allow MAR to be loaded with the contents of the bus
                PCMUX = 2'b00;      // Get new PC value from PC + 1
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
            
            State_33_nR1:
                MIO_EN = 1'b0;      // Read data from memory at M[MAR] (active-low)
            State_33_nR2:
                MIO_EN = 1'b0;      // Read data from memory at M[MAR] (active-low)
            State_33_R: begin 
                MIO_EN = 1'b0;      // Disable memory read (active-low)
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end
            
            State_35: begin 
                GateMDR = 1'b1;     // Allow contents of MDR onto the bus
                LD_IR = 1'b1;       // Load contents of bus into IR
            end
            
            /* ===== DECODE ===== */
            State_32:
                LD_BEN = 1'b1;      // Allow BEN register to be loaded
            
            /* ===== EXECUTE ===== */
            // BR_1 (PC <- PC + offset9)
            State_22: begin
                ADDR2MUX = 2'b10;   // Read offset9 from SEXT(IR[8:0])
                PCMUX = 2'b10;      // Load PC from address MUXes
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
            
            // ADD (DR <- SR1 + OP2, setCC)
            State_01: begin
                DRMUX = 1'b0;       // Select DR from IR[11:9]
                SR1MUX = 1'b1;      // Select SR1 from IR[8:6]
                ALUK = 2'b00;       // Set ALU to add SR1 and SR2
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            STEP:   ;
            HALT:   ;
        endcase
        
    end

endmodule
