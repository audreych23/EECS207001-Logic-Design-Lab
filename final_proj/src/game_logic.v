`timescale 1ns / 1ps

module GameLogic(
    input clk,
    input rst,
    input [255:0] passed_board,
    input [9:0] MOUSE_X_POS,
    input [9:0] MOUSE_Y_POS,
    input MOUSE_LEFT,
    input MOUSE_RIGHT,
    output reg[5:0] board_out_address,
    output reg[3:0] board_out_piece,
    output reg board_change_en_wire,
    output reg[5:0] cursor_address,
    output reg[5:0] selected_address,
    output highlight_selected_square
);

    parameter
    STANDBY = 2'b00, // before the player choose a piece
    SELECTED = 2'b01, // the piece is selected and choose destination
    MOVE = 2'b10, // the piece is copied to the destination
    ERASE = 2'b11; // erase the piece in original address

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

    reg next_board_change_en_wire;

    reg[5:0] next_board_out_address;

    reg[3:0] next_board_out_piece;

    reg[5:0] next_cursor_address;

    reg[5:0] next_selected_address;

    reg player_state ;
    reg next_player_state;

    reg [1:0] game_state;
    reg [1:0] next_game_state;

    wire[3:0] horizontal_difference;
    wire[3:0] vertical_difference;

    wire[3:0] cursor_contents;
    wire[3:0] selected_contents;

    wire [3:0] board[63:0];

    reg is_valid_move;

    always @(posedge clk, posedge rst)begin
        if(rst)begin
            player_state <= WHITE;
            game_state <= STANDBY;

            board_out_address <= 6'b000000;
            board_out_piece <= 4'b0000;
            board_change_en_wire <= 0;

            selected_address <= 6'b000000;
            cursor_address <= 6'b000000;
        end
        else begin
            player_state <= next_player_state;
            game_state <= next_game_state;

            board_out_address <= next_board_out_address;
            board_out_piece <= next_board_out_piece;
            board_change_en_wire <= next_board_change_en_wire;

            selected_address <= next_selected_address;
            cursor_address <= next_cursor_address;
        end
    end

    /* cursor movement */
    always@(*) begin
      if (MOUSE_X_POS <= 170) begin
          if (MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_000;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_000;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_000;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_000;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_000;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_000;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_000;
          end
          else begin
              next_cursor_address = 6'b111_000;
          end
      end
      else if(MOUSE_X_POS <= 220) begin
          if(MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_001;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_001;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_001;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_001;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_001;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_001;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_001;
          end
          else begin
              next_cursor_address = 6'b111_001;
          end
      end
      else if (MOUSE_X_POS <= 270) begin
          if(MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_010;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_010;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_010;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_010;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_010;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_010;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_010;
          end
          else begin
              next_cursor_address = 6'b111_010;
          end
      end
      else if (MOUSE_X_POS <= 320) begin
          if (MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_011;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_011;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_011;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_011;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_011;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_011;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_011;
          end
          else begin
              next_cursor_address = 6'b111_011;
          end
      end
      else if (MOUSE_X_POS <= 370) begin
          if(MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_100;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_100;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_100;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_100;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_100;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_100;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_100;
          end
          else begin
              next_cursor_address = 6'b111_100;
          end
      end
      else if (MOUSE_X_POS <= 420) begin
          if(MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_101;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_101;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_101;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_101;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_101;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_101;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_101;
          end
          else begin
              next_cursor_address = 6'b111_101;
          end
      end
      else if (MOUSE_X_POS <= 470) begin
          if (MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_110;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_110;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_110;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_110;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_110;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_110;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_110;
          end
          else begin
              next_cursor_address = 6'b111_110;
          end
      end
      else begin
          if(MOUSE_Y_POS <=  90) begin
              next_cursor_address = 6'b000_111;
          end
          else if (MOUSE_Y_POS <= 140) begin
              next_cursor_address = 6'b001_111;
          end
          else if (MOUSE_Y_POS <= 190) begin
              next_cursor_address = 6'b010_111;
          end
          else if (MOUSE_Y_POS <= 240) begin
              next_cursor_address = 6'b011_111;
          end
          else if (MOUSE_Y_POS <= 290) begin
              next_cursor_address = 6'b100_111;
          end
          else if (MOUSE_Y_POS <= 340) begin
              next_cursor_address = 6'b101_111;
          end
          else if (MOUSE_Y_POS <= 390) begin
              next_cursor_address = 6'b110_111;
          end
          else begin
              next_cursor_address = 6'b111_111;
          end
       end
    end


    always @(*)begin
        case (game_state)
            STANDBY: begin
                if (MOUSE_LEFT && cursor_contents[3] == player_state && cursor_contents[2:0] != EMPTY) begin
                    next_game_state = SELECTED;
                    next_selected_address = cursor_address;
                end
                else begin
                    next_game_state = game_state;
                    next_selected_address = selected_address;
                end
                next_board_out_address = board_out_address;
                next_board_out_piece = board_out_piece;
                next_board_change_en_wire = 1'b0;
                next_player_state = player_state;
            end
            SELECTED: begin
                if((MOUSE_LEFT && cursor_address == selected_address) || MOUSE_RIGHT)begin
                    next_game_state = STANDBY;
                    next_board_out_address = cursor_address;
                    next_board_out_piece = selected_contents;
                    next_board_change_en_wire = 1'b0;
                end
                else if(MOUSE_LEFT && (cursor_contents[3] != player_state || cursor_contents[2:0] == EMPTY) && is_valid_move) begin
                    next_game_state = MOVE;
                    next_board_out_address = cursor_address;
                    next_board_out_piece = selected_contents;
                    next_board_change_en_wire = 1'b1;
                end
                else begin
                    next_game_state = game_state;
                    next_board_out_address = board_out_address;
                    next_board_out_piece = board_out_piece;
                    next_board_change_en_wire = 1'b0;
                end
                next_selected_address = selected_address;
                next_player_state = player_state;
            end
            MOVE:begin
                next_game_state = ERASE;

                next_board_out_address = selected_address;
                next_board_out_piece = {WHITE, EMPTY};
                next_board_change_en_wire = 1'b1;

                next_selected_address = selected_address;
                next_player_state = player_state;
            end
            ERASE:begin
                next_game_state = STANDBY;

                next_board_out_address = 6'bxxxxxx;
                next_board_out_piece = 4'bxxxx;
                next_board_change_en_wire = 1'b0;

                next_selected_address = selected_address;
                next_player_state = ~player_state;
            end
       endcase
    end

    always @(*) begin
       if (selected_contents[2:0] == PAWN) begin
           if (player_state == WHITE) begin
               if (
                   vertical_difference == 2
                   && horizontal_difference == 0
                   && selected_address[5:3] == 3'b110
                   && cursor_contents[2:0] == EMPTY
                   && board[selected_address - 6'b001_000][2:0] == EMPTY
                   && cursor_address[5:3] < selected_address[5:3]
                 ) is_valid_move = 1;
               else if (
                   vertical_difference == 1
                   && horizontal_difference == 0
                   && cursor_contents[2:0] == EMPTY
                   && cursor_address[5:3] < selected_address[5:3]
               ) is_valid_move = 1;
               else if (
                   vertical_difference == 1
                   && (horizontal_difference == 1)
                   && cursor_contents[3] == BLACK
                   && cursor_contents[2:0] != EMPTY
                   && cursor_address[5:3] < selected_address[5:3]
               ) is_valid_move = 1;
               else is_valid_move = 0;
           end

           else if (player_state == BLACK) begin
               if (
                   vertical_difference == 2
                   && horizontal_difference == 0
                   && selected_address[5:3] == 3'b001
                   && cursor_contents[2:0] == EMPTY
                   && board[selected_address + 6'b001_000][2:0] == EMPTY
                   && cursor_address[5:3] > selected_address[5:3]
               ) is_valid_move = 1;
               else if (
                   vertical_difference == 1 // move forward by 1?
                   && horizontal_difference == 0
                   && cursor_contents[2:0] == EMPTY
                   && cursor_address[5:3] > selected_address[5:3]
               ) is_valid_move = 1;
               else if (
                   vertical_difference == 1
                   && horizontal_difference==1
                   && cursor_contents[3] == WHITE
                   && cursor_contents[2:0] != EMPTY
                     && cursor_address[5:3] > selected_address[5:3]
               ) is_valid_move = 1;
               else is_valid_move = 0;
           end
       end

       else if (selected_contents[2:0] == ROOK) begin
           is_valid_move = (horizontal_difference == 0 || vertical_difference == 0); // doesnt check if there is a piece in the way?
       end

       else if(selected_contents[2:0] == KNIGHT) begin
           is_valid_move = ((horizontal_difference == 2 && vertical_difference == 1) || (vertical_difference == 2 && horizontal_difference == 1));
       end

       else if (selected_contents[2:0] == BISHOP) begin
           is_valid_move = (horizontal_difference == vertical_difference);
       end

       else if (selected_contents[2:0] == QUEEN) begin
           is_valid_move = ((horizontal_difference == 0 || vertical_difference == 0) || (horizontal_difference == vertical_difference));
       end

       else if(selected_contents[2:0] == KING)  begin
           is_valid_move = ((horizontal_difference == 0 || horizontal_difference == 1) && ( vertical_difference == 0 || vertical_difference == 1));
       end

       else is_valid_move = 0;
   end

    /* assign the difference of the y and x coordinate with the absolute value of selected_address and cursor_address */
    assign vertical_difference = (cursor_address[5:3] < selected_address[5:3]) ?
                                 (selected_address[5:3] - cursor_address[5:3]) : (cursor_address[5:3] - selected_address[5:3]);

    assign horizontal_difference = (cursor_address[2:0] < selected_address[2:0]) ?
                                   (selected_address[2:0] - cursor_address[2:0]) : (cursor_address[2:0] - selected_address[2:0]);

    /* convert 1D passed_board to 2d board */
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

    assign cursor_contents = board[cursor_address]; // contents of the cursor square
    assign selected_contents = board[selected_address]; // contents of the selected square

    assign highlight_selected_square = (game_state == SELECTED); // only highlight the selected square at selected state

endmodule
