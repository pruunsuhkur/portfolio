module dither
( 
  input wire         iclk, 
  input wire         inCS, 
  input wire         iresetn, 
  output reg [2 : 0] out
);

reg [7 : 0] lfsr;
always @(posedge iclk or negedge iresetn)
    if (~iresetn)
        lfsr <= 8'b10101010;
    else if (~inCS)
        begin
            lfsr[0] <= ~^lfsr[3] ~^lfsr[4] ~^lfsr[5] ~^lfsr[7];
            lfsr[1] <= lfsr[0];
            lfsr[2] <= lfsr[1];
            lfsr[3] <= lfsr[2];
            lfsr[4] <= lfsr[3];
            lfsr[5] <= lfsr[4];
            lfsr[6] <= lfsr[5];
            lfsr[7] <= lfsr[6];
        end

always @(posedge iclk or negedge iresetn)
    if (~iresetn)
        out <= 3'b000;
    else if (~inCS)
        out <= {lfsr[7], lfsr[6], lfsr[5]};

endmodule 