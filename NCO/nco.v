module NCO(
  input clk, reset,
  input  wire signed [ACC_SIZE - 1 + 1 : 0] step,
  output reg  signed [LUT_WIDTH  + 1 - 1 : 0] out );
  
  parameter LUT_WIDTH  = 32;
  parameter LUT_LENGTH = 6;
  localparam PHASE_BITWIDTH_INTEGER = LUT_LENGTH;
  localparam PHASE_BITWIDTH_FRACTIONAL = 2;
  localparam ACC_SIZE = PHASE_BITWIDTH_INTEGER + PHASE_BITWIDTH_FRACTIONAL;
  
  reg signed [ACC_SIZE + 1 : 0] accum;
  reg        [LUT_WIDTH  - 1 : 0] LUT [2**LUT_LENGTH - 1 : 0];
  
  initial begin
    $readmemb("lut.mem", LUT);
  end
  
  always @(posedge clk or posedge reset)
    begin
      if (reset)
        accum <= 0;
      else 
        accum <= accum + step;
    end
          
  always @(posedge clk or posedge reset)
    if (reset)
      out <= 0;
    else
      begin
        case (accum[ACC_SIZE + 1 : ACC_SIZE])
          2'b00: 
            out <= {1'b0, LUT[accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL]]};
          2'b01: 
            out <= {1'b0, LUT[~accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL]]};
          2'b10: 
            out <= {1'b1, ~LUT[accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL]]};
          2'b11: 
            out <= {1'b1, ~LUT[~accum[ACC_SIZE - 1 : PHASE_BITWIDTH_FRACTIONAL]]};
        endcase
      end

endmodule
