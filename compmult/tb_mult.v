`timescale 1ns / 1ps
module tb_mult #(parameter N = 8) ();
reg clk = 0;
reg reset = 0;
reg signed [   N-1 : 0] a_r;
reg signed [   N-1 : 0] a_i; 
reg signed [   N-1 : 0] b_r; 
reg signed [   N-1 : 0] b_i; 
wire signed [2*N-1 : 0] c_r;
wire signed [2*N-1 : 0] c_i;

altbestpipe dut (clk, reset, a_r, a_i, b_r, b_i, c_r, c_i);

always #10 clk = ~clk;

initial begin 
  a_r = 1;
  a_i = 2;
  b_r = 3;
  b_i = 4;
  #5;
  reset = 1;
  #17;
  reset = 0;
  #23;
  a_r = 2;
  a_i = 3;
  b_r = 4;
  b_i = 5;
  #20;
  a_r = 3;
  a_i = 4;
  b_r = 5;
  b_i = 6;
  #300;
  $finish;
end

endmodule
