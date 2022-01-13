`timescale 1ns / 1ps

module clock_divisor(clk, clk1, clk11);
    input clk;
    output clk1;
    output clk11;
    
    reg [26:0] num;
    wire [26:0] next_num;
    
    always @(posedge clk) begin
      num <= next_num;
    end
    
    assign next_num = num + 1'b1;
    
    assign clk1 = num[1];
    assign clk11 = num[11];

endmodule
