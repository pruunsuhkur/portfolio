module altbestpipe  #(parameter N = 8) ( 
  input clk,
  input reset,
	input wire signed [  N-1 : 0] a_r, 
	input wire signed [  N-1 : 0] a_i, 
	input wire signed [  N-1 : 0] b_r, 
	input wire signed [  N-1 : 0] b_i, 
	output reg signed [2*N-1 : 0] c_r, 
	output reg signed [2*N-1 : 0] c_i);

	integer i;
	reg [0:2*N-1] stage0 [5 : 0];
  always @(posedge clk or posedge reset)
    if (reset)
        for (i = 0; i < 6; i = i + 1)
          stage0[i] <= 0;
    else  
      begin
        stage0[0] <= a_r + a_i;
        stage0[1] <= b_r + b_i;
        stage0[2] <= a_r; 
        stage0[3] <= a_i; 
        stage0[4] <= b_r; 
        stage0[5] <= b_i; 
      end
  
  reg [0:2*N-1] stage1 [2 : 0];
  always @(posedge clk or posedge reset)
    if (reset)
      for (i = 0; i < 3; i = i + 1)
        stage1[i] <= 0;
    else  
      begin
        stage1[0] <= stage0[2] * stage0[4];
        stage1[1] <= stage0[3] * stage0[5];
        stage1[2] <= stage0[0] * stage0[1];
      end
    
	reg [0:2*N-1] stage2 [2 : 0];
  always @(posedge clk or posedge reset)
    if (reset)
      for (i = 0; i < 3; i = i + 1)
        stage2[i] <= 0;
    else  
      begin
        stage2[0] <= stage1[0] - stage1[1]; 
        stage2[1] <= stage1[2] - stage1[0]; 
        stage2[2] <= stage1[1];
      end
  
  always @(posedge clk or posedge reset)
    if (reset)
      begin
        c_r <= 0;
        c_i <= 0;
      end
    else  
      begin
        c_r <= stage2[0];                            
        c_i <= stage2[1] - stage2[2];
      end  
    
endmodule
