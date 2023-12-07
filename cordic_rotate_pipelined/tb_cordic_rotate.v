module tb_cordic_rotate ();
                          
reg                 iclk;
reg                 iresetn;
reg                 inCS;
reg                 ivalid;
reg signed [19 : 0] ix;
reg signed [19 : 0] iy;
reg signed [22 : 0] iz;

wire ovalid;
wire signed [19 : 0] ox;
wire signed [19 : 0] oy;

cordic_rotate_pipelined dut (iclk, iresetn, inCS, ivalid, ix, iy, iz, ovalid, ox, oy);

initial iclk = 1'b0;
always #1 iclk = ~iclk;

initial 
    begin
        iresetn = 1'b1;
        #1; iresetn = 1'b0;
        #1; iresetn = 1'b1;
    end
    
initial 
    begin
        inCS = 1'b1;
        ivalid = 1'b0;
        #2; 
        inCS = 1'b0;
        ivalid = 1'b1;
    end

initial ix = 127;
initial iy = 0;
always @(negedge iclk or negedge iresetn)
    if (~iresetn)
        iz = 0;
    else iz = iz + 5'b11111;

endmodule
