`timescale 1ns / 1ps

module Game_Logic(
    input clk,
    input rst,
    input BtnL,
    input BtnU,
    input BtnR,
    input BtnD,
    input BtnC,
    input [255:0] Passed_Board,
    output reg[5:0] board_out_addr,
    output reg[3:0] board_out_piece,
    output reg board_change_en_wire,
    output reg[5:0] cursor_addr,
    output reg[5:0] selected_addr,
    output highlight_selected_square,
    output Game_State,
    output reg move_is_legal,
    output is_in_initial_state
);

    parameter
    Standby = 3'b000,
    Selected = 3'b001,
    Move = 3'b010,
    Erase = 3'b011,
    Wait = 3'b100;
    
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
    
    reg[5:0] next_board_out_addr;
    
    reg[3:0] next_board_out_piece;
    
    reg[5:0] next_cursor_addr;
    
    reg[5:0] next_selected_addr;
    
    reg Player_State = 1'b0;
    reg Next_Player_State = 1'b0;
    
    reg [2:0] Game_State;
    reg [2:0] Next_Game_State;
    
    reg[3:0] h_delta;
    reg[3:0] v_delta;
    
    wire[3:0] cursor_contents;
    wire[3:0] selected_contents;
    
    wire [3:0] Board[63:0];
    
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            Player_State <= WHITE;
            Game_State <= Standby;
            
            board_out_addr <= 6'b000000;
            board_out_piece <= 4'b0000;
            board_change_en_wire <= 0;
            
            selected_addr <= 6'b000000;
            cursor_addr <= 6'b000000;
        end
        else begin
            Player_State <= Next_Player_State;
            Game_State <= Next_Game_State;
            
            board_out_addr <= next_board_out_addr;
            board_out_piece <= next_board_out_piece;
            board_change_en_wire <= next_board_change_en_wire;
            
            selected_addr <= next_selected_addr;
            cursor_addr <= next_cursor_addr;
        end
    end
    
    always @(*)begin
        if(BtnL && cursor_addr[2:0] != 3'b000)
            next_cursor_addr = cursor_addr - 6'b000_001;
        else if(BtnR && cursor_addr[2:0] != 3'b111)
            next_cursor_addr = cursor_addr + 6'b000_001;
        else if(BtnU && cursor_addr[5:3] != 3'b000)
            next_cursor_addr = cursor_addr - 6'b001_000;
        else if(BtnD && cursor_addr[5:3] != 3'b111)
            next_cursor_addr = cursor_addr + 6'b001_000;
        else next_cursor_addr = cursor_addr;
        
        case (Game_State)
            Standby: begin
                if (BtnC && cursor_contents[3] == Player_State && cursor_contents[2:0] != EMPTY) begin
                    Next_Game_State = Selected; 
                    next_selected_addr = cursor_addr;
                end
                else begin
                    Next_Game_State = Game_State;
                    next_selected_addr = selected_addr; 
                end
                next_board_out_addr = board_out_addr;
                next_board_out_piece = board_out_piece;
                next_board_change_en_wire = 1'b0;
                Next_Player_State = Player_State;
            end
            Selected: begin
                if(BtnC && cursor_addr == selected_addr)begin
                    Next_Game_State = Standby;
                    next_board_out_addr = cursor_addr;
                    next_board_out_piece = selected_contents;
                    next_board_change_en_wire = 1'b0;
                end
                else if(BtnC && (cursor_contents[3] != Player_State || cursor_contents[2:0] == EMPTY)) begin
                    Next_Game_State = Move;
                    next_board_out_addr = cursor_addr;
                    next_board_out_piece = selected_contents;
                    next_board_change_en_wire = 1'b1;
                end 
                else begin
                    Next_Game_State = Game_State;
                    next_board_out_addr = board_out_addr;
                    next_board_out_piece = board_out_piece;
                    next_board_change_en_wire = 1'b0;
                end
                next_selected_addr = selected_addr;
                Next_Player_State = Player_State;
            end
            Move:begin
                Next_Game_State = Erase;
                
                next_board_out_addr = selected_addr;
                next_board_out_piece = {WHITE, EMPTY};
                next_board_change_en_wire = 1'b1;
                
                next_selected_addr = selected_addr;
                Next_Player_State = Player_State;
            end
            Erase:begin
                Next_Game_State = Standby;
                
                next_board_out_addr = 6'bxxxxxx;
                next_board_out_piece = 4'bxxxx;
                next_board_change_en_wire = 1'b0;
                
                next_selected_addr = selected_addr;
                Next_Player_State = ~Player_State;
            end
       endcase 
    end
    
//    always @(*) begin
//        if (selected_contents[2:0] == PAWN) begin
//            if (Player_State == WHITE) begin // pawn moves forward (decreasing MSB)
//                if (
//                    v_delta == 2 // skip forward by 2?
//                    && h_delta == 0 // not moving diagonally?
//                    && selected_addr[5:3] == 3'b110 // moving from home row?
//                    && cursor_contents[2:0] == EMPTY // no piece at dest?
//                    && Board[selected_addr - 6'b001_000][2:0] == EMPTY // no piece in way?
//                    && cursor_addr[5:3] < selected_addr[5:3]
//                  ) move_is_legal = 1; // moving from home row by 2
//                else if (
//                    v_delta == 1 // move forward by 1?
//                    && h_delta == 0
//                    && cursor_contents[2:0] == EMPTY
//                    && cursor_addr[5:3] < selected_addr[5:3]
//                ) move_is_legal = 1;
//                else if (
//                v_delta == 1
//                    && (h_delta == 1) // moving diagonally by 1?
//                    && cursor_contents[3] == BLACK // capturing opponent?
//                    && cursor_contents[2:0] != EMPTY // capturing something?
//                    && cursor_addr[5:3] < selected_addr[5:3]
//                ) move_is_legal = 1;
//                else move_is_legal = 0;
//            end
    
//            else if (Player_State == BLACK) begin
//                if (
//                    v_delta == 2 // skip forward by 2?
//                    && h_delta == 0 // not moving diagonally?
//                    && selected_addr[5:3] == 3'b001 // moving from home row?
//                    && cursor_contents[2:0] == EMPTY // no piece at dest?
//                    && Board[selected_addr + 6'b001_000][2:0] == EMPTY // no piece in way?
//                    && cursor_addr[5:3] > selected_addr[5:3]
//                ) move_is_legal = 1; // moving from home row by Black_Castle_State 
//                else if (
//                    v_delta == 1 // move forward by 1?
//                    && h_delta == 0
//                    && cursor_contents[2:0] == EMPTY
//                    && cursor_addr[5:3] > selected_addr[5:3]
//                ) move_is_legal = 1;
//                else if (
//                    v_delta == 1
//                    && h_delta==1 // moving diagonally by 1?
//                    && cursor_contents[3] == WHITE // capturing opponent?
//                    && cursor_contents[2:0] != EMPTY // capturing something?
//                      && cursor_addr[5:3] > selected_addr[5:3]
//                ) move_is_legal = 1;
//                else move_is_legal = 0;
//            end
//        end
    
//        else if (selected_contents[2:0] == ROOK) begin
//            move_is_legal = (h_delta == 0 || v_delta == 0); // doesnt check if there is a piece in the way?
//        end
    
//        else if(selected_contents[2:0] == KNIGHT) begin
//            move_is_legal = ((h_delta == 2 && v_delta == 1) || (v_delta == 2 && h_delta == 1));
//        end
    
//        else if (selected_contents[2:0] == BISHOP) begin
//            move_is_legal = (h_delta == v_delta);
//        end
    
//        else if (selected_contents[2:0] == QUEEN) begin
//            move_is_legal = ((h_delta == 0 || v_delta == 0) || (h_delta == v_delta));
//        end
    
//        else if(selected_contents[2:0] == KING)  begin
//            move_is_legal = ((h_delta == 0 || h_delta == 1) && ( v_delta == 0 || v_delta == 1));
//        end
        
//        else move_is_legal = 0;
//    end
//
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
    
    assign cursor_contents = Board[cursor_addr]; // contents of the cursor square
    assign selected_contents = Board[selected_addr]; // contents of the selected square
    
    assign highlight_selected_square = (Game_State == Selected);

endmodule
