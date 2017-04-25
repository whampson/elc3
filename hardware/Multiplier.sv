module Multiplier
(
    input   logic           Clk, Reset,
    input   logic           Run,
    input   logic   [7:0]   A, B,
    output  logic           Ready,
    output  logic   [15:0]  Out
);

    logic   [8:0]   Sum;            // Result of SEXT(A) +- SEXT(MUL) (ADDMUX_Out)
    logic   [8:0]   MUL;            // Output of Multiplicand register
    logic   [7:0]   A_Out, B_Out;   // Output of A and B registers
    logic   [8:0]   A_Out_SEXT;     // Sign-extended output of A register
    logic   [7:0]   AMUX_Out;       // Output of A register input selection MUX
    logic           A0;             // 0th bit of A (shifted out of A and into B)
    logic           X;              // Output of X register (sign extension bit)
    logic           M;              // "Add multiplicand" indicator
    
    // Control signals
    logic           LD_A;           // Load A register
    logic           LD_B;           // Load B register
    logic           LD_MUL;         // Load MUL register
    logic           LD_X;           // Load X register
    logic           CLR_A;          // Clear A register
    logic           SH;             // Register shift enable
    logic           AMUX;           // A register input MUX select bit
    logic           ADDMUX;         // Add/Sub MUX select bit
    
    assign LD_X = M;                // Load X register only when an add is performed
    assign AMUX = M;                // Choose A <- A + MUL when an add is performed, else choose A <- A + 0
    
    assign Out = { A_Out, B_Out };  // Result is bitwise concatenation of A and B
    
    RShiftRegister #(8) _A
    (
        .Clk(Clk),
        .Reset(Reset | CLR_A),  // Ensure that A is zeroed when multiplication begins
        .In(AMUX_Out),
        .Out(A_Out),
        .Load(LD_A),            // Parallel load
        .ShiftIn(X),
        .ShiftOut(A0),
        .ShiftEnable(SH)
    );
    
    RShiftRegister #(8) _B
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(B),
        .Out(B_Out),
        .Load(LD_B),            // Parallel load
        .ShiftIn(A0),
        .ShiftOut(M),
        .ShiftEnable(SH)
    );
    
    Register #(9)       _MUL
    (
        .Clk(Clk),
        .Reset(Reset),
        .In({ {1{A[7]}}, A }),   // Sign extend 1 bit
        .Out(MUL),
        .Load(LD_MUL)
    );
    
    Register #(1)       _X
    (
        .Clk(Clk),
        .Reset(Reset),
        .In(Sum[8]),
        .Out(X),
        .Load(LD_X)
    );
    
    Mux_2to1 #(8)       _AMUX
    (
        .In0(A_Out),
        .In1(Sum[7:0]),
        .Out(AMUX_Out),
        .Select(AMUX)
    );
    
    assign A_Out_SEXT = { {1{A_Out[7]}}, A_Out };   // Sign extend 1 bit
    Mux_2to1 #(9)       _ADDMUX
    (
        .In0(A_Out_SEXT + MUL), // ADD
        .In1(A_Out_SEXT - MUL), // SUB
        .Out(Sum),
        .Select(ADDMUX)
    );
    
    /* ==== State Machine ==== */
    logic   [3:0]   Counter, Counter_Next;
    logic           Done;
    
    enum logic [1:0]
    {
        Wait,
        Load,
        Multiply,
        Halt
    } State, Next_State;
    
    // Update counter and state
    always_ff @(posedge Clk) begin
        if (Reset) begin
            Counter <= 4'h0;
            State <= Wait;
        end
        else begin
            Counter <= Counter_Next;
            State <= Next_State;
        end
    end
    
    // Next state logic
    always_comb begin
        Next_State = State;
        case (State)
            Wait:       Next_State = (Run) ? Load : Wait;
            Load:       Next_State = Multiply;
            Multiply:   Next_State = (Done) ? Halt : Multiply;
            Halt:       Next_State = Wait;
        endcase
    end
    
    // Control signals for each state
    always_comb begin
        CLR_A = 1'b0;
        LD_A = 1'b0;
        LD_B = 1'b0;
        LD_MUL = 1'b0;
        ADDMUX = 1'b0;
        SH = 1'b0;
        Ready = 1'b0;
        Done = 1'b0;
        Counter_Next = Counter;
        
        case (State)
            Load: begin
                CLR_A = 1'b1;
                LD_B = 1'b1;
                LD_MUL = 1'b1;
                Counter_Next = 4'h0;
            end
            
            Multiply: begin
                // Subtract in the 7th add state (14th counter state)
                if (Counter == 4'hE) begin
                    ADDMUX = 1'b1;
                end
                
                // End condition
                if (Counter == 4'hF) begin
                    Done = 1'b1;
                    SH = 1'b1;
                end
                else begin
                    // Increment the counter
                    Counter_Next = Counter + 4'h1;
                    
                    // Add on even cycles, shift on odd cycles
                    if (Counter % 2 == 0)
                        LD_A = 1'b1;
                    else
                        SH = 1'b1;
                end
            end
            
            Halt: begin
                Ready = 1'b1;
            end
        endcase
    end

endmodule
