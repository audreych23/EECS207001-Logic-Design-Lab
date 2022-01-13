`timescale 1ns / 1ps

module VGAController(
    input clk,
    input reset,
    output h_sync,
    output v_sync,
    output reg valid,
    output reg [9:0] h_cnt,
    output reg [9:0] v_cnt
);

    reg hsync_i, vsync_i;

    parameter HD = 10'd640;
    parameter HF = 10'd16;
    parameter HS = 10'd96;
    parameter HB = 10'd48;
    parameter HT = 10'd800;
    parameter VD = 10'd480;
    parameter VF = 10'd10;
    parameter VS = 10'd2;
    parameter VB = 10'd33;
    parameter VT = 10'd521;

    //increment column counter
    always @(posedge clk)begin
       if(reset)begin
          h_cnt <= 0;
          v_cnt <= 0;
          valid <= 0;
       end
       else begin
           if (h_cnt == HT) h_cnt <= 0;
           else h_cnt <= h_cnt +1;

           if (v_cnt == VT) v_cnt <= 0;
           else if (h_cnt == HT) v_cnt <= v_cnt + 1;
           else v_cnt <= v_cnt;

           hsync_i <= (h_cnt > (HD + HF - 1'd1) && h_cnt < (HD + HF + HS - 1'd1));
	         vsync_i <= (v_cnt == (VD + VF) || v_cnt == (VD + VF + VS - 1'd1));
	         valid <= (h_cnt < HD) && (v_cnt < VD);
       end
    end

    assign h_sync = ~hsync_i;
    assign v_sync = ~vsync_i;

endmodule
