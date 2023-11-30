
`include "params.svh"
`include "tile_config.svh"

module noc(
    input       wire                            clk,
    input       wire                            rstn,

    // tile interfaces
    input       wire        [`DW-1:0]           cast_gather_data_i [`NW] [`NH],
    input       wire                            cast_gather_valid_i [`NW] [`NH],
    output      wire                            cast_gather_ready_o [`NW] [`NH],

    output      wire        [`DW-1:0]           cast_data_o [`NW] [`NH],
    output      wire                            cast_valid_o [`NW] [`NH],
    input       wire                            cast_ready_i [`NW] [`NH],

    output      wire        [`DW-1:0]           gather_data_o [`NW] [`NH],
    output      wire                            gather_valid_o [`NW] [`NH],
    input       wire                            gather_ready_i [`NW] [`NH],

    input       wire        [`DW-1:0]           merge_data_i [`NW] [`NH],
    input       wire                            merge_valid_i [`NW] [`NH],
    output      wire                            merge_ready_o [`NW] [`NH],

    output      wire        [`DW-1:0]           merge_data_o [`NW] [`NH],
    output      wire                            merge_valid_o [`NW] [`NH],
    input       wire                            merge_ready_i [`NW] [`NH]
);

/*********** cast network interface ***********/
logic       [`VN-1:0]       cast_vc_r2t [`NW] [`NH];
logic       [`VN-1:0]       cast_vc_t2r [`NW] [`NH];
logic       [`DW-1:0]       cast_data_r2t [`NW] [`NH];
logic       [`DW-1:0]       cast_data_t2r [`NW] [`NH];

logic                       cast_valid_r2t [`NW] [`NH];
logic                       cast_valid_t2r [`NW] [`NH];
logic                       cast_ready_r2t [`NW] [`NH];
logic                       cast_ready_t2r [`NW] [`NH];


cast_network cast_network(
    .clk                                        (clk),
    .rstn                                       (rstn),

    .vc_i                                       (cast_vc_t2r),
    .data_i                                     (cast_data_t2r),
    .valid_i                                    (cast_valid_t2r),
    .ready_o                                    (cast_ready_r2t),

    .vc_o                                       (cast_vc_r2t),
    .data_o                                     (cast_data_r2t),
    .valid_o                                    (cast_valid_r2t),
    .ready_i                                    (cast_ready_t2r)
);

merge_network merge_network(
    .clk                                        (clk),
    .rstn                                       (rstn),

    .data_i                                     (merge_data_i),
    .valid_i                                    (merge_valid_i),
    .ready_o                                    (merge_ready_o),

    .data_o                                     (merge_data_o),
    .valid_o                                    (merge_valid_o),
    .ready_i                                    (merge_ready_i)   
);

genvar x, y;
generate
    for(x=0; x<`NW; x=x+1) begin: X_POS
        for(y=0; y<`NH; y=y+1) begin: Y_POS
            cast_converter #(
                .cast_in_vc                     (cast_in_vc[x][y]),
                .gather_in_vc                   (gather_in_vc[x][y]),
                .cast_out_vc                    (cast_out_vc[x][y]),
                .gather_out_vc                  (gather_out_vc[x][y]),
                .is_cast_out                    (cast_out[x][y]),
                .is_gather_out                  (gather_out[x][y])
            )cast_converter(
                .clk                            (clk),
                .rstn                           (rstn),

                // router end
                .local_vc_i                     (cast_vc_r2t[x][y]),
                .local_data_i                   (cast_data_r2t[x][y]),
                .local_valid_i                  (cast_valid_r2t[x][y]),
                .local_ready_o                  (cast_ready_t2r[x][y]),

                .local_vc_o                     (cast_vc_t2r[x][y]),
                .local_data_o                   (cast_data_t2r[x][y]),
                .local_valid_o                  (cast_valid_t2r[x][y]),
                .local_ready_i                  (cast_ready_r2t[x][y]),

                // tile end
                .cast_gather_data_i             (cast_gather_data_i[x][y]),
                .cast_gather_valid_i            (cast_gather_valid_i[x][y]),
                .cast_gather_ready_o            (cast_gather_ready_o[x][y]),

                .cast_data_o                    (cast_data_o[x][y]),
                .cast_valid_o                   (cast_valid_o[x][y]),
                .cast_ready_i                   (cast_ready_i[x][y]),

                .gather_data_o                  (gather_data_o[x][y]),
                .gather_valid_o                 (gather_valid_o[x][y]),
                .gather_ready_i                 (gather_ready_i[x][y])
            );
        end
    end
endgenerate

endmodule

