`timescale 1ns / 1ps

module DisplayInterface(
    input clk,
    input rst,
    input [255:0] passed_board,
    input [5:0] cursor_address,
    input [5:0] selected_address,
    input selected_enable,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input is_in_display_area,
    input enable_mouse_display,
    input [11:0] mouse_pixel,
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue
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

    wire [0:7] pawn_art[0:7];
    wire [0:7] bishop_art[0:7];
    wire [0:7] knight_art[0:7];
    wire [0:7] queen_art[0:7];
    wire [0:7] king_art[0:7];
    wire [0:7] rook_art[0:7];

    parameter RGB_OUTSIDE = 12'h000; // color outside the board
    parameter RGB_DARK_SQUARE = 12'hb98;
    parameter RGB_LIGHT_SQUARE = 12'hedc;
    parameter RGB_BLACK_PIECE = 12'h000;
    parameter RGB_WHITE_PIECE = 12'hfff;
    parameter RGB_CURSOR = 12'h00f; // color of the cursor to select the piece with fpga board
    parameter RGB_SELECTED = 12'hf00; // color of the selected piece

    reg [2:0] counter_row;
    reg [2:0] counter_col;

    reg [6:0] square_x;
    reg [6:0] square_y;

    reg [4:0] art_x;
    reg [4:0] art_y;

    reg [11:0] output_color;
    reg [11:0] next_output_color;

    wire is_in_square_border;
    wire is_in_board;
    wire dark_square;

    //wire is_in_display_area;

    wire [3:0] board[63:0];

    //wire [9:0] h_cnt;
    //wire [9:0] v_cnt;

    wire clk_flicker_enable;
    wire flicker_reset;

    always @(h_cnt) begin
        if(h_cnt <= 170) begin
            counter_col = 0;
            square_x = h_cnt - 120;
        end
        else if (h_cnt <= 220) begin
            counter_col = 1;
            square_x = h_cnt - 170;
        end
        else if (h_cnt <= 270) begin
            counter_col = 2;
            square_x = h_cnt - 220;
        end
        else if (h_cnt <= 320) begin
            counter_col = 3;
            square_x = h_cnt - 270;
        end
        else if (h_cnt <= 370) begin
            counter_col = 4;
            square_x = h_cnt - 320;
        end
        else if (h_cnt <= 420) begin
            counter_col = 5;
            square_x = h_cnt - 370;
        end
        else if (h_cnt <= 470) begin
            counter_col = 6;
            square_x = h_cnt - 420;
        end
        else begin
            counter_col = 7;
            square_x = h_cnt - 470;
        end
    end

    always @(v_cnt) begin
        if(v_cnt <=  90) begin
            counter_row = 0;
            square_y = v_cnt - 40;
        end
        else if (v_cnt <= 140) begin
            counter_row = 1;
            square_y = v_cnt - 90;
        end
        else if (v_cnt <= 190) begin
            counter_row = 2;
            square_y = v_cnt - 140;
        end
        else if (v_cnt <= 240) begin
            counter_row = 3;
            square_y = v_cnt - 190;
        end
        else if (v_cnt <= 290) begin
            counter_row = 4;
            square_y = v_cnt - 240;
        end
        else if (v_cnt <= 340) begin
            counter_row = 5;
            square_y = v_cnt - 290;
        end
        else if (v_cnt <= 390) begin
            counter_row = 6;
            square_y = v_cnt - 340;
        end
        else begin
            counter_row = 7;
            square_y = v_cnt - 390;
        end
    end

    always @(square_x) begin
        if (square_x <= 10) art_x = 0;
        else if (square_x <= 15) art_x = 1;
        else if (square_x <= 20) art_x = 2;
        else if (square_x <= 25) art_x = 3;
        else if (square_x <= 30) art_x = 4;
        else if (square_x <= 35) art_x = 5;
        else if (square_x <= 40) art_x = 6;
        else art_x = 7;
    end

    always @(square_y) begin
        if (square_y <= 10) art_y = 0;
        else if (square_y <= 15) art_y = 1;
        else if (square_y <= 20) art_y = 2;
        else if (square_y <= 25) art_y = 3;
        else if (square_y <= 30) art_y = 4;
        else if (square_y <= 35) art_y = 5;
        else if (square_y <= 40) art_y = 6;
        else art_y = 7;
    end

    // to check if it is inside the square border
    assign is_in_square_border = (square_x <= 5 || square_x >= 45 || square_y <= 5 || square_y >= 45);
    // signal to check if it is actually in the board
    assign is_in_board = (h_cnt >= 120 && h_cnt < 520) && (v_cnt >= 40  && v_cnt < 440);
    // to check if it is above the black or white square
    assign dark_square = counter_row[0] ^ counter_col[0];

    always @(posedge clk) output_color <= next_output_color;

    always @(*) begin
        if (!is_in_board) next_output_color = RGB_OUTSIDE;
        else if (enable_mouse_display) begin
            next_output_color = mouse_pixel;
        end
        else begin
            if (is_in_square_border) begin
                if (cursor_address == {counter_row, counter_col}) next_output_color = RGB_CURSOR;
                else if (is_in_square_border && selected_address == { counter_row, counter_col } && selected_enable) begin
                    if (!clk_flicker_enable) next_output_color = RGB_SELECTED;
                    else begin
                        if (dark_square) next_output_color = RGB_DARK_SQUARE;
                        else next_output_color = RGB_LIGHT_SQUARE;
                    end
                end
                else if (dark_square) next_output_color = RGB_DARK_SQUARE;
                else next_output_color = RGB_LIGHT_SQUARE;
            end

            else begin
                case (board[{counter_row, counter_col}][2:0])
                    EMPTY : begin
                        if (dark_square) next_output_color = RGB_DARK_SQUARE;
                        else next_output_color = RGB_LIGHT_SQUARE;
                    end
                    PAWN : begin
                        if (pawn_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                            else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    KNIGHT : begin
                        if (knight_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                            else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    BISHOP: begin
                        if (bishop_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                            else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    ROOK : begin
                        if (rook_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                            else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    QUEEN : begin
                        if (queen_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                           else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    KING : begin
                        if (king_art[art_y][art_x]) begin
                            if(board[{counter_row, counter_col}][3] == BLACK) next_output_color = RGB_BLACK_PIECE;
                            else next_output_color = RGB_WHITE_PIECE;
                        end
                        else begin
                            if (dark_square) next_output_color = RGB_DARK_SQUARE;
                            else next_output_color = RGB_LIGHT_SQUARE;
                        end
                    end
                    default: next_output_color = RGB_OUTSIDE;
                endcase
            end
        end
    end

    /* drawing all the pieces in the board */
    /* pawn */
    assign pawn_art[0] = 8'b00000000;
    assign pawn_art[1] = 8'b00011000;
    assign pawn_art[2] = 8'b00111100;
    assign pawn_art[3] = 8'b00111100;
    assign pawn_art[4] = 8'b00011000;
    assign pawn_art[5] = 8'b00111100;
    assign pawn_art[6] = 8'b01111110;
    assign pawn_art[7] = 8'b01111110;

    /* bishop */
    assign bishop_art[0] = 8'b00011000;
    assign bishop_art[1] = 8'b00100100;
    assign bishop_art[2] = 8'b00100100;
    assign bishop_art[3] = 8'b00011000;
    assign bishop_art[4] = 8'b00011000;
    assign bishop_art[5] = 8'b00111100;
    assign bishop_art[6] = 8'b01111110;
    assign bishop_art[7] = 8'b11100111;

    /* knight */
    assign knight_art[0] = 8'b00011000;
    assign knight_art[1] = 8'b01111100;
    assign knight_art[2] = 8'b10111110;
    assign knight_art[3] = 8'b11101111;
    assign knight_art[4] = 8'b00000111;
    assign knight_art[5] = 8'b00011111;
    assign knight_art[6] = 8'b00111111;
    assign knight_art[7] = 8'b01111110;

    /* queen */
    assign queen_art[0] = 8'b00000000;
    assign queen_art[1] = 8'b01010101;
    assign queen_art[2] = 8'b01010101;
    assign queen_art[3] = 8'b01010101;
    assign queen_art[4] = 8'b01111111;
    assign queen_art[5] = 8'b01111111;
    assign queen_art[6] = 8'b01111111;
    assign queen_art[7] = 8'b00111110;

    /* king */
    assign king_art[0] = 8'b00011000;
    assign king_art[1] = 8'b01111110;
    assign king_art[2] = 8'b00011000;
    assign king_art[3] = 8'b00011000;
    assign king_art[4] = 8'b00111100;
    assign king_art[5] = 8'b01111110;
    assign king_art[6] = 8'b01111110;
    assign king_art[7] = 8'b00111100;

    /* rook */
    assign rook_art[0] = 8'b00000000;
    assign rook_art[1] = 8'b01011010;
    assign rook_art[2] = 8'b01111110;
    assign rook_art[3] = 8'b00111100;
    assign rook_art[4] = 8'b00011000;
    assign rook_art[5] = 8'b00011000;
    assign rook_art[6] = 8'b00111100;
    assign rook_art[7] = 8'b01111110;

    /* convert 1D passed board to 2D */
    assign board[0] = passed_board[3 : 0];
    assign board[1] = passed_board[7 : 4];
    assign board[2] = passed_board[11 : 8];
    assign board[3] = passed_board[15 : 12];
    assign board[4] = passed_board[19 : 16];
    assign board[5] = passed_board[23 : 20];
    assign board[6] = passed_board[27 : 24];
    assign board[7] = passed_board[31 : 28];

    assign board[8] = passed_board[35 : 32];
    assign board[9] = passed_board[39 : 36];
    assign board[10] = passed_board[43 : 40];
    assign board[11] = passed_board[47 : 44];
    assign board[12] = passed_board[51 : 48];
    assign board[13] = passed_board[55 : 52];
    assign board[14] = passed_board[59 : 56];
    assign board[15] = passed_board[63 : 60];

    assign board[16] = passed_board[67 : 64];
    assign board[17] = passed_board[71 : 68];
    assign board[18] = passed_board[75 : 72];
    assign board[19] = passed_board[79 : 76];
    assign board[20] = passed_board[83 : 80];
    assign board[21] = passed_board[87 : 84];
    assign board[22] = passed_board[91 : 88];
    assign board[23] = passed_board[95 : 92];

    assign board[24] = passed_board[99 : 96];
    assign board[25] = passed_board[103 : 100];
    assign board[26] = passed_board[107 : 104];
    assign board[27] = passed_board[111 : 108];
    assign board[28] = passed_board[115 : 112];
    assign board[29] = passed_board[119 : 116];
    assign board[30] = passed_board[123 : 120];
    assign board[31] = passed_board[127 : 124];

    assign board[32] = passed_board[131 : 128];
    assign board[33] = passed_board[135 : 132];
    assign board[34] = passed_board[139 : 136];
    assign board[35] = passed_board[143 : 140];
    assign board[36] = passed_board[147 : 144];
    assign board[37] = passed_board[151 : 148];
    assign board[38] = passed_board[155 : 152];
    assign board[39] = passed_board[159 : 156];

    assign board[40] = passed_board[163 : 160];
    assign board[41] = passed_board[167 : 164];
    assign board[42] = passed_board[171 : 168];
    assign board[43] = passed_board[175 : 172];
    assign board[44] = passed_board[179 : 176];
    assign board[45] = passed_board[183 : 180];
    assign board[46] = passed_board[187 : 184];
    assign board[47] = passed_board[191 : 188];

    assign board[48] = passed_board[195 : 192];
    assign board[49] = passed_board[199 : 196];
    assign board[50] = passed_board[203 : 200];
    assign board[51] = passed_board[207 : 204];
    assign board[52] = passed_board[211 : 208];
    assign board[53] = passed_board[215 : 212];
    assign board[54] = passed_board[219 : 216];
    assign board[55] = passed_board[223 : 220];

    assign board[56] = passed_board[227 : 224];
    assign board[57] = passed_board[231 : 228];
    assign board[58] = passed_board[235 : 232];
    assign board[59] = passed_board[239 : 236];
    assign board[60] = passed_board[243 : 240];
    assign board[61] = passed_board[247 : 244];
    assign board[62] = passed_board[251 : 248];
    assign board[63] = passed_board[255 : 252];

    assign vga_red = {
        output_color[11] & is_in_display_area,
        output_color[10] & is_in_display_area,
        output_color[9] & is_in_display_area,
        output_color[8] & is_in_display_area
    };

    assign vga_green = {
        output_color[7] & is_in_display_area,
        output_color[6] & is_in_display_area,
        output_color[5] & is_in_display_area,
        output_color[4] & is_in_display_area
    };

    assign vga_blue = {
        output_color[3] & is_in_display_area,
        output_color[2] & is_in_display_area,
        output_color[1] & is_in_display_area,
        output_color[0] & is_in_display_area
    };

    assign flicker_reset = !(selected_enable && (selected_address != cursor_address));

    /* module instantiation */
    ClockDivisorSlow clock_div (
        .reset(flicker_reset),
        .clk(clk),
        .slow_clk(clk_flicker_enable)
    );

endmodule
