module lut_based_nco #( parameter LUT_WIDTH  = 16, 
                                  LUT_LENGTH = 6, 
                       localparam PHASE_BITWIDTH_INTEGER = LUT_LENGTH, 
                                  PHASE_BITWIDTH_FRACTIONAL = 2, 
                                  ACC_SIZE = PHASE_BITWIDTH_INTEGER + PHASE_BITWIDTH_FRACTIONAL)
(
    input wire                            iclk, 
    input wire 														inCS,
    input wire                            iresetn,
    input wire        [ACC_SIZE  - 1 : 0] step,
    output reg signed [LUT_WIDTH - 1 : 0] out 
);
    
    reg [ACC_SIZE  + 1 : 0] accum; 
    reg [LUT_WIDTH - 1 : 0] LUT; 
    wire [ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL] mem_addr;
    assign mem_addr = (accum[ACC_SIZE]) ? ~accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL] : accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL];
    
    always @(posedge iclk or negedge iresetn)
        if (~iresetn)
        		LUT <= 16'b0;   
        else
        		if (~inCS)
            		case (mem_addr)
                		6'b000000 : LUT <= 16'b0000000000000000; 
                		6'b000001 : LUT <= 16'b0000001100101010; 
                		6'b000010 : LUT <= 16'b0000011001010100; 
                		6'b000011 : LUT <= 16'b0000100101111101; 
                		6'b000100 : LUT <= 16'b0000110010100101; 
                		6'b000101 : LUT <= 16'b0000111111001010; 
                		6'b000110 : LUT <= 16'b0001001011101101; 
                		6'b000111 : LUT <= 16'b0001011000001101; 
                		6'b001000 : LUT <= 16'b0001100100101010; 
                		6'b001001 : LUT <= 16'b0001110001000011; 
                		6'b001010 : LUT <= 16'b0001111101010111; 
                		6'b001011 : LUT <= 16'b0010001001100110; 
                		6'b001100 : LUT <= 16'b0010010101110000; 
                		6'b001101 : LUT <= 16'b0010100001110100; 
                		6'b001110 : LUT <= 16'b0010101101110010; 
                		6'b001111 : LUT <= 16'b0010111001101001; 
                		6'b010000 : LUT <= 16'b0011000101011001; 
                		6'b010001 : LUT <= 16'b0011010001000001; 
                		6'b010010 : LUT <= 16'b0011011100100001; 
                		6'b010011 : LUT <= 16'b0011100111111000; 
                		6'b010100 : LUT <= 16'b0011110011000110; 
                		6'b010101 : LUT <= 16'b0011111110001010; 
                		6'b010110 : LUT <= 16'b0100001001000101; 
                		6'b010111 : LUT <= 16'b0100010011110101; 
                		6'b011000 : LUT <= 16'b0100011110011011; 
                		6'b011001 : LUT <= 16'b0100101000110101; 
                		6'b011010 : LUT <= 16'b0100110011000011; 
                		6'b011011 : LUT <= 16'b0100111101000110; 
                		6'b011100 : LUT <= 16'b0101000110111100; 
                		6'b011101 : LUT <= 16'b0101010000100101; 
                		6'b011110 : LUT <= 16'b0101011010000010; 
                		6'b011111 : LUT <= 16'b0101100011010000; 
                		6'b100000 : LUT <= 16'b0101101100010001; 
                		6'b100001 : LUT <= 16'b0101110101000011; 
                		6'b100010 : LUT <= 16'b0101111101100111; 
                		6'b100011 : LUT <= 16'b0110000101111100; 
                		6'b100100 : LUT <= 16'b0110001110000010; 
                		6'b100101 : LUT <= 16'b0110010101111000; 
                		6'b100110 : LUT <= 16'b0110011101011110; 
                		6'b100111 : LUT <= 16'b0110100100110100; 
                		6'b101000 : LUT <= 16'b0110101011111001; 
                		6'b101001 : LUT <= 16'b0110110010101110; 
                		6'b101010 : LUT <= 16'b0110111001010001; 
                		6'b101011 : LUT <= 16'b0110111111100100; 
                		6'b101100 : LUT <= 16'b0111000101100101; 
                		6'b101101 : LUT <= 16'b0111001011010100; 
                		6'b101110 : LUT <= 16'b0111010000110001; 
                		6'b101111 : LUT <= 16'b0111010101111100; 
                		6'b110000 : LUT <= 16'b0111011010110100; 
                		6'b110001 : LUT <= 16'b0111011111011010; 
                		6'b110010 : LUT <= 16'b0111100011101101; 
                		6'b110011 : LUT <= 16'b0111100111101101; 
                		6'b110100 : LUT <= 16'b0111101011011011; 
                		6'b110101 : LUT <= 16'b0111101110110100; 
                		6'b110110 : LUT <= 16'b0111110001111011; 
                		6'b110111 : LUT <= 16'b0111110100101110; 
                		6'b111000 : LUT <= 16'b0111110111001101; 
                		6'b111001 : LUT <= 16'b0111111001011001; 
                		6'b111010 : LUT <= 16'b0111111011010001; 
                		6'b111011 : LUT <= 16'b0111111100110101; 
                		6'b111100 : LUT <= 16'b0111111110000101; 
                		6'b111101 : LUT <= 16'b0111111111000001; 
                		6'b111110 : LUT <= 16'b0111111111101001; 
                		6'b111111 : LUT <= 16'b0111111111111101;  
            endcase
    
    always @(posedge iclk or negedge iresetn) 
        if (~iresetn)
            accum <= 10'b0;
        else 
        		if (~inCS)
            		accum <= accum  + {{2{step[ACC_SIZE - 1]}}, step};
          
    always @(posedge iclk or negedge iresetn)
    		begin
    				if (~iresetn)
    						out <= 16'b0;
						else if (~inCS)
								out <= (accum[ACC_SIZE + 1]) ? (~LUT) : (LUT);
				end

endmodule
