module altnopipelining  #(parameter N = 8) ( 
  input clk,
	input wire signed [  N-1 : 0] a_r, 
	input wire signed [  N-1 : 0] a_i, 
	input wire signed [  N-1 : 0] b_r, 
	input wire signed [  N-1 : 0] b_i, 
	output reg signed [2*N-1 : 0] c_r, 
	output reg signed [2*N-1 : 0] c_i);
    
  wire signed [2*N-1 : 0] mult1;
  wire signed [2*N-1 : 0] mult2;
  
  assign mult1 = a_r * b_r;
  assign mult2 = a_i * b_i;

  always @(posedge clk)
    begin
      c_r <= mult1 - mult2;
      c_i <= (a_r + a_i) * (b_r + b_i) - mult1 - mult2;
    end
    
endmodule
