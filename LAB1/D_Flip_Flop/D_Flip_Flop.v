`timescale 1ns/1ps

module D_Flip_Flop(clk, d, q);
input clk;
input d;
output q;

wire clkbar;
wire master;
not n0(clkbar, clk);

D_Latch Dmaster(clkbar, d, master);
D_Latch Dslave(clk, master, q);

endmodule

module D_Latch(e, d, q);
input e;
input d;
output q;

wire dbar;
wire w0, w1;
wire qbar;

not n0(dbar, d);

nand nand0(w0, d, e);
nand nand1(w1, dbar, e);

nand nand2(q, w0, qbar);
nand nand3(qbar, w1, q);


endmodule
