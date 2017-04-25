module FrameGenerator
(
	Clk,
	toVGA
);

// The counter will become the address of the each pixel in the frame buffer.
// Count up until all of the memory addresses have been filled with
// the current frame.

enum logic
{
	WRITE,
	DONE	
} state, next_state;

logic [18:0] counter, counter_in;


always_ff @ (posedge Clk) begin
	state <= next_state;
	counter <= counter_in;
end

always_comb begin
	next_state = state;
	
	unique case (state)
		
		WRITE : begin
			if (counter == 19'd307200)
				next_state = DONE;
		end
		
		DONE : begin
			
		end
		
	endcase
	
	unique case (state)
	
		WRTIE : begin
			counter_in = counter + 19'd1;
		end
	
	endcase
	
end

endmodule

