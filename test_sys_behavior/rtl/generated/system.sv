
`include "params.svh"
`include "tile_config.svh"

module system(
    input       logic                           clk_nw, // network
    input       logic                           clk_bw, // buffer write
    input       logic                           clk_br, // buffer_read
    input       logic                           clk_pc, // post-convolution
    input       logic                           rstn_nw, // network
    input       logic                           rstn_bw, // buffer write
    input       logic                           rstn_br, // buffer read
    input       logic                           rstn_pc, // post-convolution

    // inject ports
    input       logic       [`DW-1:0]           data_i_inject,
    input       logic                           valid_i_inject,
    output      logic                           ready_o_inject,

    // eject ports
    output      logic       [`DW-1:0]           data_o_eject [`EPN],
    output      logic                           valid_o_eject [`EPN],
    input       logic                           ready_i_eject [`EPN]
);

logic       [`DW-1:0]           cast_gather_data_t2n [`NW] [`NH];
logic                           cast_gather_valid_t2n [`NW] [`NH];
logic                           cast_gather_ready_n2t [`NW] [`NH];

logic       [`DW-1:0]           cast_data_n2t [`NW] [`NH];
logic                           cast_valid_n2t [`NW] [`NH];
logic                           cast_ready_t2n [`NW] [`NH];

logic       [`DW-1:0]           gather_data_n2t [`NW] [`NH];
logic                           gather_valid_n2t [`NW] [`NH];
logic                           gather_ready_t2n [`NW] [`NH];   

logic       [`DW-1:0]           merge_data_n2t [`NW] [`NH];
logic                           merge_valid_n2t [`NW] [`NH];
logic                           merge_ready_t2n [`NW] [`NH];

logic       [`DW-1:0]           merge_data_t2n [`NW] [`NH];
logic                           merge_valid_t2n [`NW] [`NH];
logic                           merge_ready_n2t [`NW] [`NH];

logic                           tile_done [`NW] [`NH];

noc noc(
    .clk                                        (clk_nw),
    .rstn                                       (rstn_nw),

    .cast_gather_data_i                         (cast_gather_data_t2n),
    .cast_gather_valid_i                        (cast_gather_valid_t2n),
    .cast_gather_ready_o                        (cast_gather_ready_n2t),

    .cast_data_o                                (cast_data_n2t),
    .cast_valid_o                               (cast_valid_n2t),
    .cast_ready_i                               (cast_ready_t2n),      

    .gather_data_o                              (gather_data_n2t),
    .gather_valid_o                             (gather_valid_n2t),
    .gather_ready_i                             (gather_ready_t2n),

    .merge_data_i                               (merge_data_t2n),
    .merge_valid_i                              (merge_valid_t2n),
    .merge_ready_o                              (merge_ready_n2t),

    .merge_data_o                               (merge_data_n2t),
    .merge_valid_o                              (merge_valid_n2t),
    .merge_ready_i                              (merge_ready_t2n)
);


assign cast_ready_t2n[0][0] = 0;

tile #(
    .x                              (0),
    .y                              (0),
    .is_mapped                      (is_mapped[0][0]),
    .conv_kernel_x                  (conv_kernel_x[0][0]), 
    .conv_kernel_y                  (conv_kernel_y[0][0]),
    .conv_stride_x                  (conv_stride_x[0][0]), 
    .conv_stride_y                  (conv_stride_y[0][0]),
    .conv_ifsize_x                  (conv_ifsize_x[0][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][0]),
    .conv_ifpads_u                  (conv_ifpads_u[0][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][0]),
    .conv_ifpads_l                  (conv_ifpads_l[0][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][0]),
    .conv_ofsize_x                  (conv_ofsize_x[0][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][0]),
    .xbar_num_ichan                 (xbar_num_ichan[0][0]),
    .xbar_num_ochan                 (xbar_num_ochan[0][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][0]),
    .has_bias                       (has_bias[0][0]),
    .has_act                        (has_act[0][0]),
    .has_pool                       (has_pool[0][0]),
    .pool_mode                      (pool_mode[0][0]),
    .pool_kernel_x                  (pool_kernel_x[0][0]), 
    .pool_kernel_y                  (pool_kernel_y[0][0]),
    .pool_stride_x                  (pool_stride_x[0][0]), 
    .pool_stride_y                  (pool_stride_y[0][0]),
    .pool_ifsize_x                  (pool_ifsize_x[0][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][0]),
    .pool_ifpads_u                  (pool_ifpads_u[0][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][0]),
    .pool_ifpads_l                  (pool_ifpads_l[0][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][0]),
    .pool_ofsize_x                  (pool_ofsize_x[0][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][0]),
    .merge_in                       (merge_in[0][0]),
    .gather_in                      (gather_in[0][0]),
    .merge_out                      (merge_out[0][0]),
    .gather_out                     (gather_out[0][0]),
    .cast_out                       (cast_out[0][0])
)tile_0_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (data_i_inject),
    .cast_valid_i                   (valid_i_inject),
    .cast_ready_o                   (ready_o_inject),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][0]),
    .merge_valid_i                  (merge_valid_n2t[0][0]),
    .merge_ready_o                  (merge_ready_t2n[0][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][0]),
    .gather_valid_i                 (gather_valid_n2t[0][0]),
    .gather_ready_o                 (gather_ready_t2n[0][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][0]),
    .merge_valid_o                  (merge_valid_t2n[0][0]),
    .merge_ready_i                  (merge_ready_n2t[0][0]),

    .frame_done                     (tile_done[0][0])
);


tile #(
    .x                              (0),
    .y                              (1),
    .is_mapped                      (is_mapped[0][1]),
    .conv_kernel_x                  (conv_kernel_x[0][1]), 
    .conv_kernel_y                  (conv_kernel_y[0][1]),
    .conv_stride_x                  (conv_stride_x[0][1]), 
    .conv_stride_y                  (conv_stride_y[0][1]),
    .conv_ifsize_x                  (conv_ifsize_x[0][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][1]),
    .conv_ifpads_u                  (conv_ifpads_u[0][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][1]),
    .conv_ifpads_l                  (conv_ifpads_l[0][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][1]),
    .conv_ofsize_x                  (conv_ofsize_x[0][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][1]),
    .xbar_num_ichan                 (xbar_num_ichan[0][1]),
    .xbar_num_ochan                 (xbar_num_ochan[0][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][1]),
    .has_bias                       (has_bias[0][1]),
    .has_act                        (has_act[0][1]),
    .has_pool                       (has_pool[0][1]),
    .pool_mode                      (pool_mode[0][1]),
    .pool_kernel_x                  (pool_kernel_x[0][1]), 
    .pool_kernel_y                  (pool_kernel_y[0][1]),
    .pool_stride_x                  (pool_stride_x[0][1]), 
    .pool_stride_y                  (pool_stride_y[0][1]),
    .pool_ifsize_x                  (pool_ifsize_x[0][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][1]),
    .pool_ifpads_u                  (pool_ifpads_u[0][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][1]),
    .pool_ifpads_l                  (pool_ifpads_l[0][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][1]),
    .pool_ofsize_x                  (pool_ofsize_x[0][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][1]),
    .merge_in                       (merge_in[0][1]),
    .gather_in                      (gather_in[0][1]),
    .merge_out                      (merge_out[0][1]),
    .gather_out                     (gather_out[0][1]),
    .cast_out                       (cast_out[0][1])
)tile_0_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][1]),
    .cast_valid_i                   (cast_valid_n2t[0][1]),
    .cast_ready_o                   (cast_ready_t2n[0][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][1]),
    .merge_valid_i                  (merge_valid_n2t[0][1]),
    .merge_ready_o                  (merge_ready_t2n[0][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][1]),
    .gather_valid_i                 (gather_valid_n2t[0][1]),
    .gather_ready_o                 (gather_ready_t2n[0][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][1]),
    .merge_valid_o                  (merge_valid_t2n[0][1]),
    .merge_ready_i                  (merge_ready_n2t[0][1]),

    .frame_done                     (tile_done[0][1])
);


tile #(
    .x                              (0),
    .y                              (2),
    .is_mapped                      (is_mapped[0][2]),
    .conv_kernel_x                  (conv_kernel_x[0][2]), 
    .conv_kernel_y                  (conv_kernel_y[0][2]),
    .conv_stride_x                  (conv_stride_x[0][2]), 
    .conv_stride_y                  (conv_stride_y[0][2]),
    .conv_ifsize_x                  (conv_ifsize_x[0][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][2]),
    .conv_ifpads_u                  (conv_ifpads_u[0][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][2]),
    .conv_ifpads_l                  (conv_ifpads_l[0][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][2]),
    .conv_ofsize_x                  (conv_ofsize_x[0][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][2]),
    .xbar_num_ichan                 (xbar_num_ichan[0][2]),
    .xbar_num_ochan                 (xbar_num_ochan[0][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][2]),
    .has_bias                       (has_bias[0][2]),
    .has_act                        (has_act[0][2]),
    .has_pool                       (has_pool[0][2]),
    .pool_mode                      (pool_mode[0][2]),
    .pool_kernel_x                  (pool_kernel_x[0][2]), 
    .pool_kernel_y                  (pool_kernel_y[0][2]),
    .pool_stride_x                  (pool_stride_x[0][2]), 
    .pool_stride_y                  (pool_stride_y[0][2]),
    .pool_ifsize_x                  (pool_ifsize_x[0][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][2]),
    .pool_ifpads_u                  (pool_ifpads_u[0][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][2]),
    .pool_ifpads_l                  (pool_ifpads_l[0][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][2]),
    .pool_ofsize_x                  (pool_ofsize_x[0][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][2]),
    .merge_in                       (merge_in[0][2]),
    .gather_in                      (gather_in[0][2]),
    .merge_out                      (merge_out[0][2]),
    .gather_out                     (gather_out[0][2]),
    .cast_out                       (cast_out[0][2])
)tile_0_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][2]),
    .cast_valid_i                   (cast_valid_n2t[0][2]),
    .cast_ready_o                   (cast_ready_t2n[0][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][2]),
    .merge_valid_i                  (merge_valid_n2t[0][2]),
    .merge_ready_o                  (merge_ready_t2n[0][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][2]),
    .gather_valid_i                 (gather_valid_n2t[0][2]),
    .gather_ready_o                 (gather_ready_t2n[0][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][2]),
    .merge_valid_o                  (merge_valid_t2n[0][2]),
    .merge_ready_i                  (merge_ready_n2t[0][2]),

    .frame_done                     (tile_done[0][2])
);


tile #(
    .x                              (0),
    .y                              (3),
    .is_mapped                      (is_mapped[0][3]),
    .conv_kernel_x                  (conv_kernel_x[0][3]), 
    .conv_kernel_y                  (conv_kernel_y[0][3]),
    .conv_stride_x                  (conv_stride_x[0][3]), 
    .conv_stride_y                  (conv_stride_y[0][3]),
    .conv_ifsize_x                  (conv_ifsize_x[0][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][3]),
    .conv_ifpads_u                  (conv_ifpads_u[0][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][3]),
    .conv_ifpads_l                  (conv_ifpads_l[0][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][3]),
    .conv_ofsize_x                  (conv_ofsize_x[0][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][3]),
    .xbar_num_ichan                 (xbar_num_ichan[0][3]),
    .xbar_num_ochan                 (xbar_num_ochan[0][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][3]),
    .has_bias                       (has_bias[0][3]),
    .has_act                        (has_act[0][3]),
    .has_pool                       (has_pool[0][3]),
    .pool_mode                      (pool_mode[0][3]),
    .pool_kernel_x                  (pool_kernel_x[0][3]), 
    .pool_kernel_y                  (pool_kernel_y[0][3]),
    .pool_stride_x                  (pool_stride_x[0][3]), 
    .pool_stride_y                  (pool_stride_y[0][3]),
    .pool_ifsize_x                  (pool_ifsize_x[0][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][3]),
    .pool_ifpads_u                  (pool_ifpads_u[0][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][3]),
    .pool_ifpads_l                  (pool_ifpads_l[0][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][3]),
    .pool_ofsize_x                  (pool_ofsize_x[0][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][3]),
    .merge_in                       (merge_in[0][3]),
    .gather_in                      (gather_in[0][3]),
    .merge_out                      (merge_out[0][3]),
    .gather_out                     (gather_out[0][3]),
    .cast_out                       (cast_out[0][3])
)tile_0_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][3]),
    .cast_valid_i                   (cast_valid_n2t[0][3]),
    .cast_ready_o                   (cast_ready_t2n[0][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][3]),
    .merge_valid_i                  (merge_valid_n2t[0][3]),
    .merge_ready_o                  (merge_ready_t2n[0][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][3]),
    .gather_valid_i                 (gather_valid_n2t[0][3]),
    .gather_ready_o                 (gather_ready_t2n[0][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][3]),
    .merge_valid_o                  (merge_valid_t2n[0][3]),
    .merge_ready_i                  (merge_ready_n2t[0][3]),

    .frame_done                     (tile_done[0][3])
);


tile #(
    .x                              (0),
    .y                              (4),
    .is_mapped                      (is_mapped[0][4]),
    .conv_kernel_x                  (conv_kernel_x[0][4]), 
    .conv_kernel_y                  (conv_kernel_y[0][4]),
    .conv_stride_x                  (conv_stride_x[0][4]), 
    .conv_stride_y                  (conv_stride_y[0][4]),
    .conv_ifsize_x                  (conv_ifsize_x[0][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][4]),
    .conv_ifpads_u                  (conv_ifpads_u[0][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][4]),
    .conv_ifpads_l                  (conv_ifpads_l[0][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][4]),
    .conv_ofsize_x                  (conv_ofsize_x[0][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][4]),
    .xbar_num_ichan                 (xbar_num_ichan[0][4]),
    .xbar_num_ochan                 (xbar_num_ochan[0][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][4]),
    .has_bias                       (has_bias[0][4]),
    .has_act                        (has_act[0][4]),
    .has_pool                       (has_pool[0][4]),
    .pool_mode                      (pool_mode[0][4]),
    .pool_kernel_x                  (pool_kernel_x[0][4]), 
    .pool_kernel_y                  (pool_kernel_y[0][4]),
    .pool_stride_x                  (pool_stride_x[0][4]), 
    .pool_stride_y                  (pool_stride_y[0][4]),
    .pool_ifsize_x                  (pool_ifsize_x[0][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][4]),
    .pool_ifpads_u                  (pool_ifpads_u[0][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][4]),
    .pool_ifpads_l                  (pool_ifpads_l[0][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][4]),
    .pool_ofsize_x                  (pool_ofsize_x[0][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][4]),
    .merge_in                       (merge_in[0][4]),
    .gather_in                      (gather_in[0][4]),
    .merge_out                      (merge_out[0][4]),
    .gather_out                     (gather_out[0][4]),
    .cast_out                       (cast_out[0][4])
)tile_0_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][4]),
    .cast_valid_i                   (cast_valid_n2t[0][4]),
    .cast_ready_o                   (cast_ready_t2n[0][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][4]),
    .merge_valid_i                  (merge_valid_n2t[0][4]),
    .merge_ready_o                  (merge_ready_t2n[0][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][4]),
    .gather_valid_i                 (gather_valid_n2t[0][4]),
    .gather_ready_o                 (gather_ready_t2n[0][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][4]),
    .merge_valid_o                  (merge_valid_t2n[0][4]),
    .merge_ready_i                  (merge_ready_n2t[0][4]),

    .frame_done                     (tile_done[0][4])
);


