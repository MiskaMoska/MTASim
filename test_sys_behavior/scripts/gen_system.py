import os
from typing import Tuple, List, Optional
from maptools.core import PhysicalTile

__all__ = ['gen_system']

def gen_ports():
    port_str = '''
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
);\n
'''
    return port_str

def gen_tile_insatnces(w, h, tile_module_name, head_tile, tail_tiles):
    tile_str = ''
    for x in range(w):
        for y in range(h):
            cast_data_i = f'cast_data_n2t[{x}][{y}]'
            cast_valid_i = f'cast_valid_n2t[{x}][{y}]'
            cast_ready_o = f'cast_ready_t2n[{x}][{y}]'
            cast_gather_data_o = f'cast_gather_data_t2n[{x}][{y}]'
            cast_gather_valid_o = f'cast_gather_valid_t2n[{x}][{y}]'
            cast_gather_ready_i = f'cast_gather_ready_n2t[{x}][{y}]'

            if (x, y) == head_tile: # is head tile
                cast_data_i = 'data_i_inject'
                cast_valid_i = 'valid_i_inject'
                cast_ready_o = 'ready_o_inject'

                tile_str += f'''
assign cast_ready_t2n[{x}][{y}] = 0;
'''

            for i, tail_tile in enumerate(tail_tiles):
                if (x, y) == tail_tile: # is tail tile
                    cast_gather_data_o = f'data_o_eject[{i}]'
                    cast_gather_valid_o = f'valid_o_eject[{i}]'
                    cast_gather_ready_i = f'ready_i_eject[{i}]'

                    tile_str += f'''
assign cast_gather_data_t2n[{x}][{y}] = 0;
assign cast_gather_valid_t2n[{x}][{y}] = 0;
'''

            tile_str += f'''
{tile_module_name} #(
    .x                              ({x}),
    .y                              ({y}),
    .is_mapped                      (is_mapped[{x}][{y}]),
    .conv_kernel_x                  (conv_kernel_x[{x}][{y}]), 
    .conv_kernel_y                  (conv_kernel_y[{x}][{y}]),
    .conv_stride_x                  (conv_stride_x[{x}][{y}]), 
    .conv_stride_y                  (conv_stride_y[{x}][{y}]),
    .conv_ifsize_x                  (conv_ifsize_x[{x}][{y}]), 
    .conv_ifsize_y                  (conv_ifsize_y[{x}][{y}]),
    .conv_ifpads_u                  (conv_ifpads_u[{x}][{y}]), 
    .conv_ifpads_d                  (conv_ifpads_d[{x}][{y}]),
    .conv_ifpads_l                  (conv_ifpads_l[{x}][{y}]), 
    .conv_ifpads_r                  (conv_ifpads_r[{x}][{y}]),
    .conv_ofsize_x                  (conv_ofsize_x[{x}][{y}]), 
    .conv_ofsize_y                  (conv_ofsize_y[{x}][{y}]),
    .xbar_num_ichan                 (xbar_num_ichan[{x}][{y}]),
    .xbar_num_ochan                 (xbar_num_ochan[{x}][{y}]),
    .xbar_adc_trans_delay           (xbar_adc_trans_delay[{x}][{y}]),
    .has_bias                       (has_bias[{x}][{y}]),
    .has_act                        (has_act[{x}][{y}]),
    .has_pool                       (has_pool[{x}][{y}]),
    .pool_mode                      (pool_mode[{x}][{y}]),
    .pool_kernel_x                  (pool_kernel_x[{x}][{y}]), 
    .pool_kernel_y                  (pool_kernel_y[{x}][{y}]),
    .pool_stride_x                  (pool_stride_x[{x}][{y}]), 
    .pool_stride_y                  (pool_stride_y[{x}][{y}]),
    .pool_ifsize_x                  (pool_ifsize_x[{x}][{y}]), 
    .pool_ifsize_y                  (pool_ifsize_y[{x}][{y}]),
    .pool_ifpads_u                  (pool_ifpads_u[{x}][{y}]), 
    .pool_ifpads_d                  (pool_ifpads_d[{x}][{y}]),
    .pool_ifpads_l                  (pool_ifpads_l[{x}][{y}]), 
    .pool_ifpads_r                  (pool_ifpads_r[{x}][{y}]),
    .pool_ofsize_x                  (pool_ofsize_x[{x}][{y}]), 
    .pool_ofsize_y                  (pool_ofsize_y[{x}][{y}]),
    .merge_in                       (merge_in[{x}][{y}]),
    .gather_in                      (gather_in[{x}][{y}]),
    .merge_out                      (merge_out[{x}][{y}]),
    .gather_out                     (gather_out[{x}][{y}]),
    .cast_out                       (cast_out[{x}][{y}])
)tile_{x}_{y}(
    .clk_nw                         (clk_nw),
    .clk_bw                         (clk_bw),
    .clk_br                         (clk_br),
    .clk_pc                         (clk_pc),
    .rstn_nw                        (rstn_nw), 
    .rstn_bw                        (rstn_bw), 
    .rstn_br                        (rstn_br), 
    .rstn_pc                        (rstn_pc), 

    // cast in
    .cast_data_i                    ({cast_data_i}),
    .cast_valid_i                   ({cast_valid_i}),
    .cast_ready_o                   ({cast_ready_o}),

    // merge in
    .merge_data_i                   (merge_data_n2t[{x}][{y}]),
    .merge_valid_i                  (merge_valid_n2t[{x}][{y}]),
    .merge_ready_o                  (merge_ready_t2n[{x}][{y}]),

    // gather in 
    .gather_data_i                  (gather_data_n2t[{x}][{y}]),
    .gather_valid_i                 (gather_valid_n2t[{x}][{y}]),
    .gather_ready_o                 (gather_ready_t2n[{x}][{y}]),

    // cast gather out
    .cast_gather_data_o             ({cast_gather_data_o}),
    .cast_gather_valid_o            ({cast_gather_valid_o}),   
    .cast_gather_ready_i            ({cast_gather_ready_i}),

    // merge out
    .merge_data_o                   (merge_data_t2n[{x}][{y}]),
    .merge_valid_o                  (merge_valid_t2n[{x}][{y}]),
    .merge_ready_i                  (merge_ready_n2t[{x}][{y}]),

    .frame_done                     (tile_done[{x}][{y}])
);\n
'''
    return tile_str


def gen_system(root_dir, w, h, tile_module_name, head_tile, tail_tiles):
    save_dir = os.path.join(root_dir, 'rtl', 'generated')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'system.sv')
    containt = ""
    containt += gen_ports()
    containt += gen_tile_insatnces(w, h, tile_module_name, head_tile, tail_tiles)
    containt += "\nendmodule"

    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()

    print(f"system has been written to: {file_dir}")