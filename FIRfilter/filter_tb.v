`timescale 1ns / 1ps
module tb #(parameter SRL_LENGTH=27, NUM_PRECISION=16);

reg signed [NUM_PRECISION - 1 : 0] data;
reg clk = 0;
reg reset = 0;
wire signed [NUM_PRECISION*2 - 2 : 0] y;

simplelfir DUT(data, clk, reset, y);
always #1 clk=~clk;
// impulse responce
//initial data <= 2**(NUM_PRECISION - 1) - 1;
//initial #1 reset = 1;
//initial #2 reset = 0;
//initial #4 data <= 0;
// sinewave responce
real x = 0, z = 0, f = 0;
always #1 z = $sin(x)*(2**(NUM_PRECISION - 1) - 1);
always #1 x = x + f;
always #1 f = f + 0.00007;
initial data <= 0;
always #1 data <= z;

endmodule
