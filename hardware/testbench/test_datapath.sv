/**
 * Datapath testbench.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module test_datapath();

    timeunit 10ns;
    timeprecision 1ns;
    
    // Datapath I/O signals
    logic           Clk, Reset;
    logic   [15:0]  In = 0;                                              // Data from RAM
    logic           LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC; // Register load signals
    logic           GatePC, GateMDR, GateMUL, GateALU, GateMARMUX;       // Bus gates
    logic           ADDR1MUX;                                            // Mux select signals
    logic   [1:0]   ADDR2MUX, PCMUX, DRMUX, SR1MUX;                      // Mux select signals
    logic           SR2MUX, MARMUX;                                      // Mux select signal
    logic   [1:0]   ALUK;                                                // ALU function select signal
    logic           MUL_EN;                                              // Multiplier start signal
    logic           MIO_EN;                                              // RAM operation signals
    logic   [15:0]  Out;                                                 // Data to RAM
    logic   [15:0]  Address;                                             // Current RAM address
    logic           BEN;                                                 // Branch enable signal
    logic           MUL_R;                                               // Multiplier ready signal
    logic           IR_5;                                                // Bit 5 of instruction register
	logic           IR_11;												 // Bit 11 of instruction register
    logic   [3:0]   IR_15_12;                                            // Bits 15-12 of instruction register
    
    // Internal signals
    logic   [15:0]  R0, R1, R2, R3, R4, R5, R6, R7;                      // General purpose registers
    logic   [15:0]  MAR, MDR, IR, PC;                                    // Special registers
    logic   [15:0]  SR1, SR2;                                            // Register file data outputs
    logic   [15:0]  Bus;                                                 // Main data bus
    logic   [15:0]  ALU;                                                 // ALU output
    logic           N, Z, P;                                             // Condition code registers
    
    assign SR2MUX = IR_5;
    
    // Datapath instantiation
    Datapath dp(.*);
    
    always begin : CLOCK_GENERATION
    #1  Clk = ~Clk;
    end
    
    initial begin : CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin : SIGNAL_INITIALIZATION
        In = 0;
        LD_MAR = 0;
        LD_MDR = 0;
        LD_IR = 0;
        LD_BEN = 0;
        LD_REG = 0;
        LD_CC = 0;
        LD_PC = 0;
        GatePC = 0;
        GateMDR = 0;
        GateALU = 0;
        GateMARMUX = 0;
        ADDR1MUX = 0;
        ADDR2MUX = 0;
        PCMUX = 0;
        DRMUX = 0;
        SR1MUX = 0;
        //SR2MUX = 0;
        MARMUX = 0;
        ALUK = 0;
        MIO_EN = 0;
    end
    
    always begin : INTERNAL_MONITORING
    #1  R0 = dp._GenPurposeRegs.R0_Out;
        R1 = dp._GenPurposeRegs.R1_Out;
        R2 = dp._GenPurposeRegs.R2_Out;
        R3 = dp._GenPurposeRegs.R3_Out;
        R4 = dp._GenPurposeRegs.R4_Out;
        R5 = dp._GenPurposeRegs.R5_Out;
        R6 = dp._GenPurposeRegs.R6_Out;
        R7 = dp._GenPurposeRegs.R7_Out;
        MAR = dp.MAR;
        MDR = dp.MDR;
        IR = dp.IR;
        PC = dp.PC;
        SR1 = dp.SR1;
        SR2 = dp.SR2;
        Bus = dp.Bus;
        N = dp.N;
        Z = dp.Z;
        P = dp.P;
    end
    
    initial begin : TEST_VECTORS
        // Initialize
        Reset = 1'b1;
    #2  Reset = 1'b0;
    
        /* ===== Test ADD immediate ===== */
        // Load instruction from "memory" into MDR
        In = 16'b0001_000_000_1_01111;  // ADD R0,R0,#15
        MIO_EN = 1'b1;
        LD_MDR = 1'b1;
    #2  In = 16'd0;
        MIO_EN = 1'b0;
        LD_MDR = 1'b0;
    
        // Move data from MDR onto bus and into IR
        LD_IR = 1'b1;
        GateMDR = 1'b1;
    #2  LD_IR = 1'b0;
        GateMDR = 1'b0;
    
        // Move data from ALU into register file
        DRMUX = 2'b00;
        SR1MUX = 2'b01;
        ALUK = 2'b00;   // ADD
        LD_REG = 1'b1;
        GateALU = 1'b1;
        LD_CC = 1'b1;
    #2  LD_REG = 1'b0;
        GateALU = 1'b0;
        LD_CC = 1'b0;
    
    #2  if (R0 != 16'h000F && !(!N && !Z && P))
            $display("ADD R0,R0,#15 failed!");
    
        /* ===== Test ADD register ===== */
        // Load instruction from "memory" into MDR
        In = 16'b0001_010_000_0_00_000;  // ADD R2,R0,R0
        MIO_EN = 1'b1;
        LD_MDR = 1'b1;
    #2  In = 16'd0;
        MIO_EN = 1'b0;
        LD_MDR = 1'b0;
    
        // Move data from MDR onto bus and into IR
        LD_IR = 1'b1;
        GateMDR = 1'b1;
    #2  LD_IR = 1'b0;
        GateMDR = 1'b0;
    
        // Move data from ALU into register file
        DRMUX = 2'b00;
        SR1MUX = 2'b01;
        ALUK = 2'b00;   // ADD
        LD_REG = 1'b1;
        GateALU = 1'b1;
        LD_CC = 1'b1;
    #2  LD_REG = 1'b0;
        GateALU = 1'b0;
        LD_CC = 1'b0;
    
    #2  if (R2 != 16'h001E && !(!N && !Z && P))
            $display("ADD R2,R0,R0 failed!");
    
        /* ===== Test AND immediate ===== */
        // Load instruction from "memory" into MDR
        In = 16'b0101_000_000_1_00000;  // AND R0,R0,#0
        MIO_EN = 1'b1;
        LD_MDR = 1'b1;
    #2  In = 16'd0;
        MIO_EN = 1'b0;
        LD_MDR = 1'b0;
    
        // Move data from MDR onto bus and into IR
        LD_IR = 1'b1;
        GateMDR = 1'b1;
    #2  LD_IR = 1'b0;
        GateMDR = 1'b0;
    
        // Move data from ALU into register file
        DRMUX = 2'b00;
        SR1MUX = 2'b01;
        ALUK = 2'b01;   // AND
        LD_REG = 1'b1;
        GateALU = 1'b1;
        LD_CC = 1'b1;
    #2  LD_REG = 1'b0;
        GateALU = 1'b0;
        LD_CC = 1'b0;
    
    #2  if (R0 != 16'h0000 && !(!N && Z && !P))
            $display("AND R0,R0,#0 failed!");
    
        /* ===== Test PC Increment ===== */
        LD_PC = 1'b1;
        PCMUX = 2'b00;
    #2  LD_PC = 1'b0;
    
    #2  if (PC != 16'h0001)
            $display("PC increment failed!");
    
        /* ===== Test Base + offset address ===== */
        /* (MAR <- PC + off9) */
        // Load instruction from "memory" into MDR
        In = 16'b1010_000_010000010;    // LDI R0,#130
        MIO_EN = 1'b1;
        LD_MDR = 1'b1;
    #2  In = 16'd0;
        MIO_EN = 1'b0;
        LD_MDR = 1'b0;
    
        // Move data from MDR onto bus and into IR
        LD_IR = 1'b1;
        GateMDR = 1'b1;
    #2  LD_IR = 1'b0;
        GateMDR = 1'b0;
        
        // Resolve address from PC + SEXT(IR[8:0])
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b10;
        MARMUX = 1'b1;
        GateMARMUX = 1'b1;
        LD_MAR = 1'b1;
    #2  GateMARMUX = 1'b0;
        LD_MAR = 1'b0;
    
    #2  if (MAR != 16'h0083)
            $display("PC + off9 failed!");
    
        /* ===== Test Base + offset address (negative offset) ===== */
        /* (MAR <- PC + off9) */
        // Load instruction from "memory" into MDR
        In = 16'b1010_000_111111110;    // LDI R0,#-2
        MIO_EN = 1'b1;
        LD_MDR = 1'b1;
    #2  In = 16'd0;
        MIO_EN = 1'b0;
        LD_MDR = 1'b0;
    
        // Move data from MDR onto bus and into IR
        LD_IR = 1'b1;
        GateMDR = 1'b1;
    #2  LD_IR = 1'b0;
        GateMDR = 1'b0;
        
        // Resolve address from PC + SEXT(IR[8:0])
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b10;
        MARMUX = 1'b1;
        GateMARMUX = 1'b1;
        LD_MAR = 1'b1;
    #2  GateMARMUX = 1'b0;
        LD_MAR = 1'b0;
    
    #2  if (MAR != 16'hFFFF)
            $display("PC + off9 (negative offset) failed!");
    end

endmodule