tile #(
    .x                              (0),
    .y                              (5),
    .is_mapped                      (is_mapped[0][5]),
    .conv_kernel_x                  (conv_kernel_x[0][5]), 
    .conv_kernel_y                  (conv_kernel_y[0][5]),
    .conv_stride_x                  (conv_stride_x[0][5]), 
    .conv_stride_y                  (conv_stride_y[0][5]),
    .conv_ifsize_x                  (conv_ifsize_x[0][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][5]),
    .conv_ifpads_u                  (conv_ifpads_u[0][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][5]),
    .conv_ifpads_l                  (conv_ifpads_l[0][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][5]),
    .conv_ofsize_x                  (conv_ofsize_x[0][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][5]),
    .xbar_num_ichan                 (xbar_num_ichan[0][5]),
    .xbar_num_ochan                 (xbar_num_ochan[0][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][5]),
    .has_bias                       (has_bias[0][5]),
    .has_act                        (has_act[0][5]),
    .has_pool                       (has_pool[0][5]),
    .pool_mode                      (pool_mode[0][5]),
    .pool_kernel_x                  (pool_kernel_x[0][5]), 
    .pool_kernel_y                  (pool_kernel_y[0][5]),
    .pool_stride_x                  (pool_stride_x[0][5]), 
    .pool_stride_y                  (pool_stride_y[0][5]),
    .pool_ifsize_x                  (pool_ifsize_x[0][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][5]),
    .pool_ifpads_u                  (pool_ifpads_u[0][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][5]),
    .pool_ifpads_l                  (pool_ifpads_l[0][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][5]),
    .pool_ofsize_x                  (pool_ofsize_x[0][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][5]),
    .merge_in                       (merge_in[0][5]),
    .gather_in                      (gather_in[0][5]),
    .merge_out                      (merge_out[0][5]),
    .gather_out                     (gather_out[0][5]),
    .cast_out                       (cast_out[0][5])
)tile_0_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][5]),
    .cast_valid_i                   (cast_valid_n2t[0][5]),
    .cast_ready_o                   (cast_ready_t2n[0][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][5]),
    .merge_valid_i                  (merge_valid_n2t[0][5]),
    .merge_ready_o                  (merge_ready_t2n[0][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][5]),
    .gather_valid_i                 (gather_valid_n2t[0][5]),
    .gather_ready_o                 (gather_ready_t2n[0][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][5]),
    .merge_valid_o                  (merge_valid_t2n[0][5]),
    .merge_ready_i                  (merge_ready_n2t[0][5]),

    .frame_done                     (tile_done[0][5])
);


tile #(
    .x                              (0),
    .y                              (6),
    .is_mapped                      (is_mapped[0][6]),
    .conv_kernel_x                  (conv_kernel_x[0][6]), 
    .conv_kernel_y                  (conv_kernel_y[0][6]),
    .conv_stride_x                  (conv_stride_x[0][6]), 
    .conv_stride_y                  (conv_stride_y[0][6]),
    .conv_ifsize_x                  (conv_ifsize_x[0][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][6]),
    .conv_ifpads_u                  (conv_ifpads_u[0][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][6]),
    .conv_ifpads_l                  (conv_ifpads_l[0][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][6]),
    .conv_ofsize_x                  (conv_ofsize_x[0][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][6]),
    .xbar_num_ichan                 (xbar_num_ichan[0][6]),
    .xbar_num_ochan                 (xbar_num_ochan[0][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][6]),
    .has_bias                       (has_bias[0][6]),
    .has_act                        (has_act[0][6]),
    .has_pool                       (has_pool[0][6]),
    .pool_mode                      (pool_mode[0][6]),
    .pool_kernel_x                  (pool_kernel_x[0][6]), 
    .pool_kernel_y                  (pool_kernel_y[0][6]),
    .pool_stride_x                  (pool_stride_x[0][6]), 
    .pool_stride_y                  (pool_stride_y[0][6]),
    .pool_ifsize_x                  (pool_ifsize_x[0][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][6]),
    .pool_ifpads_u                  (pool_ifpads_u[0][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][6]),
    .pool_ifpads_l                  (pool_ifpads_l[0][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][6]),
    .pool_ofsize_x                  (pool_ofsize_x[0][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][6]),
    .merge_in                       (merge_in[0][6]),
    .gather_in                      (gather_in[0][6]),
    .merge_out                      (merge_out[0][6]),
    .gather_out                     (gather_out[0][6]),
    .cast_out                       (cast_out[0][6])
)tile_0_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][6]),
    .cast_valid_i                   (cast_valid_n2t[0][6]),
    .cast_ready_o                   (cast_ready_t2n[0][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][6]),
    .merge_valid_i                  (merge_valid_n2t[0][6]),
    .merge_ready_o                  (merge_ready_t2n[0][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][6]),
    .gather_valid_i                 (gather_valid_n2t[0][6]),
    .gather_ready_o                 (gather_ready_t2n[0][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][6]),
    .merge_valid_o                  (merge_valid_t2n[0][6]),
    .merge_ready_i                  (merge_ready_n2t[0][6]),

    .frame_done                     (tile_done[0][6])
);


tile #(
    .x                              (0),
    .y                              (7),
    .is_mapped                      (is_mapped[0][7]),
    .conv_kernel_x                  (conv_kernel_x[0][7]), 
    .conv_kernel_y                  (conv_kernel_y[0][7]),
    .conv_stride_x                  (conv_stride_x[0][7]), 
    .conv_stride_y                  (conv_stride_y[0][7]),
    .conv_ifsize_x                  (conv_ifsize_x[0][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[0][7]),
    .conv_ifpads_u                  (conv_ifpads_u[0][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[0][7]),
    .conv_ifpads_l                  (conv_ifpads_l[0][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[0][7]),
    .conv_ofsize_x                  (conv_ofsize_x[0][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[0][7]),
    .xbar_num_ichan                 (xbar_num_ichan[0][7]),
    .xbar_num_ochan                 (xbar_num_ochan[0][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[0][7]),
    .has_bias                       (has_bias[0][7]),
    .has_act                        (has_act[0][7]),
    .has_pool                       (has_pool[0][7]),
    .pool_mode                      (pool_mode[0][7]),
    .pool_kernel_x                  (pool_kernel_x[0][7]), 
    .pool_kernel_y                  (pool_kernel_y[0][7]),
    .pool_stride_x                  (pool_stride_x[0][7]), 
    .pool_stride_y                  (pool_stride_y[0][7]),
    .pool_ifsize_x                  (pool_ifsize_x[0][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[0][7]),
    .pool_ifpads_u                  (pool_ifpads_u[0][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[0][7]),
    .pool_ifpads_l                  (pool_ifpads_l[0][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[0][7]),
    .pool_ofsize_x                  (pool_ofsize_x[0][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[0][7]),
    .merge_in                       (merge_in[0][7]),
    .gather_in                      (gather_in[0][7]),
    .merge_out                      (merge_out[0][7]),
    .gather_out                     (gather_out[0][7]),
    .cast_out                       (cast_out[0][7])
)tile_0_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[0][7]),
    .cast_valid_i                   (cast_valid_n2t[0][7]),
    .cast_ready_o                   (cast_ready_t2n[0][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[0][7]),
    .merge_valid_i                  (merge_valid_n2t[0][7]),
    .merge_ready_o                  (merge_ready_t2n[0][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[0][7]),
    .gather_valid_i                 (gather_valid_n2t[0][7]),
    .gather_ready_o                 (gather_ready_t2n[0][7]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[0][7]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[0][7]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[0][7]),

    // merge out
    .merge_data_o                   (merge_data_t2n[0][7]),
    .merge_valid_o                  (merge_valid_t2n[0][7]),
    .merge_ready_i                  (merge_ready_n2t[0][7]),

    .frame_done                     (tile_done[0][7])
);


tile #(
    .x                              (1),
    .y                              (0),
    .is_mapped                      (is_mapped[1][0]),
    .conv_kernel_x                  (conv_kernel_x[1][0]), 
    .conv_kernel_y                  (conv_kernel_y[1][0]),
    .conv_stride_x                  (conv_stride_x[1][0]), 
    .conv_stride_y                  (conv_stride_y[1][0]),
    .conv_ifsize_x                  (conv_ifsize_x[1][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][0]),
    .conv_ifpads_u                  (conv_ifpads_u[1][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][0]),
    .conv_ifpads_l                  (conv_ifpads_l[1][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][0]),
    .conv_ofsize_x                  (conv_ofsize_x[1][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][0]),
    .xbar_num_ichan                 (xbar_num_ichan[1][0]),
    .xbar_num_ochan                 (xbar_num_ochan[1][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][0]),
    .has_bias                       (has_bias[1][0]),
    .has_act                        (has_act[1][0]),
    .has_pool                       (has_pool[1][0]),
    .pool_mode                      (pool_mode[1][0]),
    .pool_kernel_x                  (pool_kernel_x[1][0]), 
    .pool_kernel_y                  (pool_kernel_y[1][0]),
    .pool_stride_x                  (pool_stride_x[1][0]), 
    .pool_stride_y                  (pool_stride_y[1][0]),
    .pool_ifsize_x                  (pool_ifsize_x[1][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][0]),
    .pool_ifpads_u                  (pool_ifpads_u[1][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][0]),
    .pool_ifpads_l                  (pool_ifpads_l[1][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][0]),
    .pool_ofsize_x                  (pool_ofsize_x[1][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][0]),
    .merge_in                       (merge_in[1][0]),
    .gather_in                      (gather_in[1][0]),
    .merge_out                      (merge_out[1][0]),
    .gather_out                     (gather_out[1][0]),
    .cast_out                       (cast_out[1][0])
)tile_1_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][0]),
    .cast_valid_i                   (cast_valid_n2t[1][0]),
    .cast_ready_o                   (cast_ready_t2n[1][0]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][0]),
    .merge_valid_i                  (merge_valid_n2t[1][0]),
    .merge_ready_o                  (merge_ready_t2n[1][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][0]),
    .gather_valid_i                 (gather_valid_n2t[1][0]),
    .gather_ready_o                 (gather_ready_t2n[1][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][0]),
    .merge_valid_o                  (merge_valid_t2n[1][0]),
    .merge_ready_i                  (merge_ready_n2t[1][0]),

    .frame_done                     (tile_done[1][0])
);


tile #(
    .x                              (1),
    .y                              (1),
    .is_mapped                      (is_mapped[1][1]),
    .conv_kernel_x                  (conv_kernel_x[1][1]), 
    .conv_kernel_y                  (conv_kernel_y[1][1]),
    .conv_stride_x                  (conv_stride_x[1][1]), 
    .conv_stride_y                  (conv_stride_y[1][1]),
    .conv_ifsize_x                  (conv_ifsize_x[1][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][1]),
    .conv_ifpads_u                  (conv_ifpads_u[1][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][1]),
    .conv_ifpads_l                  (conv_ifpads_l[1][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][1]),
    .conv_ofsize_x                  (conv_ofsize_x[1][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][1]),
    .xbar_num_ichan                 (xbar_num_ichan[1][1]),
    .xbar_num_ochan                 (xbar_num_ochan[1][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][1]),
    .has_bias                       (has_bias[1][1]),
    .has_act                        (has_act[1][1]),
    .has_pool                       (has_pool[1][1]),
    .pool_mode                      (pool_mode[1][1]),
    .pool_kernel_x                  (pool_kernel_x[1][1]), 
    .pool_kernel_y                  (pool_kernel_y[1][1]),
    .pool_stride_x                  (pool_stride_x[1][1]), 
    .pool_stride_y                  (pool_stride_y[1][1]),
    .pool_ifsize_x                  (pool_ifsize_x[1][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][1]),
    .pool_ifpads_u                  (pool_ifpads_u[1][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][1]),
    .pool_ifpads_l                  (pool_ifpads_l[1][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][1]),
    .pool_ofsize_x                  (pool_ofsize_x[1][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][1]),
    .merge_in                       (merge_in[1][1]),
    .gather_in                      (gather_in[1][1]),
    .merge_out                      (merge_out[1][1]),
    .gather_out                     (gather_out[1][1]),
    .cast_out                       (cast_out[1][1])
)tile_1_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][1]),
    .cast_valid_i                   (cast_valid_n2t[1][1]),
    .cast_ready_o                   (cast_ready_t2n[1][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][1]),
    .merge_valid_i                  (merge_valid_n2t[1][1]),
    .merge_ready_o                  (merge_ready_t2n[1][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][1]),
    .gather_valid_i                 (gather_valid_n2t[1][1]),
    .gather_ready_o                 (gather_ready_t2n[1][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][1]),
    .merge_valid_o                  (merge_valid_t2n[1][1]),
    .merge_ready_i                  (merge_ready_n2t[1][1]),

    .frame_done                     (tile_done[1][1])
);


tile #(
    .x                              (1),
    .y                              (2),
    .is_mapped                      (is_mapped[1][2]),
    .conv_kernel_x                  (conv_kernel_x[1][2]), 
    .conv_kernel_y                  (conv_kernel_y[1][2]),
    .conv_stride_x                  (conv_stride_x[1][2]), 
    .conv_stride_y                  (conv_stride_y[1][2]),
    .conv_ifsize_x                  (conv_ifsize_x[1][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][2]),
    .conv_ifpads_u                  (conv_ifpads_u[1][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][2]),
    .conv_ifpads_l                  (conv_ifpads_l[1][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][2]),
    .conv_ofsize_x                  (conv_ofsize_x[1][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][2]),
    .xbar_num_ichan                 (xbar_num_ichan[1][2]),
    .xbar_num_ochan                 (xbar_num_ochan[1][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][2]),
    .has_bias                       (has_bias[1][2]),
    .has_act                        (has_act[1][2]),
    .has_pool                       (has_pool[1][2]),
    .pool_mode                      (pool_mode[1][2]),
    .pool_kernel_x                  (pool_kernel_x[1][2]), 
    .pool_kernel_y                  (pool_kernel_y[1][2]),
    .pool_stride_x                  (pool_stride_x[1][2]), 
    .pool_stride_y                  (pool_stride_y[1][2]),
    .pool_ifsize_x                  (pool_ifsize_x[1][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][2]),
    .pool_ifpads_u                  (pool_ifpads_u[1][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][2]),
    .pool_ifpads_l                  (pool_ifpads_l[1][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][2]),
    .pool_ofsize_x                  (pool_ofsize_x[1][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][2]),
    .merge_in                       (merge_in[1][2]),
    .gather_in                      (gather_in[1][2]),
    .merge_out                      (merge_out[1][2]),
    .gather_out                     (gather_out[1][2]),
    .cast_out                       (cast_out[1][2])
)tile_1_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][2]),
    .cast_valid_i                   (cast_valid_n2t[1][2]),
    .cast_ready_o                   (cast_ready_t2n[1][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][2]),
    .merge_valid_i                  (merge_valid_n2t[1][2]),
    .merge_ready_o                  (merge_ready_t2n[1][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][2]),
    .gather_valid_i                 (gather_valid_n2t[1][2]),
    .gather_ready_o                 (gather_ready_t2n[1][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][2]),
    .merge_valid_o                  (merge_valid_t2n[1][2]),
    .merge_ready_i                  (merge_ready_n2t[1][2]),

    .frame_done                     (tile_done[1][2])
);


