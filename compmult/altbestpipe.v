`timescale 1ns/1ps
module compmult  #(parameter N = 8) ( 
  input clk,
  input reset,
	input wire signed [  N-1 : 0] a_r, 
	input wire signed [  N-1 : 0] a_i, 
	input wire signed [  N-1 : 0] b_r, 
	input wire signed [  N-1 : 0] b_i, 
	output reg signed [2*N-1 : 0] c_r, 
	output reg signed [2*N-1 : 0] c_i);

	reg signed [0:N  ] stage0_0;
  reg signed [0:N  ] stage0_1;
  reg signed [0:N-1] stage0_2;
  reg signed [0:N-1] stage0_3;
  reg signed [0:N-1] stage0_4;
  reg signed [0:N-1] stage0_5;
  always @(posedge clk  or posedge reset)
    if (reset) 
      begin
        stage0_0 <= 9'b0;
        stage0_1 <= 9'b0;
        stage0_2 <= 8'b0;
        stage0_3 <= 8'b0;
        stage0_4 <= 8'b0;
        stage0_5 <= 8'b0;
      end
    else  
      begin
        stage0_0 <= a_r + a_i;
        stage0_1 <= b_r + b_i;
        stage0_2 <= a_r; 
        stage0_3 <= a_i; 
        stage0_4 <= b_r; 
        stage0_5 <= b_i; 
      end
  
  reg signed [0:2*N-1] stage1 [2 : 0];
  always @(posedge clk or posedge reset)
    if (reset)
      begin
        stage1[0] <= 16'b0;
        stage1[1] <= 16'b0;
        stage1[2] <= 16'b0;
      end
    else  
      begin
        stage1[0] <= stage0_2 * stage0_4;
        stage1[1] <= stage0_3 * stage0_5;
        stage1[2] <= stage0_0 * stage0_1;
      end
    
	reg signed [0:2*N-1] stage2 [2 : 0];
  always @(posedge clk or posedge reset)
    if (reset)
      begin
        stage2[0] <= 16'b0;
        stage2[1] <= 16'b0;
        stage2[2] <= 16'b0;
      end
    else  
      begin
        stage2[0] <= stage1[0] - stage1[1]; 
        stage2[1] <= stage1[2] - stage1[0]; 
        stage2[2] <= stage1[1];
      end
  
  always @(posedge clk or posedge reset)
    if (reset)
      begin
        c_r <= 16'b0;
        c_i <= 16'b0;
      end
    else  
      begin
        c_r <= stage2[0];                            
        c_i <= stage2[1] - stage2[2];
      end  
    
endmodule

