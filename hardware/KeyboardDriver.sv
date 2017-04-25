//-------------------------------------------------------------------------
//      PS2 Keyboard interface                                           --
//      Sai Ma, Marie Liu                                                           --
//      11-13-2014                                                       --
//                                                                       --
//      For use with ECE 385 Final Project                     --
//      ECE Department @ UIUC                                            --
//-------------------------------------------------------------------------
module KeyboardDriver(input logic Clk, psClk, psData, reset,
					 output logic [7:0] keyCode,
					 output logic press);


	logic Q1, Q2, en, enable, shiftout1, shiftout2, Press;
	logic [4:0] Count;
	logic [10:0] Byte_1, Byte_2;
	logic [7:0] Data, Typematic_Keycode;
	logic [9:0] counter;

	//Counter to sync ps2 clock and system clock
	always@(posedge Clk or posedge reset)
	begin
		if(reset)
		begin
			counter = 10'b0000000000;
			enable = 1'b1;
		end
		else if (counter == 10'b0111111111)
		begin
			counter = 10'b0000000000;
			enable = 1'b1;
		end
		else
		begin
			counter += 1'b1;
			enable = 1'b0;
		end
	end

	//edge detector of PS2 clock
	always@(posedge Clk)
	begin
		if(enable==1)
		begin
			if((reset)|| (Count==5'b01011))
				Count <= 5'b00000;
		else if(Q1==0 && Q2==1)
			begin
				Count += 1'b1;
				en = 1'b1;
			end
		end
	end

	always@(posedge Clk)
	begin
		if(Count == 5'd11)
		begin
			// An extended key code will be recieved. This driver does not fully support extended key codes, so these are ignored.
			if (Byte_2[9:2] == 8'hE0)
			begin
				// Do nothing
			end

			// An as-of-yet unknown key will be released.
			else if (Byte_2[9:2] == 8'hF0)
			begin
				// Do nothing
			end

			// A key has been released.
			else if (Byte_1[9:2] == 8'hF0)
			begin
				Data = Byte_2[9:2];
				Press = 1'b0;

				if (Data == Typematic_Keycode)
					Typematic_Keycode = 8'h00;
			end

			// This make code is a repeat.
			else if (Byte_2[9:2] == Typematic_Keycode)
			begin
				// Do nothing
			end

			// A key has been pressed.
			else if (Byte_1[9:2] != 8'hF0)
			begin
				Data = Byte_2[9:2];
				Press = 1'b1;
				Typematic_Keycode = Data;
			end
		end
	end

	Register #(1) Dreg_instance1 ( .*,
								 .Load(enable),
								 .Reset(reset),
								 .In(psClk),
								 .Out(Q1) );
    Register #(1) Dreg_instance2 ( .*,
								 .Load(enable),
								 .Reset(reset),
								 .In(Q1),
								 .Out(Q2) );

	RShiftRegister #(11) reg_B(
					.Clk(psClk),
					.Reset(reset),
					.ShiftIn(psData),
					.Load(1'b0),
					.ShiftEnable(en),
					.In(11'd0),
					.ShiftOut(shiftout2),
					.Out(Byte_2)
					);

	RShiftRegister #(11) reg_A(
					.Clk(psClk),
					.Reset(reset),
					.ShiftIn(shiftout2),
					.Load(1'b0),
					.ShiftEnable(en),
					.In(11'd0),
					.ShiftOut(shiftout1),
					.Out(Byte_1)
					);

	assign keyCode=Data;
	assign press=Press;

endmodule

///**
// * A driver for a PS/2 keyboard.
// *
// * Based on code written by Sai Ma and Marie Liu for use with the ECE 385
// * final project.
// *
// * @author Wes Hampson, Xavier Rocha
// */
//module KeyboardDriver
//(
//    input   logic           Clk, PSClk, Reset,
//    input   logic           PSData,
//    output  logic   [7:0]   Keycode,
//    output  logic           Keypress
//);
//
//    logic           Q1, Q2;
//    logic           Load, ShiftEnable;
//    logic           ShiftOut1, ShiftOut2;
//    logic           Press;
//    logic   [4:0]   Count;
//    logic   [10:0]  Byte1, Byte2;
//    logic   [7:0]   Data, Typematic_Keycode;
//    logic   [9:0]   Counter;
//    
//    // Counter to sync PS/2 clock andd system clock
//    always @(posedge Clk or posedge Reset) begin
//        if (Reset) begin
//           Counter = 10'b0000000000;
//           Load = 1'b1;
//        end
//        else if (Counter == 10'b0111111111) begin
//            Counter = 10'b0000000000;
//            Load = 1'b1;
//        end
//        else begin
//            Counter += 1'b1;
//            Load = 1'b0;
//        end
//    end
//    
//    // Edge detector of PS/2 clock
//    always @(posedge Clk) begin
//        if (Load == 1'b1) begin
//            if (Reset || Count == 5'b01011)
//                Count <= 5'b00000;
//            else if (Q1 == 0 && Q1 == 1) begin
//                Count += 1'b1;
//                ShiftEnable = 1'b1;
//            end
//        end
//    end
//    
//    always @(posedge Clk) begin
//        if (Count == 5'd11) begin
//            // Extended keycode will be received
//            if (Byte2[9:2] == 8'hE0) begin
//                // Do nothing
//            end
//            
//            // An as-of-yet unknown key will be released
//            else if (Byte2[9:2] == 8'hF0) begin
//                // Do nothing
//            end
//            
//            // A key has been released
//            else if (Byte1[9:2] == 8'hF0) begin
//                Data = Byte2[9:2];
//                Press = 1'b0;
//                
//                if (Data == Typematic_Keycode)
//                    Typematic_Keycode = 8'h00;
//            end
//            
//            // This makes a key repeat
//            else if (Byte2[9:2] == Typematic_Keycode) begin
//                // Do nothing
//            end
//            
//            // A key has been pressed
//            else if (Byte1[9:2] != 8'hF0) begin
//                Data = Byte2[9:2];
//                Press = 1'b1;
//                Typematic_Keycode = Data;
//            end
//        end
//    end
//    
//    assign Keypress = Press;
//    assign Keycode = Data;
//    
//    Register #(1)   DReg1
//    (
//        .Clk(Clk),
//        .Reset(Reset),
//        .In(PSClk),
//        .Out(Q1),
//        .Load(Load)
//    );
//    
//    Register #(1)   DReg2
//    (
//        .Clk(Clk),
//        .Reset(Reset),
//        .In(Q1),
//        .Out(Q2),
//        .Load(Load)
//    );
//    
//    RShiftRegister #(11) BReg
//    (
//        .Clk(PSClk),
//        .Reset(Reset),
//        .In(11'd0),
//        .Out(Byte2),
//        .ShiftIn(PSData),
//        .ShiftOut(ShiftOut2),
//        .Load(1'b0),
//        .ShiftEnable(ShiftEnable)
//    );
//    
//    RShiftRegister #(11) AReg
//    (
//        .Clk(PSClk),
//        .Reset(Reset),
//        .In(11'd0),
//        .Out(Byte1),
//        .ShiftIn(ShiftOut2),
//        .ShiftOut(ShiftOut1),
//        .Load(1'b0),
//        .ShiftEnable(ShiftEnable)
//    );
//
//endmodule
