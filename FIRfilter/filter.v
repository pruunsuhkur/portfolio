module transversalfir(
	input  wire signed [NUM_PRECISION   - 1 : 0] data, 
	input clk, reset,
	output wire signed [NUM_PRECISION*2 - 1 : 0] y 	);

	parameter SRL_LENGTH 		= 27;
	parameter NUM_PRECISION = 16;

	reg  signed [0 : NUM_PRECISION*2 - 1] dff   [SRL_LENGTH - 1 : 0];
	wire signed [0 : NUM_PRECISION 	 - 1] coeff [SRL_LENGTH - 1 : 0];
	wire signed [0 : NUM_PRECISION*2 - 1] mult  [SRL_LENGTH - 1 : 0];

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
				  dff[SRL_LENGTH - 1] <= mult[SRL_LENGTH - 1];
					for (i = SRL_LENGTH - 2; i > -1; i = i - 1) 
						begin
							dff[i] <= dff[i + 1] + mult[i];
						end
				end
	
	genvar gi;
	generate
	for (gi = SRL_LENGTH - 1; gi > -1; gi = gi - 1) 
		begin
			assign mult[gi] = data * coeff[gi];
		end
	endgenerate
	
	assign y = dff[0];
	
endmodule