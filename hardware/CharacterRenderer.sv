/**
 * Sets the current VGA pixel color based on the current character
 * being drawn.
 *
 * This module generates X and Y coordinates for the current character
 * cell using the curent pixel X and Y coordinates. These cell coordinates
 * are used to fetch a character from the display's character buffer,
 * which is then drawn using pixel information from the font ROM.
 *
 * @author Wes Hampson, Xavier Rocha
 */
module CharacterRenderer
(
    input   logic   [7:0]   CharToRender,
    input   logic   [9:0]   VGA_X, VGA_Y,
    output  logic   [7:0]   CellX, CellY,
    output  logic   [7:0]   VGA_R, VGA_G, VGA_B
);

    // Background color
    parameter   [7:0]   BG_R = 8'h00;
    parameter   [7:0]   BG_G = 8'h00;
    parameter   [7:0]   BG_B = 8'h00;
    
    // Foreground color
    parameter   [7:0]   FG_R = 8'h00;
    parameter   [7:0]   FG_G = 8'hAA;
    parameter   [7:0]   FG_B = 8'h00;
    
    // Width and height in pixels of each cell
    parameter   [9:0]   CELL_WIDTH  = 10'd8;
    parameter   [9:0]   CELL_HEIGHT = 10'd16;
    
    logic       [9:0]   CellX_Offset, CellY_Offset;
    
    logic       [10:0]  FontRowAddress;
    logic       [7:0]   FontRowData;
    
    assign CellX = VGA_X / CELL_WIDTH;
    assign CellY = VGA_Y / CELL_HEIGHT;
    
    assign CellX_Offset = VGA_X % CELL_WIDTH;
    assign CellY_Offset = VGA_Y % CELL_HEIGHT;
    
    assign FontRowAddress = (CharToRender * CELL_HEIGHT) + CellY_Offset;
    
    FontROM font(.Address(FontRowAddress), .Data(FontRowData));
    
    // Color mapper
    always_comb begin
        VGA_R = BG_R;
        VGA_G = BG_G;
        VGA_B = BG_B;
        
        if (FontRowData[CELL_WIDTH - CellX_Offset - 1] == 1'b1) begin
            VGA_R = FG_R;
            VGA_G = FG_G;
            VGA_B = FG_B;
        end
    end

endmodule
