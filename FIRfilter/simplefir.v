module simplelfir(
	input wire signed [NUM_PRECISION   - 1 : 0] data, 
	input clk, reset,
	output reg signed [NUM_PRECISION*2 - 1 : 0] y 	);

	parameter SRL_LENGTH 		= 27;
	parameter NUM_PRECISION = 16;

	reg  signed [0 : NUM_PRECISION - 1] dff   [SRL_LENGTH - 1 : 0];
	wire signed [0 : NUM_PRECISION - 1] coeff [SRL_LENGTH - 1 : 0];

	integer i;

	assign
				coeff[0]  = 272,
				coeff[1]  = 449,
				coeff[2]  = -266,
				coeff[3]  = -540,
				coeff[4]  = -55,
				coeff[5]  = -227,
				coeff[6]  = -1029,
				coeff[7]  = 745,
				coeff[8]  = 3927,
				coeff[9]  = 1699,
				coeff[10] = -5616,
				coeff[11] = -6594,
				coeff[12] = 2766,
				coeff[13] = 9228,
				coeff[14] = 2766,
				coeff[15] = -6594,
				coeff[16] = -5616,
				coeff[17] = 1699,
				coeff[18] = 3927,
				coeff[19] = 745,
				coeff[20] = -1029,
				coeff[21] = -227,
				coeff[22] = -55,
				coeff[23] = -540,
				coeff[24] = -266,
				coeff[25] = 449,
				coeff[26] = 272;

	always @(posedge clk) 
			if (reset) 
				for (i = 0; i < SRL_LENGTH; i = i + 1) 
					begin
						dff[i] <= {NUM_PRECISION{1'b0}};
					end
			else 
				begin
					dff[0] <= data;
					for (i = 0; i < SRL_LENGTH; i = i + 1) 
						begin
							dff[i + 1] <= dff[i];
						end
				end

		
		always @(posedge clk) 
			if (reset) 
				y <= {NUM_PRECISION{1'b0}};
			else 
				y <= (coeff[0] * dff[0]) + (coeff[1] * dff[1]) + (coeff[2] * dff[2]) + (coeff[3] * dff[3]) + (coeff[4] * dff[4]) + 
						 (coeff[5] * dff[5]) + (coeff[6] * dff[6]) + (coeff[7] * dff[7]) + (coeff[8] * dff[8]) + (coeff[9] * dff[9]) + 
						 (coeff[10] * dff[10]) + (coeff[11] * dff[11]) + (coeff[12] * dff[12]) + (coeff[13] * dff[13]) + (coeff[14] * dff[14]) + 
						 (coeff[15] * dff[15]) + (coeff[16] * dff[16]) + (coeff[17] * dff[17]) + (coeff[18] * dff[18]) + (coeff[19] * dff[19]) + 
						 (coeff[20] * dff[20]) + (coeff[21] * dff[21]) + (coeff[22] * dff[22]) + (coeff[23] * dff[23]) + (coeff[24] * dff[24]) + 
						 (coeff[25] * dff[25]) + (coeff[26] * dff[26]);
	
endmodule