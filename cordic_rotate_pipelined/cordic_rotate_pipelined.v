module cordic_rotate_pipelined(
    input wire                 iclk,
    input wire                 iresetn,
    input wire                 inCS,
    input wire                 ivalid,
    input wire signed [19 : 0] ix,
    input wire signed [19 : 0] iy,
    input wire signed [22 : 0] iz,
    
    output wire                 ovalid,
    output wire signed [19 : 0] ox,
    output wire signed [19 : 0] oy
    );
    
    wire pi_rotate = ^iz[22:21];
    wire [19 : 0] x_rotated = (pi_rotate) ? (~ix) : (ix);
    wire [19 : 0] y_rotated = (pi_rotate) ? (~iy) : (iy);
    
    wire                 connect_valid [0 : 14];
    
    wire signed [19 : 0] connect_x     [0 : 14];
    wire signed [19 : 0] connect_y     [0 : 14];
    wire signed [22 : 0] connect_z     [0 : 14];
                                             
    wire signed [22 : 0] atan          [0 : 14];
    
    assign atan[ 0] = 23'b00100000000000000000000;
    assign atan[ 1] = 23'b00010010111001000000011;
    assign atan[ 2] = 23'b00001001111110110011100;
    assign atan[ 3] = 23'b00000101000100010001001;
    assign atan[ 4] = 23'b00000010100010110000111;
    assign atan[ 5] = 23'b00000001010001011101100;
    assign atan[ 6] = 23'b00000000101000101111011;
    assign atan[ 7] = 23'b00000000010100010111110;
    assign atan[ 8] = 23'b00000000001010001011111;
    assign atan[ 9] = 23'b00000000000101000110000;
    assign atan[10] = 23'b00000000000010100011000;
    assign atan[11] = 23'b00000000000001010001100;
    assign atan[12] = 23'b00000000000000101000110;
    assign atan[13] = 23'b00000000000000010100011;
    assign atan[14] = 23'b00000000000000001010001;
    assign atan[15] = 23'b00000000000000000101001;
    
    shift_add first_cascade (.iclk(iclk),
                             .iresetn(iresetn),
                             .inCS(inCS),
                             .iteration_number(4'b0000),
                             .ivalid(ivalid),
                             .atan(atan[0]),
                             .ix(x_rotated),
                             .iy(y_rotated),
                             .iz((pi_rotate) ? {~iz[22], iz[21 : 0]} : (iz[22 : 0])),
                             .ovalid(connect_valid[0]),
                             .ox(connect_x[0]),
                             .oy(connect_y[0]),
                             .oz(connect_z[0])
                             );
    
    genvar i;
    generate
        for (i = 1; i < 15; i = i + 1)
            begin: cordic_cascades
                shift_add iterations (.iclk(iclk),
                                      .iresetn(iresetn),
                                      .inCS(inCS),
                                      .iteration_number(i),
                                      .ivalid(connect_valid[i - 1]),
                                      .atan(atan[i]),
                                      .ix(connect_x[i - 1]),
                                      .iy(connect_y[i - 1]),
                                      .iz(connect_z[i - 1]),
                                      .ovalid(connect_valid[i]),
                                      .ox(connect_x[i]),
                                      .oy(connect_y[i]),
                                      .oz(connect_z[i])
                                      );
            end
    endgenerate
    
    shift_add last_cascade (.iclk(iclk),
                            .iresetn(iresetn),
                            .inCS(inCS),
                            .iteration_number(4'b1111),
                            .ivalid(connect_valid[14]),
                            .atan(atan[14]),
                            .ix(connect_x[14]),
                            .iy(connect_y[14]),
                            .iz(connect_z[14]),
                            .ovalid(ovalid),
                            .ox(ox),
                            .oy(oy),
                            .oz()
                            );

    
endmodule
