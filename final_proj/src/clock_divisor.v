`timescale 1ns / 1ps

module ClockDivisor(clk, clk1);
    input clk;
    output clk1;

    reg [26:0] num;
    wire [26:0] next_num;

    always @(posedge clk) begin
      num <= next_num;
    end

    assign next_num = num + 1'b1;

    assign clk1 = num[1];

endmodule

/* clock divisor for the flickering */
module ClockDivisorSlow (reset, clk, slow_clk);
    input reset;
    input clk;
    output slow_clk;

    reg [26:0] num;
    wire [26:0] next_num;

    always @(posedge clk) begin
        if(reset) num <= 27'd0;
        else num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign slow_clk = num[26];

endmodule
