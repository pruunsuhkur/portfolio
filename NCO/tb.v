`timescale 1ns / 1ps

module nco_tb #(parameter LUT_WIDTH  = 32, LUT_LENGTH = 6);

reg clk = 0, reset = 0;
reg  signed [ACC_SIZE - 1 + 1 : 0] step;
wire signed [LUT_WIDTH  + 1 - 1 : 0] out;

localparam PHASE_BITWIDTH_INTEGER = LUT_LENGTH;
localparam PHASE_BITWIDTH_FRACTIONAL = 2;
localparam ACC_SIZE = PHASE_BITWIDTH_INTEGER + PHASE_BITWIDTH_FRACTIONAL;

NCO dut (clk, reset, step, out);

always #1 clk = ~clk;

initial
    begin
        #1 reset = 1;
        #1 reset = 0;
        #1 step = 3'b001;
        #1000;
        step = 3'b010;
        #1000;
        step = 3'b011;
        #1000;
        step = 3'b100;
        #1000;
        step = 3'b101;
        #1000;
        step = 3'b110;
        #1000;
        step = 3'b111;
        #1000;
        $finish;
    end
    
endmodule