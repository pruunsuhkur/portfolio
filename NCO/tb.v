`timescale 1ns / 1ps
module tb_lut_based_nco #(parameter LUT_WIDTH  = 15, 
                                    LUT_LENGTH = 6,
                         localparam PHASE_BITWIDTH_INTEGER = LUT_LENGTH,
                         localparam PHASE_BITWIDTH_FRACTIONAL = 2,
                         localparam ACC_SIZE = PHASE_BITWIDTH_INTEGER + PHASE_BITWIDTH_FRACTIONAL);

reg iclk = 1'b0;
reg iresetn = 1'b1;
reg  signed [ACC_SIZE   + 1 - 1 : 0] step;
wire signed [LUT_WIDTH  + 1 - 1 : 0] out;

lut_based_nco dut (iclk, iresetn, step, out);

always #5 iclk = ~iclk;

initial
    begin
        #1 iresetn = 1'b0;
        #3 iresetn = 1'b1;
        #1; 
        step = 9'b000000001;
        #10000;
        step = 9'b000000010;
        #10000;
        step = 9'b000000011;
        #10000;
        step = 9'b000000100;
        #10000;
        step = 9'b000000101;
        #10000;
        step = 9'b000000110;
        #10000;
        step = 9'b000000111;
        #10000;
        step = 9'b000000000;
        #10000;
        step = 9'b000001000;
        #10000;
        step = 9'b000000000;
        #10000;
        step = 9'b111111110;
        #10000;
        $finish;
    end
    
endmodule
