module nopipelining  #(parameter N = 8) ( 
  input clk, 
  input wire signed [  N-1 : 0] a_r, 
  input wire signed [  N-1 : 0] a_i, 
  input wire signed [  N-1 : 0] b_r, 
  input wire signed [  N-1 : 0] b_i, 
  output reg signed [2*N-1 : 0] c_r, 
  output reg signed [2*N-1 : 0] c_i);
  
  always @(posedge clk)
    begin
      c_r <= a_r * b_r - a_i * b_i;
      c_i <= a_r * b_i + a_i * b_r;
    end
    
endmodule