tile #(
    .x                              (1),
    .y                              (3),
    .is_mapped                      (is_mapped[1][3]),
    .conv_kernel_x                  (conv_kernel_x[1][3]), 
    .conv_kernel_y                  (conv_kernel_y[1][3]),
    .conv_stride_x                  (conv_stride_x[1][3]), 
    .conv_stride_y                  (conv_stride_y[1][3]),
    .conv_ifsize_x                  (conv_ifsize_x[1][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][3]),
    .conv_ifpads_u                  (conv_ifpads_u[1][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][3]),
    .conv_ifpads_l                  (conv_ifpads_l[1][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][3]),
    .conv_ofsize_x                  (conv_ofsize_x[1][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][3]),
    .xbar_num_ichan                 (xbar_num_ichan[1][3]),
    .xbar_num_ochan                 (xbar_num_ochan[1][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][3]),
    .has_bias                       (has_bias[1][3]),
    .has_act                        (has_act[1][3]),
    .has_pool                       (has_pool[1][3]),
    .pool_mode                      (pool_mode[1][3]),
    .pool_kernel_x                  (pool_kernel_x[1][3]), 
    .pool_kernel_y                  (pool_kernel_y[1][3]),
    .pool_stride_x                  (pool_stride_x[1][3]), 
    .pool_stride_y                  (pool_stride_y[1][3]),
    .pool_ifsize_x                  (pool_ifsize_x[1][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][3]),
    .pool_ifpads_u                  (pool_ifpads_u[1][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][3]),
    .pool_ifpads_l                  (pool_ifpads_l[1][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][3]),
    .pool_ofsize_x                  (pool_ofsize_x[1][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][3]),
    .merge_in                       (merge_in[1][3]),
    .gather_in                      (gather_in[1][3]),
    .merge_out                      (merge_out[1][3]),
    .gather_out                     (gather_out[1][3]),
    .cast_out                       (cast_out[1][3])
)tile_1_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][3]),
    .cast_valid_i                   (cast_valid_n2t[1][3]),
    .cast_ready_o                   (cast_ready_t2n[1][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][3]),
    .merge_valid_i                  (merge_valid_n2t[1][3]),
    .merge_ready_o                  (merge_ready_t2n[1][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][3]),
    .gather_valid_i                 (gather_valid_n2t[1][3]),
    .gather_ready_o                 (gather_ready_t2n[1][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][3]),
    .merge_valid_o                  (merge_valid_t2n[1][3]),
    .merge_ready_i                  (merge_ready_n2t[1][3]),

    .frame_done                     (tile_done[1][3])
);


tile #(
    .x                              (1),
    .y                              (4),
    .is_mapped                      (is_mapped[1][4]),
    .conv_kernel_x                  (conv_kernel_x[1][4]), 
    .conv_kernel_y                  (conv_kernel_y[1][4]),
    .conv_stride_x                  (conv_stride_x[1][4]), 
    .conv_stride_y                  (conv_stride_y[1][4]),
    .conv_ifsize_x                  (conv_ifsize_x[1][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][4]),
    .conv_ifpads_u                  (conv_ifpads_u[1][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][4]),
    .conv_ifpads_l                  (conv_ifpads_l[1][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][4]),
    .conv_ofsize_x                  (conv_ofsize_x[1][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][4]),
    .xbar_num_ichan                 (xbar_num_ichan[1][4]),
    .xbar_num_ochan                 (xbar_num_ochan[1][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][4]),
    .has_bias                       (has_bias[1][4]),
    .has_act                        (has_act[1][4]),
    .has_pool                       (has_pool[1][4]),
    .pool_mode                      (pool_mode[1][4]),
    .pool_kernel_x                  (pool_kernel_x[1][4]), 
    .pool_kernel_y                  (pool_kernel_y[1][4]),
    .pool_stride_x                  (pool_stride_x[1][4]), 
    .pool_stride_y                  (pool_stride_y[1][4]),
    .pool_ifsize_x                  (pool_ifsize_x[1][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][4]),
    .pool_ifpads_u                  (pool_ifpads_u[1][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][4]),
    .pool_ifpads_l                  (pool_ifpads_l[1][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][4]),
    .pool_ofsize_x                  (pool_ofsize_x[1][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][4]),
    .merge_in                       (merge_in[1][4]),
    .gather_in                      (gather_in[1][4]),
    .merge_out                      (merge_out[1][4]),
    .gather_out                     (gather_out[1][4]),
    .cast_out                       (cast_out[1][4])
)tile_1_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][4]),
    .cast_valid_i                   (cast_valid_n2t[1][4]),
    .cast_ready_o                   (cast_ready_t2n[1][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][4]),
    .merge_valid_i                  (merge_valid_n2t[1][4]),
    .merge_ready_o                  (merge_ready_t2n[1][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][4]),
    .gather_valid_i                 (gather_valid_n2t[1][4]),
    .gather_ready_o                 (gather_ready_t2n[1][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][4]),
    .merge_valid_o                  (merge_valid_t2n[1][4]),
    .merge_ready_i                  (merge_ready_n2t[1][4]),

    .frame_done                     (tile_done[1][4])
);


tile #(
    .x                              (1),
    .y                              (5),
    .is_mapped                      (is_mapped[1][5]),
    .conv_kernel_x                  (conv_kernel_x[1][5]), 
    .conv_kernel_y                  (conv_kernel_y[1][5]),
    .conv_stride_x                  (conv_stride_x[1][5]), 
    .conv_stride_y                  (conv_stride_y[1][5]),
    .conv_ifsize_x                  (conv_ifsize_x[1][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][5]),
    .conv_ifpads_u                  (conv_ifpads_u[1][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][5]),
    .conv_ifpads_l                  (conv_ifpads_l[1][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][5]),
    .conv_ofsize_x                  (conv_ofsize_x[1][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][5]),
    .xbar_num_ichan                 (xbar_num_ichan[1][5]),
    .xbar_num_ochan                 (xbar_num_ochan[1][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][5]),
    .has_bias                       (has_bias[1][5]),
    .has_act                        (has_act[1][5]),
    .has_pool                       (has_pool[1][5]),
    .pool_mode                      (pool_mode[1][5]),
    .pool_kernel_x                  (pool_kernel_x[1][5]), 
    .pool_kernel_y                  (pool_kernel_y[1][5]),
    .pool_stride_x                  (pool_stride_x[1][5]), 
    .pool_stride_y                  (pool_stride_y[1][5]),
    .pool_ifsize_x                  (pool_ifsize_x[1][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][5]),
    .pool_ifpads_u                  (pool_ifpads_u[1][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][5]),
    .pool_ifpads_l                  (pool_ifpads_l[1][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][5]),
    .pool_ofsize_x                  (pool_ofsize_x[1][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][5]),
    .merge_in                       (merge_in[1][5]),
    .gather_in                      (gather_in[1][5]),
    .merge_out                      (merge_out[1][5]),
    .gather_out                     (gather_out[1][5]),
    .cast_out                       (cast_out[1][5])
)tile_1_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][5]),
    .cast_valid_i                   (cast_valid_n2t[1][5]),
    .cast_ready_o                   (cast_ready_t2n[1][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][5]),
    .merge_valid_i                  (merge_valid_n2t[1][5]),
    .merge_ready_o                  (merge_ready_t2n[1][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][5]),
    .gather_valid_i                 (gather_valid_n2t[1][5]),
    .gather_ready_o                 (gather_ready_t2n[1][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][5]),
    .merge_valid_o                  (merge_valid_t2n[1][5]),
    .merge_ready_i                  (merge_ready_n2t[1][5]),

    .frame_done                     (tile_done[1][5])
);


tile #(
    .x                              (1),
    .y                              (6),
    .is_mapped                      (is_mapped[1][6]),
    .conv_kernel_x                  (conv_kernel_x[1][6]), 
    .conv_kernel_y                  (conv_kernel_y[1][6]),
    .conv_stride_x                  (conv_stride_x[1][6]), 
    .conv_stride_y                  (conv_stride_y[1][6]),
    .conv_ifsize_x                  (conv_ifsize_x[1][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][6]),
    .conv_ifpads_u                  (conv_ifpads_u[1][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][6]),
    .conv_ifpads_l                  (conv_ifpads_l[1][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][6]),
    .conv_ofsize_x                  (conv_ofsize_x[1][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][6]),
    .xbar_num_ichan                 (xbar_num_ichan[1][6]),
    .xbar_num_ochan                 (xbar_num_ochan[1][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][6]),
    .has_bias                       (has_bias[1][6]),
    .has_act                        (has_act[1][6]),
    .has_pool                       (has_pool[1][6]),
    .pool_mode                      (pool_mode[1][6]),
    .pool_kernel_x                  (pool_kernel_x[1][6]), 
    .pool_kernel_y                  (pool_kernel_y[1][6]),
    .pool_stride_x                  (pool_stride_x[1][6]), 
    .pool_stride_y                  (pool_stride_y[1][6]),
    .pool_ifsize_x                  (pool_ifsize_x[1][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][6]),
    .pool_ifpads_u                  (pool_ifpads_u[1][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][6]),
    .pool_ifpads_l                  (pool_ifpads_l[1][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][6]),
    .pool_ofsize_x                  (pool_ofsize_x[1][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][6]),
    .merge_in                       (merge_in[1][6]),
    .gather_in                      (gather_in[1][6]),
    .merge_out                      (merge_out[1][6]),
    .gather_out                     (gather_out[1][6]),
    .cast_out                       (cast_out[1][6])
)tile_1_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][6]),
    .cast_valid_i                   (cast_valid_n2t[1][6]),
    .cast_ready_o                   (cast_ready_t2n[1][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][6]),
    .merge_valid_i                  (merge_valid_n2t[1][6]),
    .merge_ready_o                  (merge_ready_t2n[1][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][6]),
    .gather_valid_i                 (gather_valid_n2t[1][6]),
    .gather_ready_o                 (gather_ready_t2n[1][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[1][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[1][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[1][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][6]),
    .merge_valid_o                  (merge_valid_t2n[1][6]),
    .merge_ready_i                  (merge_ready_n2t[1][6]),

    .frame_done                     (tile_done[1][6])
);


assign cast_gather_data_t2n[1][7] = 0;
assign cast_gather_valid_t2n[1][7] = 0;

tile #(
    .x                              (1),
    .y                              (7),
    .is_mapped                      (is_mapped[1][7]),
    .conv_kernel_x                  (conv_kernel_x[1][7]), 
    .conv_kernel_y                  (conv_kernel_y[1][7]),
    .conv_stride_x                  (conv_stride_x[1][7]), 
    .conv_stride_y                  (conv_stride_y[1][7]),
    .conv_ifsize_x                  (conv_ifsize_x[1][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[1][7]),
    .conv_ifpads_u                  (conv_ifpads_u[1][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[1][7]),
    .conv_ifpads_l                  (conv_ifpads_l[1][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[1][7]),
    .conv_ofsize_x                  (conv_ofsize_x[1][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[1][7]),
    .xbar_num_ichan                 (xbar_num_ichan[1][7]),
    .xbar_num_ochan                 (xbar_num_ochan[1][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[1][7]),
    .has_bias                       (has_bias[1][7]),
    .has_act                        (has_act[1][7]),
    .has_pool                       (has_pool[1][7]),
    .pool_mode                      (pool_mode[1][7]),
    .pool_kernel_x                  (pool_kernel_x[1][7]), 
    .pool_kernel_y                  (pool_kernel_y[1][7]),
    .pool_stride_x                  (pool_stride_x[1][7]), 
    .pool_stride_y                  (pool_stride_y[1][7]),
    .pool_ifsize_x                  (pool_ifsize_x[1][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[1][7]),
    .pool_ifpads_u                  (pool_ifpads_u[1][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[1][7]),
    .pool_ifpads_l                  (pool_ifpads_l[1][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[1][7]),
    .pool_ofsize_x                  (pool_ofsize_x[1][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[1][7]),
    .merge_in                       (merge_in[1][7]),
    .gather_in                      (gather_in[1][7]),
    .merge_out                      (merge_out[1][7]),
    .gather_out                     (gather_out[1][7]),
    .cast_out                       (cast_out[1][7])
)tile_1_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[1][7]),
    .cast_valid_i                   (cast_valid_n2t[1][7]),
    .cast_ready_o                   (cast_ready_t2n[1][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[1][7]),
    .merge_valid_i                  (merge_valid_n2t[1][7]),
    .merge_ready_o                  (merge_ready_t2n[1][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[1][7]),
    .gather_valid_i                 (gather_valid_n2t[1][7]),
    .gather_ready_o                 (gather_ready_t2n[1][7]),

    // cast gather out
    .cast_gather_data_o             (data_o_eject[1]),
    .cast_gather_valid_o            (valid_o_eject[1]),   
    .cast_gather_ready_i            (ready_i_eject[1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[1][7]),
    .merge_valid_o                  (merge_valid_t2n[1][7]),
    .merge_ready_i                  (merge_ready_n2t[1][7]),

    .frame_done                     (tile_done[1][7])
);


tile #(
    .x                              (2),
    .y                              (0),
    .is_mapped                      (is_mapped[2][0]),
    .conv_kernel_x                  (conv_kernel_x[2][0]), 
    .conv_kernel_y                  (conv_kernel_y[2][0]),
    .conv_stride_x                  (conv_stride_x[2][0]), 
    .conv_stride_y                  (conv_stride_y[2][0]),
    .conv_ifsize_x                  (conv_ifsize_x[2][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][0]),
    .conv_ifpads_u                  (conv_ifpads_u[2][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][0]),
    .conv_ifpads_l                  (conv_ifpads_l[2][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][0]),
    .conv_ofsize_x                  (conv_ofsize_x[2][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][0]),
    .xbar_num_ichan                 (xbar_num_ichan[2][0]),
    .xbar_num_ochan                 (xbar_num_ochan[2][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][0]),
    .has_bias                       (has_bias[2][0]),
    .has_act                        (has_act[2][0]),
    .has_pool                       (has_pool[2][0]),
    .pool_mode                      (pool_mode[2][0]),
    .pool_kernel_x                  (pool_kernel_x[2][0]), 
    .pool_kernel_y                  (pool_kernel_y[2][0]),
    .pool_stride_x                  (pool_stride_x[2][0]), 
    .pool_stride_y                  (pool_stride_y[2][0]),
    .pool_ifsize_x                  (pool_ifsize_x[2][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][0]),
    .pool_ifpads_u                  (pool_ifpads_u[2][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][0]),
    .pool_ifpads_l                  (pool_ifpads_l[2][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][0]),
    .pool_ofsize_x                  (pool_ofsize_x[2][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][0]),
    .merge_in                       (merge_in[2][0]),
    .gather_in                      (gather_in[2][0]),
    .merge_out                      (merge_out[2][0]),
    .gather_out                     (gather_out[2][0]),
    .cast_out                       (cast_out[2][0])
)tile_2_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][0]),
    .cast_valid_i                   (cast_valid_n2t[2][0]),
    .cast_ready_o                   (cast_ready_t2n[2][0]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][0]),
    .merge_valid_i                  (merge_valid_n2t[2][0]),
    .merge_ready_o                  (merge_ready_t2n[2][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][0]),
    .gather_valid_i                 (gather_valid_n2t[2][0]),
    .gather_ready_o                 (gather_ready_t2n[2][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][0]),
    .merge_valid_o                  (merge_valid_t2n[2][0]),
    .merge_ready_i                  (merge_ready_n2t[2][0]),

    .frame_done                     (tile_done[2][0])
);


tile #(
    .x                              (2),
    .y                              (1),
    .is_mapped                      (is_mapped[2][1]),
    .conv_kernel_x                  (conv_kernel_x[2][1]), 
    .conv_kernel_y                  (conv_kernel_y[2][1]),
    .conv_stride_x                  (conv_stride_x[2][1]), 
    .conv_stride_y                  (conv_stride_y[2][1]),
    .conv_ifsize_x                  (conv_ifsize_x[2][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][1]),
    .conv_ifpads_u                  (conv_ifpads_u[2][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][1]),
    .conv_ifpads_l                  (conv_ifpads_l[2][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][1]),
    .conv_ofsize_x                  (conv_ofsize_x[2][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][1]),
    .xbar_num_ichan                 (xbar_num_ichan[2][1]),
    .xbar_num_ochan                 (xbar_num_ochan[2][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][1]),
    .has_bias                       (has_bias[2][1]),
    .has_act                        (has_act[2][1]),
    .has_pool                       (has_pool[2][1]),
    .pool_mode                      (pool_mode[2][1]),
    .pool_kernel_x                  (pool_kernel_x[2][1]), 
    .pool_kernel_y                  (pool_kernel_y[2][1]),
    .pool_stride_x                  (pool_stride_x[2][1]), 
    .pool_stride_y                  (pool_stride_y[2][1]),
    .pool_ifsize_x                  (pool_ifsize_x[2][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][1]),
    .pool_ifpads_u                  (pool_ifpads_u[2][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][1]),
    .pool_ifpads_l                  (pool_ifpads_l[2][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][1]),
    .pool_ofsize_x                  (pool_ofsize_x[2][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][1]),
    .merge_in                       (merge_in[2][1]),
    .gather_in                      (gather_in[2][1]),
    .merge_out                      (merge_out[2][1]),
    .gather_out                     (gather_out[2][1]),
    .cast_out                       (cast_out[2][1])
)tile_2_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][1]),
    .cast_valid_i                   (cast_valid_n2t[2][1]),
    .cast_ready_o                   (cast_ready_t2n[2][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][1]),
    .merge_valid_i                  (merge_valid_n2t[2][1]),
    .merge_ready_o                  (merge_ready_t2n[2][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][1]),
    .gather_valid_i                 (gather_valid_n2t[2][1]),
    .gather_ready_o                 (gather_ready_t2n[2][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][1]),
    .merge_valid_o                  (merge_valid_t2n[2][1]),
    .merge_ready_i                  (merge_ready_n2t[2][1]),

    .frame_done                     (tile_done[2][1])
);


tile #(
    .x                              (2),
    .y                              (2),
    .is_mapped                      (is_mapped[2][2]),
    .conv_kernel_x                  (conv_kernel_x[2][2]), 
    .conv_kernel_y                  (conv_kernel_y[2][2]),
    .conv_stride_x                  (conv_stride_x[2][2]), 
    .conv_stride_y                  (conv_stride_y[2][2]),
    .conv_ifsize_x                  (conv_ifsize_x[2][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][2]),
    .conv_ifpads_u                  (conv_ifpads_u[2][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][2]),
    .conv_ifpads_l                  (conv_ifpads_l[2][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][2]),
    .conv_ofsize_x                  (conv_ofsize_x[2][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][2]),
    .xbar_num_ichan                 (xbar_num_ichan[2][2]),
    .xbar_num_ochan                 (xbar_num_ochan[2][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][2]),
    .has_bias                       (has_bias[2][2]),
    .has_act                        (has_act[2][2]),
    .has_pool                       (has_pool[2][2]),
    .pool_mode                      (pool_mode[2][2]),
    .pool_kernel_x                  (pool_kernel_x[2][2]), 
    .pool_kernel_y                  (pool_kernel_y[2][2]),
    .pool_stride_x                  (pool_stride_x[2][2]), 
    .pool_stride_y                  (pool_stride_y[2][2]),
    .pool_ifsize_x                  (pool_ifsize_x[2][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][2]),
    .pool_ifpads_u                  (pool_ifpads_u[2][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][2]),
    .pool_ifpads_l                  (pool_ifpads_l[2][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][2]),
    .pool_ofsize_x                  (pool_ofsize_x[2][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][2]),
    .merge_in                       (merge_in[2][2]),
    .gather_in                      (gather_in[2][2]),
    .merge_out                      (merge_out[2][2]),
    .gather_out                     (gather_out[2][2]),
    .cast_out                       (cast_out[2][2])
)tile_2_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][2]),
    .cast_valid_i                   (cast_valid_n2t[2][2]),
    .cast_ready_o                   (cast_ready_t2n[2][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][2]),
    .merge_valid_i                  (merge_valid_n2t[2][2]),
    .merge_ready_o                  (merge_ready_t2n[2][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][2]),
    .gather_valid_i                 (gather_valid_n2t[2][2]),
    .gather_ready_o                 (gather_ready_t2n[2][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][2]),
    .merge_valid_o                  (merge_valid_t2n[2][2]),
    .merge_ready_i                  (merge_ready_n2t[2][2]),

    .frame_done                     (tile_done[2][2])
);


