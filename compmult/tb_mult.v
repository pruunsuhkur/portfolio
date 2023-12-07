`timescale 1ns / 1ps
module tb_mult #(parameter N = 8) ();
reg  clk = 0;
reg  reset = 0;
reg  signed [  N-1 : 0] a_r;
reg  signed [  N-1 : 0] a_i; 
reg  signed [  N-1 : 0] b_r; 
reg  signed [  N-1 : 0] b_i; 
wire signed [2*N-1 : 0] c_r;
wire signed [2*N-1 : 0] c_i;

compmult dut (clk, reset, a_r, a_i, b_r, b_i, c_r, c_i);

always #5 clk = ~clk;

initial begin 
  a_r = 1;
  a_i = 2;
  b_r = 3;
  b_i = 4;
  #1;
  reset = 1;
  #2;
  reset = 0;
  #9;
  a_r = 2;
  a_i = 3;
  b_r = 4;
  b_i = 5;
  #10;
  a_r = 3;
  a_i = 4;
  b_r = 5;
  b_i = 6;
  #10;
  a_r = 0;
  a_i = 0;
  b_r = 0;
  b_i = 0;
  #10
  a_r = 121;
  a_i = 122;
  b_r = 123;
  b_i = 124;
  #10
  a_r = 0;
  a_i = 0;
  b_r = 0;
  b_i = 0;
  #50;
  $finish;
end

endmodule

