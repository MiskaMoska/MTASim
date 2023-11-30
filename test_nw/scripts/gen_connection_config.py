'''
Generating the connection configuration information such as the cast_in/out indicators 
and VC numbers for each tile.
'''

import os

__all__ = ['gen_connection_config']

def get_param(w, h, key, config):
    c0 = "'{\n"
    for x in range(w):
        c1 = "'{"
        for y in range(h):
            tile = (x, y)
            if tile in config: # mapped tile
                cfg = config[tile]
                res = int(cfg[key])
            else:
                res = 0
            c1 += f'{res}, '
        c1 = c1.rstrip(', ')
        c1 += '}'
        c0 += c1+',\n'
    c0 = c0.rstrip(',\n')
    c0 += '}'
    return c0

def gen_connection_config(root_dir, w, h, config):
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'connection_config.svh')
    containt = '''
`ifndef __CONNECTION_CONFIG_SVH_
`define __CONNECTION_CONFIG_SVH_
`include "params.svh"\n
'''
    for key in {
        'cast_out', 'merge_out', 'gather_out', 
        'merge_in', 'gather_in', 'cast_in_vc', 
        'cast_out_vc', 'gather_in_vc', 'gather_out_vc'
    }:
        containt += f"localparam int {key} [`NW] [`NH] = {get_param(w, h, key, config)};\n"

    containt += '''
`endif
'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"connection configuration info has been written to: {file_dir}")