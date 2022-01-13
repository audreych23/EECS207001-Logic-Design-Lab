`timescale 1ns / 1ps

module onepulse(clk, pb_db, pb_op);
    input clk, pb_db;
    
    output reg pb_op;
    
    reg pb_delay;
    
    always@(posedge clk)begin
        pb_op <= pb_db & (!pb_delay);
        pb_delay <= pb_db;
    end
    
endmodule