tile #(
    .x                              (2),
    .y                              (3),
    .is_mapped                      (is_mapped[2][3]),
    .conv_kernel_x                  (conv_kernel_x[2][3]), 
    .conv_kernel_y                  (conv_kernel_y[2][3]),
    .conv_stride_x                  (conv_stride_x[2][3]), 
    .conv_stride_y                  (conv_stride_y[2][3]),
    .conv_ifsize_x                  (conv_ifsize_x[2][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][3]),
    .conv_ifpads_u                  (conv_ifpads_u[2][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][3]),
    .conv_ifpads_l                  (conv_ifpads_l[2][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][3]),
    .conv_ofsize_x                  (conv_ofsize_x[2][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][3]),
    .xbar_num_ichan                 (xbar_num_ichan[2][3]),
    .xbar_num_ochan                 (xbar_num_ochan[2][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][3]),
    .has_bias                       (has_bias[2][3]),
    .has_act                        (has_act[2][3]),
    .has_pool                       (has_pool[2][3]),
    .pool_mode                      (pool_mode[2][3]),
    .pool_kernel_x                  (pool_kernel_x[2][3]), 
    .pool_kernel_y                  (pool_kernel_y[2][3]),
    .pool_stride_x                  (pool_stride_x[2][3]), 
    .pool_stride_y                  (pool_stride_y[2][3]),
    .pool_ifsize_x                  (pool_ifsize_x[2][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][3]),
    .pool_ifpads_u                  (pool_ifpads_u[2][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][3]),
    .pool_ifpads_l                  (pool_ifpads_l[2][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][3]),
    .pool_ofsize_x                  (pool_ofsize_x[2][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][3]),
    .merge_in                       (merge_in[2][3]),
    .gather_in                      (gather_in[2][3]),
    .merge_out                      (merge_out[2][3]),
    .gather_out                     (gather_out[2][3]),
    .cast_out                       (cast_out[2][3])
)tile_2_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][3]),
    .cast_valid_i                   (cast_valid_n2t[2][3]),
    .cast_ready_o                   (cast_ready_t2n[2][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][3]),
    .merge_valid_i                  (merge_valid_n2t[2][3]),
    .merge_ready_o                  (merge_ready_t2n[2][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][3]),
    .gather_valid_i                 (gather_valid_n2t[2][3]),
    .gather_ready_o                 (gather_ready_t2n[2][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][3]),
    .merge_valid_o                  (merge_valid_t2n[2][3]),
    .merge_ready_i                  (merge_ready_n2t[2][3]),

    .frame_done                     (tile_done[2][3])
);


tile #(
    .x                              (2),
    .y                              (4),
    .is_mapped                      (is_mapped[2][4]),
    .conv_kernel_x                  (conv_kernel_x[2][4]), 
    .conv_kernel_y                  (conv_kernel_y[2][4]),
    .conv_stride_x                  (conv_stride_x[2][4]), 
    .conv_stride_y                  (conv_stride_y[2][4]),
    .conv_ifsize_x                  (conv_ifsize_x[2][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][4]),
    .conv_ifpads_u                  (conv_ifpads_u[2][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][4]),
    .conv_ifpads_l                  (conv_ifpads_l[2][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][4]),
    .conv_ofsize_x                  (conv_ofsize_x[2][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][4]),
    .xbar_num_ichan                 (xbar_num_ichan[2][4]),
    .xbar_num_ochan                 (xbar_num_ochan[2][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][4]),
    .has_bias                       (has_bias[2][4]),
    .has_act                        (has_act[2][4]),
    .has_pool                       (has_pool[2][4]),
    .pool_mode                      (pool_mode[2][4]),
    .pool_kernel_x                  (pool_kernel_x[2][4]), 
    .pool_kernel_y                  (pool_kernel_y[2][4]),
    .pool_stride_x                  (pool_stride_x[2][4]), 
    .pool_stride_y                  (pool_stride_y[2][4]),
    .pool_ifsize_x                  (pool_ifsize_x[2][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][4]),
    .pool_ifpads_u                  (pool_ifpads_u[2][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][4]),
    .pool_ifpads_l                  (pool_ifpads_l[2][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][4]),
    .pool_ofsize_x                  (pool_ofsize_x[2][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][4]),
    .merge_in                       (merge_in[2][4]),
    .gather_in                      (gather_in[2][4]),
    .merge_out                      (merge_out[2][4]),
    .gather_out                     (gather_out[2][4]),
    .cast_out                       (cast_out[2][4])
)tile_2_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][4]),
    .cast_valid_i                   (cast_valid_n2t[2][4]),
    .cast_ready_o                   (cast_ready_t2n[2][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][4]),
    .merge_valid_i                  (merge_valid_n2t[2][4]),
    .merge_ready_o                  (merge_ready_t2n[2][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][4]),
    .gather_valid_i                 (gather_valid_n2t[2][4]),
    .gather_ready_o                 (gather_ready_t2n[2][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][4]),
    .merge_valid_o                  (merge_valid_t2n[2][4]),
    .merge_ready_i                  (merge_ready_n2t[2][4]),

    .frame_done                     (tile_done[2][4])
);


tile #(
    .x                              (2),
    .y                              (5),
    .is_mapped                      (is_mapped[2][5]),
    .conv_kernel_x                  (conv_kernel_x[2][5]), 
    .conv_kernel_y                  (conv_kernel_y[2][5]),
    .conv_stride_x                  (conv_stride_x[2][5]), 
    .conv_stride_y                  (conv_stride_y[2][5]),
    .conv_ifsize_x                  (conv_ifsize_x[2][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][5]),
    .conv_ifpads_u                  (conv_ifpads_u[2][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][5]),
    .conv_ifpads_l                  (conv_ifpads_l[2][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][5]),
    .conv_ofsize_x                  (conv_ofsize_x[2][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][5]),
    .xbar_num_ichan                 (xbar_num_ichan[2][5]),
    .xbar_num_ochan                 (xbar_num_ochan[2][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][5]),
    .has_bias                       (has_bias[2][5]),
    .has_act                        (has_act[2][5]),
    .has_pool                       (has_pool[2][5]),
    .pool_mode                      (pool_mode[2][5]),
    .pool_kernel_x                  (pool_kernel_x[2][5]), 
    .pool_kernel_y                  (pool_kernel_y[2][5]),
    .pool_stride_x                  (pool_stride_x[2][5]), 
    .pool_stride_y                  (pool_stride_y[2][5]),
    .pool_ifsize_x                  (pool_ifsize_x[2][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][5]),
    .pool_ifpads_u                  (pool_ifpads_u[2][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][5]),
    .pool_ifpads_l                  (pool_ifpads_l[2][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][5]),
    .pool_ofsize_x                  (pool_ofsize_x[2][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][5]),
    .merge_in                       (merge_in[2][5]),
    .gather_in                      (gather_in[2][5]),
    .merge_out                      (merge_out[2][5]),
    .gather_out                     (gather_out[2][5]),
    .cast_out                       (cast_out[2][5])
)tile_2_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][5]),
    .cast_valid_i                   (cast_valid_n2t[2][5]),
    .cast_ready_o                   (cast_ready_t2n[2][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][5]),
    .merge_valid_i                  (merge_valid_n2t[2][5]),
    .merge_ready_o                  (merge_ready_t2n[2][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][5]),
    .gather_valid_i                 (gather_valid_n2t[2][5]),
    .gather_ready_o                 (gather_ready_t2n[2][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][5]),
    .merge_valid_o                  (merge_valid_t2n[2][5]),
    .merge_ready_i                  (merge_ready_n2t[2][5]),

    .frame_done                     (tile_done[2][5])
);


tile #(
    .x                              (2),
    .y                              (6),
    .is_mapped                      (is_mapped[2][6]),
    .conv_kernel_x                  (conv_kernel_x[2][6]), 
    .conv_kernel_y                  (conv_kernel_y[2][6]),
    .conv_stride_x                  (conv_stride_x[2][6]), 
    .conv_stride_y                  (conv_stride_y[2][6]),
    .conv_ifsize_x                  (conv_ifsize_x[2][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][6]),
    .conv_ifpads_u                  (conv_ifpads_u[2][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][6]),
    .conv_ifpads_l                  (conv_ifpads_l[2][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][6]),
    .conv_ofsize_x                  (conv_ofsize_x[2][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][6]),
    .xbar_num_ichan                 (xbar_num_ichan[2][6]),
    .xbar_num_ochan                 (xbar_num_ochan[2][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][6]),
    .has_bias                       (has_bias[2][6]),
    .has_act                        (has_act[2][6]),
    .has_pool                       (has_pool[2][6]),
    .pool_mode                      (pool_mode[2][6]),
    .pool_kernel_x                  (pool_kernel_x[2][6]), 
    .pool_kernel_y                  (pool_kernel_y[2][6]),
    .pool_stride_x                  (pool_stride_x[2][6]), 
    .pool_stride_y                  (pool_stride_y[2][6]),
    .pool_ifsize_x                  (pool_ifsize_x[2][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][6]),
    .pool_ifpads_u                  (pool_ifpads_u[2][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][6]),
    .pool_ifpads_l                  (pool_ifpads_l[2][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][6]),
    .pool_ofsize_x                  (pool_ofsize_x[2][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][6]),
    .merge_in                       (merge_in[2][6]),
    .gather_in                      (gather_in[2][6]),
    .merge_out                      (merge_out[2][6]),
    .gather_out                     (gather_out[2][6]),
    .cast_out                       (cast_out[2][6])
)tile_2_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][6]),
    .cast_valid_i                   (cast_valid_n2t[2][6]),
    .cast_ready_o                   (cast_ready_t2n[2][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][6]),
    .merge_valid_i                  (merge_valid_n2t[2][6]),
    .merge_ready_o                  (merge_ready_t2n[2][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][6]),
    .gather_valid_i                 (gather_valid_n2t[2][6]),
    .gather_ready_o                 (gather_ready_t2n[2][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][6]),
    .merge_valid_o                  (merge_valid_t2n[2][6]),
    .merge_ready_i                  (merge_ready_n2t[2][6]),

    .frame_done                     (tile_done[2][6])
);


