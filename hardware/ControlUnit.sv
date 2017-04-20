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
   input   logic           IR_11,
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
	
/*FETCH*/   State_18, 
            State_33_nR1,     // nR : State when data is NOT Ready (Clk cycle 1)
            State_33_nR2,     //         (Clk cycle 2)
            State_33_R,       // R  : State when data is Ready and Signals can be set
            State_35, 
/*DECODE*/  State_32, 
/*ADD*/     State_01,
/*AND*/     State_05, 
/*NOT*/     State_09, 
/*TRAP*/    State_15, State_28_nR1, State_28_nR2, State_28_R, State_30, 

/*LEA*/     State_14,         // To State 25...
/*LD*/      State_02,         // To State 25...
/*LDR*/     State_06,         // To State 25...
/*LDI*/     State_10, State_24_nR1, State_24_nR2, State_24_R, State_26, // To State 25...
            State_25_nR1, State_25_nR2, State_25_R, State_27,

/*STI*/     State_11, State_29_nR1, State_29_nR2, State_29_R, State_31, // To State 23...
/*STR*/     State_07,         // To State 23...
/*ST*/      State_03,         // To State 23...
            State_23, State_16_nR1, State_16_nR2, State_16_R,
    
/*JSR*/     State_04, State_21, State_20,
/*JMP*/     State_12, 
/*BR*/      State_00, State_22,
/*MULT*/    State_13
    } State, Next_State;
    
    // ADDED INST: TRAP(9), LEA(14), LD(2), LDI(10), STI(11), ST(3), JSR(4), MULT(13)
    
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
        Next_State = State;        // Default NextState is to stay at current State
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
            State_18:       Next_State = State_33_nR1;
            State_33_nR1:   Next_State = State_33_nR2;
            State_33_nR2:   Next_State = State_33_R;
            State_33_R:     Next_State = State_35;
            State_35:       Next_State = State_32;

			/* ===== DECODE ===== */
			State_32: begin
				case (Opcode)
					4'b0000:    Next_State = State_00;      // BR
					4'b0001:    Next_State = State_01;      // ADD/ADDi
					4'b0010:    Next_State = State_02;      // LD
					4'b0011:    Next_State = State_03;      // ST
					4'b0100:    Next_State = State_04;      // JSR
					4'b0101:    Next_State = State_05;      // AND/ANDi
					4'b0110:    Next_State = State_06;      // LDR
					4'b0111:    Next_State = State_07;      // STR
					4'b1001:    Next_State = State_09;      // NOT
					4'b1010:    Next_State = State_10;      // LDI
					4'b1011:    Next_State = State_11;      // STI
					4'b1100:    Next_State = State_12;      // JMP
					4'b1101:    Next_State = HALT; // Next_State = State_13;      // MULT/MULTi
					4'b1110:    Next_State = State_14;      // LEA
					4'b1111:    Next_State = State_15;      // TRAP
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
			State_02:       Next_State = State_25_nR1;
			State_25_nR1:   Next_State = State_25_nR2;
			State_25_nR2:   Next_State = State_25_R;
			State_25_R:     Next_State = State_27;
			State_27:       Next_State = State_18;
			
			// ST (State 03)
			State_03:       Next_State = State_23;
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
			State_10:       Next_State = State_24_nR1;
			State_24_nR1:   Next_State = State_24_nR2;
			State_24_nR2:   Next_State = State_24_R;
			State_24_R:     Next_State = State_26;
			State_26:       Next_State = State_25_nR1;
			State_25_nR1:   Next_State = State_25_nR2;
			State_25_nR2:   Next_State = State_25_R;
			State_25_R:     Next_State = State_27;
			State_27:       Next_State = State_18;
			
			// STI (State 11)
			State_11:       Next_State = State_29_nR1;
			State_29_nR1:   Next_State = State_29_nR2;
			State_29_nR2:   Next_State = State_29_R;
			State_29_R:     Next_State = State_31;
			State_31:       Next_State = State_23;
			State_23:       Next_State = State_16_nR1;
			State_16_nR1:   Next_State = State_16_nR2;
			State_16_nR2:   Next_State = State_16_R;
			State_16_R:     Next_State = State_18;
			
			
			// JMP (State 12)
			State_12:       Next_State = State_18;
			
			// MULT/MULTi (State 13)
			State_13:       Next_State = HALT; // GOTO HALT for now
			
			// LEA (State 14)
			State_14:        Next_State = State_18;
			
			// TRAP (State 15)
			State_15:        Next_State = State_28_nR1;
			State_28_nR1:    Next_State = State_28_nR2;
			State_28_nR2:    Next_State = State_28_R;
			State_28_R:      Next_State = State_30;
			State_30:        Next_State = State_18;
        
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
            STEP: ;
            /* ===== HALT ===== */
            HALT: ;
            
            /* ===== FETCH ===== */
            State_18: begin 
                GatePC = 1'b1;      // Allow the contents of PC onto the bus
                LD_MAR = 1'b1;      // Allow MAR to be loaded with the contents of the bus
                PCMUX = 2'b00;      // Get new PC value from PC + 1
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
            
            State_33_nR1: begin
				MIO_EN = 1'b1;      // Read data from memory at M[MAR]
			end	
            State_33_nR2: begin
				MIO_EN = 1'b1;      // Read data from memory at M[MAR] 
			end
            State_33_R: begin 
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end
            
            State_35: begin 
                GateMDR = 1'b1;     // Allow contents of MDR onto the bus
                LD_IR = 1'b1;       // Load contents of bus into IR
            end
            
            /* ===== DECODE ===== */
            State_32:   LD_BEN = 1'b1;      // Allow BEN register to be loaded
            
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
                // SR2MUX = IR_5;      // Allow SR2 to be selected based on IR[5]
                ALUK = 2'b00;       // Set ALU to add SR1 and SR2
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            // JSR_1 (R7 <- PC)
            State_04: begin
                DRMUX = 1'b1;       // Set DR to R7
                GatePC = 1'b1;      // Allow PC onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
            end
        
            // JSR_IR[11] == 1 (PC <- PC + offset11)
            State_21: begin
                ADDR2MUX = 2'b01;   // Read offset11 from SEXT(IR[10:0])
                PCMUX = 2'b10;      // Read PC next value from address MUXes
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
			 
                
            // AND (DR <- SR1 AND OP2, setCC)
            State_05: begin
                DRMUX = 1'b0;       // Select DR from IR[11:9]
                SR1MUX = 1'b1;      // Select SR1 from IR[8:6]
                // SR2MUX = IR_5;      // Allow SR2 to be selected based on IR[5]
                ALUK = 2'b01;       // Set ALU to AND SR1 and SR2
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            // LDR_1 (MAR <- BaseR + offset6)
            State_06: begin    
                SR1MUX = 1'b1;      // Select BaseR from IR[8:6]
                ADDR1MUX = 1'b1;    // Read base address from BaseR
                ADDR2MUX = 2'b01;   // Read offset6 from SEXT(IR[5:0])
                GateMARMUX = 1'b1;  // Allow absolute address onto the bus
                LD_MAR = 1'b1;      // Allow contents of bus to be loaded into MAR
            end
            
            // LDR_2 (MDR <- M[MAR])
            State_25_nR1: begin
                MIO_EN = 1'b1;      // Read data from memory at M[MAR] 
            end
            State_25_nR2: begin
				MIO_EN = 1'b1;   	// Read data from memory at M[MAR] 
			end
            State_25_R: begin
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end	
            
            // LDR_3 (DR <- MDR, setCC)
            State_27: begin
                DRMUX = 1'b0;       // Select DR from IR[11:9]
                GateMDR = 1'b1;     // Allow contents of MDR onto the bus
                LD_REG = 1'b1;      // Load DR from contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            // STR_1 (MAR <- BaseR + offset6)
            State_07: begin
                SR1MUX = 1'b1;      // Select BaseR from IR[8:6]
                ADDR1MUX = 1'b1;    // Read base address from BaseR
                ADDR2MUX = 2'b01;   // Read offset6 from SEXT(IR[5:0])
                GateMARMUX = 1'b1;  // Allow absolute address onto the bus
                LD_MAR = 1'b1;      // Allow contents of bus to be loaded into MAR
            end
            
            // STR_2 (MDR <- SR)
            State_23: begin
                SR1MUX = 1'b0;      // Select SR from IR[11:9]
                ALUK = 2'b11;       // Allow SR to pass through the ALU
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_MDR = 1'b1;      // Allow contents of bus to be loaded into MDR
            end
            
            // STR_3 (M[MAR] <- MDR)
            State_16_nR1: begin
				MIO_EN = 1'b1;      // Write MDR to memory at M[MAR]
				R_W = 1'b1;
			end
            State_16_nR2: begin
				MIO_EN = 1'b1;      // Write MDR to memory at M[MAR] 
				R_W = 1'b1;
			end
            State_16_R: begin
				MIO_EN = 1'b0;      // Disable memory write 
            end
			
            // NOT (DR <- NOT(SR), setCC)
            State_09: begin
                DRMUX = 2'b00;      // Select DR from IR[11:9] (fixed from 1 bit to 2)
                SR1MUX = 1'b1;      // Select SR from IR[8:6]
                ALUK = 2'b10;       // Set ALU to negate SR
                GateALU = 1'b1;     // Allow ALU output onto the bus
                LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
            
            // JMP (PC <- BaseR)
            State_12: begin
                SR1MUX = 1'b1;      // Select BaseR from IR[8:6]
                ALUK = 2'b11;       // Allow contents of BaseR to pass theough the ALU
                GateALU = 1'b1;
                PCMUX = 2'b01;      // Read PC next value from contents of the bus
                LD_PC = 1'b1;       // Allow PC to be overwritten
            end
        
            /* NEWLY ADDED FOR FINAL PROJECT */
            // TO ADD LIST : TRAP(9)#done, LEA(14)#done, LD(2)#done, LDI(10)#done, STI(11)#done, ST(3)#done, JSR(4)#done, MULT(13)#done
			// TO TEST LIST: TRAP(9), LEA(14), LD(2), LDI(10), STI(11), ST(3), JSR(4), MULT(13)
            
            // MULT
            State_13: begin
                /* Do Nothing */;
            end
            
            // JSR_1 (MAR <- ZEXT(IR[7:0]))
            State_15: begin
                MARMUX = 1'b0;		// Have MAR become IR[7:0]
                GateMARMUX = 1'b1;	// Put the ZEXT(IR[7:0]) onto the bus
                LD_MAR = 1'b1;		// Load the value currently on the bus to MAR
            end
            
            // JSR_2 (MDR <- M[MAR], R7 <- PC)
            State_28_nR2: begin
				MIO_EN = 1'b1;    // Write MDR to memory at M[MAR] 
				R_W = 1'b1;
			end
			State_28_nR1: begin
				MIO_EN = 1'b1;    // Write MDR to memory at M[MAR]
				R_W = 1'b1;
			end
			State_28_R: begin 
				/* Instruction 1 (MDR <- M[MAR]) */
                MIO_EN = 1'b1;      // Disable memory write (Default behavior)
				LD_MAR = 1'b1;		// Load MDR with M[MAR]
				/* Instruction 2 (R7 <- PC) */
                GatePC = 1'b1;      // Allow PC to output to the bus
                LD_REG = 1'b1;      // Allow the Register File to be loaded
                DRMUX = 2'b01;      // Allow the PC to be stored in R7
            end
            
            // JSR_3 (PC <- MDR)
            State_30: begin
                GateMDR = 1'b1;		// Allows MDR to be put on the bus
				PCMUX = 2'b01;		// Opens PC to read from the bus
				LD_PC = 1'b1;		// Loads PC with the value currently on the bus
            end
            
            // LEA
            State_14: begin
                ADDR2MUX = 2'b10;   // Read offset9 from SEXT(IR[8:0])
				MARMUX = 1'b1;		// Set MARMUX to to read PC + offset9
				GateMARMUX = 1'b1;	// Allow MARMUX contents to go on the bus
                DRMUX = 2'b00;      // Select DR from IR[11:9] (Default behavior)
				LD_REG = 1'b1;      // Allow DR to be loaded with contents of bus
                LD_CC = 1'b1;       // Set condition codes (NZP) based on contents of bus
            end
			
			// LD (MAR <- PC + offset9)
			State_02: begin
				ADDR2MUX = 2'b10;
				MARMUX = 1'b1;
				GateMARMUX = 1'b1;
				LD_MAR = 1'b1;
			end
			
			// LDI_1 (MAR <- PC + offset9)
			State_10: begin
				ADDR2MUX = 2'b10;
				MARMUX = 1'b1;
				GateMARMUX = 1'b1;
				LD_MAR = 1'b1;
			end
			
			// LDI_2 (MDR <- M[MAR]) 
            State_24_nR1: begin
                MIO_EN = 1'b1;      // Read data from memory at M[MAR] 
            end
            State_24_nR2: begin
				MIO_EN = 1'b1;  	// Read data from memory at M[MAR] .
			end
            State_24_R: begin
                MIO_EN = 1'b1;      // Read data from memory at M[MAR]
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end 
			
			// LDI_3 (MAR <- MDR)
			State_26: begin
				GateMDR = 1'b1;		// Put data from MDR to the bus
				LD_MAR = 1'b1;		// Load MAR with contents from the bus (MDR)
			end
			
			// STI_1 (MAR <- PC + offset9)
			State_11: begin
				ADDR2MUX = 2'b10;
				MARMUX = 1'b1;
				GateMARMUX = 1'b1;
				LD_MAR = 1'b1;
			end
			
			// STI_2 (MDR <- M[MAR])
			State_29_nR1: begin
                MIO_EN = 1'b1;      // Read data from memory at M[MAR] 
                R_W = 1'b1;			// Read enable
            end
            State_29_nR2: begin
				MIO_EN = 1'b1;  	// Read data from memory at M[MAR] 
				R_W = 1'b1;			// Read enable
			end
            State_29_R: begin
                MIO_EN = 1'b1;      // Disable memory read (Defualt behavior)
                LD_MDR = 1'b1;      // Allow MDR to be loaded with data from memory
            end 
			
			// STI_3 (MAR <- MDR)
			State_31: begin
				GateMDR = 1'b1;		// Put data from MDR to the bus
				LD_MAR = 1'b1;		// Load MAR with contents from the bus (MDR)	
			end
			
			// ST (MAR <- PC + offset9)
			State_03: begin
				ADDR2MUX = 2'b10;
				MARMUX = 1'b1;
				GateMARMUX = 1'b1;
				LD_MAR = 1'b1;
			end
			
			// JSR_IR[11] == 0 (PC <- BaseR) The rest of JSR is above from previous iteration
			State_20: begin
				SR1MUX = 1'b1;      // Select BaseR from IR[8:6]
                ALUK = 2'b11;       // Allow contents of BaseR to pass theough the ALU
                GateALU = 1'b1;
                PCMUX = 2'b01;      // Read PC next value from contents of the bus
                LD_PC = 1'b1;       // Allow PC to be overwritten
			end
			
            default: /* Do Nothing */ ;
            
        endcase
        
    end

endmodule
