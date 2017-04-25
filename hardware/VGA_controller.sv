module VGA_controller
(
	input 			Clk,			// 50 MHz clock
					Reset,			// Reset signal.
	output logic	VGA_HS,			// Horizontal sync pulse. (Active low)
					VGA_VS,			// Vertical sync pulse. (Active low)
					VGA_CLK,		// 25 MHz VGA clock output
					VGA_BLANK_N,	// Blanking interval indicator (Active low)
					VGA_SYNC_N,		// Composite Sync signal (unused but needed to compile)
					
	output logic [9:0]	X, Y 		// H and V coordinates
);

parameter [9:0] H_TOTAL = 10'd800;
parameter [9:0] V_TOTAL = 10'd525;

logic 		VGA_HA_in, VGA_VS_in, VGA_BLANK_N_in;
logic [9:0]	h_counter, v_counter;
logic [9:0]	h_counter_in, v_counter_in;

assign	VGA_SYNC_N = 1'b0;
assign	X = h_counter;
assign 	Y = v_counter;

    // Generate VGA_CLK
    always_ff @ (posedge Clk) begin
        if (Reset) begin
            VGA_CLK <= 1'b0;
		end
        else begin
            VGA_CLK <= ~VGA_CLK;
		end
    end

	always_ff @ (posedge VGA_CLK or posedge Reset) begin
		if (Reset) begin
			VGA_HS <= 1'b0;
			VGA_VS <= 1'b0;
			VGA_BLANK_N <= 1'b0;
			h_counter <= 1'b0;
			v_counter <= 1'b0;
		end 
		else begin
			VGA_HS <= VGA_HS_in;
			VGA_VS <= VGA_VS_in;
			VGA_BLANK_N <= VGA_BLANK_N_in;
			h_counter <= h_counter_in;
			v_counter <= v_counter_in;
		end
	end
	
	always_comb begin 
	
		h_counter_in = h_counter + 10'd1;			// Count horizontal
		v_counter_in = v_counter;
		
		if (h_counter + 10'd1 == H_TOTAL) begin		// Check H limits
			h_counter_in = 10'd0;
			
			if (v_counter + 10'd1 == V_TOTAL)		// Check V limits
				v_counter_in = 10'd0;
			else 
				v_counter_in = v_counter + 10'd1;	// Count vertical
			end
			
		end
		
		VGA_HS_in = 1'b1;			// H-Sync pulse
		if(h_counter_in >= 10'd656 && h_counter_in < 10'd752)
			VGA_HS_in = 1'b0;
		
        VGA_VS_in = 1'b1;			// V-Sync pulse
        if(v_counter_in >= 10'd490 && v_counter_in < 10'd492)
            VGA_VS_in = 1'b0;
		
        VGA_BLANK_N_in = 1'b0;		// Display pixels
        if(h_counter_in < 10'd640 && v_counter_in < 10'd480)
            VGA_BLANK_N_in = 1'b1;
		
	end
	
endmodule
