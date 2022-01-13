`timescale 1ns / 1ps

module Display_Interface(
    input clk,
    input rst,
    input [255:0] Passed_Board,
    input [5:0] Cursor_Addr,
    input [5:0] Select_Addr,
    input Select_En,
    output hsync,
    output vsync,
    output [2:0] R,
    output [2:0] G,
    output [1:0] B
);
    
    parameter
    EMPTY = 3'b000,
    PAWN = 3'b001,
    BISHOP = 3'b010,
    KNIGHT = 3'b011,
    ROOK = 3'b100,
    QUEEN = 3'b101,
    KING = 3'b110;

    parameter
    WHITE = 1'b0,
    BLACK = 1'b1;
    
    wire [0:7]pawnArt[0:7];
    assign pawnArt[0] = 8'b00000000;
    assign pawnArt[1] = 8'b00011000;
    assign pawnArt[2] = 8'b00111100;
    assign pawnArt[3] = 8'b00111100;
    assign pawnArt[4] = 8'b00011000;
    assign pawnArt[5] = 8'b00111100;
    assign pawnArt[6] = 8'b01111110;
    assign pawnArt[7] = 8'b01111110;
    
    wire [0:7]bishopArt[0:7];
    assign bishopArt[0] = 8'b00011000;
    assign bishopArt[1] = 8'b00100100;
    assign bishopArt[2] = 8'b00100100;
    assign bishopArt[3] = 8'b00011000;
    assign bishopArt[4] = 8'b00011000;
    assign bishopArt[5] = 8'b00111100;
    assign bishopArt[6] = 8'b01111110;
    assign bishopArt[7] = 8'b11100111;
    
    wire [0:7]knightArt[0:7];
    assign knightArt[0] = 8'b00011000;
    assign knightArt[1] = 8'b01111100;
    assign knightArt[2] = 8'b10111110;
    assign knightArt[3] = 8'b11101111;
    assign knightArt[4] = 8'b00000111;
    assign knightArt[5] = 8'b00011111;
    assign knightArt[6] = 8'b00111111;
    assign knightArt[7] = 8'b01111110;
    
    wire [0:7]queenArt[0:7];
    assign queenArt[0] = 8'b00000000;
    assign queenArt[1] = 8'b01010101;
    assign queenArt[2] = 8'b01010101;
    assign queenArt[3] = 8'b01010101;
    assign queenArt[4] = 8'b01111111;
    assign queenArt[5] = 8'b01111111;
    assign queenArt[6] = 8'b01111111;
    assign queenArt[7] = 8'b00111110;
    
    wire [0:7] kingArt[0:7];
    assign kingArt[0] = 8'b00011000;
    assign kingArt[1] = 8'b01111110;
    assign kingArt[2] = 8'b00011000;
    assign kingArt[3] = 8'b00011000;
    assign kingArt[4] = 8'b00111100;
    assign kingArt[5] = 8'b01111110;
    assign kingArt[6] = 8'b01111110;
    assign kingArt[7] = 8'b00111100;
    
    wire [0:7] rookArt[0:7];
    assign rookArt[0] = 8'b00000000;
    assign rookArt[1] = 8'b01011010;
    assign rookArt[2] = 8'b01111110;
    assign rookArt[3] = 8'b00111100;
    assign rookArt[4] = 8'b00011000;
    assign rookArt[5] = 8'b00011000;
    assign rookArt[6] = 8'b00111100;
    assign rookArt[7] = 8'b01111110;
    
    parameter RGB_OUTSIDE = 8'b000_000_00;  // outside the drawn board
    parameter RGB_DARK_SQ = 8'b101_000_00;  // color of the dark squares
    parameter RGB_LIGHT_SQ = 8'b111_110_10; // color of the light squares
    parameter RGB_BLACK_PIECE = 8'b001_001_01; // color of the black player's pieces
    parameter RGB_WHITE_PIECE = 8'b111_111_11; // color of the white player's pieces
    parameter RGB_CURSOR = 8'b000_000_11; // color of the squares' outline that shows the cursor
    parameter RGB_SELECTED = 8'b111_000_00; // color of the outline showing which piece is selected 
        
        
    reg [2:0] counter_row;
    reg [2:0] counter_col;
    
    reg [6:0] square_x;
    reg [6:0] square_y;
    
    reg [4:0] art_x;
    reg [4:0] art_y; 
    
    reg [7:0] output_color;
    
    wire in_square_border;
    wire in_board;
    wire dark_square;
    
    wire [3:0] Board[63:0];
    wire inDisplayArea;
    
    wire [9:0] CounterX;
    wire [9:0] CounterY;
    
    always @(CounterX) begin
        if(CounterX <= 170) begin
            counter_col <= 0;
            square_x <= CounterX - 120;
        end
        else if (CounterX <= 220) begin
            counter_col <= 1;
            square_x <= CounterX - 170;    
        end
        else if (CounterX <= 270) begin
            counter_col <= 2;
            square_x <= CounterX - 220;
        end
        else if (CounterX <= 320) begin
            counter_col <= 3;
            square_x <= CounterX - 270;
        end
        else if (CounterX <= 370) begin
            counter_col <= 4;
            square_x <= CounterX - 320;
        end
        else if (CounterX <= 420) begin
            counter_col <= 5;
            square_x <= CounterX - 370;
        end
        else if (CounterX <= 470) begin
            counter_col <= 6;
            square_x <= CounterX - 420;
        end
        else begin
            counter_col <= 7;
            square_x <= CounterX - 470;
        end
    end
    
    always @(CounterY) begin
        if(CounterY <=  90) begin
            counter_row <= 0;
            square_y <= CounterY - 40;
        end
        else if (CounterY <= 140) begin
            counter_row <= 1;
            square_y <= CounterY - 90;
        end
        else if (CounterY <= 190) begin
            counter_row <= 2;
            square_y <= CounterY - 140;
        end
        else if (CounterY <= 240) begin
            counter_row <= 3; 
            square_y <= CounterY - 190; 
        end
        else if (CounterY <= 290) begin 
            counter_row <= 4; 
            square_y <= CounterY - 240; 
        end
        else if (CounterY <= 340) begin 
            counter_row <= 5; 
            square_y <= CounterY - 290; 
        end
        else if (CounterY <= 390) begin 
            counter_row <= 6; 
            square_y <= CounterY - 340; 
        end
        else begin 
            counter_row <= 7; 
            square_y <= CounterY - 390; 
        end
    end
    
    always @(square_x) begin
        if (square_x <= 10) art_x <= 0;
        else if (square_x <= 15) art_x <= 1;
        else if (square_x <= 20) art_x <= 2;
        else if (square_x <= 25) art_x <= 3;
        else if (square_x <= 30) art_x <= 4;
        else if (square_x <= 35) art_x <= 5;
        else if (square_x <= 40) art_x <= 6;
        else art_x <= 7;	
    end
    
    always @(square_y) begin
        if (square_y <= 10) art_y <= 0;
        else if (square_y <= 15) art_y <= 1;
        else if (square_y <= 20) art_y <= 2;
        else if (square_y <= 25) art_y <= 3;
        else if (square_y <= 30) art_y <= 4;
        else if (square_y <= 35) art_y <= 5;
        else if (square_y <= 40) art_y <= 6;
        else art_y <= 7;	
    end
    
    // whether the pointer is in the border outline region of each square
    assign in_square_border = (square_x <= 5 || square_x >= 45 || square_y <= 5 || square_y >= 45);
    // whether the pointer is in the board at all
    assign in_board = (CounterX >= 120 && CounterX < 520) && (CounterY >= 40  && CounterY < 440);
    //whether the pointer is in a black or white square
    assign dark_square = counter_row[0] ^ counter_col[0];
    
    // Set the pixel colors based on the Counter positions
    always @(posedge clk) begin
        if (!in_board) output_color <= RGB_OUTSIDE;
        else begin
            if (in_square_border) begin
                if (Cursor_Addr == { counter_row, counter_col }) 
                    output_color <= RGB_CURSOR;
                else if (in_square_border && Select_Addr == { counter_row, counter_col } && Select_En)
                    output_color <= RGB_SELECTED;
                else if (dark_square) 
                    output_color <= RGB_DARK_SQ;
                else
                    output_color <= RGB_LIGHT_SQ;
            end
            else begin
                // we are inside the drawable area of a square
                case (Board[{counter_row, counter_col}][2:0])
                    EMPTY  : begin
                        if (dark_square) 
                            output_color <= RGB_DARK_SQ;
                        else
                            output_color <= RGB_LIGHT_SQ;
                    end
                    PAWN  : begin
                        if (pawnArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    KNIGHT: begin
                        if (knightArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    BISHOP: begin
                        if (bishopArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    ROOK : begin
                        if (rookArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    QUEEN : begin
                        if (queenArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    KING : begin
                        if (kingArt[art_y][art_x]) begin
                            if(Board[{counter_row, counter_col}][3] == BLACK)
                                output_color <= RGB_BLACK_PIECE;
                            else
                                output_color <= RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) 
                                output_color <= RGB_DARK_SQ;
                            else
                                output_color <= RGB_LIGHT_SQ;
                        end
                    end
                    default: output_color <= RGB_OUTSIDE;
                endcase
            end
        end
    end
    
    //convert 1D passed board to 2d
    assign Board[0] = Passed_Board[3 : 0];
    assign Board[1] = Passed_Board[7 : 4];
    assign Board[2] = Passed_Board[11 : 8];
    assign Board[3] = Passed_Board[15 : 12];
    assign Board[4] = Passed_Board[19 : 16];
    assign Board[5] = Passed_Board[23 : 20];
    assign Board[6] = Passed_Board[27 : 24];
    assign Board[7] = Passed_Board[31 : 28];
    
    assign Board[8] = Passed_Board[35 : 32];
    assign Board[9] = Passed_Board[39 : 36];
    assign Board[10] = Passed_Board[43 : 40];
    assign Board[11] = Passed_Board[47 : 44];
    assign Board[12] = Passed_Board[51 : 48];
    assign Board[13] = Passed_Board[55 : 52];
    assign Board[14] = Passed_Board[59 : 56];
    assign Board[15] = Passed_Board[63 : 60];
    
    assign Board[16] = Passed_Board[67 : 64];
    assign Board[17] = Passed_Board[71 : 68];
    assign Board[18] = Passed_Board[75 : 72];
    assign Board[19] = Passed_Board[79 : 76];
    assign Board[20] = Passed_Board[83 : 80];
    assign Board[21] = Passed_Board[87 : 84];
    assign Board[22] = Passed_Board[91 : 88];
    assign Board[23] = Passed_Board[95 : 92];
    
    assign Board[24] = Passed_Board[99 : 96];
    assign Board[25] = Passed_Board[103 : 100];
    assign Board[26] = Passed_Board[107 : 104];
    assign Board[27] = Passed_Board[111 : 108];
    assign Board[28] = Passed_Board[115 : 112];
    assign Board[29] = Passed_Board[119 : 116];
    assign Board[30] = Passed_Board[123 : 120];
    assign Board[31] = Passed_Board[127 : 124];
    
    assign Board[32] = Passed_Board[131 : 128];
    assign Board[33] = Passed_Board[135 : 132];
    assign Board[34] = Passed_Board[139 : 136];
    assign Board[35] = Passed_Board[143 : 140];
    assign Board[36] = Passed_Board[147 : 144];
    assign Board[37] = Passed_Board[151 : 148];
    assign Board[38] = Passed_Board[155 : 152];
    assign Board[39] = Passed_Board[159 : 156];
    
    assign Board[40] = Passed_Board[163 : 160];
    assign Board[41] = Passed_Board[167 : 164];
    assign Board[42] = Passed_Board[171 : 168];
    assign Board[43] = Passed_Board[175 : 172];
    assign Board[44] = Passed_Board[179 : 176];
    assign Board[45] = Passed_Board[183 : 180];
    assign Board[46] = Passed_Board[187 : 184];
    assign Board[47] = Passed_Board[191 : 188];
    
    assign Board[48] = Passed_Board[195 : 192];
    assign Board[49] = Passed_Board[199 : 196];
    assign Board[50] = Passed_Board[203 : 200];
    assign Board[51] = Passed_Board[207 : 204];
    assign Board[52] = Passed_Board[211 : 208];
    assign Board[53] = Passed_Board[215 : 212];
    assign Board[54] = Passed_Board[219 : 216];
    assign Board[55] = Passed_Board[223 : 220];
    
    assign Board[56] = Passed_Board[227 : 224];
    assign Board[57] = Passed_Board[231 : 228];
    assign Board[58] = Passed_Board[235 : 232];
    assign Board[59] = Passed_Board[239 : 236];
    assign Board[60] = Passed_Board[243 : 240];
    assign Board[61] = Passed_Board[247 : 244];
    assign Board[62] = Passed_Board[251 : 248];
    assign Board[63] = Passed_Board[255 : 252];
    
    assign R = {
        output_color[7] & inDisplayArea,
        output_color[6] & inDisplayArea,
        output_color[5] & inDisplayArea
    };
    assign G = {
        output_color[4] & inDisplayArea,
        output_color[3] & inDisplayArea,
        output_color[2] & inDisplayArea
    };
    assign B = {
        output_color[1] & inDisplayArea,
        output_color[0] & inDisplayArea
    };
    
    VGAController VGA(
        .clk(clk),
        .reset(rst),
        .h_sync(hsync), 
        .v_sync(vsync), 
        .valid(inDisplayArea), 
        .h_cnt(CounterX), 
        .v_cnt(CounterY)
    );
    
endmodule
