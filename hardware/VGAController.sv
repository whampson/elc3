/**
 * Generates VGA clock and control signals.
 *
 * @author Wes Hampson, Xavier Rocha 
 */
module VGAController
(
    input   logic           Clk, Reset,
    output  logic           VGA_CLK,
    output  logic           VGA_SYNC_N, VGA_BLANK_N,
    output  logic           VGA_VS, VGA_HS,
    output  logic   [9:0]   VGA_X, VGA_Y
);

    // Total horizontal and vertical pixels
    // (including front and back porches)
    parameter   [9:0]   H_TOTAL = 10'd800;
    parameter   [9:0]   V_TOTAL = 10'd525;
    
    logic           VGA_HS_Next, VGA_VS_Next;
    logic           VGA_BLANK_N_Next;
    logic   [9:0]   VGA_X_Next, VGA_Y_Next;
    
    assign VGA_SYNC_N = 1'b0;
    
    // Generate VGA_CLK
    always_ff @(posedge Clk) begin
        if (Reset)
            VGA_CLK <= 1'b0;
        else
            VGA_CLK <= ~VGA_CLK;
    end
    
    // VGA control signals
    always_ff @(posedge VGA_CLK or posedge Reset) begin
        if (Reset) begin
            VGA_HS <= 1'b0;
            VGA_VS <= 1'b0;
            VGA_BLANK_N <= 1'b0;
            VGA_X <= 10'd0;
            VGA_Y <= 10'd0;
        end
        else begin
            VGA_HS <= VGA_HS_Next;
            VGA_VS <= VGA_VS_Next;
            VGA_BLANK_N <= VGA_BLANK_N_Next;
            VGA_X <= VGA_X_Next;
            VGA_Y <= VGA_Y_Next;
        end
    end
    
    always_comb begin
        VGA_X_Next = VGA_X + 10'd1;
        VGA_Y_Next = VGA_Y;
        
        // Wrap X and Y
        if (VGA_X + 10'd1 == H_TOTAL) begin
            VGA_X_Next = 10'd0;
            if (VGA_Y + 10'd1 == V_TOTAL)
                VGA_Y_Next = 10'd0;
            else
                VGA_Y_Next = VGA_Y + 10'd1;
        end
        
        // Horizontal sync
        VGA_HS_Next = 1'b1;
        if (VGA_X_Next >= 10'd656 && VGA_X_Next < 10'd752)
            VGA_HS_Next = 1'b0;
        
        // Vertical sync
        VGA_VS_Next = 1'b1;
        if (VGA_Y_Next >= 10'd490 && VGA_Y_Next < 10'd492)
            VGA_VS_Next = 1'b0;
        
        // Blanking interval
        VGA_BLANK_N_Next = 1'b0;
        if (VGA_X_Next < 10'd640 && VGA_Y_Next < 10'd480)
            VGA_BLANK_N_Next = 1'b1;
    end

endmodule
