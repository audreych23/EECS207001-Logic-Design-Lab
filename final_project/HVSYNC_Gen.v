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
           if(h_cnt == HT) h_cnt <= 0;
           else h_cnt <= h_cnt +1; 
               
           if(v_cnt == VT) v_cnt <= 0;
           else if(h_cnt == HT) v_cnt <= v_cnt + 1;
           else v_cnt <= v_cnt;
           
           hsync_i <= (h_cnt > (HD + HF - 1'd1) && h_cnt < (HD + HF + HS - 1'd1)); 
	       vsync_i <= (v_cnt == (VD + VF) || v_cnt == (VD + VF + VS - 1'd1));
	       valid <= (h_cnt < HD) && (v_cnt < VD);
       end
    end
    
    assign h_sync = ~hsync_i;
    assign v_sync = ~vsync_i;

endmodule


//`timescale 1ns / 1ps

//module VGAController (
//    input clk,
//    input reset,
//    output wire h_sync,
//    output wire v_sync,
//    output wire valid,
//    output wire [9:0]h_cnt,
//    output wire [9:0]v_cnt
//);

//    reg [9:0]pixel_cnt;
//    reg [9:0]line_cnt;
//    reg hsync_i,vsync_i;
//    wire hsync_default, vsync_default;
//    wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;

//   // difference is HT on VT
//    assign HD = 640;
//    assign HF = 16;
//    assign HS = 96;
//    assign HB = 48;
//    assign HT = 800;
//    assign VD = 480;
//    assign VF = 10;
//    assign VS = 2;
//    assign VB = 33;
//    assign VT = 521;
//    assign hsync_default = 1'b1;
//    assign vsync_default = 1'b1;

//    always@(posedge clk)
//        if(reset)
//            pixel_cnt <= 0;
//        else if(pixel_cnt < (HT - 1'd1))
//                pixel_cnt <= pixel_cnt + 1'd1;
//             else
//                pixel_cnt <= 1'd0;

//    always@(posedge clk)
//        if(reset)
//            hsync_i <= hsync_default;
//        else if((pixel_cnt >= (HD + HF - 1'd1))&&(pixel_cnt < (HD + HF + HS - 1'd1)))
//                hsync_i <= ~hsync_default;
//            else
//                hsync_i <= hsync_default; 
    
//    always@(posedge clk)
//        if(reset)
//            line_cnt <= 1'd0;
//        else if(pixel_cnt == (HT - 1'd1))
//                if(line_cnt < (VT - 1'd1))
//                    line_cnt <= line_cnt + 1'd1;
//                else
//                    line_cnt <= 1'd0;
                    
//    always@(posedge clk)
//        if(reset)
//            vsync_i <= vsync_default; 
//        else if((line_cnt >= (VD + VF - 1'd1))&&(line_cnt < (VD + VF + VS - 1'd1)))
//            vsync_i <= ~vsync_default; 
//        else
//            vsync_i <= vsync_default; 
                    
//    assign hsync = hsync_i;
//    assign vsync = vsync_i;
//    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    
//    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
//    assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;
    
//endmodule