tile #(
    .x                              (2),
    .y                              (7),
    .is_mapped                      (is_mapped[2][7]),
    .conv_kernel_x                  (conv_kernel_x[2][7]), 
    .conv_kernel_y                  (conv_kernel_y[2][7]),
    .conv_stride_x                  (conv_stride_x[2][7]), 
    .conv_stride_y                  (conv_stride_y[2][7]),
    .conv_ifsize_x                  (conv_ifsize_x[2][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[2][7]),
    .conv_ifpads_u                  (conv_ifpads_u[2][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[2][7]),
    .conv_ifpads_l                  (conv_ifpads_l[2][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[2][7]),
    .conv_ofsize_x                  (conv_ofsize_x[2][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[2][7]),
    .xbar_num_ichan                 (xbar_num_ichan[2][7]),
    .xbar_num_ochan                 (xbar_num_ochan[2][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[2][7]),
    .has_bias                       (has_bias[2][7]),
    .has_act                        (has_act[2][7]),
    .has_pool                       (has_pool[2][7]),
    .pool_mode                      (pool_mode[2][7]),
    .pool_kernel_x                  (pool_kernel_x[2][7]), 
    .pool_kernel_y                  (pool_kernel_y[2][7]),
    .pool_stride_x                  (pool_stride_x[2][7]), 
    .pool_stride_y                  (pool_stride_y[2][7]),
    .pool_ifsize_x                  (pool_ifsize_x[2][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[2][7]),
    .pool_ifpads_u                  (pool_ifpads_u[2][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[2][7]),
    .pool_ifpads_l                  (pool_ifpads_l[2][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[2][7]),
    .pool_ofsize_x                  (pool_ofsize_x[2][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[2][7]),
    .merge_in                       (merge_in[2][7]),
    .gather_in                      (gather_in[2][7]),
    .merge_out                      (merge_out[2][7]),
    .gather_out                     (gather_out[2][7]),
    .cast_out                       (cast_out[2][7])
)tile_2_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[2][7]),
    .cast_valid_i                   (cast_valid_n2t[2][7]),
    .cast_ready_o                   (cast_ready_t2n[2][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[2][7]),
    .merge_valid_i                  (merge_valid_n2t[2][7]),
    .merge_ready_o                  (merge_ready_t2n[2][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[2][7]),
    .gather_valid_i                 (gather_valid_n2t[2][7]),
    .gather_ready_o                 (gather_ready_t2n[2][7]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[2][7]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[2][7]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[2][7]),

    // merge out
    .merge_data_o                   (merge_data_t2n[2][7]),
    .merge_valid_o                  (merge_valid_t2n[2][7]),
    .merge_ready_i                  (merge_ready_n2t[2][7]),

    .frame_done                     (tile_done[2][7])
);


tile #(
    .x                              (3),
    .y                              (0),
    .is_mapped                      (is_mapped[3][0]),
    .conv_kernel_x                  (conv_kernel_x[3][0]), 
    .conv_kernel_y                  (conv_kernel_y[3][0]),
    .conv_stride_x                  (conv_stride_x[3][0]), 
    .conv_stride_y                  (conv_stride_y[3][0]),
    .conv_ifsize_x                  (conv_ifsize_x[3][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][0]),
    .conv_ifpads_u                  (conv_ifpads_u[3][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][0]),
    .conv_ifpads_l                  (conv_ifpads_l[3][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][0]),
    .conv_ofsize_x                  (conv_ofsize_x[3][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][0]),
    .xbar_num_ichan                 (xbar_num_ichan[3][0]),
    .xbar_num_ochan                 (xbar_num_ochan[3][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][0]),
    .has_bias                       (has_bias[3][0]),
    .has_act                        (has_act[3][0]),
    .has_pool                       (has_pool[3][0]),
    .pool_mode                      (pool_mode[3][0]),
    .pool_kernel_x                  (pool_kernel_x[3][0]), 
    .pool_kernel_y                  (pool_kernel_y[3][0]),
    .pool_stride_x                  (pool_stride_x[3][0]), 
    .pool_stride_y                  (pool_stride_y[3][0]),
    .pool_ifsize_x                  (pool_ifsize_x[3][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][0]),
    .pool_ifpads_u                  (pool_ifpads_u[3][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][0]),
    .pool_ifpads_l                  (pool_ifpads_l[3][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][0]),
    .pool_ofsize_x                  (pool_ofsize_x[3][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][0]),
    .merge_in                       (merge_in[3][0]),
    .gather_in                      (gather_in[3][0]),
    .merge_out                      (merge_out[3][0]),
    .gather_out                     (gather_out[3][0]),
    .cast_out                       (cast_out[3][0])
)tile_3_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][0]),
    .cast_valid_i                   (cast_valid_n2t[3][0]),
    .cast_ready_o                   (cast_ready_t2n[3][0]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][0]),
    .merge_valid_i                  (merge_valid_n2t[3][0]),
    .merge_ready_o                  (merge_ready_t2n[3][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][0]),
    .gather_valid_i                 (gather_valid_n2t[3][0]),
    .gather_ready_o                 (gather_ready_t2n[3][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][0]),
    .merge_valid_o                  (merge_valid_t2n[3][0]),
    .merge_ready_i                  (merge_ready_n2t[3][0]),

    .frame_done                     (tile_done[3][0])
);


tile #(
    .x                              (3),
    .y                              (1),
    .is_mapped                      (is_mapped[3][1]),
    .conv_kernel_x                  (conv_kernel_x[3][1]), 
    .conv_kernel_y                  (conv_kernel_y[3][1]),
    .conv_stride_x                  (conv_stride_x[3][1]), 
    .conv_stride_y                  (conv_stride_y[3][1]),
    .conv_ifsize_x                  (conv_ifsize_x[3][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][1]),
    .conv_ifpads_u                  (conv_ifpads_u[3][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][1]),
    .conv_ifpads_l                  (conv_ifpads_l[3][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][1]),
    .conv_ofsize_x                  (conv_ofsize_x[3][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][1]),
    .xbar_num_ichan                 (xbar_num_ichan[3][1]),
    .xbar_num_ochan                 (xbar_num_ochan[3][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][1]),
    .has_bias                       (has_bias[3][1]),
    .has_act                        (has_act[3][1]),
    .has_pool                       (has_pool[3][1]),
    .pool_mode                      (pool_mode[3][1]),
    .pool_kernel_x                  (pool_kernel_x[3][1]), 
    .pool_kernel_y                  (pool_kernel_y[3][1]),
    .pool_stride_x                  (pool_stride_x[3][1]), 
    .pool_stride_y                  (pool_stride_y[3][1]),
    .pool_ifsize_x                  (pool_ifsize_x[3][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][1]),
    .pool_ifpads_u                  (pool_ifpads_u[3][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][1]),
    .pool_ifpads_l                  (pool_ifpads_l[3][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][1]),
    .pool_ofsize_x                  (pool_ofsize_x[3][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][1]),
    .merge_in                       (merge_in[3][1]),
    .gather_in                      (gather_in[3][1]),
    .merge_out                      (merge_out[3][1]),
    .gather_out                     (gather_out[3][1]),
    .cast_out                       (cast_out[3][1])
)tile_3_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][1]),
    .cast_valid_i                   (cast_valid_n2t[3][1]),
    .cast_ready_o                   (cast_ready_t2n[3][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][1]),
    .merge_valid_i                  (merge_valid_n2t[3][1]),
    .merge_ready_o                  (merge_ready_t2n[3][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][1]),
    .gather_valid_i                 (gather_valid_n2t[3][1]),
    .gather_ready_o                 (gather_ready_t2n[3][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][1]),
    .merge_valid_o                  (merge_valid_t2n[3][1]),
    .merge_ready_i                  (merge_ready_n2t[3][1]),

    .frame_done                     (tile_done[3][1])
);


tile #(
    .x                              (3),
    .y                              (2),
    .is_mapped                      (is_mapped[3][2]),
    .conv_kernel_x                  (conv_kernel_x[3][2]), 
    .conv_kernel_y                  (conv_kernel_y[3][2]),
    .conv_stride_x                  (conv_stride_x[3][2]), 
    .conv_stride_y                  (conv_stride_y[3][2]),
    .conv_ifsize_x                  (conv_ifsize_x[3][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][2]),
    .conv_ifpads_u                  (conv_ifpads_u[3][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][2]),
    .conv_ifpads_l                  (conv_ifpads_l[3][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][2]),
    .conv_ofsize_x                  (conv_ofsize_x[3][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][2]),
    .xbar_num_ichan                 (xbar_num_ichan[3][2]),
    .xbar_num_ochan                 (xbar_num_ochan[3][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][2]),
    .has_bias                       (has_bias[3][2]),
    .has_act                        (has_act[3][2]),
    .has_pool                       (has_pool[3][2]),
    .pool_mode                      (pool_mode[3][2]),
    .pool_kernel_x                  (pool_kernel_x[3][2]), 
    .pool_kernel_y                  (pool_kernel_y[3][2]),
    .pool_stride_x                  (pool_stride_x[3][2]), 
    .pool_stride_y                  (pool_stride_y[3][2]),
    .pool_ifsize_x                  (pool_ifsize_x[3][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][2]),
    .pool_ifpads_u                  (pool_ifpads_u[3][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][2]),
    .pool_ifpads_l                  (pool_ifpads_l[3][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][2]),
    .pool_ofsize_x                  (pool_ofsize_x[3][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][2]),
    .merge_in                       (merge_in[3][2]),
    .gather_in                      (gather_in[3][2]),
    .merge_out                      (merge_out[3][2]),
    .gather_out                     (gather_out[3][2]),
    .cast_out                       (cast_out[3][2])
)tile_3_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][2]),
    .cast_valid_i                   (cast_valid_n2t[3][2]),
    .cast_ready_o                   (cast_ready_t2n[3][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][2]),
    .merge_valid_i                  (merge_valid_n2t[3][2]),
    .merge_ready_o                  (merge_ready_t2n[3][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][2]),
    .gather_valid_i                 (gather_valid_n2t[3][2]),
    .gather_ready_o                 (gather_ready_t2n[3][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][2]),
    .merge_valid_o                  (merge_valid_t2n[3][2]),
    .merge_ready_i                  (merge_ready_n2t[3][2]),

    .frame_done                     (tile_done[3][2])
);


tile #(
    .x                              (3),
    .y                              (3),
    .is_mapped                      (is_mapped[3][3]),
    .conv_kernel_x                  (conv_kernel_x[3][3]), 
    .conv_kernel_y                  (conv_kernel_y[3][3]),
    .conv_stride_x                  (conv_stride_x[3][3]), 
    .conv_stride_y                  (conv_stride_y[3][3]),
    .conv_ifsize_x                  (conv_ifsize_x[3][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][3]),
    .conv_ifpads_u                  (conv_ifpads_u[3][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][3]),
    .conv_ifpads_l                  (conv_ifpads_l[3][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][3]),
    .conv_ofsize_x                  (conv_ofsize_x[3][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][3]),
    .xbar_num_ichan                 (xbar_num_ichan[3][3]),
    .xbar_num_ochan                 (xbar_num_ochan[3][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][3]),
    .has_bias                       (has_bias[3][3]),
    .has_act                        (has_act[3][3]),
    .has_pool                       (has_pool[3][3]),
    .pool_mode                      (pool_mode[3][3]),
    .pool_kernel_x                  (pool_kernel_x[3][3]), 
    .pool_kernel_y                  (pool_kernel_y[3][3]),
    .pool_stride_x                  (pool_stride_x[3][3]), 
    .pool_stride_y                  (pool_stride_y[3][3]),
    .pool_ifsize_x                  (pool_ifsize_x[3][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][3]),
    .pool_ifpads_u                  (pool_ifpads_u[3][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][3]),
    .pool_ifpads_l                  (pool_ifpads_l[3][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][3]),
    .pool_ofsize_x                  (pool_ofsize_x[3][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][3]),
    .merge_in                       (merge_in[3][3]),
    .gather_in                      (gather_in[3][3]),
    .merge_out                      (merge_out[3][3]),
    .gather_out                     (gather_out[3][3]),
    .cast_out                       (cast_out[3][3])
)tile_3_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][3]),
    .cast_valid_i                   (cast_valid_n2t[3][3]),
    .cast_ready_o                   (cast_ready_t2n[3][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][3]),
    .merge_valid_i                  (merge_valid_n2t[3][3]),
    .merge_ready_o                  (merge_ready_t2n[3][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][3]),
    .gather_valid_i                 (gather_valid_n2t[3][3]),
    .gather_ready_o                 (gather_ready_t2n[3][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][3]),
    .merge_valid_o                  (merge_valid_t2n[3][3]),
    .merge_ready_i                  (merge_ready_n2t[3][3]),

    .frame_done                     (tile_done[3][3])
);


tile #(
    .x                              (3),
    .y                              (4),
    .is_mapped                      (is_mapped[3][4]),
    .conv_kernel_x                  (conv_kernel_x[3][4]), 
    .conv_kernel_y                  (conv_kernel_y[3][4]),
    .conv_stride_x                  (conv_stride_x[3][4]), 
    .conv_stride_y                  (conv_stride_y[3][4]),
    .conv_ifsize_x                  (conv_ifsize_x[3][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][4]),
    .conv_ifpads_u                  (conv_ifpads_u[3][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][4]),
    .conv_ifpads_l                  (conv_ifpads_l[3][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][4]),
    .conv_ofsize_x                  (conv_ofsize_x[3][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][4]),
    .xbar_num_ichan                 (xbar_num_ichan[3][4]),
    .xbar_num_ochan                 (xbar_num_ochan[3][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][4]),
    .has_bias                       (has_bias[3][4]),
    .has_act                        (has_act[3][4]),
    .has_pool                       (has_pool[3][4]),
    .pool_mode                      (pool_mode[3][4]),
    .pool_kernel_x                  (pool_kernel_x[3][4]), 
    .pool_kernel_y                  (pool_kernel_y[3][4]),
    .pool_stride_x                  (pool_stride_x[3][4]), 
    .pool_stride_y                  (pool_stride_y[3][4]),
    .pool_ifsize_x                  (pool_ifsize_x[3][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][4]),
    .pool_ifpads_u                  (pool_ifpads_u[3][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][4]),
    .pool_ifpads_l                  (pool_ifpads_l[3][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][4]),
    .pool_ofsize_x                  (pool_ofsize_x[3][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][4]),
    .merge_in                       (merge_in[3][4]),
    .gather_in                      (gather_in[3][4]),
    .merge_out                      (merge_out[3][4]),
    .gather_out                     (gather_out[3][4]),
    .cast_out                       (cast_out[3][4])
)tile_3_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][4]),
    .cast_valid_i                   (cast_valid_n2t[3][4]),
    .cast_ready_o                   (cast_ready_t2n[3][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][4]),
    .merge_valid_i                  (merge_valid_n2t[3][4]),
    .merge_ready_o                  (merge_ready_t2n[3][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][4]),
    .gather_valid_i                 (gather_valid_n2t[3][4]),
    .gather_ready_o                 (gather_ready_t2n[3][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][4]),
    .merge_valid_o                  (merge_valid_t2n[3][4]),
    .merge_ready_i                  (merge_ready_n2t[3][4]),

    .frame_done                     (tile_done[3][4])
);


tile #(
    .x                              (3),
    .y                              (5),
    .is_mapped                      (is_mapped[3][5]),
    .conv_kernel_x                  (conv_kernel_x[3][5]), 
    .conv_kernel_y                  (conv_kernel_y[3][5]),
    .conv_stride_x                  (conv_stride_x[3][5]), 
    .conv_stride_y                  (conv_stride_y[3][5]),
    .conv_ifsize_x                  (conv_ifsize_x[3][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][5]),
    .conv_ifpads_u                  (conv_ifpads_u[3][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][5]),
    .conv_ifpads_l                  (conv_ifpads_l[3][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][5]),
    .conv_ofsize_x                  (conv_ofsize_x[3][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][5]),
    .xbar_num_ichan                 (xbar_num_ichan[3][5]),
    .xbar_num_ochan                 (xbar_num_ochan[3][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][5]),
    .has_bias                       (has_bias[3][5]),
    .has_act                        (has_act[3][5]),
    .has_pool                       (has_pool[3][5]),
    .pool_mode                      (pool_mode[3][5]),
    .pool_kernel_x                  (pool_kernel_x[3][5]), 
    .pool_kernel_y                  (pool_kernel_y[3][5]),
    .pool_stride_x                  (pool_stride_x[3][5]), 
    .pool_stride_y                  (pool_stride_y[3][5]),
    .pool_ifsize_x                  (pool_ifsize_x[3][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][5]),
    .pool_ifpads_u                  (pool_ifpads_u[3][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][5]),
    .pool_ifpads_l                  (pool_ifpads_l[3][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][5]),
    .pool_ofsize_x                  (pool_ofsize_x[3][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][5]),
    .merge_in                       (merge_in[3][5]),
    .gather_in                      (gather_in[3][5]),
    .merge_out                      (merge_out[3][5]),
    .gather_out                     (gather_out[3][5]),
    .cast_out                       (cast_out[3][5])
)tile_3_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][5]),
    .cast_valid_i                   (cast_valid_n2t[3][5]),
    .cast_ready_o                   (cast_ready_t2n[3][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][5]),
    .merge_valid_i                  (merge_valid_n2t[3][5]),
    .merge_ready_o                  (merge_ready_t2n[3][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][5]),
    .gather_valid_i                 (gather_valid_n2t[3][5]),
    .gather_ready_o                 (gather_ready_t2n[3][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][5]),
    .merge_valid_o                  (merge_valid_t2n[3][5]),
    .merge_ready_i                  (merge_ready_n2t[3][5]),

    .frame_done                     (tile_done[3][5])
);


