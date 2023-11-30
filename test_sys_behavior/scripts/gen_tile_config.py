'''
Generating configuration information of all tiles (routing nodes)
'''

import os
from typing import Union, Mapping
from maptools import TileConfig, PhysicalTile

__all__ = ['gen_tile_config']

CONFIG_VAR_NAMES = [
    'is_mapped',
    'conv_kernel_x',
    'conv_kernel_y',
    'conv_stride_x',
    'conv_stride_y',
    'conv_ifsize_x',
    'conv_ifsize_y',
    'conv_ifpads_u',
    'conv_ifpads_d',
    'conv_ifpads_l',
    'conv_ifpads_r',
    'conv_ofsize_x',
    'conv_ofsize_y',
    'xbar_num_ichan',
    'xbar_num_ochan',
    'xbar_adc_trans_delay',
    'has_bias',
    'has_act',
    'has_pool',
    'pool_mode',
    'pool_kernel_x',
    'pool_kernel_y',
    'pool_stride_x',
    'pool_stride_y',
    'pool_ifsize_x',
    'pool_ifsize_y',
    'pool_ifpads_u',
    'pool_ifpads_d',
    'pool_ifpads_l',
    'pool_ifpads_r',
    'pool_ofsize_x',
    'pool_ofsize_y',
    'merge_in',
    'gather_in',
    'merge_out',
    'gather_out',
    'cast_out',
    'cast_in_vc',
    'gather_in_vc',
    'cast_out_vc',
    'gather_out_vc'
]

def get_config_info(name: str, config: TileConfig, xatd: int) -> str:
    if name == 'is_mapped':
        return str(1)
    if name == 'conv_kernel_x':
        return str(config['conv_kernel_size'][1])
    elif name == 'conv_kernel_y':
        return str(config['conv_kernel_size'][0])
    elif name == 'conv_stride_x':
        return str(config['conv_strides'][1])
    elif name == 'conv_stride_y':
        return str(config['conv_strides'][0])
    elif name == 'conv_ifsize_x':
        return str(config['conv_input_size'][1])
    elif name == 'conv_ifsize_y':
        return str(config['conv_input_size'][0])
    elif name == 'conv_ifpads_u':
        return str(config['conv_pads'][0])
    elif name == 'conv_ifpads_d':
        return str(config['conv_pads'][2])
    elif name == 'conv_ifpads_l':
        return str(config['conv_pads'][3])
    elif name == 'conv_ifpads_r':
        return str(config['conv_pads'][1])
    elif name == 'conv_ofsize_x':
        return str(config['conv_output_size'][1])
    elif name == 'conv_ofsize_y':
        return str(config['conv_output_size'][0])
    elif name == 'xbar_num_ichan':
        return str(config['xbar_num_ichan'])
    elif name == 'xbar_num_ochan':
        return str(config['xbar_num_ochan'])
    elif name == 'has_bias':
        return str(int('Bias' in config['op_type']))
    elif name == 'has_act':
        return str(int('Act' in config['op_type']))
    elif name in {'merge_in', 'gather_in', 'merge_out', 
        'gather_out', 'cast_out', 'cast_in_vc', 
        'cast_out_vc', 'gather_in_vc', 'gather_out_vc'}:
        return str(int(config[name]))
    elif name == 'xbar_adc_trans_delay':
        return str(xatd)
    else: # for pooling
        has_pool = 'Pool' in config['op_type']
        if name == 'has_pool':
            return str(int(has_pool))
        elif name == 'pool_mode':
            if not has_pool:
                return '"max"'
            else:
                mode = config['pool_mode']
                if mode == 'MaxPool':
                    return '"max"'
                elif mode == 'AvgPool':
                    return '"avg"'
                else:
                    raise KeyError(f"unrecognized pool_mode: {mode}")
        if name == 'pool_kernel_x':
            return str(config['pool_kernel_size'][1]) if has_pool else str(0)
        elif name == 'pool_kernel_y':
            return str(config['pool_kernel_size'][0]) if has_pool else str(0)
        elif name == 'pool_stride_x':
            return str(config['pool_strides'][1]) if has_pool else str(0)
        elif name == 'pool_stride_y':
            return str(config['pool_strides'][0]) if has_pool else str(0)
        elif name == 'pool_ifsize_x':
            return str(config['pool_input_size'][1]) if has_pool else str(0)
        elif name == 'pool_ifsize_y':
            return str(config['pool_input_size'][0]) if has_pool else str(0)
        elif name == 'pool_ifpads_u':
            return str(config['pool_pads'][0]) if has_pool else str(0)
        elif name == 'pool_ifpads_d':
            return str(config['pool_pads'][2]) if has_pool else str(0)
        elif name == 'pool_ifpads_l':
            return str(config['pool_pads'][3]) if has_pool else str(0)
        elif name == 'pool_ifpads_r':
            return str(config['pool_pads'][1]) if has_pool else str(0)
        elif name == 'pool_ofsize_x':
            return str(config['pool_output_size'][1]) if has_pool else str(0)
        elif name == 'pool_ofsize_y':
            return str(config['pool_output_size'][0]) if has_pool else str(0)
        else:
            raise KeyError(f"unrecognized config var name: {name}")


def get_config_sv_type(name: str) -> str:
    if name in {'pool_mode'}:
        return 'string'
    elif name in {'is_mapped', 'has_bias', 'has_act', 
        'has_pool', 'merge_in', 'gather_in', 
        'merge_out', 'gather_out', 'cast_out'}:
        return 'bit'
    else:
        return 'int'
    

def gen_sv_config_array(
    tile_config: Mapping[PhysicalTile, TileConfig],
    nw: int, nh: str, name: str, xatd: int
) -> str:
    total_lst = []
    for i in range(nw):
        line_lst = []
        for j in range(nh):
            if (i, j) in tile_config.keys(): # mapped tiles
                config = tile_config[(i, j)]
                element = get_config_info(name, config, xatd)
                assert isinstance(element, str), f"not a string: {element}"
                line_lst.append(element)
            else: # umapped tiles
                line_lst.append(str(0))
        line_str = "\n'{{{}}}".format(", ".join(line_lst))
        total_lst.append(line_str)
    total_str = "\nlocalparam {} {} [`NW] [`NH] = '{{{}}};\n".format(
        get_config_sv_type(name), name, ", ".join(total_lst))
    return total_str


def gen_tile_config(root_dir, w, h, tile_config, xatd):
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'tile_config.svh')
    containt = '''
`ifndef __TILE_CONFIG_SVH_
`define __TILE_CONFIG_SVH_
`include "params.svh"\n
'''
    for name in CONFIG_VAR_NAMES:
        containt += gen_sv_config_array(tile_config, w, h, name, xatd)

    containt += '''
`endif
'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"tile configuration info has been written to: {file_dir}")