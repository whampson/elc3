/**
 * The eLC-3 display driver.
 *
 * This module is responsible for placing characters on the screen.
 * A cursor blinks on the screen at the location of the next character
 * to be inserted.
 *
 * TODO:
 *  - Screen scrolling
 */
module DisplayDriver
(
    input   logic           Clk, Reset,
    input   logic           CharWE,
    input   logic           AddressWE,
    input   logic   [7:0]   CharIn,
    input   logic   [11:0]  AddressIn,
    output  logic           Ready,
    output  logic           VGA_CLK,
    output  logic           VGA_SYNC_N, VGA_BLANK_N,
    output  logic           VGA_VS, VGA_HS,
    output  logic   [7:0]   VGA_R, VGA_G, VGA_B
);

    parameter   [7:0]   NUM_CELLS_X = 8'd80;
    parameter   [7:0]   NUM_CELLS_Y = 8'd30;
    parameter   [15:0]  BUFFER_SIZE = NUM_CELLS_X * NUM_CELLS_Y;
    
    parameter   [7:0]   CHAR_NUL    = 8'h00;    // NUL
    parameter   [7:0]   CHAR_BS     = 8'h08;    // Backspace
    parameter   [7:0]   CHAR_LF     = 8'h0A;    // Linefeed
    parameter   [7:0]   CHAR_CURSOR = 8'h5F;    // '_'

    logic       [9:0]   VGA_X, VGA_Y;
    logic       [7:0]   CellX, CellY;
    
    logic       [7:0]   CharToRender;
    logic       [11:0]  ReadAddress;
    
    logic               WriteEnable;
    logic       [7:0]   CharToWrite;
    logic       [11:0]  WriteAddress, WriteAddress_Next;
    
    logic               ResetDone;
    
    logic               CursorOn, CursorOn_Next;
    logic       [23:0]  CursorCounter, CursorCounter_Next;
    
    // Address of current character being drawn
    assign ReadAddress = (CellY * NUM_CELLS_X) + CellX;
    
    enum logic [2:0]
    {
        RESET_INIT,
        RESET_DO,
        DRAW,
        BACKSPACE,
        OTHER_CHARS
    } State, NextState;
    
    always_ff @(posedge Clk) begin
        if (Reset) begin
            WriteAddress <= 12'h000;
            CursorCounter <= 24'd0;
            CursorOn <= 1'b0;
            State <= RESET_INIT;
        end
        else begin
            WriteAddress <= WriteAddress_Next;
            CursorCounter <= CursorCounter_Next;
            CursorOn <= CursorOn_Next;
            State <= NextState;
        end
    end
    
    // Next state logic
    always_comb begin
        NextState = State;
        
        case (State)
            RESET_INIT: begin
                NextState = RESET_DO;
            end
            
            RESET_DO: begin
                if (ResetDone)
                    NextState = DRAW;
                else
                    NextState = RESET_DO;
            end
            
            DRAW: begin
                if (CharWE) begin
                    if (CharIn == CHAR_BS)
                        NextState = BACKSPACE;
                    else
                        NextState = OTHER_CHARS;
                end
                else
                    NextState = DRAW;
            end
            
            BACKSPACE: begin
                NextState = DRAW;
            end
            
            OTHER_CHARS: begin
                NextState = DRAW;
            end
        endcase
    end
    
    always_comb begin
        Ready = 1'b0;
        ResetDone = 1'b0;
        CharToWrite = CharIn;
        WriteEnable = CharWE;
        
        WriteAddress_Next = WriteAddress;
        CursorCounter_Next = CursorCounter;
        CursorOn_Next = CursorOn;
        
        case (State)
            RESET_INIT: begin
                // Reset write addres to 0
                WriteAddress_Next = 12'h0000;
            end
            
            RESET_DO: begin
                // Fill all cells with NUL
                WriteAddress_Next = WriteAddress + 12'h001;
                CharToWrite = CHAR_NUL;
                WriteEnable = 1'b1;
                
                if (WriteAddress_Next >= BUFFER_SIZE) begin
                    // Reset write address to 0
                    WriteAddress_Next = 12'h0000;
                    ResetDone = 1'b1;
                end
            end
            
            DRAW: begin
                CursorCounter_Next = CursorCounter + 24'd1;
                Ready = 1'b1;
                
                if (CharWE) begin
                    CursorCounter_Next = -24'd1;
                    CursorOn_Next = 1'b1;
                    // Draw a character on the screen
                    case (CharIn)
                        // Backspace
                        CHAR_BS: begin
                            // Write NUL at the current address
                            CharToWrite = CHAR_NUL;
                            
                            // Move back a cell
                            WriteAddress_Next = WriteAddress - 12'h001;
                            
                            // Disable ready because we move into BACKSPACE state
                            Ready = 1'b0;
                        end
                        
                        // Linefeed
                        8'h0A: begin
                            // Write NUL at the current address
                            CharToWrite = CHAR_NUL;
                            
                            // Move down a row and back to the first column
                            WriteAddress_Next = WriteAddress + (NUM_CELLS_X - (WriteAddress % NUM_CELLS_X));
                        end
                        
                        // All other characters
                        default: begin
                            // Write character at current cell and move ahead one cell
                            WriteAddress_Next = WriteAddress + 12'h001;
                        end
                    endcase
                end
                
                // Set the cursor position
                if (AddressWE) begin
                    // Write NUL at the current address
                    CharToWrite = 8'h00;
                    WriteEnable = 1'b1;
                    
                    // Set write address to new address, changing the cursor position
                    WriteAddress_Next = AddressIn;
                end
                
                // Draw cursor
                if (CursorCounter == 24'd0) begin
                    // Draw cursor character or NUL (creates blink effect)
                    CharToWrite = (CursorOn) ? CHAR_CURSOR : CHAR_NUL;
                    WriteEnable = 1'b1;
                    
                    // Toggle cursor on or off (happens every 2^24 cycles)
                    CursorOn_Next = ~CursorOn;
                end
                
                // Wrap to the start of the screen if screen buffer reaches the end
                // TODO: screen scrolling
                if (WriteAddress_Next >= BUFFER_SIZE)
                    WriteAddress_Next = 12'h000;
            end
            
            BACKSPACE: begin
                // Clear the previous character by writing NUL at it's position
                CharToWrite = CHAR_NUL;
                WriteEnable = 1'b1;
            end
            
            OTHER_CHARS: begin
                WriteEnable = 1'b0;
            end
        endcase
    end
    
    // Character buffer
    RAM_12by8 charBuf
    (
        .clock(Clk),
        .data(CharToWrite),
        .rdaddress(ReadAddress),
        .wraddress(WriteAddress),
        .wren(WriteEnable),
        .q(CharToRender)
    );
    
    VGAController vgaCtl(.*);
    CharacterRenderer charRend(.*);
    
endmodule