tile #(
    .x                              (3),
    .y                              (6),
    .is_mapped                      (is_mapped[3][6]),
    .conv_kernel_x                  (conv_kernel_x[3][6]), 
    .conv_kernel_y                  (conv_kernel_y[3][6]),
    .conv_stride_x                  (conv_stride_x[3][6]), 
    .conv_stride_y                  (conv_stride_y[3][6]),
    .conv_ifsize_x                  (conv_ifsize_x[3][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][6]),
    .conv_ifpads_u                  (conv_ifpads_u[3][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][6]),
    .conv_ifpads_l                  (conv_ifpads_l[3][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][6]),
    .conv_ofsize_x                  (conv_ofsize_x[3][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][6]),
    .xbar_num_ichan                 (xbar_num_ichan[3][6]),
    .xbar_num_ochan                 (xbar_num_ochan[3][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][6]),
    .has_bias                       (has_bias[3][6]),
    .has_act                        (has_act[3][6]),
    .has_pool                       (has_pool[3][6]),
    .pool_mode                      (pool_mode[3][6]),
    .pool_kernel_x                  (pool_kernel_x[3][6]), 
    .pool_kernel_y                  (pool_kernel_y[3][6]),
    .pool_stride_x                  (pool_stride_x[3][6]), 
    .pool_stride_y                  (pool_stride_y[3][6]),
    .pool_ifsize_x                  (pool_ifsize_x[3][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][6]),
    .pool_ifpads_u                  (pool_ifpads_u[3][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][6]),
    .pool_ifpads_l                  (pool_ifpads_l[3][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][6]),
    .pool_ofsize_x                  (pool_ofsize_x[3][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][6]),
    .merge_in                       (merge_in[3][6]),
    .gather_in                      (gather_in[3][6]),
    .merge_out                      (merge_out[3][6]),
    .gather_out                     (gather_out[3][6]),
    .cast_out                       (cast_out[3][6])
)tile_3_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][6]),
    .cast_valid_i                   (cast_valid_n2t[3][6]),
    .cast_ready_o                   (cast_ready_t2n[3][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][6]),
    .merge_valid_i                  (merge_valid_n2t[3][6]),
    .merge_ready_o                  (merge_ready_t2n[3][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][6]),
    .gather_valid_i                 (gather_valid_n2t[3][6]),
    .gather_ready_o                 (gather_ready_t2n[3][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][6]),
    .merge_valid_o                  (merge_valid_t2n[3][6]),
    .merge_ready_i                  (merge_ready_n2t[3][6]),

    .frame_done                     (tile_done[3][6])
);


tile #(
    .x                              (3),
    .y                              (7),
    .is_mapped                      (is_mapped[3][7]),
    .conv_kernel_x                  (conv_kernel_x[3][7]), 
    .conv_kernel_y                  (conv_kernel_y[3][7]),
    .conv_stride_x                  (conv_stride_x[3][7]), 
    .conv_stride_y                  (conv_stride_y[3][7]),
    .conv_ifsize_x                  (conv_ifsize_x[3][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[3][7]),
    .conv_ifpads_u                  (conv_ifpads_u[3][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[3][7]),
    .conv_ifpads_l                  (conv_ifpads_l[3][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[3][7]),
    .conv_ofsize_x                  (conv_ofsize_x[3][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[3][7]),
    .xbar_num_ichan                 (xbar_num_ichan[3][7]),
    .xbar_num_ochan                 (xbar_num_ochan[3][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[3][7]),
    .has_bias                       (has_bias[3][7]),
    .has_act                        (has_act[3][7]),
    .has_pool                       (has_pool[3][7]),
    .pool_mode                      (pool_mode[3][7]),
    .pool_kernel_x                  (pool_kernel_x[3][7]), 
    .pool_kernel_y                  (pool_kernel_y[3][7]),
    .pool_stride_x                  (pool_stride_x[3][7]), 
    .pool_stride_y                  (pool_stride_y[3][7]),
    .pool_ifsize_x                  (pool_ifsize_x[3][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[3][7]),
    .pool_ifpads_u                  (pool_ifpads_u[3][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[3][7]),
    .pool_ifpads_l                  (pool_ifpads_l[3][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[3][7]),
    .pool_ofsize_x                  (pool_ofsize_x[3][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[3][7]),
    .merge_in                       (merge_in[3][7]),
    .gather_in                      (gather_in[3][7]),
    .merge_out                      (merge_out[3][7]),
    .gather_out                     (gather_out[3][7]),
    .cast_out                       (cast_out[3][7])
)tile_3_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[3][7]),
    .cast_valid_i                   (cast_valid_n2t[3][7]),
    .cast_ready_o                   (cast_ready_t2n[3][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[3][7]),
    .merge_valid_i                  (merge_valid_n2t[3][7]),
    .merge_ready_o                  (merge_ready_t2n[3][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[3][7]),
    .gather_valid_i                 (gather_valid_n2t[3][7]),
    .gather_ready_o                 (gather_ready_t2n[3][7]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[3][7]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[3][7]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[3][7]),

    // merge out
    .merge_data_o                   (merge_data_t2n[3][7]),
    .merge_valid_o                  (merge_valid_t2n[3][7]),
    .merge_ready_i                  (merge_ready_n2t[3][7]),

    .frame_done                     (tile_done[3][7])
);


tile #(
    .x                              (4),
    .y                              (0),
    .is_mapped                      (is_mapped[4][0]),
    .conv_kernel_x                  (conv_kernel_x[4][0]), 
    .conv_kernel_y                  (conv_kernel_y[4][0]),
    .conv_stride_x                  (conv_stride_x[4][0]), 
    .conv_stride_y                  (conv_stride_y[4][0]),
    .conv_ifsize_x                  (conv_ifsize_x[4][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][0]),
    .conv_ifpads_u                  (conv_ifpads_u[4][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][0]),
    .conv_ifpads_l                  (conv_ifpads_l[4][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][0]),
    .conv_ofsize_x                  (conv_ofsize_x[4][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][0]),
    .xbar_num_ichan                 (xbar_num_ichan[4][0]),
    .xbar_num_ochan                 (xbar_num_ochan[4][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][0]),
    .has_bias                       (has_bias[4][0]),
    .has_act                        (has_act[4][0]),
    .has_pool                       (has_pool[4][0]),
    .pool_mode                      (pool_mode[4][0]),
    .pool_kernel_x                  (pool_kernel_x[4][0]), 
    .pool_kernel_y                  (pool_kernel_y[4][0]),
    .pool_stride_x                  (pool_stride_x[4][0]), 
    .pool_stride_y                  (pool_stride_y[4][0]),
    .pool_ifsize_x                  (pool_ifsize_x[4][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][0]),
    .pool_ifpads_u                  (pool_ifpads_u[4][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][0]),
    .pool_ifpads_l                  (pool_ifpads_l[4][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][0]),
    .pool_ofsize_x                  (pool_ofsize_x[4][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][0]),
    .merge_in                       (merge_in[4][0]),
    .gather_in                      (gather_in[4][0]),
    .merge_out                      (merge_out[4][0]),
    .gather_out                     (gather_out[4][0]),
    .cast_out                       (cast_out[4][0])
)tile_4_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][0]),
    .cast_valid_i                   (cast_valid_n2t[4][0]),
    .cast_ready_o                   (cast_ready_t2n[4][0]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][0]),
    .merge_valid_i                  (merge_valid_n2t[4][0]),
    .merge_ready_o                  (merge_ready_t2n[4][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][0]),
    .gather_valid_i                 (gather_valid_n2t[4][0]),
    .gather_ready_o                 (gather_ready_t2n[4][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][0]),
    .merge_valid_o                  (merge_valid_t2n[4][0]),
    .merge_ready_i                  (merge_ready_n2t[4][0]),

    .frame_done                     (tile_done[4][0])
);


tile #(
    .x                              (4),
    .y                              (1),
    .is_mapped                      (is_mapped[4][1]),
    .conv_kernel_x                  (conv_kernel_x[4][1]), 
    .conv_kernel_y                  (conv_kernel_y[4][1]),
    .conv_stride_x                  (conv_stride_x[4][1]), 
    .conv_stride_y                  (conv_stride_y[4][1]),
    .conv_ifsize_x                  (conv_ifsize_x[4][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][1]),
    .conv_ifpads_u                  (conv_ifpads_u[4][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][1]),
    .conv_ifpads_l                  (conv_ifpads_l[4][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][1]),
    .conv_ofsize_x                  (conv_ofsize_x[4][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][1]),
    .xbar_num_ichan                 (xbar_num_ichan[4][1]),
    .xbar_num_ochan                 (xbar_num_ochan[4][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][1]),
    .has_bias                       (has_bias[4][1]),
    .has_act                        (has_act[4][1]),
    .has_pool                       (has_pool[4][1]),
    .pool_mode                      (pool_mode[4][1]),
    .pool_kernel_x                  (pool_kernel_x[4][1]), 
    .pool_kernel_y                  (pool_kernel_y[4][1]),
    .pool_stride_x                  (pool_stride_x[4][1]), 
    .pool_stride_y                  (pool_stride_y[4][1]),
    .pool_ifsize_x                  (pool_ifsize_x[4][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][1]),
    .pool_ifpads_u                  (pool_ifpads_u[4][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][1]),
    .pool_ifpads_l                  (pool_ifpads_l[4][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][1]),
    .pool_ofsize_x                  (pool_ofsize_x[4][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][1]),
    .merge_in                       (merge_in[4][1]),
    .gather_in                      (gather_in[4][1]),
    .merge_out                      (merge_out[4][1]),
    .gather_out                     (gather_out[4][1]),
    .cast_out                       (cast_out[4][1])
)tile_4_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][1]),
    .cast_valid_i                   (cast_valid_n2t[4][1]),
    .cast_ready_o                   (cast_ready_t2n[4][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][1]),
    .merge_valid_i                  (merge_valid_n2t[4][1]),
    .merge_ready_o                  (merge_ready_t2n[4][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][1]),
    .gather_valid_i                 (gather_valid_n2t[4][1]),
    .gather_ready_o                 (gather_ready_t2n[4][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][1]),
    .merge_valid_o                  (merge_valid_t2n[4][1]),
    .merge_ready_i                  (merge_ready_n2t[4][1]),

    .frame_done                     (tile_done[4][1])
);


tile #(
    .x                              (4),
    .y                              (2),
    .is_mapped                      (is_mapped[4][2]),
    .conv_kernel_x                  (conv_kernel_x[4][2]), 
    .conv_kernel_y                  (conv_kernel_y[4][2]),
    .conv_stride_x                  (conv_stride_x[4][2]), 
    .conv_stride_y                  (conv_stride_y[4][2]),
    .conv_ifsize_x                  (conv_ifsize_x[4][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][2]),
    .conv_ifpads_u                  (conv_ifpads_u[4][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][2]),
    .conv_ifpads_l                  (conv_ifpads_l[4][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][2]),
    .conv_ofsize_x                  (conv_ofsize_x[4][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][2]),
    .xbar_num_ichan                 (xbar_num_ichan[4][2]),
    .xbar_num_ochan                 (xbar_num_ochan[4][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][2]),
    .has_bias                       (has_bias[4][2]),
    .has_act                        (has_act[4][2]),
    .has_pool                       (has_pool[4][2]),
    .pool_mode                      (pool_mode[4][2]),
    .pool_kernel_x                  (pool_kernel_x[4][2]), 
    .pool_kernel_y                  (pool_kernel_y[4][2]),
    .pool_stride_x                  (pool_stride_x[4][2]), 
    .pool_stride_y                  (pool_stride_y[4][2]),
    .pool_ifsize_x                  (pool_ifsize_x[4][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][2]),
    .pool_ifpads_u                  (pool_ifpads_u[4][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][2]),
    .pool_ifpads_l                  (pool_ifpads_l[4][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][2]),
    .pool_ofsize_x                  (pool_ofsize_x[4][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][2]),
    .merge_in                       (merge_in[4][2]),
    .gather_in                      (gather_in[4][2]),
    .merge_out                      (merge_out[4][2]),
    .gather_out                     (gather_out[4][2]),
    .cast_out                       (cast_out[4][2])
)tile_4_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][2]),
    .cast_valid_i                   (cast_valid_n2t[4][2]),
    .cast_ready_o                   (cast_ready_t2n[4][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][2]),
    .merge_valid_i                  (merge_valid_n2t[4][2]),
    .merge_ready_o                  (merge_ready_t2n[4][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][2]),
    .gather_valid_i                 (gather_valid_n2t[4][2]),
    .gather_ready_o                 (gather_ready_t2n[4][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][2]),
    .merge_valid_o                  (merge_valid_t2n[4][2]),
    .merge_ready_i                  (merge_ready_n2t[4][2]),

    .frame_done                     (tile_done[4][2])
);


tile #(
    .x                              (4),
    .y                              (3),
    .is_mapped                      (is_mapped[4][3]),
    .conv_kernel_x                  (conv_kernel_x[4][3]), 
    .conv_kernel_y                  (conv_kernel_y[4][3]),
    .conv_stride_x                  (conv_stride_x[4][3]), 
    .conv_stride_y                  (conv_stride_y[4][3]),
    .conv_ifsize_x                  (conv_ifsize_x[4][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][3]),
    .conv_ifpads_u                  (conv_ifpads_u[4][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][3]),
    .conv_ifpads_l                  (conv_ifpads_l[4][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][3]),
    .conv_ofsize_x                  (conv_ofsize_x[4][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][3]),
    .xbar_num_ichan                 (xbar_num_ichan[4][3]),
    .xbar_num_ochan                 (xbar_num_ochan[4][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][3]),
    .has_bias                       (has_bias[4][3]),
    .has_act                        (has_act[4][3]),
    .has_pool                       (has_pool[4][3]),
    .pool_mode                      (pool_mode[4][3]),
    .pool_kernel_x                  (pool_kernel_x[4][3]), 
    .pool_kernel_y                  (pool_kernel_y[4][3]),
    .pool_stride_x                  (pool_stride_x[4][3]), 
    .pool_stride_y                  (pool_stride_y[4][3]),
    .pool_ifsize_x                  (pool_ifsize_x[4][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][3]),
    .pool_ifpads_u                  (pool_ifpads_u[4][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][3]),
    .pool_ifpads_l                  (pool_ifpads_l[4][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][3]),
    .pool_ofsize_x                  (pool_ofsize_x[4][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][3]),
    .merge_in                       (merge_in[4][3]),
    .gather_in                      (gather_in[4][3]),
    .merge_out                      (merge_out[4][3]),
    .gather_out                     (gather_out[4][3]),
    .cast_out                       (cast_out[4][3])
)tile_4_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][3]),
    .cast_valid_i                   (cast_valid_n2t[4][3]),
    .cast_ready_o                   (cast_ready_t2n[4][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][3]),
    .merge_valid_i                  (merge_valid_n2t[4][3]),
    .merge_ready_o                  (merge_ready_t2n[4][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][3]),
    .gather_valid_i                 (gather_valid_n2t[4][3]),
    .gather_ready_o                 (gather_ready_t2n[4][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][3]),
    .merge_valid_o                  (merge_valid_t2n[4][3]),
    .merge_ready_i                  (merge_ready_n2t[4][3]),

    .frame_done                     (tile_done[4][3])
);


