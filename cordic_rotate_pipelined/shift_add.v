module shift_add(
    input wire                 iclk,
    input wire                 iresetn,
    input wire                 inCS,
    input wire        [ 3 : 0] iteration_number,
    input wire                 ivalid,
    input wire signed [22 : 0] atan,
    input wire signed [19 : 0] ix,
    input wire signed [19 : 0] iy,
    input wire signed [22 : 0] iz,
    
    output reg                 ovalid,
    output reg signed [19 : 0] ox,
    output reg signed [19 : 0] oy,
    output reg signed [22 : 0] oz
    );
    
    wire z_sign = iz[22];
    
    always @(posedge iclk or negedge iresetn)
        if (~iresetn)
            begin
                ovalid <= 1'b0;
                ox <= 20'b0;
                oy <= 20'b0;
                oz <= 23'b0;
            end
        else if ((~inCS) && (ivalid))
            begin
                ovalid <= ivalid;
                ox <= (z_sign) ? (ix + (iy >>> iteration_number)) : (ix - (iy >>> iteration_number));
                oy <= (z_sign) ? (iy - (ix >>> iteration_number)) : (iy + (ix >>> iteration_number));
                oz <= (z_sign) ? (iz + atan)                      : (iz - atan);
            end
    
endmodule

