`timescale 1ns / 1ps

module Top(
   input clk,
   input rst, //reset will be temporarily be on switch
   input BLeft,
   input BRight,
   input BUp,
   input BDown,
   input BCenter,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
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

    wire BLeft_db, BLeft_op;
    wire BRight_db, BRight_op;
    wire BUp_db, BUp_op;
    wire BDown_db, BDown_op;
    wire BCenter_db, BCenter_op;
    
    wire VGA_clk, Game_Logic_clk;
    
    //game state wires
    wire[5:0] board_change_addr;
    wire[3:0] board_change_piece;
    
    wire[5:0] cursor_addr;
    wire[5:0] selected_piece_addr;
    
    wire highlight_selected_square;
    
    wire[3:0] logic_state;
    
    wire board_change_en_wire;
    
    wire is_in_initial_state;
    
    reg [3:0] board[63:0];
    reg [3:0] next_board[63:0];
    
    wire [255:0] passable_board;
    
    assign passable_board[3 : 0] = board[0];
    assign passable_board[7 : 4] = board[1];
    assign passable_board[11 : 8] = board[2];
    assign passable_board[15 : 12] = board[3];
    assign passable_board[19 : 16] = board[4];
    assign passable_board[23 : 20] = board[5];
    assign passable_board[27 : 24] = board[6];
    assign passable_board[31 : 28] = board[7];
    
    assign passable_board[35 : 32] = board[8];
    assign passable_board[39 : 36] = board[9];
    assign passable_board[43 : 40] = board[10];
    assign passable_board[47 : 44] = board[11];
    assign passable_board[51 : 48] = board[12];
    assign passable_board[55 : 52] = board[13];
    assign passable_board[59 : 56] = board[14];
    assign passable_board[63 : 60] = board[15];
    
    assign passable_board[67 : 64] = board[16];
    assign passable_board[71 : 68] = board[17];
    assign passable_board[75 : 72] = board[18];
    assign passable_board[79 : 76] = board[19];
    assign passable_board[83 : 80] = board[20];
    assign passable_board[87 : 84] = board[21];
    assign passable_board[91 : 88] = board[22];
    assign passable_board[95 : 92] = board[23];
    
    assign passable_board[99 : 96] = board[24];
    assign passable_board[103 : 100] = board[25];
    assign passable_board[107 : 104] = board[26];
    assign passable_board[111 : 108] = board[27];
    assign passable_board[115 : 112] = board[28];
    assign passable_board[119 : 116] = board[29];
    assign passable_board[123 : 120] = board[30];
    assign passable_board[127 : 124] = board[31];
    
    assign passable_board[131 : 128] = board[32];
    assign passable_board[135 : 132] = board[33];
    assign passable_board[139 : 136] = board[34];
    assign passable_board[143 : 140] = board[35];
    assign passable_board[147 : 144] = board[36];
    assign passable_board[151 : 148] = board[37];
    assign passable_board[155 : 152] = board[38];
    assign passable_board[159 : 156] = board[39];
    
    assign passable_board[163 : 160] = board[40];
    assign passable_board[167 : 164] = board[41];
    assign passable_board[171 : 168] = board[42];
    assign passable_board[175 : 172] = board[43];
    assign passable_board[179 : 176] = board[44];
    assign passable_board[183 : 180] = board[45];
    assign passable_board[187 : 184] = board[46];
    assign passable_board[191 : 188] = board[47];
    
    assign passable_board[195 : 192] = board[48];
    assign passable_board[199 : 196] = board[49];
    assign passable_board[203 : 200] = board[50];
    assign passable_board[207 : 204] = board[51];
    assign passable_board[211 : 208] = board[52];
    assign passable_board[215 : 212] = board[53];
    assign passable_board[219 : 216] = board[54];
    assign passable_board[223 : 220] = board[55];
    
    assign passable_board[227 : 224] = board[56];
    assign passable_board[231 : 228] = board[57];
    assign passable_board[235 : 232] = board[58];
    assign passable_board[239 : 236] = board[59];
    assign passable_board[243 : 240] = board[60];
    assign passable_board[247 : 244] = board[61];
    assign passable_board[251 : 248] = board[62];
    assign passable_board[255 : 252] = board[63];
    
    assign vgaRed[3] = 1'b0;
    assign vgaGreen[3] = 1'b0;
    assign vgaBlue[3:2] = 2'b00;
    
    always @(posedge clk)begin
        if(rst)begin //reset the board
            board[6'b000_000] <= { BLACK, ROOK };
            board[6'b000_001] <= { BLACK, KNIGHT };
            board[6'b000_010] <= { BLACK, BISHOP };
            board[6'b000_011] <= { BLACK, QUEEN };
            board[6'b000_100] <= { BLACK, KING };
            board[6'b000_101] <= { BLACK, BISHOP };
            board[6'b000_110] <= { BLACK, KNIGHT };
            board[6'b000_111] <= { BLACK, ROOK };

            board[6'b001_000] <= { BLACK, PAWN };
            board[6'b001_001] <= { BLACK, PAWN };
            board[6'b001_010] <= { BLACK, PAWN };
            board[6'b001_011] <= { BLACK, PAWN };
            board[6'b001_100] <= { BLACK, PAWN };
            board[6'b001_101] <= { BLACK, PAWN };
            board[6'b001_110] <= { BLACK, PAWN };
            board[6'b001_111] <= { BLACK, PAWN };

            board[6'b010_000] <= { WHITE, EMPTY };
            board[6'b010_001] <= { WHITE, EMPTY };
            board[6'b010_010] <= { WHITE, EMPTY };
            board[6'b010_011] <= { WHITE, EMPTY };
            board[6'b010_100] <= { WHITE, EMPTY };
            board[6'b010_101] <= { WHITE, EMPTY };
            board[6'b010_110] <= { WHITE, EMPTY };
            board[6'b010_111] <= { WHITE, EMPTY };

            board[6'b011_000] <= { WHITE, EMPTY };
            board[6'b011_001] <= { WHITE, EMPTY };
            board[6'b011_010] <= { WHITE, EMPTY };
            board[6'b011_011] <= { WHITE, EMPTY };
            board[6'b011_100] <= { WHITE, EMPTY };
            board[6'b011_101] <= { WHITE, EMPTY };
            board[6'b011_110] <= { WHITE, EMPTY };
            board[6'b011_111] <= { WHITE, EMPTY };

            board[6'b100_000] <= { WHITE, EMPTY };
            board[6'b100_001] <= { WHITE, EMPTY };
            board[6'b100_010] <= { WHITE, EMPTY };
            board[6'b100_011] <= { WHITE, EMPTY };
            board[6'b100_100] <= { WHITE, EMPTY };
            board[6'b100_101] <= { WHITE, EMPTY };
            board[6'b100_110] <= { WHITE, EMPTY };
            board[6'b100_111] <= { WHITE, EMPTY };

            board[6'b101_000] <= { WHITE, EMPTY };
            board[6'b101_001] <= { WHITE, EMPTY };
            board[6'b101_010] <= { WHITE, EMPTY };
            board[6'b101_011] <= { WHITE, EMPTY };
            board[6'b101_100] <= { WHITE, EMPTY };
            board[6'b101_101] <= { WHITE, EMPTY };
            board[6'b101_110] <= { WHITE, EMPTY };
            board[6'b101_111] <= { WHITE, EMPTY };

            board[6'b110_000] <= { WHITE, PAWN };
            board[6'b110_001] <= { WHITE, PAWN };
            board[6'b110_010] <= { WHITE, PAWN };
            board[6'b110_011] <= { WHITE, PAWN };
            board[6'b110_100] <= { WHITE, PAWN };
            board[6'b110_101] <= { WHITE, PAWN };
            board[6'b110_110] <= { WHITE, PAWN };
            board[6'b110_111] <= { WHITE, PAWN };

            board[6'b111_000] <= { WHITE, ROOK };
            board[6'b111_001] <= { WHITE, KNIGHT };
            board[6'b111_010] <= { WHITE, BISHOP };
            board[6'b111_011] <= { WHITE, QUEEN };
            board[6'b111_100] <= { WHITE, KING };
            board[6'b111_101] <= { WHITE, BISHOP };
            board[6'b111_110] <= { WHITE, KNIGHT };
            board[6'b111_111] <= { WHITE, ROOK };
        end
        else begin //update board
            board[6'b000_000] <= next_board[6'b000_000];
            board[6'b000_001] <= next_board[6'b000_001];
            board[6'b000_010] <= next_board[6'b000_010];
            board[6'b000_011] <= next_board[6'b000_011];
            board[6'b000_100] <= next_board[6'b000_100];
            board[6'b000_101] <= next_board[6'b000_101];
            board[6'b000_110] <= next_board[6'b000_110];
            board[6'b000_111] <= next_board[6'b000_111];

            board[6'b001_000] <= next_board[6'b001_000];
            board[6'b001_001] <= next_board[6'b001_001];
            board[6'b001_010] <= next_board[6'b001_010];
            board[6'b001_011] <= next_board[6'b001_011];
            board[6'b001_100] <= next_board[6'b001_100];
            board[6'b001_101] <= next_board[6'b001_101];
            board[6'b001_110] <= next_board[6'b001_110];
            board[6'b001_111] <= next_board[6'b001_111];

            board[6'b010_000] <= next_board[6'b010_000];
            board[6'b010_001] <= next_board[6'b010_001];
            board[6'b010_010] <= next_board[6'b010_010];
            board[6'b010_011] <= next_board[6'b010_011];
            board[6'b010_100] <= next_board[6'b010_100];
            board[6'b010_101] <= next_board[6'b010_101];
            board[6'b010_110] <= next_board[6'b010_110];
            board[6'b010_111] <= next_board[6'b010_111];

            board[6'b011_000] <= next_board[6'b011_000];
            board[6'b011_001] <= next_board[6'b011_001];
            board[6'b011_010] <= next_board[6'b011_010];
            board[6'b011_011] <= next_board[6'b011_011];
            board[6'b011_100] <= next_board[6'b011_100];
            board[6'b011_101] <= next_board[6'b011_101];
            board[6'b011_110] <= next_board[6'b011_110];
            board[6'b011_111] <= next_board[6'b011_111];

            board[6'b100_000] <= next_board[6'b100_000];
            board[6'b100_001] <= next_board[6'b100_001];
            board[6'b100_010] <= next_board[6'b100_010];
            board[6'b100_011] <= next_board[6'b100_011];
            board[6'b100_100] <= next_board[6'b100_100];
            board[6'b100_101] <= next_board[6'b100_101];
            board[6'b100_110] <= next_board[6'b100_110];
            board[6'b100_111] <= next_board[6'b100_111];

            board[6'b101_000] <= next_board[6'b101_000];
            board[6'b101_001] <= next_board[6'b101_001];
            board[6'b101_010] <= next_board[6'b101_010];
            board[6'b101_011] <= next_board[6'b101_011];
            board[6'b101_100] <= next_board[6'b101_100];
            board[6'b101_101] <= next_board[6'b101_101];
            board[6'b101_110] <= next_board[6'b101_110];
            board[6'b101_111] <= next_board[6'b101_111];

            board[6'b110_000] <= next_board[6'b110_000];
            board[6'b110_001] <= next_board[6'b110_001];
            board[6'b110_010] <= next_board[6'b110_010];
            board[6'b110_011] <= next_board[6'b110_011];
            board[6'b110_100] <= next_board[6'b110_100];
            board[6'b110_101] <= next_board[6'b110_101];
            board[6'b110_110] <= next_board[6'b110_110];
            board[6'b110_111] <= next_board[6'b110_111];

            board[6'b111_000] <= next_board[6'b111_000];
            board[6'b111_001] <= next_board[6'b111_001];
            board[6'b111_010] <= next_board[6'b111_010];
            board[6'b111_011] <= next_board[6'b111_011];
            board[6'b111_100] <= next_board[6'b111_100];
            board[6'b111_101] <= next_board[6'b111_101];
            board[6'b111_110] <= next_board[6'b111_110];
            board[6'b111_111] <= next_board[6'b111_111];
        end
    end
    
    always @(*)begin
        next_board[6'b000_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_000)? board_change_piece : board[6'b000_000];
        next_board[6'b000_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_001)? board_change_piece : board[6'b000_001];
        next_board[6'b000_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_010)? board_change_piece : board[6'b000_010];
        next_board[6'b000_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_011)? board_change_piece : board[6'b000_011];
        next_board[6'b000_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_100)? board_change_piece : board[6'b000_100];
        next_board[6'b000_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_101)? board_change_piece : board[6'b000_101];
        next_board[6'b000_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_110)? board_change_piece : board[6'b000_110];
        next_board[6'b000_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b000_111)? board_change_piece : board[6'b000_111];

        next_board[6'b001_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_000)? board_change_piece : board[6'b001_000];
        next_board[6'b001_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_001)? board_change_piece : board[6'b001_001];
        next_board[6'b001_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_010)? board_change_piece : board[6'b001_010];
        next_board[6'b001_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_011)? board_change_piece : board[6'b001_011];
        next_board[6'b001_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_100)? board_change_piece : board[6'b001_100];
        next_board[6'b001_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_101)? board_change_piece : board[6'b001_101];
        next_board[6'b001_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_110)? board_change_piece : board[6'b001_110];
        next_board[6'b001_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b001_111)? board_change_piece : board[6'b001_111];

        next_board[6'b010_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_000)? board_change_piece : board[6'b010_000];
        next_board[6'b010_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_001)? board_change_piece : board[6'b010_001];
        next_board[6'b010_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_010)? board_change_piece : board[6'b010_010];
        next_board[6'b010_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_011)? board_change_piece : board[6'b010_011];
        next_board[6'b010_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_100)? board_change_piece : board[6'b010_100];
        next_board[6'b010_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_101)? board_change_piece : board[6'b010_101];
        next_board[6'b010_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_110)? board_change_piece : board[6'b010_110];
        next_board[6'b010_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b010_111)? board_change_piece : board[6'b010_111];

        next_board[6'b011_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_000)? board_change_piece : board[6'b011_000];
        next_board[6'b011_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_001)? board_change_piece : board[6'b011_001];
        next_board[6'b011_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_010)? board_change_piece : board[6'b011_010];
        next_board[6'b011_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_011)? board_change_piece : board[6'b011_011];
        next_board[6'b011_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_100)? board_change_piece : board[6'b011_100];
        next_board[6'b011_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_101)? board_change_piece : board[6'b011_101];
        next_board[6'b011_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_110)? board_change_piece : board[6'b011_110];
        next_board[6'b011_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b011_111)? board_change_piece : board[6'b011_111];

        next_board[6'b100_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_000)? board_change_piece : board[6'b100_000];
        next_board[6'b100_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_001)? board_change_piece : board[6'b100_001];
        next_board[6'b100_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_010)? board_change_piece : board[6'b100_010];
        next_board[6'b100_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_011)? board_change_piece : board[6'b100_011];
        next_board[6'b100_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_100)? board_change_piece : board[6'b100_100];
        next_board[6'b100_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_101)? board_change_piece : board[6'b100_101];
        next_board[6'b100_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_110)? board_change_piece : board[6'b100_110];
        next_board[6'b100_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b100_111)? board_change_piece : board[6'b100_111];

        next_board[6'b101_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_000)? board_change_piece : board[6'b101_000];
        next_board[6'b101_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_001)? board_change_piece : board[6'b101_001];
        next_board[6'b101_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_010)? board_change_piece : board[6'b101_010];
        next_board[6'b101_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_011)? board_change_piece : board[6'b101_011];
        next_board[6'b101_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_100)? board_change_piece : board[6'b101_100];
        next_board[6'b101_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_101)? board_change_piece : board[6'b101_101];
        next_board[6'b101_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_110)? board_change_piece : board[6'b101_110];
        next_board[6'b101_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b101_111)? board_change_piece : board[6'b101_111];

        next_board[6'b110_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_000)? board_change_piece : board[6'b110_000];
        next_board[6'b110_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_001)? board_change_piece : board[6'b110_001];
        next_board[6'b110_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_010)? board_change_piece : board[6'b110_010];
        next_board[6'b110_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_011)? board_change_piece : board[6'b110_011];
        next_board[6'b110_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_100)? board_change_piece : board[6'b110_100];
        next_board[6'b110_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_101)? board_change_piece : board[6'b110_101];
        next_board[6'b110_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_110)? board_change_piece : board[6'b110_110];
        next_board[6'b110_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b110_111)? board_change_piece : board[6'b110_111];

        next_board[6'b111_000] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_000)? board_change_piece : board[6'b111_000];
        next_board[6'b111_001] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_001)? board_change_piece : board[6'b111_001];
        next_board[6'b111_010] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_010)? board_change_piece : board[6'b111_010];
        next_board[6'b111_011] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_011)? board_change_piece : board[6'b111_011];
        next_board[6'b111_100] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_100)? board_change_piece : board[6'b111_100];
        next_board[6'b111_101] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_101)? board_change_piece : board[6'b111_101];
        next_board[6'b111_110] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_110)? board_change_piece : board[6'b111_110];
        next_board[6'b111_111] = (board_change_en_wire == 1 &&  board_change_addr == 6'b111_111)? board_change_piece : board[6'b111_111];
    end
    
    debounce
    LDB(.clk(Game_Logic_clk), .pb(BLeft), .pb_db(BLeft_db)),
    RDB(.clk(Game_Logic_clk), .pb(BRight), .pb_db(BRight_db)),
    UDB(.clk(Game_Logic_clk), .pb(BUp), .pb_db(BUp_db)),
    DDB(.clk(Game_Logic_clk), .pb(BDown), .pb_db(BDown_db)),
    CDB(.clk(Game_Logic_clk), .pb(BCenter), .pb_db(BCenter_db));

    onepulse
    LOP(.clk(Game_Logic_clk), .pb_db(BLeft_db), .pb_op(BLeft_op)),
    ROP(.clk(Game_Logic_clk), .pb_db(BRight_db), .pb_op(BRight_op)),
    UOP(.clk(Game_Logic_clk), .pb_db(BUp_db), .pb_op(BUp_op)),
    DOP(.clk(Game_Logic_clk), .pb_db(BDown_db), .pb_op(BDown_op)),
    COP(.clk(Game_Logic_clk), .pb_db(BCenter_db), .pb_op(BCenter_op));
        
    clock_divisor CD(.clk(clk), .clk1(VGA_clk), .clk11(Game_Logic_clk));
    
    Display_Interface DI(
        .clk(VGA_clk),
        .rst(Reset),
        .Passed_Board(passable_board),
        .Cursor_Addr(cursor_addr), // 6 bit address showing what square to hilite
        .Select_Addr(selected_piece_addr), // 6b address showing the address of which piece is selected
        .Select_En(highlight_selected_square),// binary flag to show a selected piece
        .hsync(hsync), // direct outputs to VGA monitor
        .vsync(vsync),
        .R(vgaRed[2:0]),
        .G(vgaGreen[2:0]),
        .B(vgaBlue[1:0])
	); 
	
	Game_Logic GL(
        .clk(Game_Logic_clk), 
        .rst(rst),
        .BtnL(BLeft_op),
        .BtnU(BUp_op),
        .BtnR(BRight_op),
        .BtnD(BDown_op),
        .BtnC(BCenter_op),
        .Passed_Board(passable_board),
        .board_out_addr(board_change_addr),//the spot of the moved piece
        .board_out_piece(board_change_piece), //the moved piece
        .board_change_en_wire(board_change_en_wire), //triggers when there is a change
        .cursor_addr(cursor_addr),
        .selected_addr(selected_piece_addr),
        .highlight_selected_square(highlight_selected_square),
        .Game_State(logic_state),
        .move_is_legal(Ld4),
        .is_in_initial_state(is_in_initial_state)
	);    
    
endmodule