tile #(
    .x                              (4),
    .y                              (4),
    .is_mapped                      (is_mapped[4][4]),
    .conv_kernel_x                  (conv_kernel_x[4][4]), 
    .conv_kernel_y                  (conv_kernel_y[4][4]),
    .conv_stride_x                  (conv_stride_x[4][4]), 
    .conv_stride_y                  (conv_stride_y[4][4]),
    .conv_ifsize_x                  (conv_ifsize_x[4][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][4]),
    .conv_ifpads_u                  (conv_ifpads_u[4][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][4]),
    .conv_ifpads_l                  (conv_ifpads_l[4][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][4]),
    .conv_ofsize_x                  (conv_ofsize_x[4][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][4]),
    .xbar_num_ichan                 (xbar_num_ichan[4][4]),
    .xbar_num_ochan                 (xbar_num_ochan[4][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][4]),
    .has_bias                       (has_bias[4][4]),
    .has_act                        (has_act[4][4]),
    .has_pool                       (has_pool[4][4]),
    .pool_mode                      (pool_mode[4][4]),
    .pool_kernel_x                  (pool_kernel_x[4][4]), 
    .pool_kernel_y                  (pool_kernel_y[4][4]),
    .pool_stride_x                  (pool_stride_x[4][4]), 
    .pool_stride_y                  (pool_stride_y[4][4]),
    .pool_ifsize_x                  (pool_ifsize_x[4][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][4]),
    .pool_ifpads_u                  (pool_ifpads_u[4][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][4]),
    .pool_ifpads_l                  (pool_ifpads_l[4][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][4]),
    .pool_ofsize_x                  (pool_ofsize_x[4][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][4]),
    .merge_in                       (merge_in[4][4]),
    .gather_in                      (gather_in[4][4]),
    .merge_out                      (merge_out[4][4]),
    .gather_out                     (gather_out[4][4]),
    .cast_out                       (cast_out[4][4])
)tile_4_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][4]),
    .cast_valid_i                   (cast_valid_n2t[4][4]),
    .cast_ready_o                   (cast_ready_t2n[4][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][4]),
    .merge_valid_i                  (merge_valid_n2t[4][4]),
    .merge_ready_o                  (merge_ready_t2n[4][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][4]),
    .gather_valid_i                 (gather_valid_n2t[4][4]),
    .gather_ready_o                 (gather_ready_t2n[4][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][4]),
    .merge_valid_o                  (merge_valid_t2n[4][4]),
    .merge_ready_i                  (merge_ready_n2t[4][4]),

    .frame_done                     (tile_done[4][4])
);


tile #(
    .x                              (4),
    .y                              (5),
    .is_mapped                      (is_mapped[4][5]),
    .conv_kernel_x                  (conv_kernel_x[4][5]), 
    .conv_kernel_y                  (conv_kernel_y[4][5]),
    .conv_stride_x                  (conv_stride_x[4][5]), 
    .conv_stride_y                  (conv_stride_y[4][5]),
    .conv_ifsize_x                  (conv_ifsize_x[4][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][5]),
    .conv_ifpads_u                  (conv_ifpads_u[4][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][5]),
    .conv_ifpads_l                  (conv_ifpads_l[4][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][5]),
    .conv_ofsize_x                  (conv_ofsize_x[4][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][5]),
    .xbar_num_ichan                 (xbar_num_ichan[4][5]),
    .xbar_num_ochan                 (xbar_num_ochan[4][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][5]),
    .has_bias                       (has_bias[4][5]),
    .has_act                        (has_act[4][5]),
    .has_pool                       (has_pool[4][5]),
    .pool_mode                      (pool_mode[4][5]),
    .pool_kernel_x                  (pool_kernel_x[4][5]), 
    .pool_kernel_y                  (pool_kernel_y[4][5]),
    .pool_stride_x                  (pool_stride_x[4][5]), 
    .pool_stride_y                  (pool_stride_y[4][5]),
    .pool_ifsize_x                  (pool_ifsize_x[4][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][5]),
    .pool_ifpads_u                  (pool_ifpads_u[4][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][5]),
    .pool_ifpads_l                  (pool_ifpads_l[4][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][5]),
    .pool_ofsize_x                  (pool_ofsize_x[4][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][5]),
    .merge_in                       (merge_in[4][5]),
    .gather_in                      (gather_in[4][5]),
    .merge_out                      (merge_out[4][5]),
    .gather_out                     (gather_out[4][5]),
    .cast_out                       (cast_out[4][5])
)tile_4_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][5]),
    .cast_valid_i                   (cast_valid_n2t[4][5]),
    .cast_ready_o                   (cast_ready_t2n[4][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][5]),
    .merge_valid_i                  (merge_valid_n2t[4][5]),
    .merge_ready_o                  (merge_ready_t2n[4][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][5]),
    .gather_valid_i                 (gather_valid_n2t[4][5]),
    .gather_ready_o                 (gather_ready_t2n[4][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][5]),
    .merge_valid_o                  (merge_valid_t2n[4][5]),
    .merge_ready_i                  (merge_ready_n2t[4][5]),

    .frame_done                     (tile_done[4][5])
);


tile #(
    .x                              (4),
    .y                              (6),
    .is_mapped                      (is_mapped[4][6]),
    .conv_kernel_x                  (conv_kernel_x[4][6]), 
    .conv_kernel_y                  (conv_kernel_y[4][6]),
    .conv_stride_x                  (conv_stride_x[4][6]), 
    .conv_stride_y                  (conv_stride_y[4][6]),
    .conv_ifsize_x                  (conv_ifsize_x[4][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][6]),
    .conv_ifpads_u                  (conv_ifpads_u[4][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][6]),
    .conv_ifpads_l                  (conv_ifpads_l[4][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][6]),
    .conv_ofsize_x                  (conv_ofsize_x[4][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][6]),
    .xbar_num_ichan                 (xbar_num_ichan[4][6]),
    .xbar_num_ochan                 (xbar_num_ochan[4][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][6]),
    .has_bias                       (has_bias[4][6]),
    .has_act                        (has_act[4][6]),
    .has_pool                       (has_pool[4][6]),
    .pool_mode                      (pool_mode[4][6]),
    .pool_kernel_x                  (pool_kernel_x[4][6]), 
    .pool_kernel_y                  (pool_kernel_y[4][6]),
    .pool_stride_x                  (pool_stride_x[4][6]), 
    .pool_stride_y                  (pool_stride_y[4][6]),
    .pool_ifsize_x                  (pool_ifsize_x[4][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][6]),
    .pool_ifpads_u                  (pool_ifpads_u[4][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][6]),
    .pool_ifpads_l                  (pool_ifpads_l[4][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][6]),
    .pool_ofsize_x                  (pool_ofsize_x[4][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][6]),
    .merge_in                       (merge_in[4][6]),
    .gather_in                      (gather_in[4][6]),
    .merge_out                      (merge_out[4][6]),
    .gather_out                     (gather_out[4][6]),
    .cast_out                       (cast_out[4][6])
)tile_4_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][6]),
    .cast_valid_i                   (cast_valid_n2t[4][6]),
    .cast_ready_o                   (cast_ready_t2n[4][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][6]),
    .merge_valid_i                  (merge_valid_n2t[4][6]),
    .merge_ready_o                  (merge_ready_t2n[4][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][6]),
    .gather_valid_i                 (gather_valid_n2t[4][6]),
    .gather_ready_o                 (gather_ready_t2n[4][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][6]),
    .merge_valid_o                  (merge_valid_t2n[4][6]),
    .merge_ready_i                  (merge_ready_n2t[4][6]),

    .frame_done                     (tile_done[4][6])
);


tile #(
    .x                              (4),
    .y                              (7),
    .is_mapped                      (is_mapped[4][7]),
    .conv_kernel_x                  (conv_kernel_x[4][7]), 
    .conv_kernel_y                  (conv_kernel_y[4][7]),
    .conv_stride_x                  (conv_stride_x[4][7]), 
    .conv_stride_y                  (conv_stride_y[4][7]),
    .conv_ifsize_x                  (conv_ifsize_x[4][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[4][7]),
    .conv_ifpads_u                  (conv_ifpads_u[4][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[4][7]),
    .conv_ifpads_l                  (conv_ifpads_l[4][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[4][7]),
    .conv_ofsize_x                  (conv_ofsize_x[4][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[4][7]),
    .xbar_num_ichan                 (xbar_num_ichan[4][7]),
    .xbar_num_ochan                 (xbar_num_ochan[4][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[4][7]),
    .has_bias                       (has_bias[4][7]),
    .has_act                        (has_act[4][7]),
    .has_pool                       (has_pool[4][7]),
    .pool_mode                      (pool_mode[4][7]),
    .pool_kernel_x                  (pool_kernel_x[4][7]), 
    .pool_kernel_y                  (pool_kernel_y[4][7]),
    .pool_stride_x                  (pool_stride_x[4][7]), 
    .pool_stride_y                  (pool_stride_y[4][7]),
    .pool_ifsize_x                  (pool_ifsize_x[4][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[4][7]),
    .pool_ifpads_u                  (pool_ifpads_u[4][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[4][7]),
    .pool_ifpads_l                  (pool_ifpads_l[4][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[4][7]),
    .pool_ofsize_x                  (pool_ofsize_x[4][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[4][7]),
    .merge_in                       (merge_in[4][7]),
    .gather_in                      (gather_in[4][7]),
    .merge_out                      (merge_out[4][7]),
    .gather_out                     (gather_out[4][7]),
    .cast_out                       (cast_out[4][7])
)tile_4_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[4][7]),
    .cast_valid_i                   (cast_valid_n2t[4][7]),
    .cast_ready_o                   (cast_ready_t2n[4][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[4][7]),
    .merge_valid_i                  (merge_valid_n2t[4][7]),
    .merge_ready_o                  (merge_ready_t2n[4][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[4][7]),
    .gather_valid_i                 (gather_valid_n2t[4][7]),
    .gather_ready_o                 (gather_ready_t2n[4][7]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[4][7]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[4][7]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[4][7]),

    // merge out
    .merge_data_o                   (merge_data_t2n[4][7]),
    .merge_valid_o                  (merge_valid_t2n[4][7]),
    .merge_ready_i                  (merge_ready_n2t[4][7]),

    .frame_done                     (tile_done[4][7])
);


tile #(
    .x                              (5),
    .y                              (0),
    .is_mapped                      (is_mapped[5][0]),
    .conv_kernel_x                  (conv_kernel_x[5][0]), 
    .conv_kernel_y                  (conv_kernel_y[5][0]),
    .conv_stride_x                  (conv_stride_x[5][0]), 
    .conv_stride_y                  (conv_stride_y[5][0]),
    .conv_ifsize_x                  (conv_ifsize_x[5][0]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][0]),
    .conv_ifpads_u                  (conv_ifpads_u[5][0]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][0]),
    .conv_ifpads_l                  (conv_ifpads_l[5][0]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][0]),
    .conv_ofsize_x                  (conv_ofsize_x[5][0]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][0]),
    .xbar_num_ichan                 (xbar_num_ichan[5][0]),
    .xbar_num_ochan                 (xbar_num_ochan[5][0]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][0]),
    .has_bias                       (has_bias[5][0]),
    .has_act                        (has_act[5][0]),
    .has_pool                       (has_pool[5][0]),
    .pool_mode                      (pool_mode[5][0]),
    .pool_kernel_x                  (pool_kernel_x[5][0]), 
    .pool_kernel_y                  (pool_kernel_y[5][0]),
    .pool_stride_x                  (pool_stride_x[5][0]), 
    .pool_stride_y                  (pool_stride_y[5][0]),
    .pool_ifsize_x                  (pool_ifsize_x[5][0]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][0]),
    .pool_ifpads_u                  (pool_ifpads_u[5][0]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][0]),
    .pool_ifpads_l                  (pool_ifpads_l[5][0]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][0]),
    .pool_ofsize_x                  (pool_ofsize_x[5][0]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][0]),
    .merge_in                       (merge_in[5][0]),
    .gather_in                      (gather_in[5][0]),
    .merge_out                      (merge_out[5][0]),
    .gather_out                     (gather_out[5][0]),
    .cast_out                       (cast_out[5][0])
)tile_5_0(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][0]),
    .cast_valid_i                   (cast_valid_n2t[5][0]),
    .cast_ready_o                   (cast_ready_t2n[5][0]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][0]),
    .merge_valid_i                  (merge_valid_n2t[5][0]),
    .merge_ready_o                  (merge_ready_t2n[5][0]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][0]),
    .gather_valid_i                 (gather_valid_n2t[5][0]),
    .gather_ready_o                 (gather_ready_t2n[5][0]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][0]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][0]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][0]),
    .merge_valid_o                  (merge_valid_t2n[5][0]),
    .merge_ready_i                  (merge_ready_n2t[5][0]),

    .frame_done                     (tile_done[5][0])
);


tile #(
    .x                              (5),
    .y                              (1),
    .is_mapped                      (is_mapped[5][1]),
    .conv_kernel_x                  (conv_kernel_x[5][1]), 
    .conv_kernel_y                  (conv_kernel_y[5][1]),
    .conv_stride_x                  (conv_stride_x[5][1]), 
    .conv_stride_y                  (conv_stride_y[5][1]),
    .conv_ifsize_x                  (conv_ifsize_x[5][1]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][1]),
    .conv_ifpads_u                  (conv_ifpads_u[5][1]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][1]),
    .conv_ifpads_l                  (conv_ifpads_l[5][1]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][1]),
    .conv_ofsize_x                  (conv_ofsize_x[5][1]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][1]),
    .xbar_num_ichan                 (xbar_num_ichan[5][1]),
    .xbar_num_ochan                 (xbar_num_ochan[5][1]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][1]),
    .has_bias                       (has_bias[5][1]),
    .has_act                        (has_act[5][1]),
    .has_pool                       (has_pool[5][1]),
    .pool_mode                      (pool_mode[5][1]),
    .pool_kernel_x                  (pool_kernel_x[5][1]), 
    .pool_kernel_y                  (pool_kernel_y[5][1]),
    .pool_stride_x                  (pool_stride_x[5][1]), 
    .pool_stride_y                  (pool_stride_y[5][1]),
    .pool_ifsize_x                  (pool_ifsize_x[5][1]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][1]),
    .pool_ifpads_u                  (pool_ifpads_u[5][1]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][1]),
    .pool_ifpads_l                  (pool_ifpads_l[5][1]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][1]),
    .pool_ofsize_x                  (pool_ofsize_x[5][1]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][1]),
    .merge_in                       (merge_in[5][1]),
    .gather_in                      (gather_in[5][1]),
    .merge_out                      (merge_out[5][1]),
    .gather_out                     (gather_out[5][1]),
    .cast_out                       (cast_out[5][1])
)tile_5_1(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][1]),
    .cast_valid_i                   (cast_valid_n2t[5][1]),
    .cast_ready_o                   (cast_ready_t2n[5][1]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][1]),
    .merge_valid_i                  (merge_valid_n2t[5][1]),
    .merge_ready_o                  (merge_ready_t2n[5][1]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][1]),
    .gather_valid_i                 (gather_valid_n2t[5][1]),
    .gather_ready_o                 (gather_ready_t2n[5][1]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][1]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][1]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][1]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][1]),
    .merge_valid_o                  (merge_valid_t2n[5][1]),
    .merge_ready_i                  (merge_ready_n2t[5][1]),

    .frame_done                     (tile_done[5][1])
);


