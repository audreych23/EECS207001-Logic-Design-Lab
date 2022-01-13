`timescale 1ns / 1ps

module Debounce(clk, pb, pb_db);
    input clk, pb;

    output pb_db;
    
    reg [3:0] DFF;

    always@(posedge clk)begin
        DFF[3:1] <= DFF[2:0];
        DFF[0] <= pb;
    end

    assign pb_db = (DFF == 4'b1111)? 1'b1 : 1'b0;
endmodule
