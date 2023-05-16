module altpipelining  #(parameter N = 8) ( 
  input clk,
	input wire signed [  N-1 : 0] a_r, 
	input wire signed [  N-1 : 0] a_i, 
	input wire signed [  N-1 : 0] b_r, 
	input wire signed [  N-1 : 0] b_i, 
	output reg signed [2*N-1 : 0] c_r, 
	output reg signed [2*N-1 : 0] c_i);

  reg [0:2*N-1] temp [2 : 0];
  always @(posedge clk)
    begin
      temp[0] <= a_r * b_r;
      temp[1] <= a_i * b_i;
      temp[2] <= (a_r + a_i) * (b_r + b_i);
    end
  
  always @(posedge clk)
    begin
      c_r <= temp[0] - temp[1];                            
      c_i <= temp[2] - temp[0] - temp[1];
    end  
    
endmodule