tile #(
    .x                              (5),
    .y                              (2),
    .is_mapped                      (is_mapped[5][2]),
    .conv_kernel_x                  (conv_kernel_x[5][2]), 
    .conv_kernel_y                  (conv_kernel_y[5][2]),
    .conv_stride_x                  (conv_stride_x[5][2]), 
    .conv_stride_y                  (conv_stride_y[5][2]),
    .conv_ifsize_x                  (conv_ifsize_x[5][2]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][2]),
    .conv_ifpads_u                  (conv_ifpads_u[5][2]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][2]),
    .conv_ifpads_l                  (conv_ifpads_l[5][2]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][2]),
    .conv_ofsize_x                  (conv_ofsize_x[5][2]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][2]),
    .xbar_num_ichan                 (xbar_num_ichan[5][2]),
    .xbar_num_ochan                 (xbar_num_ochan[5][2]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][2]),
    .has_bias                       (has_bias[5][2]),
    .has_act                        (has_act[5][2]),
    .has_pool                       (has_pool[5][2]),
    .pool_mode                      (pool_mode[5][2]),
    .pool_kernel_x                  (pool_kernel_x[5][2]), 
    .pool_kernel_y                  (pool_kernel_y[5][2]),
    .pool_stride_x                  (pool_stride_x[5][2]), 
    .pool_stride_y                  (pool_stride_y[5][2]),
    .pool_ifsize_x                  (pool_ifsize_x[5][2]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][2]),
    .pool_ifpads_u                  (pool_ifpads_u[5][2]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][2]),
    .pool_ifpads_l                  (pool_ifpads_l[5][2]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][2]),
    .pool_ofsize_x                  (pool_ofsize_x[5][2]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][2]),
    .merge_in                       (merge_in[5][2]),
    .gather_in                      (gather_in[5][2]),
    .merge_out                      (merge_out[5][2]),
    .gather_out                     (gather_out[5][2]),
    .cast_out                       (cast_out[5][2])
)tile_5_2(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][2]),
    .cast_valid_i                   (cast_valid_n2t[5][2]),
    .cast_ready_o                   (cast_ready_t2n[5][2]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][2]),
    .merge_valid_i                  (merge_valid_n2t[5][2]),
    .merge_ready_o                  (merge_ready_t2n[5][2]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][2]),
    .gather_valid_i                 (gather_valid_n2t[5][2]),
    .gather_ready_o                 (gather_ready_t2n[5][2]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][2]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][2]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][2]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][2]),
    .merge_valid_o                  (merge_valid_t2n[5][2]),
    .merge_ready_i                  (merge_ready_n2t[5][2]),

    .frame_done                     (tile_done[5][2])
);


tile #(
    .x                              (5),
    .y                              (3),
    .is_mapped                      (is_mapped[5][3]),
    .conv_kernel_x                  (conv_kernel_x[5][3]), 
    .conv_kernel_y                  (conv_kernel_y[5][3]),
    .conv_stride_x                  (conv_stride_x[5][3]), 
    .conv_stride_y                  (conv_stride_y[5][3]),
    .conv_ifsize_x                  (conv_ifsize_x[5][3]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][3]),
    .conv_ifpads_u                  (conv_ifpads_u[5][3]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][3]),
    .conv_ifpads_l                  (conv_ifpads_l[5][3]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][3]),
    .conv_ofsize_x                  (conv_ofsize_x[5][3]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][3]),
    .xbar_num_ichan                 (xbar_num_ichan[5][3]),
    .xbar_num_ochan                 (xbar_num_ochan[5][3]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][3]),
    .has_bias                       (has_bias[5][3]),
    .has_act                        (has_act[5][3]),
    .has_pool                       (has_pool[5][3]),
    .pool_mode                      (pool_mode[5][3]),
    .pool_kernel_x                  (pool_kernel_x[5][3]), 
    .pool_kernel_y                  (pool_kernel_y[5][3]),
    .pool_stride_x                  (pool_stride_x[5][3]), 
    .pool_stride_y                  (pool_stride_y[5][3]),
    .pool_ifsize_x                  (pool_ifsize_x[5][3]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][3]),
    .pool_ifpads_u                  (pool_ifpads_u[5][3]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][3]),
    .pool_ifpads_l                  (pool_ifpads_l[5][3]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][3]),
    .pool_ofsize_x                  (pool_ofsize_x[5][3]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][3]),
    .merge_in                       (merge_in[5][3]),
    .gather_in                      (gather_in[5][3]),
    .merge_out                      (merge_out[5][3]),
    .gather_out                     (gather_out[5][3]),
    .cast_out                       (cast_out[5][3])
)tile_5_3(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][3]),
    .cast_valid_i                   (cast_valid_n2t[5][3]),
    .cast_ready_o                   (cast_ready_t2n[5][3]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][3]),
    .merge_valid_i                  (merge_valid_n2t[5][3]),
    .merge_ready_o                  (merge_ready_t2n[5][3]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][3]),
    .gather_valid_i                 (gather_valid_n2t[5][3]),
    .gather_ready_o                 (gather_ready_t2n[5][3]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][3]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][3]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][3]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][3]),
    .merge_valid_o                  (merge_valid_t2n[5][3]),
    .merge_ready_i                  (merge_ready_n2t[5][3]),

    .frame_done                     (tile_done[5][3])
);


tile #(
    .x                              (5),
    .y                              (4),
    .is_mapped                      (is_mapped[5][4]),
    .conv_kernel_x                  (conv_kernel_x[5][4]), 
    .conv_kernel_y                  (conv_kernel_y[5][4]),
    .conv_stride_x                  (conv_stride_x[5][4]), 
    .conv_stride_y                  (conv_stride_y[5][4]),
    .conv_ifsize_x                  (conv_ifsize_x[5][4]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][4]),
    .conv_ifpads_u                  (conv_ifpads_u[5][4]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][4]),
    .conv_ifpads_l                  (conv_ifpads_l[5][4]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][4]),
    .conv_ofsize_x                  (conv_ofsize_x[5][4]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][4]),
    .xbar_num_ichan                 (xbar_num_ichan[5][4]),
    .xbar_num_ochan                 (xbar_num_ochan[5][4]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][4]),
    .has_bias                       (has_bias[5][4]),
    .has_act                        (has_act[5][4]),
    .has_pool                       (has_pool[5][4]),
    .pool_mode                      (pool_mode[5][4]),
    .pool_kernel_x                  (pool_kernel_x[5][4]), 
    .pool_kernel_y                  (pool_kernel_y[5][4]),
    .pool_stride_x                  (pool_stride_x[5][4]), 
    .pool_stride_y                  (pool_stride_y[5][4]),
    .pool_ifsize_x                  (pool_ifsize_x[5][4]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][4]),
    .pool_ifpads_u                  (pool_ifpads_u[5][4]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][4]),
    .pool_ifpads_l                  (pool_ifpads_l[5][4]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][4]),
    .pool_ofsize_x                  (pool_ofsize_x[5][4]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][4]),
    .merge_in                       (merge_in[5][4]),
    .gather_in                      (gather_in[5][4]),
    .merge_out                      (merge_out[5][4]),
    .gather_out                     (gather_out[5][4]),
    .cast_out                       (cast_out[5][4])
)tile_5_4(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][4]),
    .cast_valid_i                   (cast_valid_n2t[5][4]),
    .cast_ready_o                   (cast_ready_t2n[5][4]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][4]),
    .merge_valid_i                  (merge_valid_n2t[5][4]),
    .merge_ready_o                  (merge_ready_t2n[5][4]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][4]),
    .gather_valid_i                 (gather_valid_n2t[5][4]),
    .gather_ready_o                 (gather_ready_t2n[5][4]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][4]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][4]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][4]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][4]),
    .merge_valid_o                  (merge_valid_t2n[5][4]),
    .merge_ready_i                  (merge_ready_n2t[5][4]),

    .frame_done                     (tile_done[5][4])
);


tile #(
    .x                              (5),
    .y                              (5),
    .is_mapped                      (is_mapped[5][5]),
    .conv_kernel_x                  (conv_kernel_x[5][5]), 
    .conv_kernel_y                  (conv_kernel_y[5][5]),
    .conv_stride_x                  (conv_stride_x[5][5]), 
    .conv_stride_y                  (conv_stride_y[5][5]),
    .conv_ifsize_x                  (conv_ifsize_x[5][5]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][5]),
    .conv_ifpads_u                  (conv_ifpads_u[5][5]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][5]),
    .conv_ifpads_l                  (conv_ifpads_l[5][5]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][5]),
    .conv_ofsize_x                  (conv_ofsize_x[5][5]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][5]),
    .xbar_num_ichan                 (xbar_num_ichan[5][5]),
    .xbar_num_ochan                 (xbar_num_ochan[5][5]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][5]),
    .has_bias                       (has_bias[5][5]),
    .has_act                        (has_act[5][5]),
    .has_pool                       (has_pool[5][5]),
    .pool_mode                      (pool_mode[5][5]),
    .pool_kernel_x                  (pool_kernel_x[5][5]), 
    .pool_kernel_y                  (pool_kernel_y[5][5]),
    .pool_stride_x                  (pool_stride_x[5][5]), 
    .pool_stride_y                  (pool_stride_y[5][5]),
    .pool_ifsize_x                  (pool_ifsize_x[5][5]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][5]),
    .pool_ifpads_u                  (pool_ifpads_u[5][5]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][5]),
    .pool_ifpads_l                  (pool_ifpads_l[5][5]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][5]),
    .pool_ofsize_x                  (pool_ofsize_x[5][5]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][5]),
    .merge_in                       (merge_in[5][5]),
    .gather_in                      (gather_in[5][5]),
    .merge_out                      (merge_out[5][5]),
    .gather_out                     (gather_out[5][5]),
    .cast_out                       (cast_out[5][5])
)tile_5_5(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][5]),
    .cast_valid_i                   (cast_valid_n2t[5][5]),
    .cast_ready_o                   (cast_ready_t2n[5][5]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][5]),
    .merge_valid_i                  (merge_valid_n2t[5][5]),
    .merge_ready_o                  (merge_ready_t2n[5][5]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][5]),
    .gather_valid_i                 (gather_valid_n2t[5][5]),
    .gather_ready_o                 (gather_ready_t2n[5][5]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][5]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][5]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][5]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][5]),
    .merge_valid_o                  (merge_valid_t2n[5][5]),
    .merge_ready_i                  (merge_ready_n2t[5][5]),

    .frame_done                     (tile_done[5][5])
);


tile #(
    .x                              (5),
    .y                              (6),
    .is_mapped                      (is_mapped[5][6]),
    .conv_kernel_x                  (conv_kernel_x[5][6]), 
    .conv_kernel_y                  (conv_kernel_y[5][6]),
    .conv_stride_x                  (conv_stride_x[5][6]), 
    .conv_stride_y                  (conv_stride_y[5][6]),
    .conv_ifsize_x                  (conv_ifsize_x[5][6]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][6]),
    .conv_ifpads_u                  (conv_ifpads_u[5][6]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][6]),
    .conv_ifpads_l                  (conv_ifpads_l[5][6]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][6]),
    .conv_ofsize_x                  (conv_ofsize_x[5][6]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][6]),
    .xbar_num_ichan                 (xbar_num_ichan[5][6]),
    .xbar_num_ochan                 (xbar_num_ochan[5][6]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][6]),
    .has_bias                       (has_bias[5][6]),
    .has_act                        (has_act[5][6]),
    .has_pool                       (has_pool[5][6]),
    .pool_mode                      (pool_mode[5][6]),
    .pool_kernel_x                  (pool_kernel_x[5][6]), 
    .pool_kernel_y                  (pool_kernel_y[5][6]),
    .pool_stride_x                  (pool_stride_x[5][6]), 
    .pool_stride_y                  (pool_stride_y[5][6]),
    .pool_ifsize_x                  (pool_ifsize_x[5][6]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][6]),
    .pool_ifpads_u                  (pool_ifpads_u[5][6]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][6]),
    .pool_ifpads_l                  (pool_ifpads_l[5][6]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][6]),
    .pool_ofsize_x                  (pool_ofsize_x[5][6]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][6]),
    .merge_in                       (merge_in[5][6]),
    .gather_in                      (gather_in[5][6]),
    .merge_out                      (merge_out[5][6]),
    .gather_out                     (gather_out[5][6]),
    .cast_out                       (cast_out[5][6])
)tile_5_6(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][6]),
    .cast_valid_i                   (cast_valid_n2t[5][6]),
    .cast_ready_o                   (cast_ready_t2n[5][6]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][6]),
    .merge_valid_i                  (merge_valid_n2t[5][6]),
    .merge_ready_o                  (merge_ready_t2n[5][6]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][6]),
    .gather_valid_i                 (gather_valid_n2t[5][6]),
    .gather_ready_o                 (gather_ready_t2n[5][6]),

    // cast gather out
    .cast_gather_data_o             (cast_gather_data_t2n[5][6]),
    .cast_gather_valid_o            (cast_gather_valid_t2n[5][6]),   
    .cast_gather_ready_i            (cast_gather_ready_n2t[5][6]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][6]),
    .merge_valid_o                  (merge_valid_t2n[5][6]),
    .merge_ready_i                  (merge_ready_n2t[5][6]),

    .frame_done                     (tile_done[5][6])
);


assign cast_gather_data_t2n[5][7] = 0;
assign cast_gather_valid_t2n[5][7] = 0;

tile #(
    .x                              (5),
    .y                              (7),
    .is_mapped                      (is_mapped[5][7]),
    .conv_kernel_x                  (conv_kernel_x[5][7]), 
    .conv_kernel_y                  (conv_kernel_y[5][7]),
    .conv_stride_x                  (conv_stride_x[5][7]), 
    .conv_stride_y                  (conv_stride_y[5][7]),
    .conv_ifsize_x                  (conv_ifsize_x[5][7]), 
    .conv_ifsize_y                  (conv_ifsize_y[5][7]),
    .conv_ifpads_u                  (conv_ifpads_u[5][7]), 
    .conv_ifpads_d                  (conv_ifpads_d[5][7]),
    .conv_ifpads_l                  (conv_ifpads_l[5][7]), 
    .conv_ifpads_r                  (conv_ifpads_r[5][7]),
    .conv_ofsize_x                  (conv_ofsize_x[5][7]), 
    .conv_ofsize_y                  (conv_ofsize_y[5][7]),
    .xbar_num_ichan                 (xbar_num_ichan[5][7]),
    .xbar_num_ochan                 (xbar_num_ochan[5][7]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[5][7]),
    .has_bias                       (has_bias[5][7]),
    .has_act                        (has_act[5][7]),
    .has_pool                       (has_pool[5][7]),
    .pool_mode                      (pool_mode[5][7]),
    .pool_kernel_x                  (pool_kernel_x[5][7]), 
    .pool_kernel_y                  (pool_kernel_y[5][7]),
    .pool_stride_x                  (pool_stride_x[5][7]), 
    .pool_stride_y                  (pool_stride_y[5][7]),
    .pool_ifsize_x                  (pool_ifsize_x[5][7]), 
    .pool_ifsize_y                  (pool_ifsize_y[5][7]),
    .pool_ifpads_u                  (pool_ifpads_u[5][7]), 
    .pool_ifpads_d                  (pool_ifpads_d[5][7]),
    .pool_ifpads_l                  (pool_ifpads_l[5][7]), 
    .pool_ifpads_r                  (pool_ifpads_r[5][7]),
    .pool_ofsize_x                  (pool_ofsize_x[5][7]), 
    .pool_ofsize_y                  (pool_ofsize_y[5][7]),
    .merge_in                       (merge_in[5][7]),
    .gather_in                      (gather_in[5][7]),
    .merge_out                      (merge_out[5][7]),
    .gather_out                     (gather_out[5][7]),
    .cast_out                       (cast_out[5][7])
)tile_5_7(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    (cast_data_n2t[5][7]),
    .cast_valid_i                   (cast_valid_n2t[5][7]),
    .cast_ready_o                   (cast_ready_t2n[5][7]),

    // merge in
    .merge_data_i                   (merge_data_n2t[5][7]),
    .merge_valid_i                  (merge_valid_n2t[5][7]),
    .merge_ready_o                  (merge_ready_t2n[5][7]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[5][7]),
    .gather_valid_i                 (gather_valid_n2t[5][7]),
    .gather_ready_o                 (gather_ready_t2n[5][7]),

    // cast gather out
    .cast_gather_data_o             (data_o_eject[0]),
    .cast_gather_valid_o            (valid_o_eject[0]),   
    .cast_gather_ready_i            (ready_i_eject[0]),

    // merge out
    .merge_data_o                   (merge_data_t2n[5][7]),
    .merge_valid_o                  (merge_valid_t2n[5][7]),
    .merge_ready_i                  (merge_ready_n2t[5][7]),

    .frame_done                     (tile_done[5][7])
);


endmodule
