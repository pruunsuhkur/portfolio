`timescale 1ns / 1ps
module tb_lut_based_nco #(parameter LUT_WIDTH  = 16, 
                                    LUT_LENGTH = 6,
                         localparam PHASE_BITWIDTH_INTEGER = LUT_LENGTH,
                         localparam PHASE_BITWIDTH_FRACTIONAL = 3,
                         localparam ACC_SIZE = PHASE_BITWIDTH_INTEGER + PHASE_BITWIDTH_FRACTIONAL);

reg iclk = 1'b0;
reg iresetn = 1'b1;
reg inCS = 1'b1;
reg  signed [ACC_SIZE  - 1 : 0] step;
wire signed [LUT_WIDTH - 1 : 0] out;

lut_based_nco dut (iclk, inCS, iresetn, step, out);

always #5 iclk = ~iclk;

initial
    begin
        #1 iresetn = 1'b0;
        #3 iresetn = 1'b1;
        #1 inCS = 1'b0;
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
        step = 9'b111111111;
        #10000;
        step = 9'b000001000;
        #10000;
        step = 9'b111111110;
        #10000;
        step = 9'b000001001;
        #10000;
        step = 9'b111111101;
        #10000;
        step = 9'b000001010;
        #10000;
        step = 9'b111111100;
        #10000;
        step = 9'b000000000;
        #10000;
        $finish;
    end

//integer f;
//integer i;
//initial 
//    begin
//        #1 iresetn = 1'b0;
//        #3 iresetn = 1'b1;
//        #1 inCS = 1'b0;
//        f = $fopen("../tb/output.txt", "w");
//        step = 8'b00000101;
//        for (i = 0; i < 1000; i = i + 1)
//            begin
//                @(negedge iclk);
//                $fwrite(f,"%d\n", out);
//            end
//        $fclose(f);
//        $finish;
//    end

endmodule
