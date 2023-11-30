import os
from typing import Tuple, List, Optional
from maptools.core import PhysicalTile

__all__ = ['gen_system']

def gen_ports():
    port_str = '''
`include "params.svh"
`include "connection_config.svh"

module system(
    input       wire                            clk,
    input       wire                            rstn,

    // inject ports
    input       wire        [`DW-1:0]           data_i_inject,
    input       wire                            valid_i_inject,
    output      wire                            ready_o_inject,

    // eject ports
    output      wire        [`DW-1:0]           data_o_eject [`EPN],
    output      wire                            valid_o_eject [`EPN],
    input       wire                            ready_i_eject [`EPN]
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

network network(
    .clk                                        (clk),
    .rstn                                       (rstn),

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
    .cast_out                       (cast_out[{x}][{y}]),
    .merge_in                       (merge_in[{x}][{y}]),
    .merge_out                      (merge_out[{x}][{y}]),
    .gather_in                      (gather_in[{x}][{y}]),
    .gather_out                     (gather_out[{x}][{y}]),
    .x                              ({x}),
    .y                              ({y})
)tile_{x}_{y}(
    .clk                            (clk),
    .rstn                           (rstn), 

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
    .merge_ready_i                  (merge_ready_n2t[{x}][{y}])
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